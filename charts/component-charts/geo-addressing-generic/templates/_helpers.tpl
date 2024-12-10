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

{{- define "addressing-svc.Url" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
{{- $sar := index . 2 -}}
{{- if (index $top.Values $sar).fullnameOverride }}
{{- (printf "%s%s" (index $top.Values $sar).fullnameOverride $var) | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default $top.Chart.Name (index $top.Values $sar).nameOverride }}
{{- if contains $name $top.Release.Name }}
{{- printf "%s%s" $top.Release.Name $var | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s%s" $top.Release.Name $name $var | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Flag to enable the Event-Emitter
*/}}
{{- define "regional-addressing.eventEmitter.enabled" -}}
{{- if (index .Values "event-emitter").enabled }}
{{- printf "%s" "true" | quote }}
{{- else }}
{{- printf "%s" "false" | quote }}
{{- end }}
{{- end }}

{{/*
Event-Emitter URL
*/}}
{{- define "event-emitter.url" -}}
{{ printf "nats://%s-nats.%s.svc.cluster.local:4222" .Release.Name .Release.Namespace }}
{{- end }}