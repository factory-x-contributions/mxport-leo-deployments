{{/*
Expand the name of the chart.
*/}}
{{- define "company-lookup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "company-lookup.fullname" -}}
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
{{- define "company-lookup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "company-lookup.labels" -}}
helm.sh/chart: {{ include "company-lookup.chart" . }}
{{ include "company-lookup.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "company-lookup.selectorLabels" -}}
app.kubernetes.io/name: {{ include "company-lookup.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "company-lookup.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "company-lookup.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host — uses the Bitnami subchart service when embedded, or a custom host.
*/}}
{{- define "company-lookup.postgresqlHost" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-postgresql" (include "company-lookup.fullname" .) -}}
{{- else -}}
{{- .Values.externalPostgresql.host | default "localhost" -}}
{{- end -}}
{{- end -}}
