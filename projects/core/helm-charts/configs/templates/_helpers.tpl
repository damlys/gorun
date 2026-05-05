{{- define "configs.selectorLabels" -}}
app.kubernetes.io/part-of: "{{ .Release.Namespace }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/component: configs
{{- end -}}

{{- define "configs.metadataLabels" -}}
{{ include "configs.selectorLabels" . }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end -}}

{{- define "configs.checksum" -}}
{{- list .Values.configEnvs .Values.secretConfigEnvs .Values.configFiles .Values.secretConfigFiles | toJson | sha256sum -}}
{{- end -}}

{{- define "configs.key" -}}
{{- . | trimPrefix "/" | replace "/" "." -}}
{{- end -}}
