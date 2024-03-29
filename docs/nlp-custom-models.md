# Natural Language Processing Custom models

Natural Language Processing (NLP) provides a set of libraries within Watson Studio to allow Data Scientists to create bespoke models.  Theses can be exported from Watson Studio as an compressed archive by adding the following to a cell at the end of the model

```python
project.save_data('ensemble_model', data=ensemble_model.as_file_like_object(), overwrite=True)
```

this can then be transferred from the Watson Studio environment to your workstation (copy the file into a models directory).

You can create a combined container with the runtime and model

```dockerfile
ARG WATSON_RUNTIME_BASE="cp.icr.io/cp/ai/watson-nlp-runtime:1.0.18"
FROM ${WATSON_RUNTIME_BASE} as base
ENV LOCAL_MODELS_DIR=/app/models
COPY models /app/models
```

Once built the container can now be used as outlined in the [combined model](nlp-combined-image.md) section

You can also use the [packaging tool](https://github.com/IBM/ibm-watson-embed-model-builder/tree/main/watson_embed_model_packager){: target=_blank} to create the containers 