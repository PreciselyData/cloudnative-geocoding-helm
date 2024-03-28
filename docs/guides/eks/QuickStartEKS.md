# Installing Geo-Addressing Helm Chart on AWS EKS

## Step 1: Prepare your environment

To deploy the Geo-Addressing application in AWS EKS, install the following client tools:

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm3](https://helm.sh/docs/intro/install/)

##### Amazon Elastic Kubernetes Service (EKS)

- [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)

## Step 2: Create the EKS Cluster

You can create the EKS cluster or use existing EKS cluster.

- If you DON'T have EKS cluster, we have provided you with a
  sample [cluster installation script](../../../cluster-sample/create-eks-cluster.yaml). Run the following command from
  parent directory to create the cluster using the script:
    ```shell
    eksctl create cluster -f ./cluster-sample/create-eks-cluster.yaml
    ```

- If you already have an EKS cluster, make sure you have following addons or plugins related to it, installed on the
  cluster:
    ```yaml
    addons:
    - name: vpc-cni
    - name: coredns
    - name: kube-proxy
    - name: aws-efs-csi-driver
    ```
  Run the following command to install addons only:
    ```shell
    aws eks --region [aws-region] update-kubeconfig --name [cluster-name]
    
    eksctl create addon -f ./cluster-sample/create-eks-cluster.yaml
    ```
- Once you create EKS cluster, you can
  apply [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) so that the
  cluster can be scaled vertically as per requirements. We have provided a sample cluster autoscaler script. Please run
  the following command to create cluster autoscaler:
    ```shell
    kubectl apply -f ./cluster-sample/cluster-auto-scaler.yaml
    ```
- To enable [HorizontalPodAutoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/), the
  cluster also needs a [Metrics API Server](https://github.com/kubernetes-sigs/metrics-server) for capturing cluster
  metrics. Run the following command for installing Metrics API Server:
    ```shell
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    ```
- The geo-addressing service requires ingress controller setup. Run the following command for setting up NGINX ingress controller:
  ```shell
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm install nginx-ingress ingress-nginx/ingress-nginx -f ./cluster-sample/ingress-values.yaml
  ```
  *Note: You can update the nodeSelector according to your cluster's ingress node.*

  Once ingress controller setup is completed, you can verify the status and get the ingress URL by using the following command:
  ```shell
  kubectl get services -o wide -w nginx-ingress-ingress-nginx-controller    
  ```

**NOTE**: EKS cluster must have the above addons and ingress for the east of installation of Geo-Addressing Helm Chart.

## Step 3: Download Geo-Addressing Docker Images

The docker files can be downloaded from Precisely's Data Portfolio. For information about Precisely's data portfolio,
see the [Precisely Data Guide](https://dataguide.precisely.com/) where you can also sign up for a free account and
access softwares, reference data and docker files available in [Precisely Data Experience](https://data.precisely.com/).

This projects assumes the docker images to be present in the ECR. However, if you haven't pushed the required docker
images in the ECR, we have provided you with the sample scripts to download the docker images
from [Precisely Data Experience](https://data.precisely.com/)
and push it to your Elastic Container Repositories.

(Note: This script requires python, docker and awscli to be installed in your system)

```shell
cd ./scripts/images-to-ecr-uploader
pip install -r requirements.txt
python upload_ecr.py --pdx-api-key [pdx-api-key] --pdx-api-secret [pdx-secret] --aws-access-key [aws-access-key] --aws-secret [aws-secret] --aws-region [aws-region]
```

There are four docker container images which will be pushed to ECR with the tag of helm chart version.

1. regional-addressing-service
2. addressing-service
3. express-engine
4. express-engine-data-restore

For more details related to docker images download script, follow the
instructions [here](../../../scripts/images-to-ecr-uploader/README.md)

## Step 4: Create Elastic File System (EFS)

The Geo-Addressing Application requires reference data for geo-addressing capabilities. This reference data should be
deployed using [persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). This persistent
volume is backed by Amazon Elastic File System (EFS) so that the data is ready to use immediately when the volume is
mounted to the pods.

We have provided python script to create EFS and link it to EKS cluster, or directly link existing EFS to the EKS cluster by creating mount targets.

**NOTE: If you already have created mount targets for the EFS to EKS cluster, skip this step.**

- If you DON'T have existing EFS, run the following commands:
  ```shell
  cd ./scripts/efs-creator
  pip install -r requirements.txt
  python ./create_efs.py --cluster-name [eks-cluster-name] --aws-access-key [aws-access-key] --aws-secret [aws-secret] --aws-region [aws-region] --efs-name [precisely-geo-addressing-efs] --security-group-name [precisely-geo-addressing-sg]
  ```

- If you already have EFS, but you want to create mount targets so that EFS can be accessed from the EKS cluster, run the following command:
  ```shell
  cd ../scripts/efs-creator
  pip install -r requirements.txt
  python ./create_efs.py --cluster-name [eks-cluster-name] --existing true --aws-access-key [aws-access-key] --aws-secret [aws-secret-key] --aws-region [aws-region] --file-system-id [file-system-id]
  ```

## Step 5: Installation of Reference Data

The Geo-Addressing Application relies on reference data for performing geo-addressing operations. For more information related to reference data, please refer to [this link](../../ReferenceData.md).


You can make use of a [miscellaneous helm chart for installing reference data](../../../charts/reference-data-setup/README.md), please follow the instructions mentioned in the helm chart or run the below command for installing data in EFS or contact Precisely Sales Team for the reference data installation.
```shell
helm install reference-data ./charts/reference-data-setup/ \
--set "global.pdxApiKey=[your-pdx-key]" \
--set "global.pdxSecret=[your-pdx-secret]" \
--set "global.efs.fileSystemId=[fileSystemId]" \
--set "dataDownload.image.repository=[reference-data-image-repository]" \
--dependency-update --timeout 60m
```

## Step 6: Installation of Geo-Addressing Helm Chart

> NOTE: For every helm chart version update, make sure you run the [Step 3](#step-3-download-geo-addressing-docker-images) for uploading the docker images with the newest tag.

To install/upgrade the geo-addressing helm chart, use the following command:

```shell
helm upgrade --install geo-addressing ./charts/geo-addressing \
--dependency-update \
--set "global.awsRegion=[aws-region]" \ 
--set "global.efs.fileSystemId=[file-system-id]" \
--set "ingress.hosts[0].host=[ingress-host-name]" \ 
--set "ingress.hosts[0].paths[0].path=/precisely/addressing" \
--set "ingress.hosts[0].paths[0].pathType=ImplementationSpecific" \
--set "global.nodeSelector.node-app=[node-selector-label]" \
--set "image.repository=[aws-account-id].dkr.ecr.[aws-region].amazonaws.com/regional-addressing-service" \
--set "global.addressingImage.repository=[aws-account-id].dkr.ecr.[aws-region].amazonaws.com/addressing-service" \
--set "global.expressEngineImage.repository=[aws-account-id].dkr.ecr.[aws-region].amazonaws.com/express-engine" \
--set "global.expressEngineDataRestoreImage.repository=[aws-account-id].dkr.ecr.[aws-region].amazonaws.com/express-engine-data-restore" \
--set "addressing-express.expressenginedata.nodeSelector.node-app=[node-selector-label-arm64-node]" \
--set "addressing-express.expressenginemaster.nodeSelector.node-app=[node-selector-label-arm64-node]" \ 
--set "addressing-express.expressEngineDataRestore.nodeSelector.node-app=[node-selector-label-arm64-node]" \
--set "global.countries={usa,can,aus,nzl}" \
--namespace geo-addressing --create-namespace
```

By default, only verify/geocode functionality is enabled.

> Note: addressing-express service is needed for Geocoding without country.

To enable other functionalities like autocomplete, lookup and
reverse-geocode you have to set the parameters in helm command as follows.

```shell
--set "autocomplete-svc.enabled=true"
--set "lookup-svc.enabled=true"
--set "reverse-svc.enabled=true"
```
> NOTE: By default, the geo-addressing helm chart runs a hook job, which identifies the latest reference-data vintage mount path.
> 
> To override this behaviour, you can disable the addressing-hook by `addressing-hook.enabled` and provide manual reference data configuration using `global.manualDataConfig`.
> 
> Refer [helm values](../../../charts/geo-addressing/README.md#helm-values) for the parameters related to `global.manualDataConfig.*` and `addressing-hook.*`.
> 
>
> NOTE: `addressing-hook` job not applicable to addressing-express service.
>
> Also, for more information, refer to the comments in [values.yaml](../../../charts/geo-addressing/values.yaml)
#### Mandatory Parameters

* ``global.awsRegion``: AWS Region
* ``global.efs.fileSystemId``: The ID of the EFS
* ``global.countries``: Required countries for Geo-Addressing (e.g. ``--set "global.countries={usa,deu,gbr}"``).
  Provide a comma separated list to enable a particular set of countries from: `{usa,gbr,deu,aus,fra,can,mex,bra,arg,rus,ind,sgp,nzl,jpn,world}`
* ``ingress.hosts[0].host``: The Host name of Ingress e.g. http://aab329b2d767544.us-east-1.elb.amazonaws.com
* ``ingress.hosts[0].paths[0].path``: The PATH at which the solution to be hosted. (e.g. ``/precisely/addressing``)
* ``ingress.hosts[0].paths[0].pathType``: The pathType of the Ingress Path
* ``image.repository``: The ECR image repository for the regional-addressing image
* ``global.addressingImage.repository``: The ECR image repository for the addressing-service image
* ``global.expressEngineImage.repository``: The ECR image repository for the express-engine image
* ``global.expressEngineDataRestoreImage.repository``: The ECR image repository for the express-engine-data-restore image
* ``global.nodeSelector``: The node selector to run the geo-addressing solutions on nodes of the cluster. Should be a amd64 based Node group.
* ``addressing-express.expressEngineDataRestore.nodeSelector``: The node selector to run the express-engine data restore job. Should be a arm64 based Node group.
* ``addressing-express.expressenginedata.nodeSelector``: The node selector to run the express-engine data service. Should be a arm64 based Node group.
* ``addressing-express.expressenginemaster.nodeSelector``: The node selector to run the express-engine master service. Should be a arm64 based Node group.

For more information on helm values, follow [this link](../../../charts/geo-addressing/README.md#helm-values).

## Step 7: Monitoring Geo-Addressing Helm Chart Installation

Once you run the geo-addressing helm install/upgrade command, it might take a couple of seconds to trigger the deployment. You can run the following command to check the creation of pods. Please wait until all the pods are in running state:
```shell
kubectl get pods -w --namespace geo-addressing
```

When all the pods are up, you can run the following command to check the ingress service host:
```shell
kubectl get services --namespace geo-addressing
```

## Next Sections
- [Geo Addressing API Usage](../../../charts/geo-addressing/README.md#geo-addressing-service-api-usage)
- [Metrics, Traces and Dashboard](../../MetricsAndTraces.md)
- [FAQs](../../faq/FAQs.md)


[🔗 Return to `Table of Contents` 🔗](../../../README.md#guides)
