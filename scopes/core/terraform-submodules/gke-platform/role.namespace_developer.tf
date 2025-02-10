resource "kubernetes_cluster_role" "namespace_developer" {
  metadata {
    name = "custom:namespace-developer"
  }
  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/status"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
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
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "deployments/status", "deployments/scale", "replicasets", "replicasets/status", "replicasets/scale", "statefulsets", "statefulsets/status", "statefulsets/scale"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets", "daemonsets/status"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "jobs/status", "cronjobs", "cronjobs/status"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
  rule {
    api_groups = ["autoscaling", "autoscaling.k8s.io"]
    resources  = ["horizontalpodautoscalers", "horizontalpodautoscalers/status", "verticalpodautoscalers", "verticalpodautoscalers/status"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets", "poddisruptionbudgets/status"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims", "persistentvolumeclaims/status"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
  rule {
    api_groups = [""]
    resources  = ["endpoints", "services", "services/status"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
  rule {
    api_groups = ["net.gke.io"]
    resources  = ["serviceexports", "serviceimports"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.k8s.io", "gateway.networking.k8s.io", "cloud.google.com"]
    resources  = ["ingresses", "ingresses/status", "frontendconfigs", "backendconfigs", "lbpolicies", "lbpolicies/status", "gateways", "gateways/status", "httproutes", "httproutes/status", "healthcheckpolicies", "healthcheckpolicies/status", "gcpgatewaypolicies", "gcpgatewaypolicies/status", "gcpbackendpolicies", "gcpbackendpolicies/status"]
    verbs      = ["get", "list", "watch"]
  }
}
