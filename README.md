# OctoML CLI

The `octoml` CLI helps you create deployable containers for your ML models using the OctoML Platform, the terminal or within your CI/CD pipeline.
You can run then deploy the same container to the cloud.

![OctoML CLI Example](https://www.datocms-assets.com/45680/1652749860-octoml_cli.gif)

## Getting started

By downloading and using the OctoML CLI, you agree to OctoML’s [Terms of Use](https://octoml.ai/legals/terms-of-service/) and [Privacy Policy](https://octoml.ai/legals/privacy-policy/).

1. Download the latest version of the OctoML CLI for your operating system:

| Operating System | Link |
| ---------------- | ----- |
| macOS            | [Installer](https://downloads.octoml.ai/octoml_macOS_v0.8.0.pkg) or [Standalone executable](https://downloads.octoml.ai/octoml_macOS_v0.8.0.zip) |
| Linux            | [Standalone executable](https://downloads.octoml.ai/octoml_ubuntu_v0.8.0.tar.gz) |
| Windows          | [Standalone executable](https://downloads.octoml.ai/octoml_v0.8.0.zip) |

2. If you downloaded the standalone executable, extract the archive and move the executable to an appropriate location like `/usr/local/bin`. Ideally, it should be in `PATH` so you can call it from anywhere in a shell. For example, you can move the executable to `/usr/local/bin` by running `mv octoml /usr/local/bin` in your current directory. If you used the macOS Installer, this step is done for you automatically.

3. Verify the `octoml` command works.

```shell
$ octoml -V
octoml 0.8.0 (commit hash, build date)
```

4. Check out the list of available commands by running `octoml`.

5. Ensure you have a Docker daemon installed, by running `docker ps`. If the command is not found, install Docker for [Mac OS](https://runnable.com/docker/install-docker-on-macos), [Linux](https://docs.rapidminer.com/9.6/deployment/overview/install-docker-on-linux.html), or [Windows](https://docs.rapidminer.com/9.6/deployment/overview/install-docker-on-windows.html).

6. Begin deploying your own model by jumping to the [Core Commands](https://github.com/octoml/octoml-cli-tutorials#core-commands-to-deploy-your-own-model-using-our-cli) section below, or follow one of our [demos](https://github.com/octoml/octoml-cli-tutorials/tree/main/tutorials#demos) in Vision, Question Answering, or Text Generation to see an end-to-end user journey first.

**Model framework coverage**: 
We support TensorFlow SavedModel, TensorFlow GraphDef, Torchcript (PyTorch), and ONNX models.

**Hardware coverage**: 
You may run our CLI on x86 or CUDA machines. If you are using macOS, ARM64 machines are also supported (including M1 and M2 machines). In unauthenticated usage, the containers built via the CLI may only be deployed on hardware architectures matching the local machine on which you ran  
`octoml package`. In authenticated usage, you may create accelerated model containers deployable to any x86, CUDA, and ARM64 remote cloud instance, even if that hardware architecture does not match that of your local machine on which you ran `octoml package`.

**OS coverage**: 
We support MacOS, Linux (Ubuntu 18.04+), and Windows. If you wish to use the CLI on Ubuntu 18.04, please ensure your protobuf version is on 3.19.4.

## Core commands to accelerate your model and build a deployable container

OctoML combines state-of-the-art compiler technologies (TVM, ONNX-RT, and others) to give you the best-performing package for any model. You will need to [sign up for an OctoML account](https://learn.octoml.ai/private-preview) after which you can [generate an API access token](https://app.octoml.ai/account/settings).

1. `octoml add --model`: This command will generate an input configuration file by prompting you for the information required for the CLI to generate a container for deployment.

2. Ensure `OCTOML_ACCESS_TOKEN` is present as an environment variable `export OCTOML_ACCESS_TOKEN=<access token obtained from the OctoML Platform>`. You can generate an API access token on the [OctoML Platform](https://app.octoml.ai/account/settings).

3.  `octoml add --hardware`: Prompts you for the desired hardware target(s) that are available to you for acceleration. This command populates the information into your input configuration file for downstream use in `octoml package`. If you choose not to run `octoml add --hardware`, make sure to configure your input configuration file manually with the requisite fields for acceleration before calling `octoml package -a` or `octoml package -x`.

4. `octoml package -a`: To start off, we recommend running acceleration in our basic mode, which completes within 20 minutes. If you are willing to wait for up to several hours for potentially better latency via a fuller exploration of the optimization space, run `octoml package -x`. Both modes return the best-performing package with minimal latency for each hardware you've selected, after exploring multiple acceleration strategies including TVM, ONNX-RT, and the native training framework. After this step we recommend that you send this built container to a remote cloud repository for downstream remote usage.

5. `octoml build`: Builds a deployment-ready Docker image from the specified tarball(s). This may require a base image that ranges from 0.4-3.5GB in size, the downloading of which may take a few minutes; future runs will be nearly instantaneous because the base image will be cached.

6. To run inferences against the container, follow our [demos](https://github.com/octoml/octoml-cli-tutorials/tree/main/tutorials#demos) to configure an appropriate `run.py` file for your specific model. `run.py` provides a standard schema on how to run inferences against the OctoML-deployed model, while requiring you to customize the pre- and post-processing code for your own model use case.

> **_n.b.:_** In the demos linked above, you may see mention of the `-s` or `--stream` flag. This flag is useful when you want to chain two or three core commands together in order to package a model and build an image all in one go. Use of `-s` is independent of any other flags; in other words, you can use it with acceleration (`-a` or `-x`) as well.

## Deploying an OctoML package

See [demos](https://github.com/octoml/octoml-cli-tutorials/tree/main/tutorials#demos) for examples showing how to deploy OctoML model containers to downstream cloud registries like ECR and Kubernetes services like EKS.

## Telemetry

OctoML by default collects telemetry on your usage of the CLI. However, we do not collect your model unless you submit an OctoML API access token.

To opt out of telemetry, set the following environment variable: `export OCTOML_TELEMETRY=false`.
