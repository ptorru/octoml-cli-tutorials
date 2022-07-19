# Demos

The end-to-end demos in this directory will walk you through:

- ML model container generation using the `octoml` CLI
- Local container deployment and inference via Docker
- Remote container deployment and inference via Amazon Elastic Kubernetes Service (EKS) and Google Kubernetes Engine (GKE)
- Accelerating a model to save on cloud costs by connecting to the OctoML platform

Three example model setups are provided for you to explore:

```
- vision/                 -- A classification vision model in ONNX, that detects whether your cat is trying to bring prey into the house
- question_answering/     -- BERT in ONNX, using the HuggingFace transformers library for pre- and post-processing
- generation/             -- GPT2 in ONNX, calling into the HuggingFace transformers library for generation at runtime
```

## Getting started

1. Make sure you've followed all the steps to [download the OctoML CLI](https://github.com/octoml/octoml-cli-tutorials#getting-started).

2. Verify you have Python3 installed:

```shell
$ python --version
Python 3.8.4
```
> Note: Python3.10 users (e.g. Ubuntu Jammy), see [instructions for Python3.10](https://github.com/octoml/octoml-cli-tutorials/tree/main/tutorials/vision#note-on-python310).

3. Clone the tutorials repo:

```shell
git clone https://github.com/octoml/octoml-cli-tutorials
cd octoml-cli-tutorials
cd tutorials
```

4. (Recommended) Set up a Python virtual environment:

```shell
python -m venv venv
source venv/bin/activate
```

5. Run setup utility to install the Python dependencies:

```shell
./setup.sh
```

6. Navigate to the vision directory:
```
$ cd vision
$ ls
cat_input_images/  critterblock.onnx  octoml.yaml  run.py
```
> Note: These steps can be completed with any of the example model dirs provided. Here we have decided to `cd` into the `vision` dir. 

## Local inference without a container

Before deploying this model to a production-scale microservice, let's make sure we can run a single inference locally on our model:

```
$ python3 run.py --local

Cat score: 1.000
Approach score: 1.000
Prey score: 0.999
--------------------------------------
```

The `critterblock.onnx` model is a Computer Vision (Resnet50-based) model customized for a cat door; the door locks when it detects that a cat is carrying its prey into the house. In `run.py`, we pass in a sample image to the model, run image preprocessing code customized for this use case, run an inference using ONNX Runtime, and finally call image post-processing code on the results of the model. In this case, the script returns a cat score of 1, approach score of 1, and prey score of 0.999 on this image, which means the model correctly detected that a cat is approaching the cat door while holding its prey.


## Generate production-scale deployment using the OctoML CLI

Now that we've confirmed the model is working as intended, let's prepare it for production-scale usage (in this case, so that we can protect thousands of cloud-connected cat doors). We will deploy the package locally using the OctoML CLI without having to upload our models to the OctoML platform.

The `octoml.yaml` file has been created for you already:

```
$ cat octoml.yaml
---
models:
  critterblock:
    path: critterblock.onnx
```

1. Use `octoml.yaml` to generate a Docker image and start a Docker container running Triton -- this will deploy a Docker container locally on your machine.

> Note: This will pull down a base image that is 12+ GB. Ensure you have enough disk space for this operation.

2. Run `octoml deploy`:
  ```
$ octoml deploy
 ∙∙∙ Models imported
 ∙∙∙ Packages generated
 ∙∙∙ Docker image assembled
 ∙∙∙ Triton image built
 ∙∙∙ 🐳 Triton container started

A docker container with a triton inference server is now running on your local
machine. For more information about how to interact with your model, please
refer to our tutorials and guides on GitHub.

https://github.com/octoml/octoml-cli-tutorials
```
3. Verify that a Docker container has been spun up successfully by running `docker ps`:

```
$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED      STATUS      PORTS                              NAMES
7182ac8ee475   a85ac5657dc0   "/opt/tritonserver/n…"   3 days ago   Up 3 days   0.0.0.0:8000-8002->8000-8002/tcp   vengeful-coach
```

## Confirm that we can run inferences on the container locally.

By default, the running Docker container exposes a GRPC endpoint at port 8001. The
following invocation will run the client code for sending a sample inference request
to that default port. `run.py` contains client code for the deployed Docker container:

```
$ python3 run.py --triton

Cat score: 1.000
Approach score: 1.000
Prey score: 0.999
--------------------------------------
```

Again, we see a cat score of 1, approach score of 1, and prey score of 0.999 on our sample image. This means our containerized model is working as intended.

## Kubernetes Deployment

Now that we have a production-grade container ready for deployment, let's deploy the container to a Kubernetes cluster using Google GKE, Amazon EKS, and Azure AKS.

Navigate one level back up to the tutorials repo: 

```shell
$ cd ..
$ ls
README.md  deploy_to_eks.sh  generation  helm_chart  question_answering  requirements.txt  setup-cloud.sh  setup.sh  vision
```

### Using Amazon EKS

If you don't already have an EKS cluster set up, follow the guides from AWS to set one up, or optionally use Terraform:

- [Getting started with Amazon EKS – eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)
- [Getting started with Amazon EKS – AWS Management Console and AWS CLI](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html)
- [Provision an EKS Cluster (AWS)](https://learn.hashicorp.com/tutorials/terraform/eks?in=terraform/kubernetes)

The script we will use to deploy to the cluster requires us to install `kubectl` and `helm`, plus the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html). 
1. Run `setup-cloud.sh` to install the necessary cloud utilities:

```
./setup-cloud.sh aws
```

2. Set up the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) and test by listing EKS clusters:

