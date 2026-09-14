resource "kubernetes_cluster_role_v1" "cluster_workstation_owner" {
  metadata {
    name = "custom:workstation-owner:cluster"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "namespaces/status"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_v1" "namespace_workstation_owner" {
  metadata {
    name = "custom:workstation-owner:namespace"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/status"]
    verbs      = ["get", "list", "watch", "delete", "deletecollection"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/portforward", "pods/exec"]
    verbs      = ["get", "create"]
  }
}
