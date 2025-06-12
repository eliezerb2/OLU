{{- define "envFromConfigMaps" -}}
- configMapRef:
    name: {{ include "configMapName" . }}
{{- end }}