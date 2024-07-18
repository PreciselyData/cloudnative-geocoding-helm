# Installing Geo-Addressing Helm Chart on Google Kubernetes Engine (GKE)

## Step 1: Before You Begin

To deploy the Geo-Addressing application in GKE, install the following client tools:

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm3](https://helm.sh/docs/intro/install/)
-

##### Google Kubernetes Engine (GKE)

- [gcloud cli](https://cloud.google.com/cli)

The Geo-Addressing Helm Chart on GKE requires access
to [Google Filestore](https://cloud.google.com/filestore?hl=en), [Google Artifact Registry (GCR)](https://cloud.google.com/artifact-registry).
Google Filestore is used to store
the reference datasets in .spd file format, and the GCR repository contains the Geo-Addressing Docker Images
which is used for the deployment.

The Geo Addressing Helm Chart on Google GKE requires access to Cloud Storage buckets and GCR. Google Cloud Storage (GS)
is used to store the reference datasets, and the GCR repository contains the Geo Addressing
application's Docker images which will be used for the deployment.

Running the geo addressing helm chart on GKE requires permissions on these Google Cloud resources along with some others
listed below.

GCP IAM Permissions
To deploy the geo addressing application on a GKE cluster, make sure you have the following IAM roles and permissions:

- roles/container.admin - to create and manage a GKE cluster
- roles/iam.serviceAccountUser - to assign a service account to Nodes
- roles/storage.admin - to read/write data in Google Storage
- roles/file.editor - to read/write data from Google Filestore

For more details about IAM roles and permissions, see
Google's [documentation](https://cloud.google.com/iam/docs/understanding-roles).

##### Authenticate and configure gcloud

Replace the path parameter with the absolute path to your service account key file, and run the command below. For
more options for authentication, refer to
the [Google Cloud documentation](https://cloud.google.com/sdk/gcloud/reference/auth).

  ```shell 
  gcloud auth activate-service-account  --key-file=<path-to-key-file>  
  ``` 

Configure a GCP project ID to create the Filestore instance; otherwise, you will have to provide this project ID in each
command.

  ```shell
  gcloud config set project <project-name>
  ```

## Step 2: Create the GKE Cluster

You can create the GKE cluster or use existing GKE cluster.

- If you DON'T have GKE cluster, we have provided you with few
  sample cluster installation commands. Run the following sample commands to create the cluster:
    ```shell
    gcloud container clusters create <cluster-name> --disk-size=200G --zone <zone-name> --node-locations <zone-name> --machine-type n1-standard-8 --num-nodes 2 --no-enable-autoupgrade --min-nodes 1 --max-nodes 2 --node-labels=node-app=geo-addressing

    gcloud container node-pools create ingress-pool --cluster <cluster-name> --machine-type n1-standard-4 --num-nodes 1 --no-enable-autoupgrade --zone <zone-name> --node-labels=node-app=geo-addressing-ingress

    gcloud container node-pools create express-data --cluster <cluster-name> --machine-type t2a-standard-8 --num-nodes 20 --no-enable-autoupgrade --min-nodes 3 --max-nodes 20 --zone <zone-name> --node-labels=node-app=express-data

    gcloud container node-pools create express-master --cluster <cluster-name> --machine-type t2a-standard-2 --num-nodes 20 --no-enable-autoupgrade --min-nodes 3 --max-nodes 20 --zone <zone-name> --node-labels=node-app=express-master

    gcloud container clusters get-credentials <cluster-name> --zone us-central1-a
    ```

- If you already have a GKE cluster, make sure you have the following driver related to it enabled on the
  cluster:
  ```shell
  gcloud container clusters update <cluster-name> --update-addons=GcePersistentDiskCsiDriver=ENABLED
  ```
- The geo-addressing service requires ingress controller setup. Run the following command for setting up NGINX ingress
  controller:
  ```shell
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm install nginx-ingress ingress-nginx/ingress-nginx -f ./cluster-sample/gke/ingress-values.yaml
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
> Contact Precisely or visit [Precisely Data Experience](https://data.precisely.com/) for buying subscription to docker
> image

Once you have purchased a subscription to Precisely Data Experience (PDX), you can directly download Docker images.
Afterward, you can easily load these Docker images into your Docker environment.

You can run the following commands after extracting the zipped docker images:

```shell
cd ./geo-addressing-images
gcloud auth configure-docker --quiet
docker load -i ./regional-addressing-service.tar
docker tag regional-addressing-service:latest us.gcr.io/<project-name>/regional-addressing-service:2.0.1
docker push us.gcr.io/<project-name>/regional-addressing-service:2.0.1
```

Follow the above steps for ALL the images inside the zipped file.

## Step 4: Create and Configure Google Filestore

The Geo-Addressing Application requires reference data for geo-addressing capabilities. This reference data should be
deployed using [persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). This persistent
volume is backed by Google Filestore so that the data is ready to use immediately when the volume is
mounted to the pods.

If you have already created & configured an instance of the Google Filestore, and it is accessible from your GKE
cluster, then you can ignore these steps and move to the next step.

> Note: This process for configuring Google Filestore needs to be executed only once for the Geo Addressing Application
> deployment.

Follow the following steps to create a Filestore instance for the Geo Addressing Application:

#### 1. Create the Filestore Instance

- Configure the GCP project ID that will be used to create the Filestore instance; otherwise, you will need to provide
  this project ID in every command:
  ```
  gcloud config set project <project-id>
  ```

- Locate the VPC network of your cluster - the Filestore instance and GKE cluster must be in the same network to access
  the data from them in the cluster:
  ```
  gcloud container clusters describe <cluster-name> --zone us-east1-c --format="value(network)"
  ```
  Your output should be similar to this:
  ```
  default
  ```
- Locate the compute zone of your cluster, this is also required to create a Filestore instance:
  ```
  gcloud container clusters describe <cluster-name> --zone us-east1-c --format="value(location)"
  ```
  Output
  ```
  us-east1-c
  ```

- Create the Filestore instance using the retrieved values:
  ```
  gcloud filestore instances create <filestore-instance-name> --zone us-east1-c --network=name=default --file-share=name=<filestore-instance-name-with-underscore>,capacity=1TB 
  ```
  **Note:** Uppercase and hyphen ('-') are not allowed values for `--file-share`; however, using an underscore ('_') is
  supported. Google requires a minimum capacity of 1 TB.
  Creating the Filestore instance takes a few minutes. When the command completes, you can verify that your Filestore
  instance was created:
  ```
  gcloud filestore instances describe <filestore-instance-name> --zone us-east1-c
  ```
  Your output should be similar to this:
  ```
   createTime: '2020-08-18T10:13:20.387685657Z'
   fileShares:
   - capacityGb: '1024'
     name: <filestore-instance-name-with-underscore>
   name: projects/<project-id>/locations/us-east1-c/instances/<filestore-instance-name>
   networks:
   - connectMode: DIRECT_PEERING
   - ipAddresses:
     - 10.13.31.106
     network: default
     reservedIpRange: 10.13.31.104/29
   state: READY
   tier: BASIC_HDD
   ```

#### 2. Update the persistent volume resource definition

- Locate the IP address of your Filestore instance:
   ```
   gcloud filestore instances describe <filestore-instance-name> --zone us-east1-c --format="value(networks[0].ipAddresses[0])"
   ```
  Your output should be similar to this:
  ```
  10.231.81.122
  ```
- Locate the NFS path (the name) of your Filestore instance:
  ```
  gcloud filestore instances describe <filestore-instance-name> --zone us-east1-c --format="value(fileShares[0].name)"
  ```
- In the `./ggs/nfs-data/gke/ggs-data-pv.yaml` file, update the Filestore path and IP address:
  ```
  nfs:
    path: /<filestore-instance-name-with-underscore>
    server: 10.231.81.122
  ```  

**Note:** The path of the data that you are going to use must exist on Filestore.

## Step 5: Installation of Reference Data

The Geo-Addressing Application relies on reference data for performing geo-addressing operations. For more information
related to reference data, please refer to [this link](../../ReferenceData.md).

> Note: You can run the reference data helm chart after you have configured Filestore instances and linked it to the
> cluster
> when you need to update the deployed data, such as with a new vintage, or if you want to add
> support for additional countries.

You can make use of
a [miscellaneous helm chart for installing reference data](../../../charts/component-charts/reference-data-setup-generic/README.md),
please
follow the instructions mentioned in the helm chart or run the below command for installing data in EFS or contact
Precisely Sales Team for the reference data installation.

```shell
helm install reference-data ./charts/gke/reference-data-setup/ \
--set "reference-data.config.pdxApiKey=<pdx-api-key>" \
--set "reference-data.config.pdxSecret=<pdx-api-secret>" \
--set "reference-data.node-selector.node-app=<node-selector-label>" \
--set "global.nfs.path=/<filestore-instance-name-with-underscore>" \
--set "global.nfs.server=10.231.81.122" \
--set "reference-data.dataDownload.image.repository=[e.g. us.gcr.io/<project-id>/reference-data-extractor]" \
--dependency-update --timeout 60m
```

## Step 6: Installation of Geo-Addressing Helm Chart

> NOTE: For every helm chart version update, make sure you run
> the [Step 3](#step-3-download-geo-addressing-docker-images) for uploading the docker images with the newest tag.

To install/upgrade the geo-addressing helm chart, use the following command:

```shell
helm upgrade --install geo-addressing ./charts/gke/geo-addressing \
--dependency-update \
--set "global.nfs.path=/<filestore-instance-name-with-underscore>" \
--set "global.nfs.server=10.231.81.122" \
--set "geo-addressing.ingress.hosts[0].host=[ingress-host-name]" \ 
--set "geo-addressing.ingress.hosts[0].paths[0].path=/precisely/addressing" \
--set "geo-addressing.ingress.hosts[0].paths[0].pathType=ImplementationSpecific" \
--set "global.nodeSelector.node-app=<node-selector-label>" \
--set "geo-addressing.image.repository=[e.g. us.gcr.io/<project-id>/regional-addressing-service]" \
--set "global.addressingImage.repository=[e.g. us.gcr.io/<project-id>/addressing-service]" \
--set "global.expressEngineImage.repository=[e.g. us.gcr.io/<project-id>/express-engine]" \
--set "global.expressEngineDataRestoreImage.repository=[e.g. us.gcr.io/<project-id>/express-engine-data-restore]" \
--set "geo-addressing.addressing-express.expressenginedata.nodeSelector.node-app=<node-selector-label-arm64-node>" \
--set "geo-addressing.addressing-express.expressenginemaster.nodeSelector.node-app=<node-selector-label-arm64-node>" \ 
--set "geo-addressing.addressing-express.expressEngineDataRestore.nodeSelector.node-app=<node-selector-label-arm64-node>" \
--set "global.countries={usa,can,aus,nzl}" \
--namespace geo-addressing --create-namespace
```

> Note: addressing-express service is needed for Geocoding without country.

By default, only verify/geocode functionality is enabled.

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
> To override this behaviour, you can disable the addressing-hook by `geo-addressing.addressing-hook.enabled` and
> provide manual
> reference data configuration using `global.manualDataConfig`.
>
> Refer [helm values](../../../charts/component-charts/geo-addressing-generic/README.md#helm-values) for the parameters
> related
> to `global.manualDataConfig.*` and `geo-addressing.addressing-hook.*`.
>
>
> NOTE: `addressing-hook` job not applicable to addressing-express service.
>
> Also, for more information, refer to the comments
> in [values.yaml](../../../charts/component-charts/geo-addressing-generic/values.yaml)

#### Mandatory Parameters

* ``global.nfs.path``: The Path to Google Filestore Instance
* ``global.nfs.server``: The IP of your Google Filestore Instance server
* ``global.countries``: Required countries for Geo-Addressing (e.g. ``--set "global.countries={usa,deu,gbr}"``).
  Provide a comma separated list to enable a particular set of countries
  from: `{usa,gbr,deu,aus,fra,can,mex,bra,arg,rus,ind,sgp,nzl,jpn,world}`
* ``geo-addressing.image.repository``: The image repository for the regional-addressing image
* ``global.addressingImage.repository``: The image repository for the addressing-service image
* ``global.expressEngineImage.repository``: The image repository for the express-engine image
* ``global.expressEngineDataRestoreImage.repository``: The image repository for the express-engine-data-restore
  image
* ``global.nodeSelector``: The node selector to run the geo-addressing solutions on nodes of the cluster. Should be an
  amd64 based Node group.
* ``geo-addressing.addressing-express.expressEngineDataRestore.nodeSelector``: The node selector to run the
  express-engine data restore
  job. Should be an arm64 based Node group.
* ``geo-addressing.addressing-express.expressenginedata.nodeSelector``: The node selector to run the express-engine data
  service.
  Should be an arm64 based Node group.
* ``geo-addressing.addressing-express.expressenginemaster.nodeSelector``: The node selector to run the express-engine
  master service.
  Should be an arm64 based Node group.

For more information on helm values,
follow [this link](../../../charts/component-charts/geo-addressing-generic/README.md#helm-values).

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
 