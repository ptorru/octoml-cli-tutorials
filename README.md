# OctoML CLI

The `octoml` CLI helps you create deployable containers for your ML models using the OctoML Platform, in the terminal or within your CI/CD pipeline.
You can [deploy and run](https://github.com/octoml/octoml-cli-tutorials/tree/main/tutorials#demos) inferences on the container locally for development and testing, then deploy the same container to the cloud.

By use of this CLI application, you agree to OctoML’s [Terms of Service](https://octoml.ai/legals/terms-of-service/) and [Privacy Policy](https://octoml.ai/legals/privacy-policy/).

![OctoML CLI Example](https://www.datocms-assets.com/45680/1652749860-octoml_cli.gif)

## Getting started

1. To get started all you need to do is download the latest version of the OctoML CLI from [here](https://try.octoml.ai/cli/).

2. Once you have the tool you should be able to view the list of available commands by running `./octoml` in your current directory.

3. Now move the binary to an appropriate location like `/usr/local/bin` by running the following command in your current directory: `mv octoml /usr/local/bin`

4. Verify the `octoml` command works and accept the TOS if needed:

```shell
$ octoml -V
By use of this CLI application, you agree to OctoML’s terms of use and privacy policy.
https://octoml.ai/legals/terms-of-service/
https://octoml.ai/legals/privacy-policy/
? Do you wish to continue? · yes
octoml 0.4.2 (8f3bfbd 2022-06-09 23:11:41)

$ octoml -V
octoml 0.4.2 (8f3bfbd 2022-06-09 23:11:41)
```

5. Ensure you have a Docker daemon installed and up running, by running `docker ps`. If the command is not found, you need to install Docker: see [here](https://runnable.com/docker/install-docker-on-macos) for MacOS, here for [Linux](https://docs.rapidminer.com/9.6/deployment/overview/install-docker-on-linux.html), and here for [Windows](https://docs.rapidminer.com/9.6/deployment/overview/install-docker-on-windows.html).

6. Now you have two choices: either immediately start deploying your own model by jumping to the [Core Commands section below](https://github.com/octoml/octoml-cli-tutorials#core-commands-to-deploy-your-own-model-using-our-cli), or follow one of our [examples](https://github.com/octoml/octoml-cli-tutorials/tree/main/tutorials#demos) in Vision, Question Answering, Text Generation to see an end-to-end user journey first.

**Model framework coverage**: 
We support TensorFlow SavedModel, TensorFlow GraphDef, Torchcript (PyTorch), and ONNX models.

**Hardware coverage**: 
You may run our CLI on x86, CUDA machines, and ARM64 machines (including M1 Macs). In unauthenticated usage, the containers built via the CLI may only be deployed on hardware architectures matching the local machine on which you ran `octoml package`. In authenticated usage, you may create accelerated model containers deployable to any x86, CUDA, and ARM64 remote cloud instance, even if that hardware architecture does not match that of your local machine on which you ran `octoml package`.

**OS coverage**: 
We support MacOS, Linux (Ubuntu 18.04+), and Windows. If you wish to use the CLI on Ubuntu 18.04, please ensure your protobuf version is on 3.19.4.

## Core commands to deploy your own model using our CLI

**Note: that you do not need to provide an OctoML API access token at this stage. If you run these commands without setting an OctoML API token beforehand, we do not upload your model to the OctoML platform.**

1. `octoml init`: This is the first command we recommend that you run. It helps you set up an input configuration file by prompting you for the information required for the CLI to generate a container for deployment.

2. `octoml package`: Builds a deployment-ready Docker container for the models specified in the input configuration file. The input configuration file is required for this command to complete successfully. The first time you ever run this command takes about 20 minutes because it downloads a 12GB base image; future runs will be nearly instantaneous because the base image will be cached.

3. `octoml deploy`: Deploys a Docker container to a locally hosted endpoint. After completion of this command, you may run `docker ps` to confirm the a container has been successfully generated for you.

4. To run inferences against the container, follow our [tutorials](https://github.com/octoml/octoml-cli-tutorials/tree/main/tutorials#demos) for examples on how to configure an appropriate `run.py` file for your specific model. `run.py` provides a standard schema on how to run inferences against the OctoML-deployed model, while requiring you to customize the pre- and post-processing code for your own model use case.

## Sign up for an OctoML account/ authenticate to access advanced features including model acceleration and benchmarking
OctoML combines state-of-the-art compiler technologies (TVM, ONNX-RT, and others) to give you the best-performing package for any model. To access OctoML's acceleration and benchmarking services, you will need to [sign up for an OctoML account](https://learn.octoml.ai/private-preview) and create an API token using the OctoML web UI.

5. `octoml setup acceleration`: Prompts you for information required for acceleration, including an OctoML API access token, hardware, and dynamic shape disambiguation. Populates the information into your input configuration file for downstream use in `octoml package` and `octoml deploy`. If you do not wish to do so, please make sure to configure your input configuration file manually with the requisite fields for acceleration before calling `octoml package -e` or `octoml package -a`. **If you get stuck trying to select hardware, make sure to press the space button before the return button.**

6. `octoml package -e`: We recommend running acceleration in express mode, which completes within 20 minutes. If you are willing to wait for several hours for potentially better latency via a fuller exploration of the optimization space, run `octoml package -a` for full acceleration mode. Both modes return the best-performing package with minimal latency for each hardware you've selected, after exploring multiple acceleration strategies including TVM, ONNX-RT, and the native training framework. After this step we recommend that you directly send this built container to a remote cloud repository for downstream remote usage.

(Optional) `octoml deploy -a` or `octoml deploy -e`: Only run this command if you're on hardware with an architecture matching the cloud instance for which you have accelerated the model. If you previously ran `package` on more than one hardware target, make sure to call `deploy` with a specific hardware input.

## Deploying OctoML packages to production-grade microservices and applications

See the [tutorials](https://github.com/octoml/octoml-cli-tutorials/tree/main/tutorials#demos) folder for how to deploy OctoML model containers to downstream cloud registries like ECR and Kubernetes services like EKS.

## Telemetry

OctoML by default collects telemetry on your usage of the CLI. However, we do not collect your specific model unless you decide to sign up for access to the OctoML platform and submit your OctoML API access token.

The first time you run the CLI's `octoml init` command, you will get prompted on whether you'd like to opt out of telemetry. You can also decide to opt out of telemetry anytime by setting the following environment variable: `export OCTOML_TELEMETRY=false`.
