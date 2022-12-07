# Speech to Text Local

This page describes how to run Speech to Text on your local system using Docker or Podman.

The [product documentation](https://www.ibm.com/docs/en/watson-libraries?topic=rc-run-docker-run){: target=_blank} will provide more details and additional capabilities not shown in this example.

## Access to images

To run this example you need to have access to hte IBM Watson Libraries for Embed container images.  These are available on the IBM Container Registry, but you need an [entitlement key](https://myibm.ibm.com/products-services/containerlibrary){: target=_blank}

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

To create a usable speech to text runtime container, the standard runtime needs to be combined with appropriate model(s).  There are a number of [standard models](https://www.ibm.com/docs/en/SSLEKE/SPEECH/stt_models_catalog.html){: target=_blank} provided.  In addition to the model(s) a configuration needs to be provided.  This configuration needs to be customised to match the included model(s).

The files used in this example can be found [here](https://github.com/binnes/watson-libraries/tree/main/speech/stt_local){: target=_blank}.

To build the container image run the command:

=== "Docker"

    ``` shell
    docker build -f Containerfile . -t stt-standalone
    ```

=== "Podman"

    ```shell
    podman build ---tls-verify=false -f Containerfile . -t stt-standalone
    ```

You should store the container image in a repository if you want to use it on a Kubernetes platform or make it available to other developers to run locally

=== "Docker"

    ``` shell
    docker tag stt-standalone lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/stt-standalone:0.0.1
    docker push --tls-verify=false lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/stt-standalone:0.0.1
    ```

=== "Podman"

    ```shell
    podman tag stt-standalone lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/stt-standalone:0.0.1
    podman push --tls-verify=false lab-registry-quay-openshift-operators.apps.ocp.lab.home/brian/stt-standalone:0.0.1
    ```

## Running the container

The container can be run on your local system.  The following commands assume you have the tool on your local system (either built or pulled from a repository)

=== "Docker"

    ```shell
    docker run --rm -it --env ACCEPT_LICENSE=true --publish 1080:1080 stt-standalone
    ```

=== "Podman"

    ```shell
    podman run --rm -it --env ACCEPT_LICENSE=true --publish 1080:1080 stt-standalone
    ```

## Submitting requests to the container

To submit a request to the container you need an audio file.  There is one in the repository, test.wav.

*This was created on a MacOS system using the standard Voice Memos app.  Once a recording was made, select it in the **All Recordings** list, copy it (⌘C) then paste it to the Desktop.  Use the [Convertio](https://convertio.co){: target=_blank} site, or similar, to convert the m4a file to a wav file.*

!!!Todo
    Work out process to create audio file on Linux and Windows systems

To test the speech to text container the curl utility can be used to submit requests:

```shell
curl "http://localhost:1080/speech-to-text/api/v1/recognize" --header "Content-Type: audio/wav" --data-binary @test.wav
```

Refer to the [API reference](https://cloud.ibm.com/apidocs/speech-to-text){: target=_blank} for details of the requests that can be made
