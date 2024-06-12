{{/*
Expand the name of the chart.
*/}}
{{- define "addressing-express.name" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
{{- default $top.Chart.Name (printf "%s-%s" $top.Values.nameOverride $var) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "addressing-express.fullname" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
{{- if $top.Values.fullnameOverride }}
{{- (printf "%s-%s" $top.Values.fullnameOverride $var) | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default $top.Chart.Name $top.Values.nameOverride }}
{{- if contains $name $top.Release.Name }}
{{- printf "%s-%s" $top.Release.Name $var | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s-%s" $top.Release.Name $name $var | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "addressing-express.chart" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
{{- printf "%s-%s-%s" $top.Chart.Name $var $top.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "addressing-express.labels" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
helm.sh/chart: {{ include "addressing-express.chart" .}}
{{ include "addressing-express.selectorLabels" . }}
{{- if $top.Chart.AppVersion }}
app.kubernetes.io/version: {{ $top.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $top.Release.Service }}
{{- with $top.Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "addressing-express.selectorLabels" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
app.kubernetes.io/name: {{ include "addressing-express.name" . }}
app.kubernetes.io/instance: {{ printf "%s" $top.Release.Name | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "addressing-express.serviceAccountName" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
{{- if $top.Values.serviceAccount.create }}
{{- default (include "addressing-express.fullname" .) $top.Values.serviceAccount.name }}
{{- else }}
{{- default "default" (printf "%s-%s" $top.Values.serviceAccount.name $var | trimSuffix "-") }}
{{- end }}
{{- end }}

{{/*
RBAC Express engine restore data job Service Account
*/}}
{{- define "addressing-exp-restore-job-sa.name" -}}
{{- printf "%s-sa-%s" .Release.Name "exp-restore" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
RBAC Express engine restore data job Role
*/}}
{{- define "addressing-exp-restore-job-role.name" -}}
{{- printf "%s-role-%s" .Release.Name "exp-restore" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
RBAC Express engine restore data job Role Binding
*/}}
{{- define "addressing-exp-restore-job-rb.name" -}}
{{- printf "%s-rb-%s" .Release.Name "exp-restore" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data Job name
*/}}
{{- define "addressing-exp-restore-job.name" -}}
{{- printf "%s-job-%s-%d" .Release.Name "exp-restore" (.Release.Revision | int) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data Job config name
*/}}
{{- define "addressing-exp-restore-job-config.name" -}}
{{- printf "%s-config-%s" .Release.Name "exp-restore" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- define "expressEngine.masterServiceUrl" -}}
{{- if empty .Values.expressEngineMaster.masterService -}}
{{- if empty .Values.expressEngineMaster.fullnameOverride -}}
{{- if empty .Values.expressEngineMaster.nameOverride -}}
{{ .Values.expressEngineMaster.clusterName }}-master
{{- else -}}
{{ .Values.expressEngineMaster.nameOverride }}-master
{{- end -}}
{{- else -}}
{{ .Values.expressEngineMaster.fullnameOverride }}
{{- end -}}
{{- else -}}
{{ .Values.expressEngineMaster.masterService }}
{{- end -}}
{{- end -}}