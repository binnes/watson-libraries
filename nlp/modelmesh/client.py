import grpc
from watson_nlp_runtime_client import (
    common_service_pb2,
    common_service_pb2_grpc,
    syntax_types_pb2,
)

# No TLS
# Note the 8033 port to talk to model-mesh directly
channel = grpc.insecure_channel("localhost:8033")

stub = common_service_pb2_grpc.NlpServiceStub(channel)

request = common_service_pb2.SyntaxRequest(
    raw_document=syntax_types_pb2.RawDocument(text="This is a test"),
    parsers=("sentence", "token", "part_of_speech", "lemma", "dependency"),
)

# Note the `mm-vmodel-id` header with the name of the InferenceService
response = stub.SyntaxPredict(
    request, metadata=[("mm-vmodel-id", "syntax-izumo-en")]
)

print(response)