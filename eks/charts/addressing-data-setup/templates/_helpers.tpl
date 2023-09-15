{{/*
Expand the name of the chart.
*/}}
{{- define "addressing-data.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "addressing-data.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "addressing-data.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "addressing-data.labels" -}}
helm.sh/chart: {{ include "addressing-data.chart" . }}
{{ include "addressing-data.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: Precisely
{{- end }}

{{/*
Selector labels
*/}}
{{- define "addressing-data.selectorLabels" -}}
app.kubernetes.io/name: {{ include "addressing-data.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
volumeMounts
*/}}
{{- define "addressing-data.volumeMounts" -}}
- name: geoaddressing-host-volume
  mountPath: {{ .Values.global.mountBasePath }}
{{- end }}