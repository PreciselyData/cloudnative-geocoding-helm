# Installing Geo-Addressing Helm Chart on Azure Kubernetes Service

## Step 1: Before You Begin

To deploy the Geo-Addressing application in AKS, install the following client tools:

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm3](https://helm.sh/docs/intro/install/)
-

##### Azure Kubernetes Service (AKS)

- [az](https://learn.microsoft.com/en-us/cli/azure/)

The Geo-Addressing Helm Chart on Microsoft AKS requires access
to [Azure Files Storage](https://azure.microsoft.com/en-in/services/storage/files/), [Azure Container Registry (ACR)](https://azure.microsoft.com/en-us/services/container-registry/)
and [Azure Blob Storage](https://azure.microsoft.com/en-in/services/storage/blobs/). Azure Blob Storage is used to store
the reference datasets in .spd file format, and the ACR repository contains the Geo-Addressing Docker Images
which is used for the deployment.

Running the Geo-Addressing Helm Chart on AKS requires permissions on these Microsoft's Azure Cloud resources along with
some others listed below.

- `Contributor` role to create AKS cluster
- `Azure Blob Storage Reader`  role to download .spd files from Azure Blob Storage
- `Storage File Data SMB Share Contributor` role to read, write, and delete files from Azure Storage file shares over
  SMB/NFS

##### Authenticate to Azure using Azure Cli

Azure CLI supports multiple authentication methods; use any authentication method to sign in. For details about Microsoft
authentication types see their [documentation](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli).

  ```shell 
  az login 
  ``` 

If your Azure account has multiple subscription IDs then set one ID as default subscription ID, that will be used for
all `azure CLI` commands, otherwise you will have to provide this subscription ID in each command.

  ```shell
  az account set --subscription "@SUBSCRIPTION_ID@"
  ```

Configure your resource group, this will be used to create all resources-cluster and storage account, otherwise you
will have to provide it in each command.

  ```shell
  az configure --defaults group=@RESOURCE_GROUP@
  ```

## Step 2: Create the AKS Cluster

You can create the AKS cluster or use existing AKS cluster.

- If you DON'T have AKS cluster, we have provided you with few
  sample cluster installation commands. Run the following sample commands to create the cluster:
  > NOTE: You need to create an Azure Container Registry first before starting a cluster.
  Commands to create and maintain azure container registry are
  mentioned [here](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal?tabs=azure-cli).
    ```shell
    az aks create --name geo-addressing --generate-ssh-keys --attach-acr <your-acr-name> --enable-cluster-autoscaler --node-count 1 --min-count 1 --max-count 10 --node-osdisk-type Managed --node-osdisk-size 100 --node-vm-size Standard_D8_v3 --location eastus --nodepool-labels node-app=geo-addressing --zones 1 2 3
    az aks nodepool add --name ingress --cluster-name geo-addressing --node-count 1 --node-osdisk-size 100 --labels node-app=geo-addressing-ingress --zones 1 2 3
    az aks nodepool add --name express --cluster-name geo-addressing --node-count 1 --node-osdisk-size 100 --labels node-app=express-master --node-vm-size Standard_D4ps_v5 --zones 1 2 3
    az aks nodepool add --name expressdata --cluster-name geo-addressing --node-count 1 --node-osdisk-size 100 --labels node-app=express-data --node-vm-size Standard_D16ps_v5 --zones 1 2 3
  
    az aks get-credentials --name geo-addressing --overwrite-existing
    ```

- If you already have an AKS cluster, make sure you have the following driver related to it installed on the
  cluster:
  ```shell
  helm repo add azurefile-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/charts
  helm repo update
  helm install azurefile-csi-driver azurefile-csi-driver/azurefile-csi-driver --namespace kube-system --set cloud=AzureStackCloud
  ```
  > Note: From AKS 1.21, Azure Disk and Azure File CSI drivers would be installed by default, so you can directly move
  on to the next step.
- The geo-addressing service requires ingress controller setup. Run the following command for setting up NGINX ingress
  controller:
  ```shell
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  help repo update
  helm install nginx-ingress ingress-nginx/ingress-nginx -f ./cluster-sample/aks/ingress-values.yaml
  ```

*Note: You can update the nodeSelector according to your cluster's ingress node.*

Once ingress controller setup is completed, you can verify the status and get the ingress URL by using the following
command:

  ```shell
  kubectl get services -o wide    
  ```

## Step 3: Download Geo-Addressing Docker Images

The geo-addressing helm chart relies on the availability of Docker images for several essential microservices, all of
which are conveniently obtainable from Precisely Data Experience. The required docker images include:

1. Regional Addressing Service Docker Image
2. Addressing Service Docker Image
3. Express Engine Docker Image
4. Express Engine Data Restore Docker Image

> [!NOTE]:
> Contact Precisely or visit [Precisely Data Experience](https://data.precisely.com/) for buying subscription to docker image

Once you have purchased a subscription to Precisely Data Experience (PDX), you can directly download Docker images.
Afterward, you can easily load these Docker images into your Docker environment.

You can run the following commands after extracting the zipped docker images:

```shell
cd ./geo-addressing-images
az acr login --name <registry-name> --subscription <subscription-id>
docker load -i ./regional-addressing-service.tar
docker tag regional-addressing-service:latest <your-container-registry-name>.azurecr.io/regional-addressing-service:2.0.0
docker push <your-container-registry-name>.azurecr.io/regional-addressing-service:2.0.0
```

Follow the above steps for ALL the images inside the zipped file.

## Step 4: Create and Configure Azure Files Share

The Geo-Addressing Application requires reference data for geo-addressing capabilities. This reference data should be
deployed using [persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). This persistent
volume is backed by Azure File Share so that the data is ready to use immediately when the volume is
mounted to the pods.

If you have already created & configured an instance of the Azure Files share, and it is accessible from your AKS
cluster, then you can ignore this step and move to the next step.

- Register/Enable the NFS 4.1 protocol for your Azure subscription
  ```shell
  az feature register --name AllowNfsFileShares --namespace Microsoft.Storage
  az provider register --namespace Microsoft.Storage
  ```
  Registration approval can take up to an hour. To verify that the registration is complete, use the following commands:
  ```
  az feature show --name AllowNfsFileShares --namespace Microsoft.Storage
  ```

- Create a FileStorage storage account by using following command, only `FileStorage` type storage account has support
  of [NFS protocol](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-how-to-create-nfs-shares?tabs=azure-portal).

  ```shell
  az storage account create --name oasdataaccount --location eastus --sku Premium_LRS --kind FileStorage --https-only false
  ```

- Create an NFS share
  ```shell
  az storage share-rm create --storage-account oasdataaccount --name oasdatashare --quota 100 --enabled-protocol NFS 
  ```

- Grant access of FileStorage from your
  cluster's [virtual network](https://docs.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-cli).

    - Find node resource group of your AKS cluster -
      ```shell
      az aks show --name oassample --query "nodeResourceGroup"
      ```
      Output:
      ```shell
      "MC_ss4bd-aks-deployment-sample_oassample_eastus"
      ```
    - Find name of your AKS cluster's virtual network by using node resource group.
      ```shell
      az network vnet list --resource-group MC_ss4bd-aks-deployment-sample_oassample_eastus --query "[0].name"
      ```
      Output:
      ```shell
      "aks-vnet-21040294"
      ```
    - Find subnets of your AKS cluster by using node resource group.
      ```shell
      az network vnet show --resource-group MC_ss4bd-aks-deployment-sample_oassample_eastus --name aks-vnet-21040294 --query "subnets[*].name"
      ```
      Output:
      ```shell
      [
        "aks-subnet"
      ]
      ```
    - Enable service endpoint for Azure Storage on your cluster's virtual network and subnet.
      ```shell
      az network vnet subnet update --resource-group MC_ss4bd-aks-deployment-sample_oassample_eastus --vnet-name "aks-vnet-21040294" --name "aks-subnet" --service-endpoints "Microsoft.Storage"
      ```
    - Find id of your AKS cluster's subnets
      ```shell
      az network vnet show --resource-group MC_ss4bd-aks-deployment-sample_oassample_eastus --name aks-vnet-21040294 --query "subnets[*].id"
      ```
      Output:
      ```shell
      "/subscriptions/385ad333-7058-453d-846b-6de1aa6c607a/resourceGroups/MC_ss4bd-aks-deployment-sample_oassample_eastus/providers/Microsoft.Network/virtualNetworks/aks-vnet-21040294/subnets/aks-subnet"
      ```
    - Add a network rule for your cluster's virtual network and subnet.
      ```shell
      az storage account network-rule add --account-name oasdataaccount --subnet "/subscriptions/385ad333-7058-453d-846b-6de1aa6c607a/resourceGroups/MC_ss4bd-aks-deployment-sample_oassample_eastus/providers/Microsoft.Network/virtualNetworks/aks-vnet-21040294/subnets/aks-subnet"
      az storage account update --name oasdataaccount --default-action Deny
      ```

## Step 5: Installation of Reference Data

The Geo-Addressing Application relies on reference data for performing geo-addressing operations. For more information
related to reference data, please refer to [this link](../../ReferenceData.md).

You can make use of
a [miscellaneous helm chart for installing reference data](../../../charts/component-charts/reference-data-setup-generic/README.md), please
follow the instructions mentioned in the helm chart or run the below command for installing data in EFS or contact
Precisely Sales Team for the reference data installation.

```shell
helm install reference-data ./charts/aks/reference-data-setup/ \
--set "reference-data.global.pdxApiKey=[your-pdx-key]" \
--set "reference-data.global.pdxSecret=[your-pdx-secret]" \
--set "reference-data.node-selector.node-app=geo-addressing" \
--set "global.nfs.shareName=[shareName]" \
--set "global.nfs.storageAccount=[storageAccountName]" \
--set "reference-data.dataDownload.image.repository=[reference-data-image-repository]" \
--dependency-update --timeout 60m
```

## Step 6: Installation of Geo-Addressing Helm Chart

> NOTE: For every helm chart version update, make sure you run
> the [Step 3](#step-3-download-geo-addressing-docker-images) for uploading the docker images with the newest tag.

To install/upgrade the geo-addressing helm chart, use the following command:

```shell
helm upgrade --install geo-addressing ./charts/aks/geo-addressing \
--dependency-update \
--set "global.nfs.shareName=[shareName]" \
--set "global.nfs.storageAccount=[storageAccount]" \
--set "geo-addressing.ingress.hosts[0].host=[ingress-host-name]" \ 
--set "geo-addressing.ingress.hosts[0].paths[0].path=/precisely/addressing" \
--set "geo-addressing.ingress.hosts[0].paths[0].pathType=ImplementationSpecific" \
--set "global.nodeSelector.node-app=[node-selector-label]" \
--set "geo-addressing.image.repository=[azure-acr-name].azurecr.io/regional-addressing-service" \
--set "global.addressingImage.repository=[azure-acr-name].azurecr.io/addressing-service" \
--set "global.expressEngineImage.repository=[azure-acr-name].azurecr.io/express-engine" \
--set "global.expressEngineDataRestoreImage.repository=[azure-acr-name].azurecr.io/express-engine-data-restore" \
--set "geo-addressing.addressing-express.expressenginedata.nodeSelector.node-app=[node-selector-label-arm64-node]" \
--set "geo-addressing.addressing-express.expressenginemaster.nodeSelector.node-app=[node-selector-label-arm64-node]" \ 
--set "geo-addressing.addressing-express.expressEngineDataRestore.nodeSelector.node-app=[node-selector-label-arm64-node]" \
--set "global.countries={usa,can,aus,nzl}" \
--namespace geo-addressing --create-namespace
```

By default, only verify/geocode functionality is enabled.

> Note: addressing-express service is needed for Geocoding without country.

To enable other functionalities like autocomplete, lookup and
reverse-geocode you have to set the parameters in helm command as follows.

```shell
--set "geo-addressing.autocomplete-svc.enabled=true"
--set "geo-addressing.lookup-svc.enabled=true"
--set "geo-addressing.reverse-svc.enabled=true"
```

> NOTE: By default, the geo-addressing helm chart runs a hook job, which identifies the latest reference-data vintage
> mount path.
>
> To override this behaviour, you can disable the addressing-hook by `geo-addressing.addressing-hook.enabled` and provide manual
> reference data configuration using `global.manualDataConfig`.
>
> Refer [helm values](../../../charts/component-charts/geo-addressing-generic/README.md#helm-values) for the parameters related
> to `global.manualDataConfig.*` and `geo-addressing.addressing-hook.*`.
>
>
> NOTE: `addressing-hook` job not applicable to addressing-express service.
>
> Also, for more information, refer to the comments in [values.yaml](../../../charts/component-charts/geo-addressing-generic/values.yaml)

#### Mandatory Parameters

* ``global.nfs.shareName``: The Azure File ShareName
* ``global.nfs.storageAccount``: The Azure File StorageAccount
* ``global.countries``: Required countries for Geo-Addressing (e.g. ``--set "global.countries={usa,deu,gbr}"``).
  Provide a comma separated list to enable a particular set of countries
  from: `{usa,gbr,deu,aus,fra,can,mex,bra,arg,rus,ind,sgp,nzl,jpn,world}`
* ``geo-addressing.image.repository``: The image repository for the regional-addressing image
* ``global.addressingImage.repository``: The ECR image repository for the addressing-service image
* ``global.expressEngineImage.repository``: The ECR image repository for the express-engine image
* ``global.expressEngineDataRestoreImage.repository``: The ECR image repository for the express-engine-data-restore
  image
* ``global.nodeSelector``: The node selector to run the geo-addressing solutions on nodes of the cluster. Should be an
  amd64 based Node group.
* ``geo-addressing.addressing-express.expressEngineDataRestore.nodeSelector``: The node selector to run the express-engine data restore
  job. Should be an arm64 based Node group.
* ``geo-addressing.addressing-express.expressenginedata.nodeSelector``: The node selector to run the express-engine data service.
  Should be an arm64 based Node group.
* ``geo-addressing.addressing-express.expressenginemaster.nodeSelector``: The node selector to run the express-engine master service.
  Should be an arm64 based Node group.

For more information on helm values, follow [this link](../../../charts/component-charts/geo-addressing-generic/README.md#helm-values).

## Step 7: Monitoring Geo-Addressing Helm Chart Installation

Once you run the geo-addressing helm install/upgrade command, it might take a couple of seconds to trigger the
deployment. You can run the following command to check the creation of pods. Please wait until all the pods are in
running state:

```shell
kubectl get pods -w --namespace geo-addressing
```

When all the pods are up, you can run the following command to check the ingress service host:

```shell
kubectl get services --namespace geo-addressing
```

## Next Sections

- [Geo Addressing API Usage](../../../charts/component-charts/geo-addressing-generic/README.md#geo-addressing-service-api-usage)
- [Metrics, Traces and Dashboard](../../MetricsAndTraces.md)
- [FAQs](../../faq/FAQs.md)

[🔗 Return to `Table of Contents` 🔗](../../../README.md#guides)
 