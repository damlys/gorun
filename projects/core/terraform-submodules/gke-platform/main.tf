#######################################
### VPC network
#######################################

resource "google_compute_network" "this" { # console.cloud.google.com/networking/networks/list
  project = var.google_project.project_id
  name    = var.platform_name

  routing_mode = "GLOBAL"

  # do not create default resources
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "this" {
  project = var.google_project.project_id
  network = google_compute_network.this.name
  name    = var.platform_name
  region  = var.platform_region

  ip_cidr_range = local.vpc_subnet_cidr

  private_ip_google_access = true
}

#######################################
### VPC egress
#######################################

resource "google_compute_address" "egress_internet" { # console.cloud.google.com/networking/addresses/list
  project = var.google_project.project_id
  name    = "${var.platform_name}-egress-internet"
  region  = var.platform_region

  address_type = "EXTERNAL"
  network_tier = "STANDARD"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_router" "egress_internet" { # console.cloud.google.com/hybrid/routers/list
  project = var.google_project.project_id
  network = google_compute_network.this.name
  name    = "${var.platform_name}-egress-internet"
  region  = google_compute_subnetwork.this.region
}

resource "google_compute_router_nat" "egress_internet" { # console.cloud.google.com/net-services/nat/list
  project = var.google_project.project_id
  router  = google_compute_router.egress_internet.name
  name    = "${var.platform_name}-egress-internet"
  region  = google_compute_router.egress_internet.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.egress_internet.self_link]

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_route" "egress_internet" { # console.cloud.google.com/networking/routes/list
  project = var.google_project.project_id
  network = google_compute_network.this.name
  name    = "${var.platform_name}-egress-internet"

  dest_range       = "0.0.0.0/0"
  priority         = 1000
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_firewall" "egress_internet" { # console.cloud.google.com/net-security/firewall-manager/firewall-policies/list
  project = var.google_project.project_id
  network = google_compute_network.this.name
  name    = "${var.platform_name}-egress-internet"

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  priority           = 1000

  allow {
    protocol = "all"
  }
}

#######################################
### KMS crypto
#######################################

resource "google_kms_key_ring" "this" { # console.cloud.google.com/security/kms/keyrings
  project  = var.google_project.project_id
  name     = var.platform_name
  location = var.platform_region
}

#######################################
### GKE cluster
#######################################

resource "google_kms_crypto_key" "gke_secrets" { # console.cloud.google.com/security/kms/keys
  key_ring = google_kms_key_ring.this.id
  name     = "gke-secrets"
  purpose  = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_member" "gke_secrets" {
  crypto_key_id = google_kms_crypto_key.gke_secrets.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${var.google_project.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_container_cluster" "this" { # console.cloud.google.com/kubernetes/list/overview
  depends_on = [
    google_compute_router_nat.egress_internet,
    google_compute_route.egress_internet,
    google_compute_firewall.egress_internet,
    google_kms_crypto_key_iam_member.gke_secrets,
  ]

  project  = var.google_project.project_id
  name     = var.platform_name
  location = var.cluster_location

  release_channel {
    channel = var.cluster_version == null ? "STABLE" : "UNSPECIFIED"
  }
  min_master_version = var.cluster_version
  maintenance_policy {
    daily_maintenance_window {
      start_time = "04:00" # UTC
    }
  }

  network    = google_compute_network.this.name
  subnetwork = google_compute_subnetwork.this.name
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = local.gke_master_cidr
    master_global_access_config {
      enabled = false
    }
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = local.gke_pod_cidr
    services_ipv4_cidr_block = local.gke_svc_cidr
  }

  # master_authorized_networks_config {
  #   cidr_blocks {
  #     display_name = "All IPv4"
  #     cidr_block   = "0.0.0.0/0"
  #   }
  #   cidr_blocks {
  #     display_name = "All IPv6"
  #     cidr_block   = "::/0"
  #   }
  # }
  workload_identity_config {
    workload_pool = "${var.google_project.project_id}.svc.id.goog"
  }
  # authenticator_groups_config {
  #   security_group = "gke-security-groups@${data.google_organization.this.domain}"
  # }

  enable_shielded_nodes = true
  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.gke_secrets.id
  }

  # enable Dataplane V2 (Cilium CNI)
  datapath_provider = "ADVANCED_DATAPATH"
  # enable CiliumClusterWideNetworkPolicy resource
  enable_cilium_clusterwide_network_policy = true

  # logging_service = "none"
  logging_config {
    enable_components = []
  }
  # monitoring_service = "none"
  monitoring_config {
    enable_components = []
    managed_prometheus { enabled = false }
    advanced_datapath_observability_config {
      enable_metrics = true # Dataplane V2 Metrics
      enable_relay   = true # Dataplane V2 Observability (Hubble Relay)
    }
  }

  addons_config {
    gce_persistent_disk_csi_driver_config { enabled = true } # Google Compute Engine persistent disk driver
    gcp_filestore_csi_driver_config { enabled = false }      # Filestore driver
    gcs_fuse_csi_driver_config { enabled = false }           # Google Cloud Storage driver
    horizontal_pod_autoscaling { disabled = false }
    http_load_balancing { disabled = false }
  }
  vertical_pod_autoscaling { enabled = true }
  gateway_api_config { channel = "CHANNEL_STANDARD" }

  lifecycle {
    # do not track node updates
    ignore_changes = [
      node_config,
      node_pool,
      node_version,
    ]

    prevent_destroy = true
  }
  deletion_protection = true

  # do not create default node pool
  initial_node_count       = 1
  remove_default_node_pool = true
}

