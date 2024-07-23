{{/*
Expand the name of the chart.
*/}}
{{- define "geo-addressing-gke.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "geo-addressing-gke.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "geo-addressing-gke.labels" -}}
helm.sh/chart: {{ include "geo-addressing-gke.chart" . }}
{{ include "geo-addressing-gke.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "geo-addressing-gke.selectorLabels" -}}
app.kubernetes.io/name: {{ include "geo-addressing-gke.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Express engine data Storage Class Name
*/}}
{{- define "addressing-exp-storage-class.name" -}}
{{- printf "%s-%s-%s" .Release.Name "exp-gke-sc" .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data Storage Class Name
*/}}
{{- define "addressing-nfs-storage-class.name" -}}
{{- printf "%s-%s-%s" .Release.Name "nfs-sc-gke" .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data PV
*/}}
{{- define "addressing-nfs-pv.name" -}}
{{- printf "%s-pv-%s-%s" .Release.Name "exp-snap-gke" .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data PVC
*/}}
{{- define "addressing-nfs-pvc.name" -}}
{{- printf "%s-pvc-%s-%s" .Release.Name "exp-snap-gke" .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Addressing Hook Storage Class
*/}}
{{- define "addressing-hook-storage-class.name" -}}
{{- printf "%s-%s" .Release.Name "hook-efs-gke" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Addressing Hook Persistent Volume Name
*/}}
{{- define "addressing-hook-pv.name" -}}
{{- printf "%s-%s-%s" .Release.Name "hook-gke" "pv" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Addressing Hook Persistent Volume Claim Name
*/}}
{{- define "addressing-hook-pvc.name" -}}
{{- printf "%s-%s-%s" .Release.Name "hook-gke" "pvc" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Addressing Hook PV labels
*/}}
{{- define "addressing-hook-pv.labels" -}}
app.kubernetes.io/name: {{ include "addressing-hook-pv.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Addressing Hook PVC labels
*/}}
{{- define "addressing-hook-pvc.labels" -}}
app.kubernetes.io/name: {{ include "addressing-hook-pvc.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}