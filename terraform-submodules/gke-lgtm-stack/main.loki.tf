resource "kubernetes_namespace" "loki" {
  metadata {
    name = "lgtm-loki"
  }
}

module "loki_service_account" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gke-service-account/0.0.1.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = kubernetes_namespace.loki
  service_account_name     = "loki"
}

resource "google_storage_bucket" "loki" {
  project       = var.google_project.project_id
  name          = "loki-${local.loki_hash}"
  labels        = local.loki_labels
  location      = var.platform_region
  storage_class = "REGIONAL"
  force_destroy = true

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "google_storage_bucket_iam_member" "loki_service_account" {
  for_each = toset([
    "roles/storage.legacyBucketReader",
    "roles/storage.legacyObjectReader",
    "roles/storage.objectUser",
  ])

  bucket = google_storage_bucket.loki.name
  role   = each.value
  member = module.loki_service_account.google_service_account.member
}

resource "helm_release" "loki" {
  repository = data.helm_template.loki.repository
  chart      = data.helm_template.loki.chart
  version    = data.helm_template.loki.version

  name      = data.helm_template.loki.name
  namespace = data.helm_template.loki.namespace
  values    = data.helm_template.loki.values

  timeout = 600
}
data "helm_template" "loki" {
  repository = null
  chart      = "../../third_party/helm/charts/loki" # TODO
  version    = null

  name      = "loki"
  namespace = kubernetes_namespace.loki.metadata[0].name

  values = [
    file("${path.module}/assets/loki/scale.yaml"),
    templatefile("${path.module}/assets/loki/values.yaml.tftpl", {
      loki_service_account_name = module.loki_service_account.kubernetes_service_account.metadata[0].name
      loki_bucket_name          = google_storage_bucket.loki.name
    }),
  ]
}
