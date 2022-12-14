# Natural Language Processing using KServe Model Mesh

The KServe project has the capability to serve models from an S3 bucket, without having to prepare each model and run them as separate applications on OpenShif or Kubernetes.

!!!Warning
    Currently the install instructions for KServe ModelMesh only work on a vanilla Kubernetes, they do not work on OpenShift as the instructions break the Security Context additional security measures deployed on OpenShift.

