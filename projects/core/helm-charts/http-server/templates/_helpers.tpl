{{- define "http-server.selectorLabels" -}}
app.kubernetes.io/part-of: "{{ .Release.Namespace }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/name: "{{ join "." (compact (reverse (slice (reverse (splitList "/" (printf "%s%s" "/" .Values.image.repository))) 0 2))) }}"
app.kubernetes.io/component: http-server
{{- end -}}

{{- define "http-server.metadataLabels" -}}
{{ include "http-server.selectorLabels" . }}
app.kubernetes.io/version: "{{ .Values.image.tag }}"
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end -}}
