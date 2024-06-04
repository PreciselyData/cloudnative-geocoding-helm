{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "expressEngine.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" | lower }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "expressEngine.fullname" -}}
{{- if contains .Chart.Name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "expressEngine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "expressEngine.labels" -}}
helm.sh/chart: {{ include "expressEngine.chart" . }}
{{ include "expressEngine.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: {{ include "expressEngine.uname" . }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "expressEngine.selectorLabels" -}}
app.kubernetes.io/name: {{ include "expressEngine.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: express-engine
{{- end }}

{{- define "expressEngine.uname" -}}
{{- if empty .Values.fullnameOverride -}}
{{- if empty .Values.nameOverride -}}
{{ .Values.clusterName }}-{{ .Values.nodeGroup }}
{{- else -}}
{{ .Values.nameOverride }}-{{ .Values.nodeGroup }}
{{- end -}}
{{- else -}}
{{ .Values.fullnameOverride }}
{{- end -}}
{{- end -}}

{{- define "expressEngine.masterService" -}}
{{- if empty .Values.masterService -}}
{{- if empty .Values.fullnameOverride -}}
{{- if empty .Values.nameOverride -}}
{{ .Values.clusterName }}-master
{{- else -}}
{{ .Values.nameOverride }}-master
{{- end -}}
{{- else -}}
{{ .Values.fullnameOverride }}
{{- end -}}
{{- else -}}
{{ .Values.masterService }}
{{- end -}}
{{- end -}}

{{- define "expressEngine.serviceName" -}}
{{- if eq .Values.nodeGroup "master" }}
{{- include "expressEngine.masterService" . }}
{{- else }}
{{- include "expressEngine.uname" . }}
{{- end }}
{{- end -}}

{{- define "expressEngine.endpoints" -}}
{{- $replicas := int (toString (.Values.replicas)) }}
{{- $uname := (include "expressEngine.uname" .) }}
  {{- range $i, $e := untilStep 0 $replicas 1 -}}
{{ $uname }}-{{ $i }},
  {{- end -}}
{{- end -}}

{{- define "expressEngine.majorVersion" -}}
  {{- $version := semver .Chart.Version }}
  {{- $version.Major }}
{{- end }}

{{- define "expressEngine.home" -}}
/usr/share/opensearch
{{- end -}}

{{- define "expressEngine.roles" -}}
{{- range $.Values.roles -}}
{{ . }},
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "expressEngine.serviceAccountName" -}}
{{- if $.Values.serviceAccount.create }}
{{- default (include "expressEngine.uname" .) $.Values.serviceAccount.name }}
{{- else }}
{{- default "default" (printf "%s-exp" $.Values.serviceAccount.name | trimSuffix "-") }}
{{- end }}
{{- end }}