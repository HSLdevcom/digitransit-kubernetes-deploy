# k6 load testing setup

This load testing setup uses the [k6-operator](https://github.com/grafana/k6-operator) installed with helm from https://grafana.github.io/helm-charts. You will need to install [helm](https://helm.sh/) before installing the chart.

## How to use

1. Create configmap of the desired test configuration and data.
```bash
kubectl create configmap k6-test-files --from-file run-queries-from-file.js --from-file queries.csv
```
2. Modify `testrun.yml` for running test with desired configuration and apply it.
```bash
kubectl apply -f testrun.yml
```
3. Remove resources created for the load test.
```bash
kubectl delete -f testrun.yml
```
```bash
kubectl delete configmap k6-test-files
```

## Testing with k6 locally

If you run OTP locally on port `9080`, you can use this command to run k6 with queries from `queries.csv`.
```bash
docker run -it --rm -v ~/digitransit-kubernetes-deploy/tools/k6:/scripts --net=host grafana/k6:latest \
    run /scripts/run-queries-from-file.js --vus 10 --duration "15s" -e API_URL=http://localhost:9080/otp/gtfs/v1
```

## Installation

1. [Install k6-operator.](https://grafana.com/docs/k6/latest/set-up/set-up-distributed-k6/install-k6-operator/)
```bash
helm install k6-operator grafana/k6-operator
```

## Removal

1. [Uninstall k6-operator.](https://grafana.com/docs/k6/latest/set-up/set-up-distributed-k6/install-k6-operator/)
```bash
helm uninstall k6-operator
```
