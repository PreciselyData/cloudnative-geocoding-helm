{{/*
Expand the name of the chart.
*/}}
{{- define "geo-addressing-eks.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "geo-addressing-eks.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "geo-addressing-eks.labels" -}}
helm.sh/chart: {{ include "geo-addressing-eks.chart" . }}
{{ include "geo-addressing-eks.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "geo-addressing-eks.selectorLabels" -}}
app.kubernetes.io/name: {{ include "geo-addressing-eks.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Express engine data Storage Class Name
*/}}
{{- define "addressing-exp-storage-class.name" -}}
{{- printf "%s-%s-%s" "exp-per-sc" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data Storage Class Name
*/}}
{{- define "addressing-nfs-storage-class.name" -}}
{{- printf "%s-%s-%s" "exp-snap-sc" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data PV
*/}}
{{- define "addressing-nfs-pv.name" -}}
{{- printf "%s-pv-%s-%s" "exp-snapshot" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data PVC
*/}}
{{- define "addressing-nfs-pvc.name" -}}
{{- printf "%s-pvc-%s-%s" "exp-snapshot" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}