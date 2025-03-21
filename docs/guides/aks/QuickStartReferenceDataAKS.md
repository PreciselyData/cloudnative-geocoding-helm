# Reference Data Installation Helm Chart for AKS

## Step 1: Getting Access to Reference Data

To download the reference data (country-specific data) .spd files,
visit [Precisely Data Portfolio](https://dataguide.precisely.com/) where you can also sign up for a free account and
access files available in your [Precisely Data Experience](https://data.precisely.com/) account.

## Step 2: Creating and Pushing Reference Data Docker Image

This helm chart requires a `reference-data-extractor` docker image to be available in your Container Registry.
Follow the below steps to create and push the docker image to your container registry:

```shell
cd ./charts/component-charts/reference-data-setup-generic/image
docker build . -t reference-data-extractor:4.0.0
```

```shell
az login
az acr login --name <registry-name> --subscription <subscription-id>
docker tag reference-data-extractor:4.0.0 <your-container-registry-name>.azurecr.io/reference-data-extractor:4.0.0
docker push <your-container-registry-name>.azurecr.io/reference-data-extractor:4.0.0
```

## Step 3: Prepare the Reference Data Required for Installation

You can provide the information about the reference data to be downloaded in the format of Map/Dictionary.

<details>

**_<summary> Click Here to See an example of Reference Data JSON </summary>_**

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
</details>


The format used in the JSON Dictionary/Map is `[functionality]:[country]:[reference-data-key]`

The reference data key is in the format:`[ProductName#Geography#RoasterGranularity#DataFormat]`
If you want to install specific vintage, you can pass the optional vintage parameter such as: `[ProductName#Geography#RoasterGranularity#DataFormat#Vintage]`

e.g. `Geocoding NT Street US#United States#All USA#Spectrum Platform Data` or `Geocoding NT Street US#United States#All USA#Spectrum Platform Data#2025.3`

_**NOTE: Once you prepare the JSON value in above format, Minify the JSON and Escape it using any online tools.
Afterward, overwrite the default value of dataConfigMap section in the [values.yaml](../../../charts/aks/reference-data-setup/values.yaml) file of the reference data helm chart.**_


## Step 4: Running the Reference Data Installation Helm Chart

Run the below command for installation of reference data:

```shell
helm install reference-data ./charts/eks/reference-data-setup/ \
--set "global.nfs.shareName=<e.g: geoaddressingshare>" \
--set "global.nfs.storageAccount=<e.g: geoaddressing>" \
--set "reference-data.dataDownload.image.repository=<your-azure-acr-name>.azurecr.io/reference-data-extractor" \
--set "reference-data.dataDownload.image.tag=4.0.0" \
--set "reference-data.config.pdxApiKey=<your-pdx-key>" \
--set "reference-data.config.pdxSecret=<your-pdx-secret>" \
--set "reference-data.config.countries=<e.g: {usa,aus}>" \
--dependency-update --timeout 60m
```

## Step 5: Monitoring the Reference Data Installation

The above command triggers a Kubernetes Job to install reference data. Once the Job is in active state, following commands will be helpful for monitoring the Job status:

```shell
kubectl get jobs
kubectl get pods -w
```
You will see a Pod for the Job. You can describe the Job, Pod for more details.

Run the following command to get the logs of the reference data pod, once the pod is in running state.
```shell
kubectl logs -f -l "app.kubernetes.io/name=reference-data"
```

[🔗 Return to `Table of Contents` 🔗](../../../README.md#components)