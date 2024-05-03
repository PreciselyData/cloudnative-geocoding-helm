{{/*
Addressing reference data Storage Class
*/}}
{{- define "addressing-ref-storage-class.name" -}}
{{- printf "%s-%s" "ref-efs" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Addressing reference data Persistent Volume Name
*/}}
{{- define "addressing-ref-pv.name" -}}
{{- printf "%s-%s-%s" "ref" .Release.Name "pv" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Addressing reference data Persistent Volume Claim Name
*/}}
{{- define "addressing-ref-pvc.name" -}}
{{- printf "%s-%s-%s" "ref" .Release.Name "pvc" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Addressing reference data PV labels
*/}}
{{- define "addressing-ref-pv.labels" -}}
app.kubernetes.io/name: {{ include "addressing-ref-pv.name" . }}
app.kubernetes.io/managed-by: Precisely
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Addressing reference data PVC labels
*/}}
{{- define "addressing-ref-pvc.labels" -}}
app.kubernetes.io/name: {{ include "addressing-ref-pvc.name" . }}
app.kubernetes.io/managed-by: Precisely
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}