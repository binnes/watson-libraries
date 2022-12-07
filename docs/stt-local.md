# Speech to Text Local

This page describes how to run Speech to Text on your local system using Docker or Podman.

The [product documentation](https://www.ibm.com/docs/en/watson-libraries?topic=rc-run-docker-run){: target=_blank} will provide more details and additional capabilities not shown in this example.

## Access to images

To run this example you need to have access to hte IBM Watson Libraries for Embed container images.  These are available on the IBM Container Registry, but you need an [entitlement key](https://myibm.ibm.com/products-services/containerlibrary){: target=_blank}

For the code in this repo I use a local mirror, hosted in a [Project Quay](https://www.projectquay.io){: target=_blank} repository.

If you are running against the IBM registry then you will need to change the images from `lab-registry-quay-openshift-operators.apps.ocp.lab.home/watson-libs` to `cp.icr.io/cp/ai` and login to the repository before trying to access any images with

=== "Docker"
    ``` shell
    docker login cp.icr.io --username cp --password <entitlement_key>
    ```

=== "Podman"
    ``` shell
    podman login cp.icr.io --username cp --password <entitlement_key>
    ```

## Building the runtime

To create a usable speech to text runtime container, the standard runtime needs to be combined with appropriate model(s).  There are a number of [standard models](https://www.ibm.com/docs/en/SSLEKE/SPEECH/stt_models_catalog.html){: target=_blank} provided.  In addition to the model(s) a configuration needs to be provided.  This configuration needs to be customised to match the included model(s).

The files used in this example can be found [here](){: target=_blank}