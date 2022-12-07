# Setup

## Local bare metal cluster

1. install OCP
2. install Operators from Operator Hub catalog:

    -   OpenShift Data Foundation
    -   Red Hat Quay

        !!!Warning
            There is a bug in Quay 3.7.10 that prevents large container layers from being stored, which means the Watson Libraries images cannot be stored.  [This article](https://access.redhat.com/solutions/6987551){: target=_blank} explains how to deploy a workaround

## Accessing container images on IBM Container Registry

The IBM Watson Libraries for Embed container images are provided on the IBM Container Registry service, but requires an [entitlement key](https://myibm.ibm.com/products-services/containerlibrary){: target=_blank} to access them.  Once you have a key you need to use it when accessing them.

### Local Docker / Podman / Skopeo

When accessing the images on your local machine using Docker or Podman you need to login to the IBM container registry:

=== "Docker"

    ```shell
    docker login cp.icr.io --username cp --password <entitlement_key>
    ```

=== "Podman"

    ```shell
    podman login cp.icr.io --username cp --password <entitlement_key>
    ```

=== "Skopeo"

    ```shell
    skopeo login cp.icr.io --username cp --password <entitlement_key>
    ```

### Kubernetes / OpenShift

When accessing the images from a Kubernetes of OpenShift cluster, you need to setup a secret on the cluster then refer to it in a deployment manifest.

```shell
kubectl create secret docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=<entitlement key> --docker-email=<your-email>
```

within a deployment manifest add an **imagePullSecret** to the template section:

```yaml
spec:
    ...
    template:
        ...
        spec:
            ...
            imagePullSecrets:
            - name: ibm-entitlement-key
```

## Setting up a local mirror

The example configuration installs Quay on the demo cluster.  This can be used to hold local mirrors of the IBM Watson for Embed container images.  

To mirror the images the Quay mirror repository can be used to automatically mirror the images, or [Skopeo](https://github.com/containers/skopeo){: target=_blank} can be used to copy the images from the IBM Container Registry to the local Quay registry.

### Using the local mirror

The local Quay registry has a self-signed SSL certificate by default, so docker, podman, Skopeo and Kubernetes/OpenShift need to be configured to accept or ignore the self-signed X509 certificate when accessing the local registry.

=== "Docker"

    Docker Desktop and Engine have a configuration file which allow insecure registries to be configured.  You need to add the **insecure-registries** to the configuration file.  In Docker for Desktop this can be found in the Preferences panel under the Docker Engine section.  On Linux this configuration file is usually found at location `/etc/docker/daemon.json`.  Add the section, so the file looks similar to this:

    ```json
    {
        "builder": {
            "gc": {
            "defaultKeepStorage": "20GB",
            "enabled": true
            }
        },
        "experimental": true,
        "features": {
            "buildkit": true
        },
        "insecure-registries": [
            "https://lab-registry-quay-openshift-operators.apps.ocp.lab.home"
        ]
    }
    ```

    additional details of the configuration can be found in the [docker documentation](https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file){: target=_blank}

=== "Podman"

    Podman accepts the `--tls-verify=false` command line argument, so if added to any command it will ignore any TLS errors.

=== "Skopeo"

    Skopeo accepts the `--src-tls-verify=false` and `dest-tls-verify=false` command line arguments, so if added to the copy command it will ignore TLS errors from the source and/or the destination registries.

=== "OpenShift / Kubernetes"

    Enable OpenShift to pull images from local Quay container registry (using self-signed X509 certificate) by adding the self-signed certificate to the cluster configuration.  This can be achieved by running the following as a cluster admin:

        - *Modify the REGISTRY_HOSTNAME value on the first line to match your installation*

        ```shell
        export REGISTRY_HOSTNAME=lab-registry-quay-openshift-operators.apps.ocp.lab.home
        export REGISTRY_PORT=443
        echo "" | openssl s_client -showcerts -prexit -connect "${REGISTRY_HOSTNAME}:${REGISTRY_PORT}" 2> /dev/null | sed -n -e '/BEGIN CERTIFICATE/,/END CERTIFICATE/ p' > tmp.crt
        openssl x509 -in tmp.crt -text | grep Issuer
        oc create configmap registry-quay -n openshift-config --from-file="${REGISTRY_HOSTNAME}=$(pwd)/tmp.crt"
        oc patch image.config.openshift.io/cluster --patch '{"spec":{"additionalTrustedCA":{"name":"registry-quay"}}}' --type=merge
        oc get image.config.openshift.io/cluster -o yaml
        ```
