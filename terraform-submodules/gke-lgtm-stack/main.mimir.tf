resource "kubernetes_namespace" "mimir" {
  metadata {
    name = "lgtm-mimir"
  }
}

module "mimir_service_account" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gke-service-account/0.0.1.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = kubernetes_namespace.mimir
  service_account_name     = "mimir"
}

resource "google_storage_bucket" "mimir" {
  project       = var.google_project.project_id
  name          = "mimir-${local.mimir_hash}"
  location      = var.platform_region
  storage_class = "REGIONAL"
  force_destroy = true

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "google_storage_bucket_iam_member" "mimir_service_account" {
  for_each = toset([
    "roles/storage.legacyBucketReader",
    "roles/storage.legacyObjectReader",
    "roles/storage.objectUser",
  ])

  bucket = google_storage_bucket.mimir.name
  role   = each.value
  member = module.mimir_service_account.google_service_account.member
}

resource "helm_release" "mimir" {
  chart     = data.helm_template.mimir.chart
  name      = data.helm_template.mimir.name
  namespace = data.helm_template.mimir.namespace
  values    = data.helm_template.mimir.values

  timeout = 900
}
data "helm_template" "mimir" {
  chart = "${path.module}/charts/mimir-distributed"

  name      = "mimir"
  namespace = kubernetes_namespace.mimir.metadata[0].name

  values = [
    templatefile("${path.module}/assets/mimir/values.yaml.tftpl", {
      mimir_service_account_name = module.mimir_service_account.kubernetes_service_account.metadata[0].name
      mimir_bucket_name          = google_storage_bucket.mimir.name
    }),
    file("${path.module}/assets/mimir/scale.yaml"),
  ]
}
