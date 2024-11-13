# Geo Addressing Helm Chart For EKS

## Helm Values

The `geo-addressing` helm chart follows [Go template language](https://pkg.go.dev/text/template) which is driven
by [values.yaml](values.yaml) file. The following is the summary of some *helm values*
provided by this chart:

> click the `▶` symbol to expand

<details>
<summary><code>global.*</code></summary>

| Parameter                                       | Description                                                                                                                                         | Default        |
|-------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|----------------|
| *`global.awsRegion`                             | The AWS Region of AWS EFS                                                                                                                           | `us-east-1`    |
| *`global.nfs.fileSystemId`                      | The EFS fileSystemId                                                                                                                                | `fileSystemId` |
| `global.addressingHook.storageClass.enabled`    | If you want to provide a custom Storage class for Addressing Hook, you need to disable this flag and set the storageClass Name Parameter.           | `true`         |
| `global.addressingHook.storageClass.name`       | If you want to provide a custom Storage class for Addressing Hook, you need to disable the flag and set the storageClass Name Parameter.            | `~`            |
| `global.nfs.storageClass.enabled`               | If you want to provide a custom Storage class for Addressing Service, you need to disable this flag and set the storageClass Name Parameter.        | `true`         |
| `global.nfs.storageClass.name`                  | If you want to provide a custom Storage class for Addressing Service, you need to disable the flag and set the storageClass Name Parameter.         | `~`            |
| `global.addressingExpress.storageClass.enabled` | If you want to provide a custom Storage class for Addressing Express Engine, you need to disable this flag and set the storageClass Name Parameter. | `true`         |
| `global.addressingExpress.storageClass.name`    | If you want to provide a custom Storage class for Addressing Express Engine, you need to disable the flag and set the storageClass Name Parameter.  | `~`            |

<hr>
</details>

<details>
<summary><code>geo-addressing.*</code></summary>

| Parameter          | Description                           | Default             |
|--------------------|---------------------------------------|---------------------|
| `geo-addressing.*` | The generic geo-addressing helm chart | `see <values.yaml>` |

<hr>
</details>

> NOTE: For more details of Geo Addressing Helm Chart, see
> the [geo-addressing component helm chart](../../component-charts/geo-addressing-generic/README.md)

[🔗 Return to `Table of Contents` 🔗](../../../README.md#components)
