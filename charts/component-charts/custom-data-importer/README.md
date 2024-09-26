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
helm upgrade --install custom-data-import ./path-to-your-chart \
  --namespace geo-addressing \
  --set dataImport.image.repository="custom-data-importer" \
  --set dataImport.image.tag="2.0.2" \
  --set dataImport.config.expressUrl="https://new-express-url.com" \
  --set dataImport.config.s3AccessKeyId="NEW_AKIA_ACCESS_KEY" \
  --set dataImport.config.s3AccessKeySecret="NEW_SECRET_ACCESS_KEY" \
  --set dataImport.config.s3Region="us-west-2" \
  --set dataImport.config.csvSourceFile="s3://new-bucket/new-data.csv"
```

### Helm Values for Custom Data Importer

The following table provides a summary of the key *Helm values* that can be customized when deploying or upgrading the `custom-data-import` job:

<details>
<summary><code>dataImport.*</code></summary>

| Parameter                                 | Description                                                               | Default                       |
|-------------------------------------------|---------------------------------------------------------------------------|-------------------------------|
| `dataImport.enabled`                      | Enable or disable the `custom-data-import` job                            | `true`                        |
| `dataImport.image.repository`             | The Docker image repository for the custom data importer                  | `custom-data-importer`         |
| `dataImport.image.tag`                    | The Docker image tag for the custom data importer                         | `2.0.1`                       |
| `dataImport.image.pullPolicy`             | The image pull policy                                                     | `Always`                      |
| `dataImport.config.expressUrl`            | The URL for the express engine used in the import job                     | `https://express-engine-cluster-master:9200` |
| `dataImport.config.s3AccessKeyId`         | AWS S3 access key for reading the CSV data                                | `""`                          |
| `dataImport.config.s3AccessKeySecret`     | AWS S3 secret key for reading the CSV data                                | `""`                          |
| `dataImport.config.s3Region`              | AWS S3 region for accessing the bucket                                    | `us-east-1`                   |
| `dataImport.config.csvSourceFile`         | The source file for data import stored in S3                              | `s3://new-bucket/data.csv`    |

<hr>
</details>

### Monitoring the Custom Data Import Job

You can monitor the progress of the custom data import job using the following commands:

```bash
kubectl get pods -w -n geo-addressing
kubectl logs -f -l "app.kubernetes.io/name=custom-data-import" -n geo-addressing
```

---

This section provides users with the necessary information and commands to deploy and monitor the custom data import job using Helm.