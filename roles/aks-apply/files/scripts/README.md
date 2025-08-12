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
