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

## Running the container on IBM Code Engine

This assumes you have an account on IBM cloud, have an instance of Container Registry in your account, have the ibmcloud CLI installed and the Container Registry and Code Engine plugins installed

A full tutorial can be found [here](https://github.com/ibm-build-lab/Watson-NLP/blob/main/MLOps/Deploy-to-Code-Engine/README.md){: target=_blank}

1. login to the IBM Cloud on the command line `ibmcloud login (--sso)`
2. set the region for the Container Registry service on IBM Cloud `ibmcloud cr region-set` then select the appropriate region and note the name of the registry (e.g. uk-south uses registry **uk.icr.io**)
3. login to the Container Registry `ibmcloud cr login --client podman`
4. tag the stand alone image for the IBM Cloud registry (substitute for your region registry address) `podman tag nlp-standalone:latest uk.icr.io/bi-uk/nlp-standalone:latest`
5. push the image to the registry `podman push uk.icr.io/bi-uk/nlp-standalone:latest`
6. set the correct resource group to run the application in `ibmcloud target -g bi-devops`
7. create a container engine project `ibmcloud ce project create --name bi-nlp-standalone`
8. set the new project as the current context `ibmcloud ce project select --name bi-nlp-standalone`
9. use the [IBM Cloud web UI](https://cloud.ibm.com/codeengine/overview){: target=_blank} to deploy the code engine app, specifying the image in the IBM Container Registry you pushed in step 5.
10. create the environment variable **ACCEPT_LICENSE** with the value **true**

Once the Code Engine application is deployed you can verify it is running with `ibmcloud ce app list`

Test the application is responding to requests using curl (*you can get your application endpoint from the Domain mappings tab in the web UI*)

```shell
curl -s -X POST "https://nlp-standalone-application-4a.wgry41hvzqj.eu-gb.codeengine.appdomain.cloud/v1/watson.runtime.nlp.v1/NlpService/SyntaxPredict" \
  -H "accept: application/json" \
  -H "grpc-metadata-mm-model-id: syntax_izumo_lang_en_stock" \
  -H "content-type: application/json" \
  -d "{ \"rawDocument\": { \"text\": \"This is a test.\" }, \"parsers\": [ \"TOKEN\" ]}" \
  | jq -r .
```
