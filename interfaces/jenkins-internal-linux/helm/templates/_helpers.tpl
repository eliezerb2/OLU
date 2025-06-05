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

{{/* SSH host key path template */}}
{{- define "sshHostKeyPath" -}}
{{- printf "%s%s%s" .Values.internalLinux.ssh.hostKeyPath.prefix .Values.internalLinux.ssh.hostKeyPath.algorithm .Values.internalLinux.ssh.hostKeyPath.suffix -}}
{{- end -}}

{{/* SSH host key pub path template */}}
{{- define "sshHostKeyPubPath" -}}
{{- printf "%s%s%s%s" .Values.internalLinux.ssh.hostKeyPath.prefix .Values.internalLinux.ssh.hostKeyPath.algorithm .Values.internalLinux.ssh.hostKeyPath.suffix .Values.internalLinux.ssh.hostKeyPath.pubSuffix -}}
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