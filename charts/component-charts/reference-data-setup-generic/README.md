# Reference Data Setup

The Geo Addressing Application requires reference data installed in the worker nodes for running geo-addressing
capabilities. This reference data should be deployed
using [persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). This persistent volume is
backed by Network File Storage so that the data is ready to use immediately when the volume is mounted to
the pods.

For more information on reference data and reference data structure, please
visit [this link](../../../docs/ReferenceData.md).

Follow the aforementioned steps for installation of the reference data in the mounted storage:

## Step 1: Getting Access to Reference Data

To download the reference data (country-specific data) .spd files,
visit [Precisely Data Portfolio](https://dataguide.precisely.com/) where you can also sign up for a free account and
access files available in your [Precisely Data Experience](https://data.precisely.com/) account.

## Step 2: Creating and Pushing Docker Image

This helm chart requires a `reference-data-extractor` docker image to be available in Elastic Container Registry (ECR).
Follow the below steps to create and push the docker image to ECR:

```shell
cd ./charts/component-charts/reference-data-setup-generic/image
docker build . -t reference-data-extractor:3.0.1
```

##### For AWS EKS:

```shell
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [AWS-ACCOUNT-ID].dkr.ecr.us-east-1.amazonaws.com

aws ecr create-repository --repository-name reference-data-extractor --image-scanning-configuration scanOnPush=true --region [AWS-REGION]

docker tag reference-data-extractor:3.0.1 [AWS-ACCOUNT-ID].dkr.ecr.[AWS-REGION].amazonaws.com/reference-data-extractor:3.0.1

docker push [AWS-ACCOUNT-ID].dkr.ecr.[AWS-REGION].amazonaws.com/reference-data-extractor:3.0.1
```

##### For Microsoft AKS:

```shell
az login
az acr login --name <registry-name> --subscription <subscription-id>

docker tag reference-data-extractor:3.0.1 <your-container-registry-name>.azurecr.io/reference-data-extractor:3.0.1

docker push <your-container-registry-name>.azurecr.io/reference-data-extractor:3.0.1
```

##### For Google's GKE:

```shell
gcloud auth configure-docker --quiet
docker tag reference-data-extractor:2.0.1 us.gcr.io/<project-name>/reference-data-extractor:2.0.1
docker push us.gcr.io/<project-name>/reference-data-extractor:2.0.1
```

## Step 3: Creating Mounted Storage

##### For AWS EKS:

We already have scripts to create EFS and link to the current EKS cluster. Please follow the steps
mentioned [here](../../../scripts/eks/efs-creator/README.md) to create EFS.

##### For Microsoft AKS:

Please follow the instructions and link to create mounted storage
mentioned [here](../../../docs/guides/aks/QuickStartAKS.md#step-4-create-and-configure-azure-files-share).

##### For Google's GKE:

Please follow the instructions and link to create mounted storage
mentioned [here](../../../docs/guides/gke/QuickStartGKE.md#step-4-create-and-configure-google-filestore).


## Step 4: Running the Reference Data Installation Helm Chart

Run the below command for installation of reference data in EFS:

```shell
helm install reference-data ./charts/reference-data-setup/ \
--set "reference-data.config.pdxApiKey=[your-pdx-key]" \
--set "reference-data.config.pdxSecret=[your-pdx-secret]" \
--set "reference-data.dataDownload.image.repository=[reference-data-image-repository]" \
--set "reference-data.config.countries={usa,aus}" \
--set "reference-data.config.dataConfigMap={\"verify-geocode\":{\"usa\":[\"Geocoding MLD US#United States#All USA#Spectrum Platform Data\",\"Geocoding NT Street US#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Geocoding PSMA Street#Australia#All AUS#Geocoding\",\"Geocoding GNAF Address Point#Australia#All AUS#Geocoding\"]},\"lookup\":{\"usa\":[\"Geocoding MLD US#United States#All USA#Spectrum Platform Data\",\"Geocoding NT Street US#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Geocoding PSMA Street#Australia#All AUS#Geocoding\",\"Geocoding GNAF Address Point#Australia#All AUS#Geocoding\"]},\"autocomplete\":{\"usa\":[\"Predictive Addressing Points#United States#All USA#Interactive\"],\"aus\":[\"Predictive Addressing Points#Australia#All AUS#Interactive\"]},\"express_data\":{\"usa\":[\"Address Express#United States#All USA#Spectrum Platform Data\",\"POI Express#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Address Express#Australia#All AUS#Spectrum Platform Data\"]}}" \
--dependency-update --timeout 60m
```

### Helm Values

The following is the summary of some *helm values*
provided by this chart:

> click the `▶` symbol to expand

<details>
<summary><code>image.*</code></summary>

| Parameter          | Description                                              | Default                    |
|--------------------|----------------------------------------------------------|----------------------------|
| `image.repository` | the reference-data-extractor container image repository  | `reference-data-extractor` |
| `image.tag`        | the reference-data-extractor container image version tag | `3.0.1`                    |

<hr>
</details>

<details>
<summary><code>reference-data.*</code></summary>

| Parameter                               | Description                                                                                                                      | Default                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|-----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| *`reference-data.config.pdxApiKey`      | the apiKey of your PDX account                                                                                                   | `pdx-api-key`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| *`reference-data.config.pdxSecret`      | the secret key of your PDX account                                                                                               | `pdx-api-secret`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| *`reference-data.config.countries`      | the countries for which you want to install reference data                                                                       | `{usa,aus,can,gbr,nzl}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `reference-data.config.dataConfigMap`   | a Map of reference data to be downloaded against countries                                                                       | `{\"verify-geocode\":{\"usa\":[\"Geocoding MLD US#United States#All USA#Spectrum Platform Data\",\"Geocoding NT Street US#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Geocoding PSMA Street#Australia#All AUS#Geocoding\",\"Geocoding GNAF Address Point#Australia#All AUS#Geocoding\"]},\"lookup\":{\"usa\":[\"Geocoding MLD US#United States#All USA#Spectrum Platform Data\",\"Geocoding NT Street US#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Geocoding PSMA Street#Australia#All AUS#Geocoding\",\"Geocoding GNAF Address Point#Australia#All AUS#Geocoding\"]},\"autocomplete\":{\"usa\":[\"Predictive Addressing Points#United States#All USA#Interactive\"],\"aus\":[\"Predictive Addressing Points#Australia#All AUS#Interactive\"]},\"express_data\":{\"usa\":[\"Address Express#United States#All USA#Spectrum Platform Data\",\"POI Express#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Address Express#Australia#All AUS#Spectrum Platform Data\"]}}` |
| `reference-data.config.failFastEnabled` | failFast flag allows the reference-data job to fail fast for any exception. By default, it will continue downloading other SPDs. | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `reference-data.config.timestampFolder` | The timestampFolder path where all the reference data is installed. If not passed, it will pick the current time of job run.     | ``                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |

<hr>
</details>

### Providing Information of Reference Data to be Downloaded

You can provide the information about the reference data to be downloaded in the format of Map/Dictionary. Below is an
example of default reference data map:

```shell
{
  "verify-geocode": {
    "usa": [
      "Geocoding MLD US#United States#All USA#Spectrum Platform Data",
      "Geocoding NT Street US#United States#All USA#Spectrum Platform Data"
    ],
    "aus": [
      "Geocoding PSMA Street#Australia#All AUS#Geocoding",
      "Geocoding GNAF Address Point#Australia#All AUS#Geocoding"
    ]
  },
  "lookup": {
    "usa": [
      "Geocoding MLD US#United States#All USA#Spectrum Platform Data",
      "Geocoding NT Street US#United States#All USA#Spectrum Platform Data"
    ],
    "aus": [
      "Geocoding PSMA Street#Australia#All AUS#Geocoding",
      "Geocoding GNAF Address Point#Australia#All AUS#Geocoding"
    ]
  },
  "autocomplete": {
    "usa": [
      "Predictive Addressing Points#United States#All USA#Interactive"
    ],
    "aus": [
      "Predictive Addressing Points#Australia#All AUS#Interactive"
    ]
  },
  "express_data": {
    "usa": [
      "Address Express#United States#All USA#Spectrum Platform Data",
      "POI Express#United States#All USA#Spectrum Platform Data"
    ],
    "aus": [
      "Address Express#Australia#All AUS#Spectrum Platform Data"
    ]
  }
}
```

<br>The format used in the Map is as follows:

`[functionality]:[country]:[reference-data-key]`

<br>The reference data key is in the format:

`[ProductName#Geography#RoasterGranularity#DataFormat]`

e.g. `Geocoding NT Street US#United States#All USA#Spectrum Platform Data`

<br>You can create a map of the reference data to be downloaded and override the `global.dataConfigMap` parameter while
installing the helm chart as follows:

> NOTE: If you want to download a specific vintage of data always, you can pass the vintage parameter as follows:
>
> [ProductName#Geography#RoasterGranularity#DataFormat#Vintage]
>
> e.g. `Geocoding NT Street US#United States#All USA#Spectrum Platform Data#2023.11`

```shell
--set "reference-data.config.dataConfigMap={\"verify-geocode\":{\"usa\":[\"Geocoding MLD US#United States#All USA#Spectrum Platform Data\",\"Geocoding NT Street US#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Geocoding PSMA Street#Australia#All AUS#Geocoding\",\"Geocoding GNAF Address Point#Australia#All AUS#Geocoding\"]},\"lookup\":{\"usa\":[\"Geocoding MLD US#United States#All USA#Spectrum Platform Data\",\"Geocoding NT Street US#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Geocoding PSMA Street#Australia#All AUS#Geocoding\",\"Geocoding GNAF Address Point#Australia#All AUS#Geocoding\"]},\"autocomplete\":{\"usa\":[\"Predictive Addressing Points#United States#All USA#Interactive\"],\"aus\":[\"Predictive Addressing Points#Australia#All AUS#Interactive\"]},\"express_data\":{\"usa\":[\"Address Express#United States#All USA#Spectrum Platform Data\",\"POI Express#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Address Express#Australia#All AUS#Spectrum Platform Data\"]}}"
```

## Monitoring the Helm Chart

After running the helm chart command, the reference data installation step might take a couple of minutes to download
and extract the reference data in the EFS. You can monitor the progress of the reference data downloads using following
commands:

```shell
kubectl get pods -w
kubectl logs -f -l "app.kubernetes.io/name=reference-data"
```

[🔗 Return to `Table of Contents` 🔗](../../../README.md#guides)
