import json

import numpy
import requests

post_data = {'inputs': []}

input_name_0 = "images"
input_shape_0 = [1, 3, 640, 640]
input_datatype_0 = numpy.float32
input_data_0 = numpy.ones(input_shape_0, input_datatype_0)
triton_datatype_0 = "FP32"

post_data['inputs'].append({
    'name': input_name_0,
    'shape': input_shape_0,
    'datatype': triton_datatype_0,
    'data': input_data_0.tolist()})

model_name = "yolov5s_onnx"
result = requests.post("http://localhost:8000/v2/models/yolov5s_onnx/versions/1/infer",
    data=json.dumps(post_data))
