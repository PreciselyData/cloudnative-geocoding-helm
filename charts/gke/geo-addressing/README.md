# Geo Addressing Helm Chart For GKE

## Helm Values

The `geo-addressing` helm chart follows [Go template language](https://pkg.go.dev/text/template) which is driven
by [values.yaml](values.yaml) file. The following is the summary of some *helm values*
provided by this chart:

> click the `▶` symbol to expand

<details>
<summary><code>global.*</code></summary>

| Parameter           | Description                                    | Default          |
|---------------------|------------------------------------------------|------------------|
| `global.nfs.path`   | The Path of Google Filestore Instance          | `/ga_data`       |
| `global.nfs.server` | The IP of the Google Filestore Instance Server | `10.122.176.250` |

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
