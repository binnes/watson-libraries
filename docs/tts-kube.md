# Text to Speech Kubernetes

This page covers how to get the Text to Speech service running on OpenShift.

The files relating to this example can be found in the repository [here](https://github.com/binnes/watson-libraries/tree/main/speech/tts_kube){: target=_blank}

## Deploy to OpenShift

1. Navigate to where the files from this repo have been cloned to your local machine and change to the speech/tts_kube directory
2. Create a new project on the cluster

    ```shell
    oc new-project demo-tts
    ```

3. Apply all the manifest files to your cluster

    ```shell
    oc apply -f <directory containing manifest files>
    ```

## Testing the deployment

To test the speech to text container the curl utility can be used to submit requests, alter the URL to the route of the service on your cluster:

```shell
curl -k "https://tts-embed-demo-tts.apps.ocp.lab.home/text-to-speech/api/v1/synthesize" \
  --header "Content-Type: application/json" --data '{"text":"Hello world"}' \
  --header "Accept: audio/wav" --output output.wav
```

This used the default voice set in the configuration.  You can also specify a different voice as part of the request, so long as the voice model was built into the runtime:

```shell
curl -k "https://tts-embed-demo-tts.apps.ocp.lab.home/text-to-speech/api/v1/synthesize?voice=en-GB_JamesV3Voice" \
  --header "Content-Type: application/json" \
  --data '{"text":"Hello! Isn''t it a wonderful day."}' \
  --header "Accept: audio/wav" \
  --output british-test.wav
```

Refer to the [API reference](https://cloud.ibm.com/apidocs/text-to-speech#getsynthesize){: target=_blank} for details of the requests that can be made
