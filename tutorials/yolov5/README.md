# Deploy YOLOv5 with OctoML to Docker Desktop

 1. [Introduction](#introduction)
 1. [Benefits of deploying YOLOv5 with OctoML](#benefits-of-deploying-yolov5-with-octoml)
 1. [Select your YOLOv5 candidate model](#select-your-yolov5-candidate-model)
 1. [Install Docker Desktop](#install-docker-desktop)
 1. [Create Client Code Container](#create-client-code-container)
 1. [Clone YOLOv5 repo, install requirements and export model](#clone-yolov5-repo-install-requirements-and-export-model)
 1. [Run OctoML CLI to package and deploy YOLOv5](#run-octoml-cli-to-package-and-deploy-yolov5)
 1. [Verify Triton and networking config](#verify-triton-and-networking-config)
 1. [Run Inference to Triton in OctoML model container](#run-inference-to-triton-in-octoml-container)
 
## Introduction

This follow-along tutorial is designed to help you quickly get YOLOv5 computer
vision models deployed to your local computer for inference. Below you’ll be
introduced to the [OctoML CLI](https://try.octoml.ai/cli/), a free command line
utility that packages machine learning models into deployable Docker containers
with NVIDIA Triton Inference Server. When you’re ready to deploy to production,
OctoML CLI can also be used to accelerate and deploy YOLOv5 to over 100 instance
types in AWS, Azure and GCP.

Here is the architecture of what we will be building. Your local machine will
run the OctoML CLI and Docker Desktop with two containers. The first container
will run client code to pre-process the image, request inference from Triton
Inference Server (running in a different container) and run post-processing to
embed the bounding boxes for object detection onto your original image. We will
be creating this client code container manually. The second container will be
created with OctoML CLI automatically and will host your chosen YOLOv5 model and
Triton.

![image1](images/image1.png)
