{{/*
Expand the name of the chart.
*/}}
{{- define "addressing-hook.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "addressing-hook.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "addressing-hook.labels" -}}
helm.sh/chart: {{ include "addressing-hook.chart" . }}
{{ include "addressing-hook.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "addressing-hook.selectorLabels" -}}
app.kubernetes.io/name: {{ include "addressing-hook.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
volumeMounts
*/}}
{{- define "addressing-hook.volumeMounts" -}}
- name: geoaddressing-host-volume
  mountPath: {{ .Values.global.nfs.volumeMountPath }}
{{- end }}