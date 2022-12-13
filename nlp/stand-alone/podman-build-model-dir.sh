mkdir -p models
REGISTRY=lab-registry-quay-openshift-operators.apps.ocp.lab.home/watson-libs
export MODELS="watson-nlp_syntax_izumo_lang_en_stock:1.0.7 watson-nlp_syntax_izumo_lang_fr_stock:1.0.7"
for i in $MODELS
do
  image=$REGISTRY/$i
  podman run -it --tls-verify=false --rm -e ACCEPT_LICENSE=true -v `pwd`/models:/app/models $image
done