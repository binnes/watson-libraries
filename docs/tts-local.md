Text to Speech Local

This page describes how to run Text to Speech on your local system using Docker or Podman.

The [product documentation](https://www.ibm.com/docs/en/watson-libraries?topic=rc-run-docker-run-1){: target=_blank} will provide more details and additional capabilities not shown in this example.

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

To create a usable text to speech runtime container, the standard runtime needs to be combined with appropriate model(s).  There are a number of [standard models](https://www.ibm.com/docs/en/SSLEKE/SPEECH/tts_models_catalog.html){: target=_blank} provided.  In addition to the model(s) a configuration needs to be provided.  This configuration needs to be customised to match the included model(s).

The files used in this example can be found [here](https://github.com/binnes/watson-libraries/tree/main/speech/tts_local){: target=_blank}.

To build the container image run the command:

=== "Docker"

    ``` shell
    docker build -f Containerfile . -t tts-standalone
    ```

=== "Podman"

    ```shell
    podman build --tls-verify=false -f Containerfile . -t tts-standalone
    ```

You should store the container image in a repository if you want to use it on a Kubernetes platform or make it available to other developers to run locally

=== "Docker"

    ``` shell
    docker tag tts-standalone lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/tts-standalone:0.0.1
    docker push lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/tts-standalone:0.0.1
    ```

=== "Podman"

    ```shell
    podman tag tts-standalone lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/tts-standalone:0.0.1
    podman push --tls-verify=false lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/tts-standalone:0.0.1
    ```

## Running the container locally

The container can be run on your local system.  The following commands assume you have the tool on your local system (either built or pulled from a repository)

=== "Docker"

    ```shell
    docker run --rm -it --env ACCEPT_LICENSE=true --publish 1080:1080 nlp-standalone
    ```

=== "Podman"

    ```shell
    podman run --rm -it --env ACCEPT_LICENSE=true --publish 1080:1080 nlp-standalone
    ```

## Submitting requests to the container

To test the text to speech container the curl utility can be used to submit requests:

```shell
curl "http://localhost:1080/text-to-speech/api/v1/synthesize" \
  --header "Content-Type: application/json" --data '{"text":"Hello world"}' \
  --header "Accept: audio/wav" --output output.wav
```

This used the default voice set in the configuration.  You can also specify a different voice as part of the request, so long as the voice model was built into the runtime:

```shell
curl "http://localhost:1080/text-to-speech/api/v1/synthesize?voice=en-GB_JamesV3Voice" \
  --header "Content-Type: application/json" \
  --data '{"text":"Hello! Isn''t it a wonderful day."}' \
  --header "Accept: audio/wav" \
  --output british-test.wav
```

Refer to the [API reference](https://cloud.ibm.com/apidocs/text-to-speech#getsynthesize){: target=_blank} for details of the requests that can be made
