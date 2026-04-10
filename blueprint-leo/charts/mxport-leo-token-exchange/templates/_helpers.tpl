{{- /*
Expand the name of the chart.
*/ -}}
{{- define "mxport-leo-token-exchange.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
Create a default fully qualified app name.
*/ -}}
{{- define "mxport-leo-token-exchange.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- /*
Create chart name and version as used by the chart label.
*/ -}}
{{- define "mxport-leo-token-exchange.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
Common labels.
*/ -}}
{{- define "mxport-leo-token-exchange.labels" -}}
helm.sh/chart: {{ include "mxport-leo-token-exchange.chart" . }}
{{ include "mxport-leo-token-exchange.selectorLabels" . }}
{{- if .Chart.AppVersion -}}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- /*
Selector labels.
*/ -}}
{{- define "mxport-leo-token-exchange.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mxport-leo-token-exchange.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}