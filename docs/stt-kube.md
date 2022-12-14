# Speech to Text Kubernetes

<!--- cSpell:ignore Convertio -->

This page covers how to get the Speech to Text service running on OpenShift.

The files relating to this example can be found in the repository [here](https://github.com/binnes/watson-libraries/tree/main/speech/stt_kube){: target=_blank}

## Deploy to OpenShift

1. Navigate to where the files from this repo have been cloned to your local machine and change to the speech/stt_kube directory
2. Create a new project on the cluster

    ```shell
    oc new-project demo-stt
    ```

3. Apply all the manifest files to your cluster

    ```shell
    oc apply -f <directory containing manifest files>
    ```

## Testing the deployment

To verify the service is running correctly the curl utility can be used to make requests of the service.  You need a test audio file.  One is provided in the stt_kube directory named **test.wav**.

*This was created on a MacOS system using the standard Voice Memos app.  Once a recording was made, select it in the **All Recordings** list, copy it (⌘C) then paste it to the Desktop.  Use the [Convertio](https://convertio.co){: target=_blank} site, or similar, to convert the m4a file to a wav file.*

!!!Todo
    Work out process to create audio file on Linux and Windows systems

To test the speech to text container the curl utility can be used to submit requests, alter the URL to the route of the service on your cluster:

```shell
curl -k "https://stt-embed-demo-stt.apps.ocp.lab.home/speech-to-text/api/v1/recognize" --header "Content-Type: audio/wav" --data-binary @test.wav
```
