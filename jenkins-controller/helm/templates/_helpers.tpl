{{/* internal-linux SSH key secret name */}}
{{- define "internal-linux.ssh-key.secret-name" -}}
{{- .Values.interfaces.internalLinux.name }}-{{ .Values.internalLinux.ssh.privateKeySecretName -}}
{{- end -}}

{{/* internal-linux known hosts secret name */}}
{{- define "internal-linux.known-hosts.secret-name" -}}
{{- .Values.interfaces.internalLinux.name }}-{{ .Values.internalLinux.ssh.knownHostsSecretName -}}
{{- end -}}

{{/* ssh folder path */}}
{{- define "sshFolderPath" -}}
{{- printf "%s/%s" .Values.jenkins.homePath .Values.jenkins.sshFolderName -}}
{{- end -}}

{{/* internal linux key file path */}}
{{- define "internal-linux.ssh.host-key-file-path" -}}
{{- $sshFolder := include "sshFolderPath" . -}}
{{- $hostKeyName := include "sshHostKeyFileName" (dict "path" .Values.internalLinux.ssh.hostKeyPath "ctx" .) -}}
{{- printf "%s/%s_%s" $sshFolder .Values.interfaces.internalLinux.name $hostKeyName -}}
{{- end -}}