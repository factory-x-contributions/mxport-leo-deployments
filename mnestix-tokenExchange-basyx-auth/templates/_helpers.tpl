{{- define "mnestix-tokenexchange-basyx-auth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := include "mnestix-tokenexchange-basyx-auth.name" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.componentName" -}}
{{- printf "%s-%s" (include "mnestix-tokenexchange-basyx-auth.fullname" .root) .component | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.componentDataPvcName" -}}
{{- printf "%s-data" (include "mnestix-tokenexchange-basyx-auth.componentName" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.labels" -}}
helm.sh/chart: {{ include "mnestix-tokenexchange-basyx-auth.chart" .root }}
app.kubernetes.io/name: {{ include "mnestix-tokenexchange-basyx-auth.name" .root }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/version: {{ .root.Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mnestix-tokenexchange-basyx-auth.name" .root }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.appSecretName" -}}
{{- printf "%s-app-secrets" (include "mnestix-tokenexchange-basyx-auth.fullname" .) -}}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.keycloakTlsSecretName" -}}
{{- if .Values.keycloak.tlsSecret.name -}}
{{- .Values.keycloak.tlsSecret.name -}}
{{- else -}}
{{- printf "%s-keycloak-tls" (include "mnestix-tokenexchange-basyx-auth.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.keycloakRealmConfigMapName" -}}
{{- if .Values.keycloak.realm.configMapName -}}
{{- .Values.keycloak.realm.configMapName -}}
{{- else -}}
{{- printf "%s-keycloak-realm" (include "mnestix-tokenexchange-basyx-auth.fullname" .) -}}
{{- end -}}
{{- end -}}
