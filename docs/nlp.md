# Natural Language Processing

There are a number of Natural Language Processing (NLP) services offered, covering a number of languages, within the IBM Watson Libraries for Embed.  The [model catalog](https://www.ibm.com/docs/en/watson-libraries?topic=models-catalog){: target=_blank} lists all available models.

In addition to the models there is a runtime which supports both gRPC and REST enpoints.

## Deployment options

When deploying a model you need to combine the models you want with the container and there are a number of ways to do this:

- Create a single container with the runtime and model(s) within the container
- Combine the models in a single directory structure, then map that directory in to the runtime container

The model containers available on the IBM Container Registry do not have a runtime installed.  Their default entry point is `/bin/sh -c /app/unpack_model.sh`, which will expand the model into directory `/app/models`.  This means running a model container will expand the model into directory /app/models, so if this is an external volume mounted into the container the model will be on the external volume, which could then be mounted into the NLP runtime container, which will make the model available to the runtime without having to be installed in the same container as the runtime.

The NLP containers can get very large, with the runtime currently being 2.5GB> Startup times need to be considered when adding multiple models into a single container with the NLP runtime.

### Examples

This project contains a number of examples showing:

- [building a combined container with runtime and model(s)](nlp-combined-image.md)
- [building an external volume containing unarchived models that can be mapped into the runtime container](nlp-external-volume.md)
- [deploying a model using KServe modelmesh](nlp-modelmesh.md)
- [packaging a custom model (exported from Watson Studio) to use with the runtime](nlp-custom-models.md)
