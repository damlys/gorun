#######################################
### Google Cloud Platform project
#######################################

data "google_billing_account" "damlys_dev" {
  display_name = "Damian Łysiak Dev"
  open         = true
}

resource "google_project" "this" {
  name            = "gorun-prod"
  project_id      = "gorun-prod-0"
  billing_account = data.google_billing_account.damlys_dev.id
}

resource "google_project_iam_member" "owners" {
  for_each = toset([
    "user:damian.lysiak@gmail.com",
  ])

  project = google_project.this.project_id
  role    = "roles/owner"
  member  = each.value
}

resource "google_project_iam_member" "editors" {
  for_each = toset([])

  project = google_project.this.project_id
  role    = "roles/editor"
  member  = each.value
}

resource "google_project_iam_member" "viewers" {
  for_each = toset([])

  project = google_project.this.project_id
  role    = "roles/viewer"
  member  = each.value
}

#######################################
### Google Cloud Platform services
#######################################

resource "google_project_service" "cloudkms" {
  project = google_project.this.project_id
  service = "cloudkms.googleapis.com"
}

resource "google_project_service" "container" {
  project = google_project.this.project_id
  service = "container.googleapis.com"
}

#######################################
### Virtual Private Cloud network
#######################################

data "google_compute_network" "default" {
  project = google_project.this.project_id
  name    = "default"
}

data "google_compute_subnetwork" "default" {
  project = google_project.this.project_id
  name    = "default"
  region  = local.gcp_region
}

#######################################
### Google Kubernetes Engine cluster
#######################################

resource "google_kms_key_ring" "primary_cluster_database" {
  depends_on = [
    google_project_service.cloudkms,
  ]
  project  = google_project.this.project_id
  name     = "primary-cluster-database"
  location = local.gcp_region
}

resource "google_kms_crypto_key" "primary_cluster_database" {
  key_ring = google_kms_key_ring.primary_cluster_database.id
  name     = "primary-cluster-database"
  purpose  = "ENCRYPT_DECRYPT"
}

resource "google_kms_crypto_key_iam_member" "primary_cluster_database" {
  crypto_key_id = google_kms_crypto_key.primary_cluster_database.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${google_project.this.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_container_cluster" "primary" {
  depends_on = [
    google_project_service.container,
    google_kms_crypto_key_iam_member.primary_cluster_database,
  ]
  initial_node_count       = 1
  remove_default_node_pool = true

  project  = google_project.this.project_id
  name     = "primary-cluster"
  location = local.gke_location

  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.primary_cluster_database.id
  }

  release_channel {
    channel = "STABLE"
  }
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }
  logging_service    = "none"
  monitoring_service = "none"

  workload_identity_config {
    workload_pool = "${google_project.this.project_id}.svc.id.goog"
  }

  network    = data.google_compute_network.default.name
  subnetwork = data.google_compute_subnetwork.default.name
}

resource "google_service_account" "primary_cluster_node" {
  project    = google_project.this.project_id
  account_id = "primary-cluster-node"
}

resource "google_container_node_pool" "primary" {
  project = google_project.this.project_id
  name    = "primary-node-pool"
  cluster = google_container_cluster.primary.id

  node_config {
    machine_type = "e2-standard-2"
    spot         = true
    disk_size_gb = 100

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    service_account = google_service_account.primary_cluster_node.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_count = 1
  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  lifecycle {
    ignore_changes = [
      node_count,
    ]
  }
}

resource "google_project_iam_member" "container_admins" {
  for_each = toset([
    "user:damian.lysiak@gmail.com",
  ])

  project = google_project.this.project_id
  role    = "roles/container.admin"
  member  = each.value
}

resource "google_project_iam_member" "container_developers" {
  for_each = toset([])

  project = google_project.this.project_id
  role    = "roles/container.developer"
  member  = each.value
}

resource "google_project_iam_member" "container_viewers" {
  for_each = toset([])

  project = google_project.this.project_id
  role    = "roles/container.viewer"
  member  = each.value
}

#######################################
### KUARD
#######################################

resource "kubernetes_namespace" "kuard" {
  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary,
  ]
  metadata {
    name = "kuard"
  }
}

module "kuard_sa" {
  source = "../modules/gke-service-account"

  name      = "gke-kuard"
  project   = google_project.this.project_id
  namespace = kubernetes_namespace.kuard.metadata[0].name
}

module "kuard" {
  source = "../modules/k8s-kuard"

  name            = "kuard"
  namespace       = kubernetes_namespace.kuard.metadata[0].name
  service_account = module.kuard_sa.ksa_name
  host            = "kuard.gorun-prod.damlys.dev"
}