resource "kubernetes_namespace" "gke_security_groups" {
  depends_on = [
    google_container_cluster.this,
    google_container_node_pool.this,
  ]

  metadata {
    name = "gke-security-groups"
  }
}

resource "google_service_account" "gke_node" { # console.cloud.google.com/iam-admin/serviceaccounts
  project    = var.google_project.project_id
  account_id = "${var.platform_name}-gke-node"
}

resource "google_project_iam_member" "gke_node" {
  project = var.google_project.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = google_service_account.gke_node.member
}

resource "google_container_node_pool" "this" {
  depends_on = [
    google_project_iam_member.gke_node,
  ]
  for_each = var.node_pools

  project        = var.google_project.project_id
  cluster        = google_container_cluster.this.id
  name           = each.key
  node_locations = var.node_locations

  version = var.cluster_version
  management {
    auto_upgrade = var.cluster_version == null
    auto_repair  = true
  }

  node_count = each.value.node_min_instances
  autoscaling {
    total_min_node_count = each.value.node_min_instances
    total_max_node_count = each.value.node_max_instances
    location_policy      = each.value.node_spot_instances ? "ANY" : "BALANCED"
  }

  node_config {
    machine_type = each.value.node_machine_type
    spot         = each.value.node_spot_instances
    disk_type    = "pd-standard"
    disk_size_gb = 100

    shielded_instance_config {
      enable_secure_boot = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    service_account = google_service_account.gke_node.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    # https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#built-in-node-labels
    labels = each.value.node_labels

    # https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
    dynamic "taint" {
      for_each = each.value.node_taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
  }

  lifecycle {
    ignore_changes = [
      node_count,
      node_config[0].resource_labels,
    ]
  }
}

#######################################
### Cilium & Hubble
#######################################

data "kubernetes_namespace" "gke_dataplane_v2_observability" {
  depends_on = [
    google_container_cluster.this,
    google_container_node_pool.this,
  ]

  metadata {
    name = "gke-managed-dpv2-observability" # Dataplane V2 Observability
  }
}

resource "helm_release" "hubble_ui" {
  repository = "${path.module}/helm/charts"
  chart      = "cilium"
  name       = "hubble-ui"
  namespace  = data.kubernetes_namespace.gke_dataplane_v2_observability.metadata[0].name

  values = [
    file("${path.module}/helm/values/cilium.yaml"),
    templatefile("${path.module}/assets/hubble_ui.yaml.tftpl", {
    }),
  ]
}

#######################################
### Prometheus Operator (CRDs only)
#######################################

resource "kubernetes_namespace" "prometheus_operator" {
  depends_on = [
    google_container_cluster.this,
    google_container_node_pool.this,
  ]

  metadata {
    name = "prometheus-operator"
  }
}

resource "helm_release" "prometheus_operator_crds" {
  repository = "${path.module}/helm/charts"
  chart      = "prometheus-operator-crds"
  name       = "prometheus-operator-crds"
  namespace  = kubernetes_namespace.prometheus_operator.metadata[0].name
}

#######################################
### Velero
#######################################

resource "google_kms_crypto_key" "velero_backups" {
  key_ring = google_kms_key_ring.this.id
  name     = "velero-backups"
  purpose  = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_member" "velero_backups" {
  crypto_key_id = google_kms_crypto_key.velero_backups.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = data.google_storage_project_service_account.this.member
}

resource "kubernetes_namespace" "velero" {
  depends_on = [
    google_container_cluster.this,
    google_container_node_pool.this,
  ]

  metadata {
    name = "velero"
  }
}

module "velero_service_account" {
  source = "../gke-service-account" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-service-account/0.3.100.zip"

  google_project           = var.google_project
  google_container_cluster = google_container_cluster.this
  kubernetes_namespace     = kubernetes_namespace.velero
  service_account_name     = "velero"
}

resource "google_kms_crypto_key_iam_member" "velero_service_account" {
  crypto_key_id = google_kms_crypto_key.velero_backups.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = module.velero_service_account.google_service_account.member
}

resource "google_storage_bucket" "velero_backups" {
  depends_on = [
    google_kms_crypto_key_iam_member.velero_backups,
  ]

  project       = var.google_project.project_id
  name          = "velero-backups-${local.velero_hash}"
  labels        = local.velero_labels
  location      = var.platform_region
  storage_class = "REGIONAL"

  encryption {
    default_kms_key_name = google_kms_crypto_key.velero_backups.id
  }
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle {
    prevent_destroy = true
  }
  force_destroy = false
}

resource "google_storage_bucket_iam_member" "velero_service_account" {
  bucket = google_storage_bucket.velero_backups.name
  role   = "roles/storage.objectAdmin"
  member = module.velero_service_account.google_service_account.member
}

resource "google_project_iam_custom_role" "velero_server" {
  project = var.google_project.project_id
  role_id = "velero.server"
  title   = "Velero Server"
  permissions = [ # https://github.com/vmware-tanzu/velero-plugin-for-gcp?tab=readme-ov-file#create-custom-role-with-permissions-for-the-velero-gsa
    "compute.disks.get",
    "compute.disks.create",
    "compute.disks.createSnapshot",
    "compute.projects.get",
    "compute.snapshots.get",
    "compute.snapshots.create",
    "compute.snapshots.useReadOnly",
    "compute.snapshots.delete",
    "compute.zones.get",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.list",
    "iam.serviceAccounts.signBlob",
  ]
}

resource "google_project_iam_member" "velero_service_account" {
  project = var.google_project.project_id
  role    = google_project_iam_custom_role.velero_server.id
  member  = module.velero_service_account.google_service_account.member
}

resource "helm_release" "velero" {
  depends_on = [
    helm_release.prometheus_operator_crds,
    google_kms_crypto_key_iam_member.velero_backups,
    google_kms_crypto_key_iam_member.velero_service_account,
    google_storage_bucket_iam_member.velero_service_account,
    google_project_iam_member.velero_service_account,
  ]

  repository = "${path.module}/helm/charts"
  chart      = "velero"
  name       = "velero"
  namespace  = kubernetes_namespace.velero.metadata[0].name

  values = [
    file("${path.module}/helm/values/velero.yaml"),
    templatefile("${path.module}/assets/velero.yaml.tftpl", {
      project_id      = var.google_project.project_id
      platform_region = var.platform_region

      velero_service_account_email = module.velero_service_account.google_service_account.email
      velero_service_account_name  = module.velero_service_account.kubernetes_service_account.metadata[0].name
      velero_backups_bucket_name   = google_storage_bucket.velero_backups.name
      velero_backups_kms_key_name  = google_kms_crypto_key.velero_backups.id

      kubectl_image_tag = var.kubectl_image_tag == null ? "" : var.kubectl_image_tag
    }),
  ]
}

#######################################
### cert-manager
#######################################

resource "kubernetes_namespace" "cert_manager" {
  depends_on = [
    google_container_cluster.this,
    google_container_node_pool.this,
  ]

  metadata {
    name = "cert-manager"
  }
}

module "cert_manager_service_account" {
  source = "../gke-service-account" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-service-account/0.3.100.zip"

  google_project           = var.google_project
  google_container_cluster = google_container_cluster.this
  kubernetes_namespace     = kubernetes_namespace.cert_manager
  service_account_name     = "cert-manager"
}

resource "helm_release" "cert_manager" {
  depends_on = [
    helm_release.prometheus_operator_crds,
  ]

  repository = "${path.module}/helm/charts"
  chart      = "cert-manager"
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name

  values = [
    file("${path.module}/helm/values/cert-manager.yaml"),
    templatefile("${path.module}/assets/cert_manager.yaml.tftpl", {
      cert_manager_service_account_name = module.cert_manager_service_account.kubernetes_service_account.metadata[0].name
    }),
  ]
}

#######################################
### VPC ingress
#######################################

resource "google_compute_subnetwork" "ingress_internet" {
  project = var.google_project.project_id
  network = google_compute_network.this.name
  name    = "${var.platform_name}-ingress-internet"
  region  = var.platform_region

  ip_cidr_range = local.vpc_proxy_cidr
  purpose       = "REGIONAL_MANAGED_PROXY" # a proxy-only subnet for regional GKE Gateway (https://cloud.google.com/kubernetes-engine/docs/how-to/deploying-gateways#configure_a_proxy-only_subnet)
  role          = "ACTIVE"
}

resource "google_compute_address" "ingress_internet" { # console.cloud.google.com/networking/addresses/list
  project = var.google_project.project_id
  name    = "${var.platform_name}-ingress-internet"
  region  = var.platform_region

  address_type = "EXTERNAL"
  network_tier = "STANDARD"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_managed_zone" "ingress_internet" { # console.cloud.google.com/net-services/dns/zones
  project  = var.google_project.project_id
  name     = "${var.platform_name}-ingress-internet"
  dns_name = "${var.platform_domain}."

  visibility = "public"

  dnssec_config {
    state = var.platform_dnssec_enabled ? "on" : "off"
  }

  # override default description
  description = "-"
}

data "google_dns_keys" "ingress_internet" {
  project      = var.google_project.project_id
  managed_zone = google_dns_managed_zone.ingress_internet.id
}

resource "google_dns_managed_zone_iam_member" "cert_manager_dns_admin" {
  project      = var.google_project.project_id
  managed_zone = google_dns_managed_zone.ingress_internet.name
  role         = "roles/dns.admin"
  member       = module.cert_manager_service_account.google_service_account.member
}

resource "google_dns_record_set" "ingress_internet" {
  project      = var.google_project.project_id
  managed_zone = google_dns_managed_zone.ingress_internet.name

  for_each = toset([google_dns_managed_zone.ingress_internet.dns_name, "*.${google_dns_managed_zone.ingress_internet.dns_name}"])
  name     = each.value
  type     = "A"
  ttl      = 3600
  rrdatas  = [google_compute_address.ingress_internet.address]
}

resource "kubernetes_namespace" "gke_gateway" {
  depends_on = [
    google_container_cluster.this,
    google_container_node_pool.this,
  ]

  metadata {
    name = "gke-gateway"
  }
}

resource "kubernetes_manifest" "letsencrypt_production" {
  depends_on = [
    helm_release.cert_manager,
  ]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer" # https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.Issuer
    metadata = {
      name      = "letsencrypt-production"
      namespace = kubernetes_namespace.gke_gateway.metadata[0].name
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "damlys.test@gmail.com"
        privateKeySecretRef = {
          name = "letsencrypt-production-issuer-account-key"
        }
        solvers = [{
          dns01 = {
            cloudDNS = { # https://cert-manager.io/docs/configuration/acme/dns01/google/
              project        = var.google_project.project_id
              hostedZoneName = google_dns_managed_zone.ingress_internet.name
            }
          }
        }]
      }
    }
  }
}

