{{- define "otelcol.collector.config" -}}
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

  filelog: # https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/receiver/filelogreceiver/README.md
    include_file_name: false
    include_file_path: true
    include:
      - /var/log/pods/*/*/*.log
    exclude: # format is /var/log/pods/<namespace_name>_<pod_name>_<pod_uid>/<container_name>/<run_id>.log
      # Kubernetes namespaces
      - /var/log/pods/kube-*_*_*/*/*.log
      - /var/log/pods/gke-*_*_*/*/*.log
      # Observability namespaces
      - /var/log/pods/o11y-*_*_*/*/*.log
      # OpenTelemetry auto-instrumentation
      - /var/log/pods/*_*_*/opentelemetry-auto-instrumentation/*.log
      - /var/log/pods/*_*_*/opentelemetry-auto-instrumentation-*/*.log
    operators:
      - id: container-parser
        type: container # https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/pkg/stanza/docs/operators/container.md
        max_log_size: 102400 # bytes, it's 100 KiB
    retry_on_failure:
      enabled: true

  k8s_cluster: # https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/k8sclusterreceiver
    auth_type: serviceAccount
    allocatable_types_to_report:
      - cpu
      - memory
      - ephemeral-storage
      - pods

  k8sobjects: # https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/k8sobjectsreceiver
    auth_type: serviceAccount
    objects:
      - name: events
        mode: watch

  kubeletstats: # https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/kubeletstatsreceiver
    auth_type: serviceAccount
    k8s_api_config:
      auth_type: serviceAccount
    node: "${env:K8S_NODE_NAME}"
    endpoint: "https://${env:K8S_NODE_NAME}:10250"
    insecure_skip_verify: true
    metric_groups:
      - node
      - pod
      - container
      - volume
    metrics: # https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/receiver/kubeletstatsreceiver/metadata.yaml
      k8s.node.uptime:
        enabled: true
      k8s.pod.uptime:
        enabled: true
      container.uptime:
        enabled: true
      k8s.pod.cpu_request_utilization:
        enabled: true
      k8s.pod.cpu_limit_utilization:
        enabled: true
      k8s.pod.memory_request_utilization:
        enabled: true
      k8s.pod.memory_limit_utilization:
        enabled: true
      k8s.container.cpu_request_utilization:
        enabled: true
      k8s.container.cpu_limit_utilization:
        enabled: true
      k8s.container.memory_request_utilization:
        enabled: true
      k8s.container.memory_limit_utilization:
        enabled: true
      k8s.volume.capacity:
        enabled: true
      k8s.pod.volume.usage:
        enabled: true
      k8s.volume.available:
        enabled: true

  prometheus: # https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/receiver/prometheusreceiver/README.md
    config:
      scrape_configs:
        - job_name: opentelemetry-collector
          scrape_interval: 1m
          static_configs:
            - targets:
                - 0.0.0.0:8888

processors:
  memory_limiter: # https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/memorylimiterprocessor/README.md
    check_interval: 1s
    limit_percentage: 80
    spike_limit_percentage: 20

  resourcedetection: # https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/resourcedetectionprocessor
    detectors: [env, gcp]
    timeout: 2s
    override: false

  k8sattributes: # https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/k8sattributesprocessor/README.md
    auth_type: serviceAccount
    {{- if eq .Values.collector.mode "daemonset" }}
    filter:
      node_from_env_var: K8S_NODE_NAME
    {{- end }}
    passthrough: false
    pod_association:
      - sources:
          - from: resource_attribute
            name: k8s.pod.uid
      - sources:
          - from: resource_attribute
            name: k8s.pod.ip
      - sources:
          - from: connection
    extract:
      metadata:
        - k8s.node.name
        - k8s.namespace.name
        - k8s.pod.name
        - k8s.pod.uid
        - k8s.deployment.name
        - k8s.replicaset.name
        - k8s.statefulset.name
        - k8s.daemonset.name
        - k8s.cronjob.name
        - k8s.job.name
      labels:
        - from: pod
          key_regex: (.*)
          tag_name: $$1

  filter: # https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/filterprocessor/README.md
    error_mode: ignore
    traces:
      span:
        - 'URL(attributes["http.url"])["url.path"] == "/healthy"'
        - 'URL(attributes["http.url"])["url.path"] == "/ready"'
        - 'URL(attributes["http.url"])["url.path"] == "/metrics"'

  batch: # https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/batchprocessor/README.md
    send_batch_size: 100000
    timeout: 10s

exporters:
  clickhouse: # https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/clickhouseexporter
    endpoint: "${env:CLICKHOUSE_ENDPOINT}"
    username: "${env:CLICKHOUSE_USER}"
    password: "${env:CLICKHOUSE_PASSWORD}"
    database: "${env:CLICKHOUSE_DB}"
    create_schema: true

extensions:
  health_check:
    endpoint: 0.0.0.0:13133
    path: /

service:
  pipelines:
    {{- if .Values.collector.logsReceivers }}
    logs:
      receivers: {{ .Values.collector.logsReceivers | toJson }}
      processors: [memory_limiter, resourcedetection, k8sattributes, filter, batch]
      exporters: [clickhouse]
    {{- end }}
    {{- if .Values.collector.metricsReceivers }}
    metrics:
      receivers: {{ .Values.collector.metricsReceivers | toJson }}
      processors: [memory_limiter, resourcedetection, k8sattributes, filter, batch]
      exporters: [clickhouse]
    {{- end }}
    {{- if .Values.collector.tracesReceivers }}
    traces:
      receivers: {{ .Values.collector.tracesReceivers | toJson }}
      processors: [memory_limiter, resourcedetection, k8sattributes, filter, batch]
      exporters: [clickhouse]
    {{- end }}

  extensions:
    - health_check
{{- end -}}
