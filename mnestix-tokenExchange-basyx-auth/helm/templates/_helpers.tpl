{{/* SPDX-License-Identifier: MIT */}}
{{/* Copyright (c) 2025 XITASO GmbH */}}
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

{{- define "mnestix-tokenexchange-basyx-auth.nameWithSuffix" -}}
{{- $base := .base -}}
{{- $suffix := .suffix -}}
{{- $maxBaseLen := sub 63 (add 1 (len $suffix)) -}}
{{- if lt $maxBaseLen 1 -}}
{{- $suffix | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $trimmedBase := $base | trunc (int $maxBaseLen) | trimSuffix "-" -}}
{{- printf "%s-%s" $trimmedBase $suffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.componentName" -}}
{{- include "mnestix-tokenexchange-basyx-auth.nameWithSuffix" (dict "base" (include "mnestix-tokenexchange-basyx-auth.fullname" .root) "suffix" .component) -}}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.componentDataPvcName" -}}
{{- include "mnestix-tokenexchange-basyx-auth.nameWithSuffix" (dict "base" (include "mnestix-tokenexchange-basyx-auth.fullname" .root) "suffix" (printf "%s-data" .component)) -}}
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
{{- include "mnestix-tokenexchange-basyx-auth.nameWithSuffix" (dict "base" (include "mnestix-tokenexchange-basyx-auth.fullname" .) "suffix" "app-secrets") -}}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.keycloakTlsSecretName" -}}
{{- if .Values.keycloak.tlsSecret.name -}}
{{- .Values.keycloak.tlsSecret.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "mnestix-tokenexchange-basyx-auth.nameWithSuffix" (dict "base" (include "mnestix-tokenexchange-basyx-auth.fullname" .) "suffix" "keycloak-tls") -}}
{{- end -}}
{{- end -}}

{{- define "mnestix-tokenexchange-basyx-auth.keycloakRealmConfigMapName" -}}
{{- if .Values.keycloak.realm.configMapName -}}
{{- .Values.keycloak.realm.configMapName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "mnestix-tokenexchange-basyx-auth.nameWithSuffix" (dict "base" (include "mnestix-tokenexchange-basyx-auth.fullname" .) "suffix" "keycloak-realm") -}}
{{- end -}}
{{- end -}}
