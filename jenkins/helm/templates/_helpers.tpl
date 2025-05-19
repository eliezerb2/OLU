{{/* Generate the name of the chart */}}
{{- define "jenkins.name" -}}
jenkins
{{- end -}}

{{/* Generate the full name of the release */}}
{{- define "jenkins.fullname" -}}
{{ include "jenkins.name" . }}
{{- end -}}