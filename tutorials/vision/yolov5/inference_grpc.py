import numpy
import tritonclient.grpc as grpc_client

url = "localhost:8001"
client = grpc_client.InferenceServerClient(url)

inputs = []
input_name_0 = "images"
input_shape_0 = [1, 3, 640, 640]
input_datatype_0 = numpy.float32
input_data_0 = numpy.array(numpy.ones(input_shape_0, input_datatype_0))
triton_datatype_0 = "FP32"

tensor = grpc_client.InferInput(name=input_name_0, shape=input_shape_0,
    datatype=triton_datatype_0)
tensor.set_data_from_numpy(input_data_0)
inputs.append(tensor)

outputs = []
output_name_0 = "output"
tensor = grpc_client.InferRequestedOutput(output_name_0)
outputs.append(tensor)
inferences = client.infer(model_name="yolov5s_onnx",
    model_version="1",
    inputs=inputs, outputs=outputs)
