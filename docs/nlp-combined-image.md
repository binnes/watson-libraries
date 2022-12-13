# Running NLP models using a single container image

<!--- cSpell:ignore Convertio -->

This page describes how to run NLP models by combining the runtime and models into a single container

The [product documentation](https://www.ibm.com/docs/en/watson-libraries?topic=containers-run-serverless-container-runtime-offering){: target=_blank} will provide more details and additional capabilities not shown in this example.

## Access to images

To run this example you need to have access to the IBM Watson Libraries for Embed container images.  These are available on the IBM Container Registry, but you need an [entitlement key](https://myibm.ibm.com/products-services/containerlibrary){: target=_blank}

For the code in this repo I use a local mirror, hosted in a [Project Quay](https://www.projectquay.io){: target=_blank} repository.

If you are running against the IBM registry then you will need to change the images from `lab-registry-quay-openshift-operators.apps.ocp.lab.home/watson-libs` to `cp.icr.io/cp/ai` and login to the repository before trying to access any images with

=== "Docker"

    ```shell
    docker login cp.icr.io --username cp --password <entitlement_key>
    ```

=== "Podman"

    ```shell
    podman login cp.icr.io --username cp --password <entitlement_key>
    ```

## Building the runtime

To create a usable NLP runtime container, the standard runtime needs to be combined with appropriate model(s).  There are a number of [standard models](https://www.ibm.com/docs/en/watson-libraries?topic=models-catalog){: target=_blank} provided.

The files used in this example can be found [here](https://github.com/binnes/watson-libraries/tree/main/nlp/stand-alone){: target=_blank}.

To build the model directory run the script:

=== "Docker"

    ``` shell
    docker build -f Containerfile . -t nlp-standalone:latest
    ```

=== "Podman"

    ```shell
    podman build --tls-verify=false -f Containerfile . -t nlp-standalone:latest
    ```


To build the container image run the command:

=== "Docker"

    ``` shell
    docker build -f Containerfile . -t nlp-standalone
    ```

=== "Podman"

    ```shell
    podman build --tls-verify=false -f Containerfile . -t nlp-standalone
    ```

You should store the container image in a repository if you want to use it on a Kubernetes platform or make it available to other developers to run locally.  If you want to run the container on a serverless platform, such as IBM Code Engine or AWS Fargate then the registry needs to be accessible from those platforms.

=== "Docker"

    ``` shell
    docker tag nlp-standalone lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/nlp-standalone:0.0.1
    docker push lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/nlp-standalone:0.0.1
    ```

=== "Podman"

    ```shell
    podman tag nlp-standalone lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/nlp-standalone:0.0.1
    podman push --tls-verify=false lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/nlp-standalone:0.0.1
    ```

## Running the container

The container can be run on your local system.  The following commands assume you have the tool on your local system (either built or pulled from a repository)

=== "Docker"

    ```shell
    docker run --rm -it -e ACCEPT_LICENSE=true -e LOCAL_MODELS_DIR=/app/model_data -p 8085:8085 -p 8080:8080 nlp-standalone
    ```

=== "Podman"

    ```shell
    podman run --rm -it -e ACCEPT_LICENSE=true -e LOCAL_MODELS_DIR=/app/model_data -p 8085:8085 -p 8080:8080 nlp-standalone
    ```

## Submitting requests to the container

```shell
 curl -s \
   "http://localhost:8080/v1/watson.runtime.nlp.v1/NlpService/SyntaxPredict" \
   -H "accept: application/json" \
   -H "content-type: application/json" \
   -H "grpc-metadata-mm-model-id: syntax_izumo_lang_en_stock" \
   -d '{ "raw_document": { "text": "This is a test sentence" }, "parsers": ["token"] }'
```
