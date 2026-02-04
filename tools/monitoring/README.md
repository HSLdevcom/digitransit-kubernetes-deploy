# Monitoring setup

This monitoring setup uses the [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) helm chart. You will need to install [helm](https://helm.sh/) before installing the chart.

## Accessing the setup

1. Get the pod name.
```
export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=monitoring-setup" -oname)
```

2. Use kubectl port-forward.
```
kubectl --namespace monitoring port-forward $POD_NAME 3000
```

3. Access from `localhost:3000`.

## Importing/exporting dashboards

A dashboard can easily be exported as JSON using the Grafana UI by navigating to the dashboard and clicking the export button.
When creating a new dashboard the option of importing a dashboard from JSON can be selected.

## Installation

1. Apply monitoring storageclass to cluster.
```
kubectl apply -f monitoring-storageclass-dev.yml
```
OR
```
kubectl apply -f monitoring-storageclass-prod.yml
```

2. Install monitoring stack from helm chart with custom values.
```
helm install -f kube-prometheus-stack-values.yml -n monitoring monitoring-setup prometheus-community/kube-prometheus-stack --version 75.1.0
```

3. Install OTP service monitors.
```
kubectl apply -f monitoring-servicemonitors.yml
```

## Upgrading

```
helm upgrade -f kube-prometheus-stack-values.yml -n monitoring monitoring-setup prometheus-community/kube-prometheus-stack --version 75.1.0
```

## Removal

Persistent storage is not removed by default when uninstalling!

1. Remove OTP service monitors.
```
kubectl delete -f monitoring-servicemonitors.yml
```

2. Remove monitoring stack.
```
helm uninstall -n monitoring monitoring-setup
```

3. Remove monitoring storageclass from cluster.
```
kubectl delete -f monitoring-storageclass-dev.yml
```
OR
```
kubectl delete -f monitoring-storageclass-prod.yml
```

4. View remaining persistent storage claims.
```
kubectl get pvc -n monitoring
```
