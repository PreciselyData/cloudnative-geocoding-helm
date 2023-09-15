# EFS Creator

## Description

This repo maintains codebase, dockerfile and instructions related to pushing efs-creator docker image.
<br>

## Running Locally

Install requirements:

```console
pip install -r ./requirements.txt
```

Run the command for creating efs and link it to a cluster:

```console
python ./create_efs.py --cluster-name [eks-cluster-name] --aws-access-key [aws-access-key] --aws-secret [aws-secret] --aws-region [aws-region] --efs-name [precisely-geo-addressing-efs] --security-group-name [precisely-geo-addressing-sg]
```

OR Run the following command if you want to link it to an existing cluster:

```console
python ./create_efs.py --cluster-name [eks-cluster-name] --existing true --aws-access-key [aws-access-key] --aws-secret [aws-secret-key] --aws-region [aws-region] --file-system-id [file-system-id]
```