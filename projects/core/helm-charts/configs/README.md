Reusable config manifests.

`values.yaml`:

```
configEnvs: {}
secretConfigEnvs: {}
configFiles: {}
secretConfigFiles: {}
```

`templates/`:

```
{{- include "configs.annotations" . | nindent 0 }}
{{- include "configs.envFrom" . | nindent 0 }}
{{- include "configs.volumeMounts" . | nindent 0 }}
{{- include "configs.volumes" . | nindent 0 }}
{{- include "configs.manifests" . | nindent 0 }}
```
