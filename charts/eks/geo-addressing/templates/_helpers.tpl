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
{{- define "addressing-exp-storage-class-test.name" -}}
{{ toYaml .Values }}
{{- end }}

{{/*
Express engine data Storage Class Name
*/}}
{{- define "addressing-exp-storage-class.name" -}}
{{- if .Values.global.addressingExpress.storageClass.enabled }}
{{- printf "%s-%s-%s" .Release.Name "exp-sc" .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" .Values.global.addressingExpress.storageClass.name }}
{{- end }}
{{- end }}

{{/*
Express engine restore data Storage Class Name
*/}}
{{- define "addressing-nfs-storage-class.name" -}}
{{- if .Values.global.nfs.storageClass.enabled }}
{{- printf "%s-%s-%s" .Release.Name "nfs-sc" .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" .Values.global.nfs.storageClass.name }}
{{- end }}
{{- end }}

{{/*
Express engine restore data PV
*/}}
{{- define "addressing-nfs-pv.name" -}}
{{- printf "%s-pv-%s-%s" .Release.Name "exp-snap" .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data PVC
*/}}
{{- define "addressing-nfs-pvc.name" -}}
{{- printf "%s-pvc-%s-%s" .Release.Name "exp-snap" .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Addressing Hook Storage Class
*/}}
{{- define "addressing-hook-storage-class.name" -}}
{{- if .Values.global.addressingHook.storageClass.enabled }}
{{- printf "%s-%s" .Release.Name "hook-efs" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" .Values.global.addressingHook.storageClass.name }}
{{- end }}
{{- end }}

{{/*
Addressing Hook Persistent Volume Name
*/}}
{{- define "addressing-hook-pv.name" -}}
{{- printf "%s-hook-pv" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Addressing Hook Persistent Volume Claim Name
*/}}
{{- define "addressing-hook-pvc.name" -}}
{{- printf "%s-hook-pvc" .Release.Name | trunc 63 | trimSuffix "-" }}
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