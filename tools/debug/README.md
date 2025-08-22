# Debug container deployments for OTP data builder

These deployments are intended for maintaining and debugging mounted storage used by the data builder jobs.
The deployments create a pod that does nothing but has storage mounted similar to the data builder jobs.

## Deployment

```
kubectl apply -f otp-data-builder-debug-dev.yml
```
or
```
kubectl apply -f otp-data-builder-debug-prod.yml
```

## Creating a shell inside the debug pod

```
kubectl exec -it <debug_pod_name> -- /bin/bash
```

## Removing a deployment

```
kubectl delete -f otp-data-builder-debug-dev.yml
```
or
```
kubectl delete -f otp-data-builder-debug-prod.yml
```
