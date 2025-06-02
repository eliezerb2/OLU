{{/* Common interface labels (configurable) */}}
{{- define "interface.labels" -}}
name: {{ .Release.Name }}
initiator: {{ .Values.labels.initiator }}
responder: {{ .Values.labels.responder }}
{{- end -}}

{{/* Get the lowercase filename without extension */}}
{{- define "get.filename" -}}
{{- .Template.Name | base | trimSuffix ".yaml" | lower -}}
{{- end -}}