```
aws eks list-clusters --profile $aws_profile --region $aws_region
```

3. Fill in these bash variables for the arguments we will pass to the deploy script:

```
model_name=
aws_profile=
docker_image_tag=
aws_registry_url=
cluster_name=
aws_region=
```

For example:

```
model_name=critterblock
aws_profile=1234567890_Sandbox-Developer
docker_image_tag=v5
aws_registry_url=1234567890.dkr.ecr.us-west-2.amazonaws.com
cluster_name=test-cluster
aws_region=us-west-2
```

4. Run the `deploy_to_eks.sh` script to create an ECR repository, push your image to it, and configure kubectl to connect to your cluster:

```
./deploy_to_eks.sh $model_name $aws_profile $docker_image_tag $aws_registry_url $cluster_name $aws_region

```

5. Check the status of the helm deployment:

```
helm list -n ${model_name}
```

### Using Azure AKS

If you don't already have an AKS cluster set up, follow the guides from Azure to set one up, or optionally use Terraform:

- [Quickstart: Deploy an Azure Kubernetes Service cluster using the Azure CLI](https://docs.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal#create-an-aks-cluster)
- [Provision an AKS Cluster (Azure)](https://learn.hashicorp.com/tutorials/terraform/aks?in=terraform/kubernetes)

The script we will use to deploy to the cluster requires us to install `kubectl` and `helm`, plus the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli). 
1. Run `setup-cloud.sh` to install the necessary cloud utilities:

```
./setup-cloud.sh azure
```

2. Set up the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli) and test by listing AKS clusters:

```
az aks list --subscription $azure_subscription_id
```

3. Fill in these bash variables for the arguments we will pass to the deploy script:

```
model_name=
azure_subscription_id=
docker_image_tag=
cluster_name=
resource_group_name=
```

For example:

```
model_name=critterblock
azure_subscription_id=aaae7ed9-5144-4602-94da-680cc5e5096f
docker_image_tag=v5
cluster_name=test-cluster
resource_group_name=test-cluster_group
```

4. Run the `deploy_to_aks.sh` script to create an artifact repository, push your image to it, and configure kubectl to connect to your cluster:

```
./deploy_to_aks.sh $model_name $azure_subscription_id $docker_image_tag $cluster_name $resource_group_name

```

5. Check the status of the helm deployment:

```
helm list -n ${model_name}
```

### Using Google GKE

If you don't already have a GKE cluster set up, follow the guide from GCP to set one up, or optionally use Terraform:

