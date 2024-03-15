# Download and Upload Docker Images to ECR

## Description

The geo-addressing helm chart relies on the availability of Docker images for several essential microservices, all of
which are conveniently obtainable from Precisely Data Experience. The required docker images include:

1. Regional Addressing Service Docker Image
2. Addressing Service Docker Image
3. Express Engine Docker Image
4. Express Engine Data Restore Docker Image

> [!NOTE]:  
> Contact Precisely for buying subscription to docker image
>

Once you have purchased a subscription to Precisely Data Experience (PDX), you can directly download Docker images.
Afterward, you can easily load these Docker images into your Docker environment.

Additionally, this repository includes a script that facilitates the download of Docker image zips from PDX and their
subsequent upload to AWS ECR.

Please note that this project assumes the presence of Python, Docker, and awscli on your system.

## Step 1 - Install Requirements

Run the following command to install requirements:

```console
pip install -r ./requirements.txt
```

## Step 2: Run Script for Uploading to ECR

The following command downloads the docker images from PDX and uploads it to your Elastic Container Registry.

> [!NOTE]:
> You need to have docker running locally for this script to work.
>

```console
python upload_ecr.py --pdx-api-key [pdx-api-key] --pdx-api-secret [pdx-secret] --aws-access-key [aws-access-key] --aws-secret [aws-secret] --aws-region [aws-region]
```
[🔗 Return to `Table of Contents` 🔗](../../README.md#components)