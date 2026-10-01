{{- define "kuard.selectorLabels" -}}
app.kubernetes.io/part-of: "{{ .Release.Namespace }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/name: "{{ join "." (compact (reverse (slice (reverse (splitList "/" (printf "%s%s" "/" .Values.image.repository))) 0 2))) }}"
{{- end -}}

{{- define "kuard.metadataLabels" -}}
{{ include "kuard.selectorLabels" . }}
app.kubernetes.io/version: "{{ .Values.image.tag }}"
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end -}}
