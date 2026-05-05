{{- define "configs.manifests" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: "{{ .Release.Name }}-config-envs"
  namespace: "{{ .Release.Namespace }}"
  labels:
    {{- include "configs.metadataLabels" . | nindent 4 }}
data:
  {{- range $key, $val := .Values.configEnvs }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}

---
apiVersion: v1
kind: Secret
metadata:
  name: "{{ .Release.Name }}-config-envs"
  namespace: "{{ .Release.Namespace }}"
  labels:
    {{- include "configs.metadataLabels" . | nindent 4 }}
data:
  {{- range $key, $val := .Values.secretConfigEnvs }}
  {{ $key }}: {{ $val | b64enc | quote }}
  {{- end }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: "{{ .Release.Name }}-config-files"
  namespace: "{{ .Release.Namespace }}"
  labels:
    {{- include "configs.metadataLabels" . | nindent 4 }}
data:
  {{- range $key, $val := .Values.configFiles }}
  {{ include "configs.key" $key }}: |
    {{- if hasSuffix ".yaml" $key }}
    {{- toYaml $val | nindent 4 }}
    {{- else }}
    {{- $val | nindent 4 }}
    {{- end }}
  {{- end }}

---
apiVersion: v1
kind: Secret
metadata:
  name: "{{ .Release.Name }}-config-files"
  namespace: "{{ .Release.Namespace }}"
  labels:
    {{- include "configs.metadataLabels" . | nindent 4 }}
data:
  {{- range $key, $val := .Values.secretConfigFiles }}
  {{- if hasSuffix ".yaml" $key }}
  {{ include "configs.key" $key }}: {{ toYaml $val | b64enc | quote }}
  {{- else }}
  {{ include "configs.key" $key }}: {{ $val | b64enc | quote }}
  {{- end }}
  {{- end }}
{{- end -}}

{{- define "configs.annotations" -}}
checksum/configs: "{{ include "configs.checksum" . }}"
{{- end -}}

{{- define "configs.envFrom" -}}
{{- if .Values.configEnvs }}
- configMapRef:
    name: "{{ .Release.Name }}-config-envs"
{{- end }}
{{- if .Values.secretConfigEnvs }}
- secretRef:
    name: "{{ .Release.Name }}-config-envs"
{{- end }}
{{- end -}}

{{- define "configs.volumes" -}}
{{- if .Values.configFiles }}
- name: config-files
  configMap:
    name: "{{ .Release.Name }}-config-files"
{{- end }}
{{- if .Values.secretConfigFiles }}
- name: secret-config-files
  secret:
    secretName: "{{ .Release.Name }}-config-files"
{{- end }}
{{- end -}}

{{- define "configs.volumeMounts" -}}
{{- if .Values.configFiles }}
{{- range $key, $_ := .Values.configFiles }}
- name: config-files
  subPath: "{{ include "configs.key" $key }}"
  mountPath: "{{ $key }}"
  readOnly: true
{{- end }}
{{- end }}
{{- if .Values.secretConfigFiles }}
{{- range $key, $_ := .Values.secretConfigFiles }}
- name: secret-config-files
  subPath: "{{ include "configs.key" $key }}"
  mountPath: "{{ $key }}"
  readOnly: true
{{- end }}
{{- end }}
{{- end -}}
