{{- define "kuard.selectorLabels" -}}
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/name: "{{ regexReplaceAll "[\\W]" .Values.image.repository "_" | trunc 63 | trimAll "_" }}"
{{- end -}}

{{- define "kuard.metadataLabels" -}}
{{ include "kuard.selectorLabels" $ }}
app.kubernetes.io/version: "{{ regexReplaceAll "[\\W]" .Values.image.tag "_" | trunc 63 | trimAll "_" }}"
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end -}}

{{- define "kuard.configsChecksum" -}}
{{- list .Values.configEnvs .Values.secretConfigEnvs .Values.configFiles .Values.secretConfigFiles | toJson | sha256sum -}}
{{- end -}}