- [GKE Quickstart: Create a GKE Cluster](https://cloud.google.com/kubernetes-engine/docs/deploy-app-cluster#create_cluster)
- [Provision a GKE Cluster (Google Cloud)](https://learn.hashicorp.com/tutorials/terraform/gke?in=terraform/kubernetes)

In order to push your image to Artifact Registry, make sure that the [Artifact Registry API](https://cloud.google.com/artifact-registry/docs/docker/store-docker-container-images#before-you-begin) is enabled for your project.

The script we will use to deploy to the cluster requires us to install `kubectl` and `helm`, plus the [gcloud CLI](https://cloud.google.com/sdk/docs/initializing). 
1. Run `setup-cloud.sh` to install the necessary cloud utilities:

```
./setup-cloud.sh gcloud
```

2. Set up the [gcloud CLI](https://cloud.google.com/sdk/docs/initializing) and test by listing gke clusters:

```
gcloud container clusters list
```

3. Fill in these bash variables for the arguments we will pass to the deploy script:

```
model_name=
gcp_project_id=
docker_image_tag=
cluster_name=
gcp_region=
```

For example:

```
model_name=critterblock
gcp_project_id=test-project-12345
docker_image_tag=v5
cluster_name=test-cluster
gcp_region=us-central1
```

4. Run the `deploy_to_gke.sh` script to create an artifact repository, push your image to it, and configure kubectl to connect to your cluster:

```
./deploy_to_gke.sh $model_name $gcp_project_id $docker_image_tag $cluster_name $gcp_region

```

5. Check the status of the helm deployment:

```
helm list -n ${model_name}
```

## Inference on Cloud

Finally, run inferences on the container deployed to the cluster.

1. Once the helm deploy completes, port-forward the EKS deployment's triton GRPC endpoint to localhost:

```
kubectl port-forward service/${model_name} -n ${model_name} 8080:8001
```

2. Run inference:

```
python run.py --triton --port 8080
```

To run inference with the http endpoint, port-forward the HTTP endpoint instead:

```
kubectl port-forward service/${model_name} -n ${model_name} 8080:8000
```

And run inference with http:

```
python run.py --triton --protocol http --port 8080
```


3. (Optional) To clean up the environment or to try other live demos on EKS, stop the port-forward script and run:

```
helm uninstall ${model_name} -n ${model_name}
```

## Metrics
Prometheus metrics from the Triton server are exposed on `localhost:8002/metrics` by default. How metrics are scraped will depend on how you are operating your Prometheus server.

If you are using the Prometheus Operator, a ServiceMonitor resource can be configured by setting the following values:
```
prometheus:
  enabled: true
  serviceMonitor:
    enabled: true
```

> NOTE: By default, the Prometheus ServiceMonitor resource will be created in the same namespace as the OctoML deployment. To change this behavior, set the `prometheus.serviceMonitor.namespace` value to the namespace in which you wish to create the ServiceMonitor. The namespace must be an existing one, otherwise deployment will fail.

If you have Prometheus Kubernetes service discovery enabled on your server you can add annotations to allow Prometheus to scrape the pod by setting the following values:
```
prometheus:
  enabled: true
  serviceMonitor:
    enabled: false
```

### Troubleshooting

To check for Kubernetes deployment info, run:

```
kubectl get all -n ${model_name}
```

To get the logs for a failed pod deployment, run the above and modify the pod name in the following command:

```
kubectl logs pod/demo-6f45998bbb-6jnlq -n ${model_name}
```

## Accelerating your model on different hardware targets

To access advanced features like model acceleration, you will need to [sign up for an OctoML account](https://learn.octoml.ai/private-preview). Once you've submitted the signup form, you will receive an email within 1 business day with instructions on how to access the OctoML platform. Next, [generate an API access token](https://app.octoml.ai/account/settings) and call `octoml setup acceleration` to store your API access token in the CLI.

`octoml setup acceleration` is an interactive help wizard that not only prompts you for the API access token but also helps you populate the input configuration file (`octoml.yaml`) with other fields required for acceleration, including hardware and (for dynamically shaped models only) the model's input shapes.


```shell
$ octoml setup acceleration

Updated octoml.yaml with the new hardware targets aws_c5.12xlarge - Cascade Lake - 48 vCP
```


Now, you are ready to run accelerated packaging. This returns the best-performing package with minimal latency for each hardware you've selected, after exploring multiple acceleration strategies including TVM, ONNX-RT, and the native training framework. We recommend running express mode acceleration as follows, which completes within 20 minutes. If you are willing to wait for several hours for potentially better latency, run `octoml package -a` for full acceleration mode. See the below table for differences.


```shell
$ octoml package -e
```

Now, verify that you've successfully built an accelerated container.

```shell
$ docker images | head
```

You can now push the local container to a remote container repository (e.g. ECR) per the instructions above, then run inferences against the container on a remote machine with an architecture matching the one you've accelerated the model for.

If you wish to locally deploy and test inferences against the accelerated container, you may run the following command, but note that it only works if the local machine on which you're running the CLI has the same hardware architecture as the hardware you accelerated the model for (e.g. if you are running the CLI on an M1 mac, you can only run deployment on your local mac successfully if you accelerated your model on a Graviton instance, as both of them share the ARM64 architecture).

```shell
$ octoml deploy -e
```

### Express Acceleration Mode and Full Acceleration Mode

The following table explains the difference between the two modes:


| Name | Express Acceleration Mode | Full Acceleration Mode |
|---|---|---|
| Time   | 20 Minutes  | Several Hours |
| Command | `octoml package -e` | `octoml package -a` |
| Purpose | Most performant package out of all optimizations attempted within 20 minutes |  Most performant package out of full optimizations attempted over several hours |

### Troubleshooting

For Torchscript models traced on a GPU, containers will not be able to be run on CPUs in the local CLI. Please [sign up for an OctoML account](https://learn.octoml.ai/private-preview) and upgrade to authenticated usage per the instructions above if this use case is applicable for you.
