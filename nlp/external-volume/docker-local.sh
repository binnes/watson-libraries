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
docker volume rm model_data 2>/dev/null || true

# Create a shared volume and initialize with open permissions
docker volume create --label model_data
docker run --rm -it -v model_data:/model_data alpine chmod 777 /model_data

# Put models into the shared volume
for model in "${models_arr[@]}"
do
  docker run --rm -it -v model_data:/app/models -e ACCEPT_LICENSE=true $IMAGE_REGISTRY/$model
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
docker run ${@} \
  --rm -it \
  -v model_data:/app/model_data \
  -e ACCEPT_LICENSE=true \
  -e LOCAL_MODELS_DIR=/app/model_data \
  -p 8085:8085 \
  -p 8080:8080 \
  $tls_args $IMAGE_REGISTRY/$RUNTIME_IMAGE