# Reference Data Highlights

> **_NOTE: Follow the Quick Start Guides based on your cloud provided for installing the reference data using provided Helm
Charts for reference data installation.
[EKS](guides/eks/QuickStartReferenceDataEKS.md)|[AKS](guides/aks/QuickStartReferenceDataAKS.md)|[GKE](guides/gke/QuickStartReferenceDataGKE.md)_**

Precisely offers a large variety of datasets, which can be utilized depending on the use case.

<details>
<summary>Highlights</summary>

- Highest building level precision. Highest overall building and parcel level precision datasets
- Low Street interpolation percentage.
- Best for address level geocodes for North American and European addresses
- Master Location Data (MLD), our best-in-class, hyper-accurate location reference data with PreciselyID, is now
  available in 11 countries, with more to come!
- Positionally-accurate location datasets delivers highly relevant, consistent context enabling more confident business
  decisions.

</details>

The geo-addressing solution relies on reference data (country-specific data) stored on mounted file storage for
operational addressing operations. It's crucial to ensure that this reference data is available in the cluster's mounted
storage before initiating the deployment of the Geo-Addressing Helm Chart.

To accommodate reference data and software upgrades, you should upload newer data to the recommended location or folder
on the mounted storage. The Geo-Addressing Helm Chart can then be rolled out with the new reference data location
seamlessly and with zero downtime.

# Reference Data Structure

As a generalized step, the reference data should exist in the following format only: `[basePath]/[addressing-functionality]/[country]/[current-time]/[vintage]/[data]`

NOTE: The current-time folder name should always be in the format: `YYMMDDhhmm` e.g. 202311081159

```
basePath/
├── verify-geocode/
│   │── usa/
│   │   └── 202311081159/
│   │       └── 202306/
│   │           ├── data-folder-1/
│   │           └── ...
│   │── gbr/
│   │   └── 202311081159/
│   │       └── 202307/
│   │           ├── data-folder-1/
│   │           └── ...
│   │── ...
├── autocomplete/
│   │── usa/
│   │   └── 202311081159/
│   │       └── 202309/
│   │           ├── data-folder-1/
│   │           └── ...
│   │── aus/
│   │   └── 202311081159/
│   │       └── 202308/
│   │           ├── data-folder-1/
│   │           └── ...
│   │── ...
├── lookup/
│   │── usa/
│   │   └── 202311081159/
│   │       └── 202309/
│   │           ├── data-folder-1/
│   │           └── ...
│   │── fra/
│   │   └── 202311081159/
│   │       └── 202308/
│   │           ├── data-folder-1/
│   │           └── ...
├── express_data/
│   │── usa/
│   │   └── 202311081159/
│   │       └── 202309/
│   │           ├── addressing/
│   │           └── poi/
│   │── fra/
│   │   └── 202311081159/
│   │       └── 202308/
│   │           ├── addressing/
│   │           └── poi/
```

### Helm Values

The following is the summary of some *helm values*
provided by this chart:

> click the `▶` symbol to expand

<details>
<summary><code>reference-data.dataDownload.*</code></summary>

| Parameter                                       | Description                                              | Default                    |
|-------------------------------------------------|----------------------------------------------------------|----------------------------|
| *`reference-data.dataDownload.image.repository` | the reference-data-extractor container image repository  | `reference-data-extractor` |
| `reference-data.dataDownload.image.tag`         | the reference-data-extractor container image version tag | `4.0.0`                    |

<hr>
</details>

<details>
<summary><code>reference-data.config.*</code></summary>

| Parameter                               | Description                                                                                                                      | Default                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|-----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| *`reference-data.config.pdxApiKey`      | the apiKey of your PDX account                                                                                                   | `pdx-api-key`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| *`reference-data.config.pdxSecret`      | the secret key of your PDX account                                                                                               | `pdx-api-secret`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| *`reference-data.config.countries`      | the countries for which you want to install reference data                                                                       | `{usa,aus}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `reference-data.config.dataConfigMap`   | a Map of reference data to be downloaded against countries                                                                       | `{\"verify-geocode\":{\"usa\":[\"Geocoding MLD US#United States#All USA#Spectrum Platform Data\",\"Geocoding NT Street US#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Geocoding PSMA Street#Australia#All AUS#Geocoding\",\"Geocoding GNAF Address Point#Australia#All AUS#Geocoding\"]},\"lookup\":{\"usa\":[\"Geocoding MLD US#United States#All USA#Spectrum Platform Data\",\"Geocoding NT Street US#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Geocoding PSMA Street#Australia#All AUS#Geocoding\",\"Geocoding GNAF Address Point#Australia#All AUS#Geocoding\"]},\"autocomplete\":{\"usa\":[\"Predictive Addressing Points#United States#All USA#Interactive\"],\"aus\":[\"Predictive Addressing Points#Australia#All AUS#Interactive\"]},\"express_data\":{\"usa\":[\"Address Express#United States#All USA#Spectrum Platform Data\",\"POI Express#United States#All USA#Spectrum Platform Data\"],\"aus\":[\"Address Express#Australia#All AUS#Spectrum Platform Data\"]}}` |
| `reference-data.config.failFastEnabled` | failFast flag allows the reference-data job to fail fast for any exception. By default, it will continue downloading other SPDs. | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `reference-data.config.timestampFolder` | The timestampFolder path where all the reference data is installed. If not passed, it will pick the current time of job run.     | ``                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |

</details>

[🔗 Return to `Table of Contents` 🔗](../README.md#components)