# Download and Upload Docker Images to ECR

## Description

This repo has a script which downloads the docker images zip from PDX and uploads it to AWS ECR.

This project assumes Python, Docker and awscli to be installed in the system.

## Running Locally

Install requirements:
```console
pip install -r ./requirements.txt
```

Run the command for creating efs and link it to a cluster:

```console
python upload_ecr.py --pdx-api-key [pdx-api-key] --pdx-api-secret [pdx-secret] --aws-access-key [aws-access-key] --aws-secret [aws-secret] --aws-region [aws-region]
```
