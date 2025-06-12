{{- define "envFromConfigMaps" -}}
- configMapRef:
    name: {{ include "configMapName" . }}
{{- end }}

{{- define "tmpMemVolumeName" -}}
{{ .Values.adminPassword.secretName }}-mem
{{- end }}

{{- define "tmpMemVolumeMountPath" -}}
/tmp/{{ include "tmpMemVolumeName" . }}
{{- end }}

{{- define "volumeMounts.tmpMemVolumeMount" -}}
- name: {{ include "tmpMemVolumeName" . | quote }}
  mountPath: {{ include "tmpMemVolumeMountPath" . | quote }}
{{- end }}

{{- define "adminPasswordMountPath" -}}
/tmp/{{ .Values.adminPassword.secretName }}
{{- end }}

{{- define "tmpMemAdminPasswordFilePath" -}}
{{ include "tmpMemVolumeMountPath" . }}/{{ .Values.adminPassword.keyName }}
{{- end }}