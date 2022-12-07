# Speech to Text Kubernetes

This page covers how to get the Speech to Text service running on OpenShift.

The files relating to this example can be found in the repository [here]

## Deploy to OpenShift

```shell
oc apply -f <directory containing manifest files>
```

## Secure communication

The speech to text runtime container doesn't support TLS termination, only http.  The OpenShift Route enforces TLS termination, so all traffic coming into the cluster will be protected by TLS, but the traffic from the cluster ingress to the service will be unencrypted, which isn't ideal.  To solve this the watson-stt-haproxy container can be run in the same pod as the stt runtime.  The service and route can then be modified to sent traffic to the watson-stt-haproxy, which will then use *localhost* within the pod to send the traffic from the proxy into the stt runtime.

!!!Todo
    Add the **watson-stt-haproxy** to the example deployment, service and route manifest files to enable internet -> pod fully encrypted traffic
