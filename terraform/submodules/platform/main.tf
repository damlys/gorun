#######################################
### Virtual Private Cloud network
#######################################

resource "google_compute_network" "this" {
  name = var.name

  routing_mode = "GLOBAL"

  # do not create default resources
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "this" {
  network = google_compute_network.this.name
  name    = var.name
  region  = local.gcp_region

  purpose                  = "PRIVATE"
  private_ip_google_access = true
  ip_cidr_range            = var.vpc_ip_cidr_range
  stack_type               = "IPV4_ONLY"
}

resource "google_compute_router" "this" {
  network = google_compute_network.this.name
  name    = var.name
  region  = google_compute_subnetwork.this.region
}

resource "google_compute_address" "router_nat" {
  name   = "${var.name}-router-nat"
  region = local.gcp_region

  address_type = "EXTERNAL"
}

resource "google_compute_router_nat" "this" {
  router = google_compute_router.this.name
  name   = var.name
  region = google_compute_router.this.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.router_nat.self_link]

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_route" "egress_internet" {
  network = google_compute_network.this.name
  name    = "egress-internet"

  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_global_address" "servicenetworking" {
  network       = google_compute_network.this.id
  name          = "servicenetworking"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  prefix_length = 24
}

resource "google_service_networking_connection" "servicenetworking" {
  network = google_compute_network.this.id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.servicenetworking.name,
  ]
}

#######################################
### Key Management Service key ring
#######################################

resource "google_kms_key_ring" "this" {
  name     = var.name
  location = local.gcp_region
}

#######################################
### Google Kubernetes Engine cluster
#######################################

resource "google_kms_crypto_key" "gke_secrets" {
  key_ring = google_kms_key_ring.this.id
  name     = "gke-secrets"
  purpose  = "ENCRYPT_DECRYPT"
}
resource "google_kms_crypto_key_iam_member" "gke_secrets" {
  crypto_key_id = google_kms_crypto_key.gke_secrets.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${var.google_project.number}@container-engine-robot.iam.gserviceaccount.com"
}

module "gmp_collector_service_account" {
  source = "../../submodules/gsa-workload"

  google_project = var.google_project

  kubernetes_service_account = {
    metadata = [{
      namespace = "gmp-system"
      name      = "collector"
    }]
  }
}
resource "google_project_iam_member" "gmp_collector_metric_writer" {
  project = module.gmp_collector_service_account.google_service_account.project
  role    = "roles/monitoring.metricWriter"
  member  = module.gmp_collector_service_account.member
}

resource "google_container_cluster" "this" {
  depends_on = [
    google_compute_router_nat.this,
    google_compute_route.egress_internet,
    google_kms_crypto_key_iam_member.gke_secrets,
    google_project_iam_member.gmp_collector_metric_writer,
  ]

  name     = var.name
  location = local.gke_location

  min_master_version = var.gke_version
  release_channel {
    channel = var.gke_version == null ? "STABLE" : "UNSPECIFIED"
  }
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  workload_identity_config {
    workload_pool = "${var.google_project.project_id}.svc.id.goog"
  }
  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.gke_secrets.id
  }

  network    = google_compute_network.this.name
  subnetwork = google_compute_subnetwork.this.name
  addons_config {
    network_policy_config {
      disabled = false
    }
  }
  network_policy {
    enabled = "true"
  }
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.gke_master_ipv4_cidr_block
  }
  master_authorized_networks_config {
    cidr_blocks {
      display_name = "All IPv4"
      cidr_block   = "0.0.0.0/0"
    }
    # cidr_blocks {
    #   display_name = "All IPv6"
    #   cidr_block   = "::/0"
    # }
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.gke_cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.gke_services_ipv4_cidr_block
  }

  # logging_service = "logging.googleapis.com/kubernetes"
  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
    ]
  }
  # monitoring_service = "monitoring.googleapis.com/kubernetes"
  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
    ]
    managed_prometheus {
      enabled = true
    }
  }

  # do not create default resources
  initial_node_count       = 1
  remove_default_node_pool = true
}

resource "google_service_account" "gke_node" {
  account_id = "gke-node-${var.name}"
}
resource "google_project_iam_member" "gke_node_log_writer" {
  project = google_service_account.gke_node.project
  role    = "roles/logging.logWriter"
  member  = google_service_account.gke_node.member
}
resource "google_project_iam_member" "gke_node_metric_writer" {
  project = google_service_account.gke_node.project
  role    = "roles/monitoring.metricWriter"
  member  = google_service_account.gke_node.member
}

resource "google_container_node_pool" "this" {
  name    = var.name
  cluster = google_container_cluster.this.id

  version = var.gke_version
  management {
    auto_upgrade = var.gke_version == null ? true : false
    auto_repair  = true
  }

  node_config {
    metadata = {
      disable-legacy-endpoints = "true"
    }

    spot         = var.gke_spot
    machine_type = var.gke_machine_type
    disk_size_gb = var.gke_disk_size_gb

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    service_account = google_service_account.gke_node.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    shielded_instance_config {
      enable_secure_boot = true
    }
  }

  node_count = var.gke_min_node_count
  autoscaling {
    min_node_count = var.gke_min_node_count
    max_node_count = var.gke_max_node_count

    location_policy = var.gke_spot ? "ANY" : "BALANCED"
  }

  lifecycle {
    ignore_changes = [
      node_count,
    ]
  }
}
