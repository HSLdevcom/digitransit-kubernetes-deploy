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
