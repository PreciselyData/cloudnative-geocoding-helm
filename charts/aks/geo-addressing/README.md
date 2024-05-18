# Geo-Addressing Helm Chart For AKS

## Helm Values

The `geo-addressing` helm chart follows [Go template language](https://pkg.go.dev/text/template) which is driven
by [values.yaml](values.yaml) file. The following is the summary of some *helm values*
provided by this chart:

> click the `▶` symbol to expand

<details>
<summary><code>global.*</code></summary>

| Parameter                   | Description                         | Default              |
|-----------------------------|-------------------------------------|----------------------|
| `global.nfs.shareName`      | The Azure File Storage Share Name   | `geoaddressingshare` |
| `global.nfs.storageAccount` | The Azure File Storage Account Name | `geoaddressing`      |

<hr>
</details>

<details>
<summary><code>geo-addressing.*</code></summary>

| Parameter          | Description                           | Default             |
|--------------------|---------------------------------------|---------------------|
| `geo-addressing.*` | The generic geo-addressing helm chart | `see <values.yaml>` |

<hr>
</details>

> NOTE: For more details of Geo-Addressing Helm Chart, see
> the [geo-addressing component helm chart](../../component-charts/geo-addressing-generic/README.md)

[🔗 Return to `Table of Contents` 🔗](../../../README.md#components)
