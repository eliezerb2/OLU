{{- define "envFromConfigMaps" -}}
- configMapRef:
    name: {{ include "configMapName" . }}
- configMapRef:
    name: {{ .Values.interfaces.updatesDownloader.name }}-config
- configMapRef:
    name: {{ .Values.interfaces.internalLinux.name }}-config
{{- end }}

{{- define "secretName" -}}
{{- $interfaceResponderName := .interfaceResponderName -}}
{{- $secretName := .secretName -}}
{{- $interfaceName := index .root.Values.interfaces $interfaceResponderName | dig "name" "" -}}
{{- $secretValue := index .root.Values $interfaceResponderName | dig "ssh" $secretName "" -}}
{{- printf "%s-%s" $interfaceName $secretValue -}}
{{- end -}}

{{- define "updatesDownloaderSSHSecretName" -}}
{{- include "secretName" (dict "interfaceResponderName" "updatesDownloader" "secretName" "privateKeySecretName" "root" $) }}
{{- end -}}

{{- define "updatesDownloaderSSHKnownHostsSecretName" -}}
{{- include "secretName" (dict "interfaceResponderName" "updatesDownloader" "secretName" "knownHostsSecretName" "root" $) }}
{{- end -}}

# TODO: replace with generic template
{{/* internal-linux SSH key secret name */}}
{{- define "internal-linux.ssh-key.secret-name" -}}
{{- .Values.interfaces.internalLinux.name }}-{{ .Values.internalLinux.ssh.privateKeySecretName -}}
{{- end -}}

# TODO: replace with generic template
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

{{/* updates downloader key file path */}}
{{- define "updates-downloader.ssh.host-key-file-path" -}}
{{- $sshFolder := include "sshFolderPath" . -}}
{{- $hostKeyName := include "sshHostKeyFileName" (dict "path" .Values.updatesDownloader.ssh.hostKeyPath "ctx" .) -}}
{{- printf "%s/%s_%s" $sshFolder .Values.interfaces.updatesDownloader.name $hostKeyName -}}
{{- end -}}