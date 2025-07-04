# Scripts and configurations for debugging and maintaining the cluster

## otp-data-builder-debug

This deployment is intended for the maintaining and debugging mounted storage used by the data builder jobs.
The deployment creates a pod that does nothing but has storage mounted similar to the data builder jobs.
To start the data builder debug deployment, run the following command:

```
kubectl apply -f otp-data-builder-debug.yml
```

To create a shell inside the debug pod, run the following command:

```
kubectl exec -it <debug_pod_name> -- /bin/bash
```

To remove the deployment, run the following command.

```
kubectl delete -f otp-data-builder-debug.yml
```

## Running data-builder cron jobs manually

To run data builder cron jobs manually, you can use the `job-from-cronjob.sh` script.
You should check the output to make sure that it contains the correct content (e.g. environment variables).
Run the following command to generate a job yaml file:

```
./job-from-cronjob.sh ../dev/otp-transit-builder-finland-v3-dev.yml manual-data-builder-job-finland-v3
```

To start the job, run the following command:
```
kubectl apply -f output/manual-data-builder-job-finland-v3.yml
```

To remove the job, run the following command:
```
kubectl delete -f output/manual-data-builder-job-finland-v3.yml
```

## Monitoring stack

### Accessing the setup

1. Get the pod name.
```
export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=monitoring-setup" -oname)
```

2. Use kubectl port-forward.
```
kubectl --namespace monitoring port-forward $POD_NAME 3000
```

3. Access from `localhost:3000`.

### Installation

1. Apply monitoring storageclass to cluster.
```
kubectl apply -f monitoring-storageclass.yml
```

2. Install monitoring stack from helm chart with custom values.
```
helm install -f kube-prometheus-stack-values.yml -n monitoring monitoring-setup prometheus-community/kube-prometheus-stack
```

### Upgrading

```
helm upgrade -f kube-prometheus-stack-values.yml -n monitoring monitoring-setup prometheus-community/kube-prometheus-stack
```

### Removal

Persistent storage is not removed by default when uninstalling!

1. Remove monitoring stack.
```
helm uninstall -n monitoring monitoring-setup
```

2. Apply monitoring storageclass to cluster.
```
kubectl delete -f monitoring-storageclass.yml
```
