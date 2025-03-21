## Deploying Custom Data Import Job with Helm

This guide explains how to deploy the `custom-data-import` job using Helm while overriding certain values such as the image repository and configuration elements.

### Prerequisites
- Helm is installed and configured.
- Kubernetes is running and connected to your `kubectl` context.
- The `geo-addressing` service is deployed with express enabled.
- Express URL and AWS S3 credentials are available.

### Helm Command to Deploy Custom Data Import Job

Use the following Helm command to deploy or upgrade the `custom-data-import` job and override specific values such as the image repository, tag, and configuration settings.

#### Command Example

```bash
helm upgrade --install custom-data-import ./charts/component-charts/custom-data-importer \
  --namespace geo-addressing \
  --set dataImport.image.repository="custom-data-importer" \
  --set dataImport.image.tag="4.0.0" \
  --set dataImport.config.expressUrl="https://new-express-url.com" \
  --set dataImport.config.aws.s3AccessKeyId="NEW_AKIA_ACCESS_KEY" \
  --set dataImport.config.aws.s3AccessKeySecret="NEW_SECRET_ACCESS_KEY" \
  --set dataImport.config.aws.s3Region="us-west-2" \
  --set dataImport.config.csvSourceFile="s3://new-bucket/new-data.csv"
```

### Helm Values for Custom Data Importer

The following table provides a summary of the key *Helm values* that can be customized when deploying or upgrading the `custom-data-import` job:

<details>
<summary><code>dataImport.*</code></summary>

| Parameter                                 | Description                                                  | Default                                      |
|-------------------------------------------|--------------------------------------------------------------|----------------------------------------------|
| `dataImport.enabled`                      | Enable or disable the `custom-data-import` job               | `true`                                       |
| `dataImport.image.repository`             | The Docker image repository for the custom data importer     | `custom-data-importer`                       |
| `dataImport.image.tag`                    | The Docker image tag for the custom data importer            | `4.0.0`                                      |
| `dataImport.image.pullPolicy`             | The image pull policy                                        | `Always`                                     |
| `dataImport.config.expressUrl`            | The URL for the express engine used in the import job        | `https://express-engine-cluster-master:9200` |
| `dataImport.config.aws.s3AccessKeyId`     | AWS S3 access key for reading the CSV data                   | `""`                                         |
| `dataImport.config.aws.s3AccessKeySecret` | AWS S3 secret key for reading the CSV data                   | `""`                                         |
| `dataImport.config.aws.s3Region`          | AWS S3 region for accessing the bucket                       | `us-east-1`                                  |
| `dataImport.config.csvSourceFile`         | The source file for data import                              | `s3://new-bucket/data.csv`                   |

<hr>
</details>

> **_NOTE:_** csv path that starts with s3:// will utilize s3 credentials to download the file and then import

### Monitoring the Custom Data Import Job

You can monitor the progress of the custom data import job using the following commands:

```bash
kubectl get pods -w -n geo-addressing
kubectl logs -f -l "app.kubernetes.io/name=custom-data-import" -n geo-addressing
```

---

This section provides users with the necessary information and commands to deploy and monitor the custom data import job using Helm.

---

# Custom Data Import - CSV File Schema

This document provides the schema for the CSV file that is used for the Custom Data Import. The table below defines the fields, data types, and descriptions for each column in the CSV file.

| Field Name      | Description                                                        | Example       | Data Type                          | Size       |
|-----------------|--------------------------------------------------------------------|---------------|------------------------------------|------------|
| `source_id`     | Identifier for the data. The source may contain a UUID (36 chars).  | `D5`          | `text` (stored as `varchar`)       | 36         |
| `place_name`    | Point of Interest (POI) name                                        | `Precisely`   | `text`                             | N/A        |
| `address_number`| Address number (e.g., 123 Main St -> 123 in parsed format)          | `1`           | `text`                             | N/A        |
| `street_name`   | Name of the street                                                  | `Global View` | `text`                             | N/A        |
| `post_code`     | Postal code                                                         | `12180`       | `text`                             | N/A        |
| `post_code_ex`  | Extended postal code (if available)                                 | `0007`        | `text`                             | N/A        |
| `admin1`        | State or Province                                                   | `NY`          | `text`                             | N/A        |
| `city`          | Name of the city                                                    | `Troy`        | `text`                             | N/A        |
| `neighborhood`  | Locality or suburb in the city                                      | `Pier 15`     | `text`                             | N/A        |
| `unit_type`     | Type of unit (e.g., Unit, Apt, #)                                   | `APT`         | `text`                             | N/A        |
| `unit_value`    | Value of the unit                                                   | `15`          | `text`                             | N/A        |
| `country`       | ISO 3 Country Code                                                  | `usa`         | `text` (stored as `varchar`)       | 3          |
| `latitude`      | Latitude coordinate (decimal format)                                | `0.0`         | `decimal`                          | (10,9)     |
| `longitude`     | Longitude coordinate (decimal format)                               | `0.0`         | `decimal`                          | (10,9)     |
| `location_desc` | Description of the location                                          | `null island` | `text`                             | N/A        |

## Notes:
- **Source ID:** This is a unique identifier for each entry in the dataset, and it can contain UUID values.
- **Address Fields:** These include fields such as `address_number`, `street_name`, `post_code`, etc., which define the physical location of the place.
- **Coordinates:** Both latitude and longitude are stored as decimal values with up to 9 digits of precision.
- **Country:** Stored as a 3-character ISO country code.
- **Unit Information:** `unit_type` and `unit_value` are used to provide additional details about the unit or apartment, if applicable.

---

This structure can be used as the reference guide for any future updates or documentation purposes for the custom data import schema.

