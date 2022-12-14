# Natural Language Processing - external volume

This page covers how to setup Natural Language Processing (NLP) using the run time with the models contained on an external volume which is mapped into the runtime

The files relating to this example can be found in the repository [here](https://github.com/binnes/watson-libraries/tree/main/nlp/external-volume){: target=_blank}

Rather than combining the model and runtime into a single container it is also possible to create an external volume, copy the models onto that volume, then map the volume into the runtime container when it is run.

The model containers have their default entrypoint set to run `/bin/sh -c /app/unpack_model.sh` which will unpack the model within the container to the directory pointed at by the **MODEL_ROOT_DIR** directory, defaults to **/app/modesl**

Simple running all of the required model containers with the external volume mapped to /app/models will create the external volume, which can then be mapped into the runtime.  Again, the environment variable **MODEL_ROOT_DIR** tells the runtime where to find available models.

There are 2 methods of deploying the models shown. One using a local environment with docker or podman and one using init containers in an OpenShift deployment.

## Local deploy

To use docker or podman on your local system you can modify then run the following script as required.  These files are available in the git repo as podman-local.sh or docker-local.sh:

```shell
#!/usr/bin/env bash
IMAGE_REGISTRY=${IMAGE_REGISTRY:-"lab-registry-quay-openshift-operators.apps.ocp.lab.home/watson-libs"}
RUNTIME_IMAGE=${RUNTIME_IMAGE:-"watson-nlp-runtime:1.0.20"}
export MODELS="${MODELS:-"watson-nlp_syntax_izumo_lang_en_stock:1.0.7,watson-nlp_syntax_izumo_lang_fr_stock:1.0.7"}"
IFS=',' read -ra models_arr <<< "${MODELS}"
TLS_CERT=${TLS_CERT:-""}
TLS_KEY=${TLS_KEY:-""}
CA_CERT=${CA_CERT:-""}

function real_path {
  echo "$(cd $(dirname ${1}) && pwd)/$(basename ${1})"
}

# Clear out existing volume
podman volume rm model_data 2>/dev/null || true

# Create a shared volume and initialize with open permissions
podman volume create --label model_data
podman run --rm -it -v model_data:/model_data alpine chmod 777 /model_data

# Put models into the shared volume
for model in "${models_arr[@]}"
do
  podman run --rm -it  --tls-verify=false -v model_data:/app/models -e ACCEPT_LICENSE=true $IMAGE_REGISTRY/$model
done

# If TLS credentials are set up, run with TLS
tls_args=""
if [ "$TLS_CERT" != "" ] && [ "$TLS_KEY" != "" ]
then
  echo "Running with TLS"
  tls_args="$tls_args -v $(real_path ${TLS_KEY}):/tls/server.key.pem"
  tls_args="$tls_args -e TLS_SERVER_KEY=/tls/server.key.pem"
  tls_args="$tls_args -e SERVE_KEY=/tls/server.key.pem"
  tls_args="$tls_args -v $(real_path ${TLS_CERT}):/tls/server.cert.pem"
  tls_args="$tls_args -e TLS_SERVER_CERT=/tls/server.cert.pem"
  tls_args="$tls_args -e SERVE_CERT=/tls/server.cert.pem"
  tls_args="$tls_args -e PROXY_CERT=/tls/server.cert.pem"

  if [ "$CA_CERT" != "" ]
  then
    echo "Enabling mTLS"
    tls_args="$tls_args -v $(real_path ${CA_CERT}):/tls/ca.cert.pem"
    tls_args="$tls_args -e TLS_CLIENT_CERT=/tls/ca.cert.pem"
    tls_args="$tls_args -e MTLS_CLIENT_CA=/tls/ca.cert.pem"
    tls_args="$tls_args -e PROXY_MTLS_KEY=/tls/server.key.pem"
    tls_args="$tls_args -e PROXY_MTLS_CERT=/tls/server.cert.pem"
  fi

  echo "TLS args: [$tls_args]"
fi

# Run the runtime with the models mounted
podman run ${@} \
  --rm -it  --tls-verify=false \
  -v model_data:/app/model_data \
  -e ACCEPT_LICENSE=true \
  -e LOCAL_MODELS_DIR=/app/model_data \
  -p 8085:8085 \
  -p 8080:8080 \
  $tls_args $IMAGE_REGISTRY/$RUNTIME_IMAGE
  ```

### Testing the model

To test the running model you can use curl

```shell
 curl -s \
   "http://localhost:8080/v1/watson.runtime.nlp.v1/NlpService/SyntaxPredict" \
   -H "accept: application/json" \
   -H "content-type: application/json" \
   -H "grpc-metadata-mm-model-id: syntax_izumo_lang_en_stock" \
   -d '{ "raw_document": { "text": "This is a test sentence" }, "parsers": ["token"] }'
```

## Deploy to OpenShift

1. Navigate to where the files from this repo have been cloned to your local machine and change to the speech/tts_kube directory
2. Create a new project on the cluster

    ```shell
    oc new-project demo-nlp
    ```

3. Apply all the manifest files to your cluster

    ```shell
    oc apply -f <directory containing manifest files>
    ```

## Testing the deployment

To test the nlp container the curl utility can be used to submit requests, alter the URL to the route of the service on your cluster:

```shell
curl -k -s "https://watson-nlp-container-demo-nlp.apps.ocp.lab.home/v1/watson.runtime.nlp.v1/NlpService/SyntaxPredict" \
   -H "accept: application/json" \
   -H "content-type: application/json" \
   -H "grpc-metadata-mm-model-id: syntax_izumo_lang_en_stock" \
   -d '{ "raw_document": { "text": "This is a test sentence" }, "parsers": ["token"] }'
```

Refer to the [API reference](https://cloud.ibm.com/apidocs/text-to-speech#getsynthesize){: target=_blank} for details of the requests that can be made
