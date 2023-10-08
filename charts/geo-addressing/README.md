# Geo-Addressing Helm Chart

Built upon the [architecture](../../README.md#architecture), this chart comprises a parent Helm chart for the '
regional-addressing' service and subsequent sub-charts for requirement-based, country-specific 'addressing-service' Helm
charts.

This design offers flexibility to users, allowing them to configure and set up infrastructure according to their
specific requirements. For example, if a user wishes to establish 'verify', 'geocode' and 'autocomplete' functionalities
for the 'USA,' 'CAN,' 'GBR,' and 'DEU' countries exclusively, they can provide the necessary configurations during the
Helm chart installation to deploy this specific type of infrastructure.

Additionally, with the assistance of `regional-addressing`, users have the capability to deploy individual premium
countries with a high volume of requests or loads. They can also create custom regions to group together countries with
fewer requests or loads, allowing them to deploy a single addressing service for these regions.

## Helm Values

The `geo-addressing` helm chart follows [Go template language](https://pkg.go.dev/text/template) which is driven
by [values.yaml](values.yaml) file. The following is the summary of some *helm values*
provided by this chart:

> click the `▶` symbol to expand

<details>
<summary><code>image.*</code></summary>

| Parameter          | Description                                         | Default                       |
|--------------------|-----------------------------------------------------|-------------------------------|
| `image.repository` | the regional-addressing container image repository  | `regional-addressing-service` |
| `image.tag`        | the regional-addressing container image version tag | `latest`                      |

<hr>
</details>

<details>
<summary><code>ingress.*</code></summary>

| Parameter                        | Description                                             | Default                       |
|----------------------------------|---------------------------------------------------------|-------------------------------|
| `ingress.hosts[0].host`          | the ingress host url base path                          | `geoaddressing.precisely.com` |
| `ingress.hosts[0].paths[0].path` | the base path for accessing regional-addressing service | `/precisely/addressing`       |

<hr>
</details>


<details>
<summary><code>global.*</code></summary>

| Parameter                                         | Description                                                                                 | Default                 |
|---------------------------------------------------|---------------------------------------------------------------------------------------------|-------------------------|
| `global.countries`                                | this parameter enables the provided country for an addressing functionality                 | `{usa,gbr,aus,nzl,can}` |
| `global.awsRegion`                                | the region for where elastic file system is present.                                        | `us-east-1`             |
| `global.addressingImage.repository`               | the addressing-service container image repository                                           | `addressing-service`    |
| `global.addressingImage.tag`                      | the addressing-service container image version tag                                          | `latest`                |
| `global.efs.fileSystemId`                         | the fileSystemId of the elastic file system (e.g. fs-0d49e756a)                             | `fileSystemId`          |
| `global.nodeSelector`                             | the default nodeSelector for all the addressing services                                    | `{}`                    |
| `global.addressing-svc.enabled`                   | the flag to indicate whether `verify-geocode` functionality is enabled or not               | `true`                  |
| `global.addressing-svc.countryConfigurations.*`   | the country-specific configurations like resource requests, nodeSelector and threadPoolSize | `<see values.yaml>`     |
| `global.autocomplete-svc.enabled`                 | the flag to indicate whether `autocomplete` functionality is enabled or not                 | `false`                 |
| `global.autocomplete-svc.countryConfigurations.*` | the country-specific configurations like resource requests, nodeSelector and threadPoolSize | `<see values.yaml>`     |
| `global.lookup-svc.enabled`                       | the flag to indicate whether `lookup` functionality is enabled or not                       | `false`                 |
| `global.lookup-svc.countryConfigurations.*`       | the country-specific configurations like resource requests, nodeSelector and threadPoolSize | `<see values.yaml>`     |
| `global.reverse-svc.enabled`                      | the flag to indicate whether `reverse-geocode` functionality is enabled or not              | `false`                 |
| `global.reverse-svc.countryConfigurations.*`      | the country-specific configurations like resource requests, nodeSelector and threadPoolSize | `<see values.yaml>`     |

<hr>
</details>

## Getting Started

To get started with installation of helm chart, follow this [Quick Start Guide](../../docs/guides/eks/QuickStartEKS.md)

## Memory Recommendations

The `regional-addressing` pod is responsible for managing requests and routing them to
country-based `addressing-service` pods. Since each country has its own unique reference data, we recommend allocating a
minimum amount of pod memory for the addressing-services for each specific country, as outlined below:

| Country | Addressing (Verify-Geocode) | Autocomplete | Lookup | Reverse-Geocode |
|---------|-----------------------------|--------------|--------|-----------------|
| USA     | 8Gi                         | 6Gi          | 6Gi    | 8Gi             |
| AUS     | 6Gi                         | 8Gi          | 6Gi    | 8Gi             |
| CAN     | 6Gi                         | 4Gi          | 6Gi    | 8Gi             |
| GBR     | 6Gi                         | 6Gi          | 6Gi    | 8Gi             |
| DEU     | 6Gi                         | 6Gi          | 6Gi    | 8Gi             |
| NZL     | 10Gi                        | 6Gi          | 6Gi    | 8Gi             |
| FRA     | 7Gi                         | 6Gi          | 6Gi    | 8Gi             |

You can adjust the values in [values.yaml](values.yaml), or you can set these parameters in the helm command itself during installation/up-gradation.


## Geo-Addressing Service API Usage

The geo-addressing service exposes different operational-addressing APIs like geocode, verify, reverse-geocode, lookup,
etc.

You can use the [postman collection](../../scripts/Geo-Addressing-Helm.postman_collection.json) provided in the
repository for hitting the APIs.

Few APIs and sample requests are provided below:

### `/li/v1/oas/geocode`:

API to geocode the addresses

Sample Request:

```curl
curl -X 'POST' \
  'https://[EXTERNAL-URL]/li/v1/oas/geocode' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "preferences": {
        "customPreferences": {
            "FALLBACK_TO_WORLD": "false"
        },
        "returnAllInfo": true
    },
  "addresses": [
    {
      "addressLines": [
        "1700 district ave #300 burlington, ma"
      ],
      "country": "USA"
    }
  ]
}'
```

### `/li/v1/oas/verify`:

API to verify the addresses

Sample Request:

```curl
curl -X 'POST' \
  'https://[EXTERNAL-URL]/li/v1/oas/verify' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "preferences": {
        "customPreferences": {
            "FALLBACK_TO_WORLD": "false"
        },
        "returnAllInfo": true
    },
  "addresses": [
    {
      "addressLines": [
        "1700 district ave #300 burlington, ma"
      ],
      "country": "USA"
    }
  ]
}'
```

### `/li/v1/oas/reverse-geocode`:

API to reverse-geocode the addresses

Sample Request:

```curl
curl -X 'POST' \
  'https://[EXTERNAL-URL]/li/v1/oas/reverse-geocode' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "preferences": {
        "maxResults": 1,
        "returnAllInfo": true,
        "customPreferences": {
            "FALLBACK_TO_WORLD": "false"
        }
    },
  "locations": [
    {
      "longitude": -73.704719,
      "latitude": 42.682251,
      "country": "USA"
    }
  ]
}'
```

### `/li/v1/oas/lookup`:

API to lookup the addresses

Sample Request:

```curl
curl -X 'POST' \
  'https://[EXTERNAL-URL]/li/v1/oas/lookup' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "preferences": {
        "maxResults": 1,
        "returnAllInfo": true,
        "streetOffset": {
            "value": 7,
            "distanceUnit": "METER"
        },
        "cornerOffset": {
            "value": 7,
            "distanceUnit": "METER"
        },
        "customPreferences": {
            "FALLBACK_TO_WORLD": "false"
        }
    },
  "keys": [
    {
      "key": "P0000GL41OME",
      "country": "USA",
      "type": "PB_KEY"
    }
  ]
}'
```

### `/li/v1/oas/autocomplete`:

API to autocomplete the addresses

Sample Request:

```curl
curl --location 'https://[EXTERNAL-URL]/li/v1/oas/autocomplete' --header 'Content-Type: application/json' --data '{
  "preferences": {
        "maxResults": 2,
        "returnAllInfo": true,
        "customPreferences": {
            "FALLBACK_TO_WORLD": "false"
        }
    },
  "address": {
    "addressLines": [
      "350 jordan"
    ],
    "country": "USA"
  }
}'
```

## Next Sections
- [Reference Data Installation](charts/reference-data-setup/README.md)
- [Quickstart Guide for EKS](docs/guides/eks/QuickStartEKS.md)
- [Trying out on Local Docker Desktop](docker-desktop/README.md)
- [Metrics, Traces and Dashboards](docs/guides/MetricsAndTraces.md)
- [FAQs](docs/faq/FAQs.md)
