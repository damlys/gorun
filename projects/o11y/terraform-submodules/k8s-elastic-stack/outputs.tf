output "elasticsearch_entrypoint" { value = "http://${data.kubernetes_service.elasticsearch.metadata[0].name}.${data.kubernetes_service.elasticsearch.metadata[0].namespace}.svc.cluster.local:9200" }
