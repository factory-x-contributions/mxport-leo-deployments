# Helm
This helm chart may be used to incorporate the gateway in other helm deployments.
The easiest method is to copy the contents of this folder to a subfolder of your umbrella chart, e.g. `/charts/gateway-sts`, and include it via your `Chart.yaml`:
```yaml
  - name: gateway-sts
    version: 0.1.0
    repository: "file://./charts/gateway-sts"
```

You can then override the default `values.yaml` with your own, e.g., to configure ingress, service, or other configurations.

Note that, by default, the chart attempts to use the `openresty-sts:dev` image, which you may need to build on your own beforehand using the resources in the [docker folder](../docker/).

Also, the default nginx configuration of the `openresty-sts:dev` image will be overridden by the one placed in `config/nginx.conf`.
