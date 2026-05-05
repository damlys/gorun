{{- define "otelcol.selectorLabels" -}}
app.kubernetes.io/part-of: "{{ .Release.Namespace }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/name: "opentelemetry-collector"
{{- end -}}

{{- define "otelcol.metadataLabels" -}}
{{ include "otelcol.selectorLabels" . }}
app.kubernetes.io/version: "0.0.0"
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end -}}

{{- define "otelcol.collector.configsChecksum" -}}
{{- list .Values.collector.configEnvs .Values.collector.secretConfigEnvs | toJson | sha256sum -}}
{{- end -}}
