# OctoML CLI

The `octoml` CLI helps you create deployable containers for your ML models using the OctoML Platform, the terminal or within your CI/CD pipeline.
You can run inferences on the container locally for development and testing, then deploy the same container to the cloud.

![OctoML CLI Example](https://www.datocms-assets.com/45680/1652749860-octoml_cli.gif)

## Getting started

1. Download the latest version of the OctoML CLI:

* [Mac](https://downloads.octoml.ai/octoml_macOS_v0.7.3.zip): Due to MacOS's security setup, you'll need to confirm in your browser that you'd like to retain the downloaded file, go to Finder to unzip the file, right-click on the `octoml` executable, and then click Open With -> Terminal -> Open.
* [Linux](https://downloads.octoml.ai/octoml_ubuntu_v0.7.3.tar.gz)
* [Windows](https://downloads.octoml.ai/octoml_v0.7.3.zip)

2. Check out the list of available commands by running `./octoml` in your current directory.

3. Move the binary to an appropriate location like `/usr/local/bin` by running `mv octoml /usr/local/bin` in your current directory.

4. Verify the `octoml` command works and accept OctoML's [Terms of Use](https://octoml.ai/legals/terms-of-service/) and [Privacy Policy](https://octoml.ai/legals/privacy-policy/):

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

5. Ensure you have a Docker daemon installed, by running `docker ps`. If the command is not found, install Docker for [Mac OS](https://runnable.com/docker/install-docker-on-macos), [Linux](https://docs.rapidminer.com/9.6/deployment/overview/install-docker-on-linux.html), or [Windows](https://docs.rapidminer.com/9.6/deployment/overview/install-docker-on-windows.html).

6. Begin deploying your own model by jumping to the [Core Commands](https://github.com/octoml/octoml-cli-tutorials#core-commands-to-deploy-your-own-model-using-our-cli) section below, or follow one of our [demos](https://github.com/octoml/octoml-cli-tutorials/tree/main/tutorials#demos) in Vision, Question Answering, or Text Generation to see an end-to-end user journey first.

**Model framework coverage**: 
We support TensorFlow SavedModel, TensorFlow GraphDef, Torchcript (PyTorch), and ONNX models.

**Hardware coverage**: 
You may run our CLI on x86, CUDA machines, and ARM64 machines (including M1 Macs). In unauthenticated usage, the containers built via the CLI may only be deployed on hardware architectures matching the local machine on which you ran  
`octoml package`. In authenticated usage, you may create accelerated model containers deployable to any x86, CUDA, and ARM64 remote cloud instance, even if that hardware architecture does not match that of your local machine on which you ran `octoml package`.

**OS coverage**: 
We support MacOS, Linux (Ubuntu 18.04+), and Windows. If you wish to use the CLI on Ubuntu 18.04, please ensure your protobuf version is on 3.19.4.

## Core commands to deploy your model

> Note: You do not need to provide an OctoML API access token at this stage. If you run these commands without setting an OctoML API access token beforehand, we do not upload your model to the OctoML platform.

1. `octoml config`: This is the first command we recommend that you run. It helps you initialize your CLI settings.

2. `octoml add --model`: Next, this command will generate an input configuration file by prompting you for the information required for the CLI to generate a container for deployment.

2. `octoml package`: Packages the models specified in the input configuration file into a Docker tarball that's ready to be built into an image on any machine that has Docker installed. The input configuration file is required for this command to complete successfully.

3. `octoml build`: Builds a deployment-ready Docker image from the specified tarball(s). This may require a base image that ranges from 0.4-3.5GB in size, the downloading of which may take a few minutes; future runs will be nearly instantaneous because the base image will be cached.

4. `octoml deploy`: Deploys a Docker container to a locally hosted endpoint. After completion of this command, you may run `docker ps` to confirm the container has been successfully generated for you.

5. To run inferences against the container, follow our [demos](https://github.com/octoml/octoml-cli-tutorials/tree/main/tutorials#demos) to configure an appropriate `run.py` file for your specific model. `run.py` provides a standard schema on how to run inferences against the OctoML-deployed model, while requiring you to customize the pre- and post-processing code for your own model use case.

> **_n.b.:_** In the demos linked above, you may see mention of the `-s` or `--stream` flag. This flag is useful when you want to chain two or three core commands together in order to package a model, build an image, and/or deploy a container all in one go. Use of `-s` is independent of any other flags; in other words, you can use it with acceleration (`-a` or `-x`) as well.

## Get access to model acceleration and benchmarking
OctoML combines state-of-the-art compiler technologies (TVM, ONNX-RT, and others) to give you the best-performing package for any model. To access OctoML's acceleration and benchmarking services, you will need to [sign up for an OctoML account](https://learn.octoml.ai/private-preview) after which you can [generate an API access token](https://app.octoml.ai/account/settings).

1. `octoml add --hardware`: Prompts you for the desired hardware target(s) for acceleration from a list of those available to you. This command requires you to have already configured your API access token. Populates the information into your input configuration file for downstream use in `octoml package`. If you choose not to run `octoml add --hardware`, make sure to configure your input configuration file manually with the requisite fields for acceleration before calling `octoml package -a` or `octoml package -x`.

2. `octoml package -a`: To start off, we recommend running acceleration in our basic mode, which completes within 20 minutes. If you are willing to wait for up to several hours for potentially better latency via a fuller exploration of the optimization space, run `octoml package -x`. Both modes return the best-performing package with minimal latency for each hardware you've selected, after exploring multiple acceleration strategies including TVM, ONNX-RT, and the native training framework. After this step we recommend that you send this built container to a remote cloud repository for downstream remote usage.

3. (Optional) `octoml deploy`: Only run this command for an image with acceleration if you're on hardware with an architecture matching the cloud instance for which you have accelerated the model. Make sure to call `deploy` with the name of a specific hardware target for which the model was accelerated.

## Deploying an OctoML package

See [demos](https://github.com/octoml/octoml-cli-tutorials/tree/main/tutorials#demos) for examples showing how to deploy OctoML model containers to downstream cloud registries like ECR and Kubernetes services like EKS.

## Telemetry

OctoML by default collects telemetry on your usage of the CLI. However, we do not collect your model unless you submit an OctoML API access token.

The first time you run the CLI's `octoml config` command, you will get prompted on whether you'd like to opt out of telemetry. You can opt out of telemetry anytime by setting the following environment variable: `export OCTOML_TELEMETRY=false`.
