{{/*
Expand the name of the chart.
*/}}
{{- define "regional-addressing.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "regional-addressing.fullname" -}}
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
{{- define "regional-addressing.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "regional-addressing.labels" -}}
helm.sh/chart: {{ include "regional-addressing.chart" . }}
{{ include "regional-addressing.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "regional-addressing.selectorLabels" -}}
app.kubernetes.io/name: {{ include "regional-addressing.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "regional-addressing.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "regional-addressing.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Storage Class Name
*/}}
{{- define "common-svc-storage-class.name" -}}
{{- printf "%s-%s" "svc-efs" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Persistent Volume Name
*/}}
{{- define "common-svc-pv.name" -}}
{{- printf "%s-%s-%s" "svc" .Release.Name "pv" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Persistent Volume Claim Name
*/}}
{{- define "common-svc-pvc.name" -}}
{{- printf "%s-%s-%s" "svc" .Release.Name "pvc" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common PV labels
*/}}
{{- define "common-svc-pv.labels" -}}
app.kubernetes.io/name: {{ include "common-svc-pv.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common PVC labels
*/}}
{{- define "common-svc-pvc.labels" -}}
app.kubernetes.io/name: {{ include "common-svc-pvc.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Gets the configuration from the provided country
*/}}
{{- define "common-svc.configuration" -}}
{{- $dictionary := index . 0 -}}
{{- $country := index . 1 -}}
{{- $config := index . 2 -}}
{{- if hasKey $dictionary $country }}
{{- if hasKey (get $dictionary $country) $config }}
{{- (get (get $dictionary $country) $config) | toYaml }}
{{- else}}
{{- (get (get $dictionary "default") $config) | toYaml }}
{{- end }}
{{- else}}
{{- (get (get $dictionary "default") $config) | toYaml }}
{{- end }}
{{- end }}

{{/*
Gets the global config from the provided country
*/}}
{{- define "common-svc.global" -}}
{{- $dictionary := index . 0 -}}
{{- $country := index . 1 -}}
{{- $config := index . 2 -}}
{{- if hasKey (get $dictionary "countryConfigurations") $country }}
{{- if hasKey (get (get $dictionary "countryConfigurations") $country) $config }}
{{- (get (get (get $dictionary "countryConfigurations") $country) $config) | toYaml }}
{{- else}}
{{- (get (get $dictionary "global") $config) | toYaml }}
{{- end }}
{{- else}}
{{- (get (get $dictionary "global") $config) | toYaml }}
{{- end }}
{{- end }}


{{/*
Addressing data config map name
*/}}
{{- define "addressing-data-config.name" -}}
{{- if .Values.global.manualDataConfig.enabled }}
{{- printf "%s-%s" .Values.global.manualDataConfig.nameOverride .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" "addressing-data-mnt-config" }}
{{- end }}
{{- end }}


{{/*
Express engine data Storage Class Name
*/}}
{{- define "autocomplete-exp-gp3-storage-class.name" -}}
{{- printf "%s-%s-%s" "exp-gp3-sc" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data Storage Class Name
*/}}
{{- define "autocomplete-exp-efs-storage-class.name" -}}
{{- printf "%s-%s-%s" "exp-efs-sc" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data PV
*/}}
{{- define "autocomplete-exp-efs-snapshot-pv.name" -}}
{{- printf "%s-pv-%s-%s" "exp-snapshot" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data PVC
*/}}
{{- define "autocomplete-exp-efs-snapshot-pvc.name" -}}
{{- printf "%s-pvc-%s-%s" "exp-snapshot" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
RBAC Express engine restore data job Service Account
*/}}
{{- define "autocomplete-exp-restore-job-sa.name" -}}
{{- printf "%s-sa-%s-%s" "exp-restore" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
RBAC Express engine restore data job Role
*/}}
{{- define "autocomplete-exp-restore-job-role.name" -}}
{{- printf "%s-role-%s-%s" "exp-restore" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
RBAC Express engine restore data job Role Binding
*/}}
{{- define "autocomplete-exp-restore-job-rb.name" -}}
{{- printf "%s-rb-%s-%s" "exp-restore" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data Job name
*/}}
{{- define "autocomplete-exp-restore-job.name" -}}
{{- printf "%s-job-%s-%s-%d" "exp-restore" .Release.Name  .Release.Namespace (.Release.Revision | int) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Express engine restore data Job config name
*/}}
{{- define "autocomplete-exp-restore-job-config.name" -}}
{{- printf "%s-config-%s-%s" "exp-restore" .Release.Name  .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}