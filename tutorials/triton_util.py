"""Utility for interacting with models on Triton server

For more examples, please refer to `Triton documentation
<https://github.com/triton-inference-server/client/blob/main/src/python/library/tritonclient/grpc/__init__.py>`__
and `examples<https://github.com/triton-inference-server/client/tree/main/src/python/examples>`__
"""
import numpy as np
from typing import Union, Tuple
from tritonclient.grpc import (
    InferenceServerClient,
    InferInput
)


class TritonRemoteModel:
    def __init__(self, url: str, model_name: str, model_version: str = ""):
        self._client = InferenceServerClient(url)
        self._name = model_name
        self._version = model_version
        self._metadata = self._client.get_model_metadata(model_name, model_version)
        self._infer_inputs = [InferInput(x.name, None, x.datatype) for x in self._metadata.inputs]

    @property
    def name(self) -> str:
        return self._name

    @property
    def version(self) -> str:
        return self._version

    @property
    def inputs(self):
        return self._metadata.inputs

    @property
    def outputs(self):
        return self._metadata.outputs

    @property
    def backend(self):
        return self._metadata.platform

    def __str__(self):
        input_sig = tuple(x.name for x in self.inputs)
        output_sig = tuple(x.name for x in self.outputs)
        return (f'Name: {self.name}[{self.version}]\n'
                f'Inputs: {input_sig}\n'
                f'Outputs: {output_sig}\n'
                f'Backend: {self.backend}')

    def _set_inputs(self, *args, **kwargs):
        if len(args) > 0 and len(kwargs) > 0:
            raise RuntimeError("Cannot specify args, and kwargs at the same time")
        if len(args) == 0 and len(kwargs) == 0:
            raise RuntimeError("At least one input needs to be specified. Got none.")

        if len(args) > 0:
            if len(args) != len(self._infer_inputs):
                raise RuntimeError("Expect {} inputs got {}".format(len(self._infer_inputs), len(args)))
            for placeholder, value in zip(self._infer_inputs, args):
                placeholder.set_shape(value.shape)
                placeholder.set_data_from_numpy(value)
        else:
            if len(kwargs) != len(self._infer_inputs):
                raise RuntimeError("Expect {} inputs got {}".format(len(self._infer_inputs), len(kwargs)))
            for placeholder in self._infer_inputs:
                value = kwargs[placeholder.name]
                placeholder.set_shape(value.shape)
                placeholder.set_data_from_numpy(value)

    def __call__(self, *args, **kwargs) -> Union[np.ndarray, Tuple[np.ndarray, ...]]:
        self._set_inputs(*args, **kwargs)
        response = self._client.infer(
            model_name=self.name,
            inputs=self._infer_inputs,
            model_version=self.version)
        outputs = tuple(response.as_numpy(o.name) for o in self.outputs)
        return outputs
