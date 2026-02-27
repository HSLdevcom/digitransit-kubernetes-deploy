# k6 load testing setup

This load testing setup uses the [k6-operator](https://github.com/grafana/k6-operator) installed with helm from https://grafana.github.io/helm-charts. You will need to install [helm](https://helm.sh/) before installing the chart.

## How to use

1. Create configmap of the desired test configuration and data.
```
kubectl create configmap k6-test-files --from-file run-queries-from-file.js --from-file queries.csv
```
2. Modify `testrun.yml` for running test with desired configuration and apply it.
```
kubectl apply -f testrun.yml
```
3. Remove resources created for the load test.
```
kubectl delete -f testrun.yml
```

## Installation

1. [Install k6-operator.](https://grafana.com/docs/k6/latest/set-up/set-up-distributed-k6/install-k6-operator/)
```
helm install k6-operator grafana/k6-operator
```

## Removal

1. [Uninstall k6-operator.](https://grafana.com/docs/k6/latest/set-up/set-up-distributed-k6/install-k6-operator/)
```
helm uninstall k6-operator
```
