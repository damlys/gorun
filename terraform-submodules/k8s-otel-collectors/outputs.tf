output "grpc_entrypoint" {
  value = local.grpc_entrypoint
}

output "http_entrypoint" {
  value = local.http_entrypoint
}

output "annotations" {
  value = {
    "instrumentation.opentelemetry.io/inject-dotnet" = "${kubernetes_manifest.otlp_instrumentation.manifest.metadata.namespace}/${kubernetes_manifest.otlp_instrumentation.manifest.metadata.name}"
    "instrumentation.opentelemetry.io/inject-go"     = "${kubernetes_manifest.otlp_instrumentation.manifest.metadata.namespace}/${kubernetes_manifest.otlp_instrumentation.manifest.metadata.name}"
    "instrumentation.opentelemetry.io/inject-java"   = "${kubernetes_manifest.otlp_instrumentation.manifest.metadata.namespace}/${kubernetes_manifest.otlp_instrumentation.manifest.metadata.name}"
    "instrumentation.opentelemetry.io/inject-nodejs" = "${kubernetes_manifest.otlp_instrumentation.manifest.metadata.namespace}/${kubernetes_manifest.otlp_instrumentation.manifest.metadata.name}"
    "instrumentation.opentelemetry.io/inject-python" = "${kubernetes_manifest.otlp_instrumentation.manifest.metadata.namespace}/${kubernetes_manifest.otlp_instrumentation.manifest.metadata.name}"

    "instrumentation.opentelemetry.io/otel-go-auto-target-exe" = "/path/to/container/executable"
  }
}