resource "kubernetes_manifest" "letsencrypt_staging" {
  depends_on = [
    helm_release.cert_manager,
  ]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "letsencrypt-staging"
      namespace = kubernetes_namespace.gke_gateway.metadata[0].name
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = "damlys.test@gmail.com"
        privateKeySecretRef = {
          name = "letsencrypt-staging-issuer-account-key"
        }
        solvers = kubernetes_manifest.letsencrypt_production.manifest.spec.acme.solvers
      }
    }
  }
}

resource "kubernetes_manifest" "gke_gateway" { # console.cloud.google.com/net-services/loadbalancing/list/loadBalancers
  depends_on = [
    google_compute_subnetwork.ingress_internet,
  ]

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "gke-gateway"
      namespace = kubernetes_namespace.gke_gateway.metadata[0].name
      annotations = {
        "cert-manager.io/issuer" = kubernetes_manifest.letsencrypt_production.manifest.metadata.name
      }
    }
    spec = {
      gatewayClassName = "gke-l7-regional-external-managed" # regional external Application Load Balancer
      listeners = [
        {
          name     = "http"
          port     = 80
          protocol = "HTTP"
          allowedRoutes = {
            kinds      = [{ kind = "HTTPRoute" }]
            namespaces = { from = "Same" }
          }
        },
        {
          name     = "https-root"
          hostname = var.platform_domain
          port     = 443
          protocol = "HTTPS"
          tls = {
            mode = "Terminate"
            certificateRefs = [{
              group = ""
              kind  = "Secret"
              name  = "tls-${join("-", reverse(split(".", var.platform_domain)))}"
            }]
          }
          allowedRoutes = {
            kinds      = [{ kind = "HTTPRoute" }]
            namespaces = { from = "All" }
          }
        },
        {
          name     = "https-wildcard"
          hostname = "*.${var.platform_domain}"
          port     = 443
          protocol = "HTTPS"
          tls = {
            mode = "Terminate"
            certificateRefs = [{
              group = ""
              kind  = "Secret"
              name  = "tls-${join("-", reverse(split(".", var.platform_domain)))}"
            }]
          }
          allowedRoutes = {
            kinds      = [{ kind = "HTTPRoute" }]
            namespaces = { from = "All" }
          }
        },
      ]
      addresses = [{
        type  = "NamedAddress"
        value = google_compute_address.ingress_internet.name
      }]
    }
  }
}

resource "kubernetes_manifest" "gke_gateway_redirect_http" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "redirect-http"
      namespace = kubernetes_namespace.gke_gateway.metadata[0].name
    }
    spec = {
      parentRefs = [{
        group       = "gateway.networking.k8s.io"
        kind        = "Gateway"
        name        = kubernetes_manifest.gke_gateway.manifest.metadata.name
        namespace   = kubernetes_manifest.gke_gateway.manifest.metadata.namespace
        sectionName = "http"
      }]
      rules = [{
        filters = [{
          type = "RequestRedirect"
          requestRedirect = {
            scheme = "https"
          }
        }]
      }]
    }
  }
}

#######################################
### IAM
#######################################

resource "google_project_iam_member" "cluster_viewers" {
  for_each = var.iam_cluster_viewers

  project = var.google_project.project_id
  role    = "roles/container.clusterViewer"
  member  = each.value
}
