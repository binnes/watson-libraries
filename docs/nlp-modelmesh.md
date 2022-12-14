# Natural Language Processing using KServe Model Mesh

The KServe project has the capability to serve models from an S3 bucket, without having to prepare each model and run them as separate applications on OpenShif or Kubernetes.

!!!Warning
    Currently the install instructions for KServe ModelMesh only work on a vanilla Kubernetes, they do not work on OpenShift as the instructions break the Security Context additional security measures deployed on OpenShift.

To use a local deploy of KServer models mesh you can use minikube, alternatively a cloud hosted Kubernetes Service should work.

1. install minikube and enable the dashboard, ingress, ingress-dns, metrics-server addons, ensuring you provide sufficient CPU and memory resources - models are resource hungry!
2. deploy KServe ModelMesh using the [quickstart instructions](https://www.ibm.com/links?url=https%3A%2F%2Fgithub.com%2Fkserve%2Fmodelmesh-serving%2Fblob%2Frelease-0.9%2Fdocs%2Finstall%2Finstall-script.md){: target=blank}
3. create the image pull secret `kubectl create secret docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=<entitlement key> --docker-email=<your-email>`
4. create the service account `kubectl apply -f service-account.yaml
5. update the model serving config `kubectl apply -f config.yaml`
6. create the watson runtim within kserve `kubectl apply -f runtime.yaml`
7. upload the required model(s) to the minio S3 service `kubectl apply -f upload.yaml`
8. create the inferencing service `kubectl apply -f inferencing-service.yaml`

you can then use the provided client application, client.py, to test the service. You will need to install the python library `pip install  watson-nlp-runtime-client`
