# Speech services

There are 2 speech services offered by IBM Watson Libraries for Embed:

-   Text to Speech
-   Speech to Text

There are examples of both provided in these examples.

The speech libraries contain a number of different containers:

-   the core runtime for speech to text and text to speech
-   a catalog image for speech to text and text to speech
-   a set of 8 kHz (Telephony) and 16 kHz (Multimedia) sampling rate models for multiple libraries

To create a run time the core runtime, the catalog image and a set of language images need to be combined.  There are 2 options available for this:

-   build a single container containing all the content required - [local example](stt-local.md)
-   use pod init containers to generate the combined run time as part of a deployment on Kubernetes - [OpenShift example](stt-kube.md)

## Configuration

When combining multiple container images you need to provide some configuration files.  Some of the files control the creation of the combined runtime, while others are used to configure the runtime.  

When creating a local runtime the configuration is created in a number of files but in the Kubernetes deployment the configuration is created in a ConfigMap.  Both of these approaches contain the same content.

The configuration is  made up of the following files:

-   env_config.json
-   resourceRequirements.py
-   sessionPools.py
-   sessionPools.yaml

The contents of these files is detailed in the [documentation](https://www.ibm.com/docs/en/watson-libraries?topic=r-configuration-options){: target=_blank}.

### Adding a model to the configuration files

The functionality of the deployed runtime is controlled by the models included in the runtime.  If you want to be able to handle a specific language at a certain sample rate (Telephony vs Multimedia) or vocalise with a specific voice you need to have the appropriate model built into the runtime.

It is important to ensure that all models that you want to include in the runtime are detailed in the configuration files for the local deployment and the Kubernetes ConfigMap manifest in **config.yaml** for a Kubernetes deployment.

1. Find the additional model images from the [text to speech model catalog](https://www.ibm.com/docs/en/watson-libraries?topic=wtsleh-models-catalog){: target=_blank} or the [speech to text model catalog](https://www.ibm.com/docs/en/watson-libraries?topic=home-models-catalog){: target=_blank}
2. Update the **clusterGroups.default.models** array in **env_config.json**
3. Update the **sessionPoolPolicies.PreWarmingPolicy** array in **sessionPools.yaml**.  

You also have to bring in the model container in the Containerfile for local running or as an additional init container in the Deployment on Kubernetes as detailed in the next 2 sections.

### Adding a model to the Containerfile

When adding a new model you need to:

1. Add the model image to the top of the Containerfile in a new `FROM <container registry>/<model-image>:<model image tag> as <short-model-image-name>` statement
2. Populate the intermediate model cache by adding another `COPY --chown=watson:0 --from=<short-model-image-name>/* /models/pool2/` to the Containerfile

### Adding a model to the Kubernetes Deployment manifest

When adding a new model you need to:

1. Add a new init container to the Deployment manifest in the **spec.template.spec.initContainers** array:

    ```yaml
      - name: <model-image>
        image: <container registry>/<model-image>:<model image tag>
        args:
        - sh
        - -c
        - cp model/* /models/pool2
        env:
        - name: ACCEPT_LICENSE
            value: "true"
        resources:
            limits:
            cpu: 1
            ephemeral-storage: 1Gi
            memory: 1Gi
            requests:
            cpu: 100m
            ephemeral-storage: 1Gi
            memory: 256Mi
        volumeMounts:
        - name: models
            mountPath: /models/pool2
    ```

## Secure communication

The speech runtime containers don't support TLS termination, only http.  The examples use OpenShift Routes to enforce TLS termination, so all traffic coming into the cluster will be protected by TLS, but the traffic from the cluster ingress to the speech runtime will be unencrypted, which isn't ideal.  To solve this the **watson-stt-haproxy** and **watson-tts-haproxy** containers can be run in the same pod as the appropriate speech runtime.  The service and route can then be modified to sent traffic to the haproxy container, which will then use a *localhost* address (stays within the pod) to send the traffic from the proxy into the speech runtime.

!!!Todo
    Add the **watson-stt-haproxy** and **watson-tts-haproxy** to the example deployment, service and route manifest files to enable *internet* -> *pod* -> *speech* runtime fully encrypted traffic

## Metering

You need to configure your production runtime to store logs on persistent storage and enable metering in the configuration so you have an accurate record of the usage as detailed in the [speech to text documentation](https://www.ibm.com/docs/en/watson-libraries?topic=i-metering-your-containers){: target=_blank} and [text to speech documentation](https://www.ibm.com/docs/en/watson-libraries?topic=i-metering-your-containers-1){: target=_blank}

!!!Todo
    Add a suitable metering configuration for persisting and processing logs to the example deployments and cluster setup
