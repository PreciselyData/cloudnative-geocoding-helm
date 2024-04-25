{{/*
Expand the name of the chart.
*/}}
{{- define "lookup-svc.name" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
{{- default $top.Chart.Name (printf "%s-%s" $top.Values.nameOverride $var) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lookup-svc.fullname" -}}
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
{{- define "lookup-svc.chart" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
{{- printf "%s-%s-%s" $top.Chart.Name $var $top.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lookup-svc.labels" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
helm.sh/chart: {{ include "lookup-svc.chart" .}}
{{ include "lookup-svc.selectorLabels" . }}
{{- if $top.Chart.AppVersion }}
app.kubernetes.io/version: {{ $top.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $top.Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lookup-svc.selectorLabels" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
app.kubernetes.io/name: {{ include "lookup-svc.name" . }}
app.kubernetes.io/instance: {{ printf "%s-%s" $top.Release.Name $var | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lookup-svc.serviceAccountName" -}}
{{- $top := index . 0 -}}
{{- $var := index . 1 -}}
{{- if $top.Values.serviceAccount.create }}
{{- default (include "lookup-svc.fullname" .) $top.Values.serviceAccount.name }}
{{- else }}
{{- default "default" (printf "%s-%s" $top.Values.serviceAccount.name $var | trimSuffix "-") }}
{{- end }}
{{- end }}


{{/*
volumeMounts
*/}}
{{- define "lookup-svc.volumeMounts" -}}
- name: geoaddressing-host-volume
  mountPath: {{ .Values.global.nfs.volumeMountPath }}
{{- end }}