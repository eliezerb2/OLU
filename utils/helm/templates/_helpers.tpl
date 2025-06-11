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

{{/* SSH host key file name template */}}
{{- define "sshHostKeyFileName" -}}
{{- $path := .path -}}
{{- printf "%s%s%s" $path.prefix $path.algorithm $path.suffix -}}
{{- end -}}

{{/* SSH host key path template */}}
{{- define "sshHostKeyPath" -}}
{{- $path := .path -}}
{{- printf "%s%s" $path.folder (include "sshHostKeyFileName" (dict "path" $path)) -}}
{{- end -}}

{{/* SSH host key pub file name template */}}
{{- define "sshHostKeyPubFileName" -}}
{{- $path := .path -}}
{{- printf "%s%s" (include "sshHostKeyFileName" (dict "path" $path)) $path.pubSuffix -}}
{{- end -}}

{{/* SSH host key pub path template */}}
{{- define "sshHostKeyPubPath" -}}
{{- $path := .path -}}
{{- printf "%s%s" (include "sshHostKeyPath" (dict "path" $path)) $path.pubSuffix -}}
{{- end -}}

{{/* SSH keygen service account name */}}
{{- define "sshKeygenServiceAccountName" -}}
{{- printf "%s-%s" .Release.Name .Values.sshKeygenJob.serviceAccountName -}}
{{- end -}}

{{/* SSH keygen role name */}}
{{- define "sshKeygenRoleName" -}}
{{- printf "%s-%s" .Release.Name .Values.sshKeygenJob.roleName -}}
{{- end -}}

{{/* config map name */}}
{{- define "configMapName" -}}
{{- printf "%s-%s" .Release.Name .Values.configMap.name -}}
{{- end -}}

{{/* initContainer image */}}
{{- define "initContainerImage" -}}
{{- printf "%s:%s" .Values.utilsChart.initContainer.image.repository .Values.utilsChart.initContainer.image.tag -}}
{{- end -}}