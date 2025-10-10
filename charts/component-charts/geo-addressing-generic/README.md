# Geo Addressing Helm Chart

Built upon the [architecture](../../../README.md#architecture), the geo-addressing helm chart offers flexibility to
users, allowing them to configure and set up infrastructure according to their
specific requirements.

For example, if a user wishes to establish 'verify', 'geocode' and 'autocomplete' functionalities
for the 'USA,' 'CAN,' 'GBR,' and 'DEU' countries exclusively, they can provide the necessary configurations during the
Helm chart installation to deploy this specific type of infrastructure.

## Getting Started

To get started with installation of helm chart, follow:
<br><br>For Amazon EKS: [Quick Start Guide for EKS](../../../docs/guides/eks/QuickStartEKS.md)
<br>For Microsoft AKS: [Quick Start Guide for AKS](../../../docs/guides/aks/QuickStartAKS.md)
<br>For Google's GKE: [Quick Start Guide for GKE](../../../docs/guides/gke/QuickStartGKE.md)

## Understanding Geo Addressing Helm charts

The geo-addressing helm chart compromises of following components:

- Environment Specific Parent Helm Chart
    - The environment specific parent chart is responsible for configurations related to specific cloud platform like
      network file storages, regions, etc.

- Component Chart
    - The geo-addressing generic component chart is responsible for the deployment of `regional-addressing-service`.
    - Additionally, it contains all the necessary helm components responsible for deploying geo-addressing application.

- Sub-Charts
    - addressing-svc:
        - deploys country-specific addressing services for `verify`, `geocode` capabilities.
    - autocomplete-svc:
        - If enabled, it deploys country-specific addressing services for `autocomplete` capability.
    - lookup-svc:
        - If enabled, it deploys country-specific addressing services for `lookup` capability.
    - reverse-svc:
        - If enabled, it deploys country-specific addressing services for `reverse-geocode` capability.
    - addressing-express:
        - If enabled, it deploys addressing-express service.
        - addressing-express needs some specific configuration in cluster.
        - Nodes to deploy the express-engine which is part of the addressing-express chart shoud be ARM based CPU
          optimized instances like the `c7g.8xlarge` instance types in AWS, `Standard_D32ds_v5` instance types in
          Microsoft AKS.
        - addressing-express engine has two components, with different behaviors of scheduling
            - express-engine-data : One-to-One POD to Node scheduling
            - express-engine-master: Many-to-One POD to Node scheduling
    - event-emitter:
        - If enabled, it will deploy event-emitter service.
        - This service collects events and generates reports in your Precisely DIS account. (
          Follow <a href="https://help.precisely.com/r/Precisely-Data-Integrity-Suite/Latest/en-US/Data-Integrity-Suite/Account/Usage">
          this link</a> for more information.)

Feel free to modify these helm charts and update it based on your needs.

## Custom Regions for Geo Addressing Helm Charts

The geo-addressing helm chart provides flexibility to deploy custom regions for addressing functionality.

You can create the custom regions by providing the `global.customRegions` parameter in the
[values.yaml](values.yaml) file.

Follow the below steps to create a custom region:

### Deploy Reference Data according to custom regions

To create a custom region, you first need to deploy the reference data according to your custom region.
e.g. If you want to create a custom region named `apac` with countries `ind`, `pak`, and `china` 
along with separate deployment for `usa`, you need to deploy the relevant reference data
for these countries in the NFS path with the region's folder name as follows:

NOTE: `apac` is just region created for countries `ind`, `pak`, and `china` for this example only, 
you can add other custom regions accordingly. Also, create custom regions according to the functionality.
e.g. If lookup functionality is not required, you can skip creating custom region for lookup.


```json
{
  "verify-geocode": {
    "usa": [
      "Geocoding MLD US#United States#All USA#Spectrum Platform Data",
      "Geocoding NT Street US#United States#All USA#Spectrum Platform Data"
    ],
    "apac": [
      "Geocoding World Places Geocoder#Global#All GLB#Geocoding"
    ]
  },
  "autocomplete": {
    "usa": [
      "Predictive Addressing Points#United States#All USA#Interactive"
    ],
    "apac": [
      "Address Autocomplete Data Option 3#Americas#ALL AME#INTERACTIVE"
    ]
  },
  "lookup": {
    "usa": [
      "Geocoding MLD US#United States#All USA#Spectrum Platform Data",
      "Geocoding NT Street US#United States#All USA#Spectrum Platform Data",
      "Geocoding Reverse PRECISELYID#United States#All USA#Spectrum Platform Data"
    ],
    "apac": [
      "Geocoding World Places Geocoder#Global#All GLB#Geocoding"
    ]
  }
}
```
By this way, you can upload reference data of custom regions with multiple countries for different functionalities.


### Update custom region parameters in values.yaml

Once the reference data is deployed according to the custom regions, 
you need to provide the custom region parameters based on the functionality enabled.
and update the [values.yaml](values.yaml) file as follows:
```yaml
global:
  countries: 
    - usa
    - apac  # add your custom region only here also
  
  # provide the mapping of countries for your region for verify-geocode and reverse-geocode functionality
  customRegions: |
    {
      "apac": ["ind", "pak", "china"]
    }
    
  # provide the mapping of countries for your region for autocomplete functionality
  customRegionsAutocomplete: |
    {
      "apac": ["ind", "pak", "china"]
    }

  # provide the mapping of countries for your region for lookup functionality
  customRegionsLookup: |
    {
      "apac": ["ind", "pak", "china"]
    }
```
**NOTE: Add your custom region in the countries parameter also.**

Once you deploy the helm chart with the above configuration, it will create a service having custom region `apac`.
Also, this service will be responsible for handling requests for provided countries `ind`, `pak`, and `china` only.

Note: Avoid deploying the same country both as part of a custom region and as a separate deployment. 
If a country is duplicated in this way, it is not guaranteed which service will process requests for that country. 
For example, do **NOT** include `usa` in the `apac` custom region while also deploying it separately.

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
| `image.tag`        | the regional-addressing container image version tag | `3.0.2`                       |

<hr>
</details>

<details>
<summary><code>ingress.*</code></summary>

| Parameter                        | Description                                             | Default                       |
|----------------------------------|---------------------------------------------------------|-------------------------------|
| `ingress.enabled`                | ingress is disabled by default                          | `false`                       |
| `ingress.hosts[0].host`          | the ingress host url base path                          | `geoaddressing.precisely.com` |
| `ingress.hosts[0].paths[0].path` | the base path for accessing regional-addressing service | `/precisely/addressing`       |

<hr>
</details>

<details>
<summary><code>global.*</code></summary>

| Parameter                                         | Description                                                                                                                                                                                                                        | Default                        |
|---------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|
| `global.countries`                                | this parameter enables the provided country for an addressing functionality. A comma separated value can be provided to enable a particular set of countries from: `usa,gbr,deu,aus,fra,can,mex,bra,arg,rus,ind,sgp,nzl,jpn,world` | `{usa,gbr,aus,nzl,can}`        |
| `global.customRegions`                            | this parameter enables custom regions for addressing functionality. A JSON of region with comma separated countries as values can be provided to enable a particular region: `{"apac": ["ind", "pak", "china"]}`                   | `{}`                           |
| `global.manualDataConfig.*`                       | the config to enable the manual configuration for country-specific vintage data config-map. `addressing-hook.enabled` should be set to false, else `global.manualDataConfig` will be given higher precedence.                      | `false`                        |
| `global.addressingImage.repository`               | the addressing-service container image repository                                                                                                                                                                                  | `addressing-service`           |
| `global.addressingImage.tag`                      | the addressing-service container image version tag                                                                                                                                                                                 | `3.0.2`                        |
| `global.expressEngineImage.repository`            | the express-engine container image repository                                                                                                                                                                                      | `express-engine`               |
| `global.expressEngineImage.tag`                   | the express-engine container image version tag                                                                                                                                                                                     | `3.0.2`                        |
| `global.expressEngineDataRestoreImage.repository` | the express-engine-data-restore container image repository                                                                                                                                                                         | `express-engine-data-restore`  |
| `global.expressEngineDataRestoreImage.tag`        | the express-engine-data-restore container image version tag                                                                                                                                                                        | `3.0.2`                        |
| `global.eventEmitterImage.repository`             | the event-emitter container image repository                                                                                                                                                                                       | `event-emitter`                |
| `global.eventEmitterImage.tag`                    | the event-emitter container image version tag                                                                                                                                                                                      | `3.0.2`                        |
| `global.nfs.addressingBasePath`                   | the base path of the folder where verify-geocode data is present                                                                                                                                                                   | `verify-geocode`               |
| `global.nfs.autoCompleteBasePath`                 | the base path of the folder where autocomplete data is present                                                                                                                                                                     | `autocomplete`                 |
| `global.nfs.lookupBasePath`                       | the base path of the folder where lookup data is present                                                                                                                                                                           | `lookup`                       |
| `global.nfs.reverseBasePath`                      | the base path of the folder where reverse-geocode data is present                                                                                                                                                                  | `verify-geocode`               |
| `global.nfs.expressEngineDataMountPath`           | the mount path of the folder where express-engine data is present                                                                                                                                                                  | `/usr/share/express_snapshots` |
| `global.nfs.expressEngineBasePath`                | the base path of the folder where express-engine data is present                                                                                                                                                                   | `verify-express_data`          |

<hr>
</details>

<details>
<summary><code>addressing-hook.*</code></summary>

| Parameter                 | Description                                                                                                                                                             | Default |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|
| `addressing-hook.enabled` | flag to enable or disable the hook jobs for identifying the latest vintage. If you want to disable the hook, you should provide `global.manualDataConfigs` information. | `true`  |

<hr>
</details>

<details>
<summary><code>addressing-svc.*</code></summary>

| Parameter                                | Description                                                                                 | Default             |
|------------------------------------------|---------------------------------------------------------------------------------------------|---------------------|
| `addressing-svc.enabled`                 | the flag to indicate whether `verify-geocode` functionality is enabled or not               | `true`              |
| `addressing-svc.countryConfigurations.*` | the country-specific configurations like resource requests, nodeSelector and threadPoolSize | `<see values.yaml>` |

<hr>
</details>

<details>
<summary><code>addressing-hook.*</code></summary>

| Parameter                                  | Description                                                                                 | Default             |
|--------------------------------------------|---------------------------------------------------------------------------------------------|---------------------|
| `autocomplete-svc.enabled`                 | the flag to indicate whether `autocomplete` functionality is enabled or not                 | `false`             |
| `autocomplete-svc.countryConfigurations.*` | the country-specific configurations like resource requests, nodeSelector and threadPoolSize | `<see values.yaml>` |

<hr>
</details>

<details>
<summary><code>addressing-hook.*</code></summary>

| Parameter                            | Description                                                                                 | Default             |
|--------------------------------------|---------------------------------------------------------------------------------------------|---------------------|
| `lookup-svc.enabled`                 | the flag to indicate whether `lookup` functionality is enabled or not                       | `false`             |
| `lookup-svc.countryConfigurations.*` | the country-specific configurations like resource requests, nodeSelector and threadPoolSize | `<see values.yaml>` |

<hr>
</details>

<details>
<summary><code>reverse-svc.*</code></summary>

| Parameter                             | Description                                                                                 | Default             |
|---------------------------------------|---------------------------------------------------------------------------------------------|---------------------|
| `reverse-svc.enabled`                 | the flag to indicate whether `reverse-geocode` functionality is enabled or not              | `false`             |
| `reverse-svc.countryConfigurations.*` | the country-specific configurations like resource requests, nodeSelector and threadPoolSize | `<see values.yaml>` |

<hr>
</details>


<details>
<summary><code>addressing-express.*</code></summary>

| Parameter                                             | Description                                                                                                                                                                                                              | Default |
|-------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|
| `addressing-express.expressEngineMaster.*`            | Values for Express Engine Master                                                                                                                                                                                         |         |
| `addressing-express.expressEngineData.*`              | Values for Express Engine Master                                                                                                                                                                                         |         |
| `addressing-express.expressEngineDataRestore.enabled` | flag to enable or disable the express engine data restore job. Refer to the comments in [values.yaml](../../../charts/component-charts/geo-addressing-generic/values.yaml) for express engine manual data configuration. | `true`  |

<hr>
</details>

<details>
<summary><code>event-emitter.*</code></summary>

| Parameter                                 |   | Description                                                                                                                                               | Default      |
|-------------------------------------------|:--|-----------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|
| `event-emitter.enabled`                   |   | flag to enable or disable the event-emitter. Refer to the comments in [values.yaml](../../../charts/component-charts/geo-addressing-generic/values.yaml). | `true`       |
| `event-emitter.configuration.USER_KEY`    |   | The DIS API KEY required for running event-emitter.                                                                                                       | `*mandatory` |
| `event-emitter.configuration.USER_SECRET` |   | The DIS API SECRET required for running event-emitter.                                                                                                    | `*mandatory` |

<hr>
</details>

## Environment Variables

> click the `▶` symbol to expand.

NOTE: `*` indicates that we recommend not to modify those values during installation.

<details>
<summary><code>regional-addressing-service</code></summary>

Refer to [this file](templates/deployment.yaml) for overriding the environment variables for regional addressing
service.

| Parameter                              | Description                                                                                                                                                                                                                                                                                        | Default                                                                        |
|----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| `*ADDRESSING_BASE_URL`                 | The internal url of country-based verify/geocode service                                                                                                                                                                                                                                           | `http://addressing-<region>.{{ .Release.Namespace }}.svc.cluster.local:8080`   |
| `*ADDRESSING_EXPRESS_BASE_URL`         | The internal url of addressing-express service service                                                                                                                                                                                                                                             | `http://addressing-express.{{ .Release.Namespace }}.svc.cluster.local:8080`    |
| `LOOKUP_BASE_URL`                      | The internal url of country-based lookup service. If you prefer not to maintain separate infrastructure for the lookup service and would like all calls to be handled by the addressing service, you have the flexibility to modify this URL and point it to addressing service.                   | `http://lookup-<region>.{{ .Release.Namespace }}.svc.cluster.local:8080`       |
| `AUTOCOMPLETE_BASE_URL`                | The internal url of country-based autocomplete service. If you prefer not to maintain separate infrastructure for the autocomplete service and would like all calls to be handled by the addressing service, you have the flexibility to modify this URL and point it to addressing service.       | `http://autocomplete-<region>.{{ .Release.Namespace }}.svc.cluster.local:8080` |
| `REVERSE_GEOCODE_BASE_URL`             | The internal url of country-based reverse-geocode service. If you prefer not to maintain separate infrastructure for the reverse-geocode service and would like all calls to be handled by the addressing service, you have the flexibility to modify this URL and point it to addressing service. | `http://reverse-<region>.{{ .Release.Namespace }}.svc.cluster.local:8080`      |
| `OTEL_EXPORTER_OTLP_ENDPOINT`          | If tracing is enabled, this is the endpoint for tracer host.                                                                                                                                                                                                                                       | `http://jaeger-collector.default.svc.cluster.local:4317`                       |
| `*SUPPORTED_COUNTRIES_GEOCODE`         | The countries that are supported for geocode functionality.                                                                                                                                                                                                                                        | `<referred from global.countries>`                                             |
| `CUSTOM_REGIONS_ADDRESSING`            | The custom regions along with countries for geocode functionality.                                                                                                                                                                                                                                 | `<referred from global.customRegions>`                                         |
| `*SUPPORTED_REGIONS_GEOCODE`           | The regions that are supported for geocode functionality.                                                                                                                                                                                                                                          |                                                                                |
| `*SUPPORTED_COUNTRIES_VERIFY`          | The countries that are supported for verify.                                                                                                                                                                                                                                                       | `<referred from global.countries>`                                             |
| `*SUPPORTED_REGIONS_VERIFY`            | The regions that are supported for verify.                                                                                                                                                                                                                                                         |                                                                                |
| `*SUPPORTED_COUNTRIES_LOOKUP`          | The countries that are supported for lookup.                                                                                                                                                                                                                                                       | `<referred from global.countries>`                                             |
| `*SUPPORTED_COUNTRIES_AUTOCOMPLETE`    | The countries that are supported for autocomplete.                                                                                                                                                                                                                                                 | `<referred from global.countries>`                                             |
| `*SUPPORTED_COUNTRIES_REVERSE_GEOCODE` | The regions that are supported for lookup.                                                                                                                                                                                                                                                         |                                                                                |
| `*AUTH_ENABLED`                        | Flag to indicate whether authorization is enabled for the endpoints or not.                                                                                                                                                                                                                        | `false`                                                                        |
| `*IS_HELM_SOLUTION`                    | Flag to indicate if on-premise helm solution is deployed.                                                                                                                                                                                                                                          | `true`                                                                         |
| `*IS_NO_COUNTRY_ENABLED_V2`            | Flag to enable geocoding without country.                                                                                                                                                                                                                                                          | `true`                                                                         |

<hr>
</details>

<details>
<summary><code>addressing-service</code></summary>

Refer to the [deployment.yml](charts/addressing-svc/templates/deployment.yaml) of respective service for override
variables for addressing-service.

| Parameter                     | Description                                                                                                      | Default                                                  |
|-------------------------------|------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------|
| `*DATA_PATH`                  | Default path of the installed reference data. Please refer to the recommended path for the installation of data. | `<referenced from configMap>`                            |
| `*DATA_REGION`                | The value of the referenced country or region.                                                                   | `<depends on the provided country e.g. usa/aus/can>`     |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | If tracing is enabled, this is the endpoint for tracer host.                                                     | `http://jaeger-collector.default.svc.cluster.local:4317` |
| `*AUTH_ENABLED`               | Flag to indicate whether authorization is enabled for the endpoints or not.                                      | `false`                                                  |
| `*GEOCODE_VERIFY_ENABLED`     | Flag to enable geocode and verify endpoints.                                                                     | `true for addressing service`                            |
| `*AUTOCOMPLETE_ENABLED`       | Flag to enable autocomplete endpoint.                                                                            | `true for autocomplete service`                          |
| `*LOOKUP_ENABLED`             | Flag to enable lookup endpoint.                                                                                  | `true for lookup service`                                |
| `*REVERSEGEOCODE_ENABLED`     | Flag to enable reverse-geocode endpoint.                                                                         | `true for reverse-geocode service`                       |

<hr>
</details>

<details>
<summary><code>addressing-express</code></summary>

Refer to the [deployment.yml](charts/addressing-express/templates/deployment.yaml) of respective service for override
variables for addressing-express.

| Parameter                     | Description                                                                 | Default                                                  |
|-------------------------------|-----------------------------------------------------------------------------|----------------------------------------------------------|
| `OTEL_EXPORTER_OTLP_ENDPOINT` | If tracing is enabled, this is the endpoint for tracer host.                | `http://jaeger-collector.default.svc.cluster.local:4317` |
| `*AUTH_ENABLED`               | Flag to indicate whether authorization is enabled for the endpoints or not. | `false`                                                  |
| `*AUTOCOMPLETE_V2_ENABLED`    | Flag to enable autocomplete V2 endpoint endpoint.                           | `true for addressing-express service`                    |
| `*COUNTRY_FINDER_ENABLED`     | Flag to enable automatic country finder from single line address endpoint.  | `true for addressing-express service`                    |
| `*EXPRESS_URL`                | Url to express-engine-master service endpoint.                              | `https://express-engine-cluster-master:9200`             |

<hr>
</details>

<details>
<summary><code>event-emitter</code></summary>

Refer to the [deployment.yml](charts/event-emitter/templates/deployment.yaml) of respective service for override
variables for event-emitter service.

| Parameter      | Description                                                                                                                                                                                                                      | Default                                                                                    |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `*NATS_URL`    | Url of the NATS server which gets deployed along with the service.                                                                                                                                                               | `{{ printf "nats://%s-nats.%s.svc.cluster.local:4222" .Release.Name .Release.Namespace }}` |
| `*BASE_URL`    | The BASE URL of the DIS API Service.                                                                                                                                                                                             | `https://api.cloud.precisely.com`                                                          |
| `*USER_KEY`    | DIS API User Key. Follow <a href ="https://help.precisely.com/r/Precisely-Data-Integrity-Suite/Latest/en-US/Data-Integrity-Suite/Account/API-Keys/Manage-API-Keys">this</a> link for creating the User Access Key and Secret.    | `<event-emitter.configuration.USER_KEY>`                                                   |
| `*USER_SECRET` | DIS API User Secret. Follow <a href ="https://help.precisely.com/r/Precisely-Data-Integrity-Suite/Latest/en-US/Data-Integrity-Suite/Account/API-Keys/Manage-API-Keys">this</a> link for creating the User Access Key and Secret. | `<event-emitter.configuration.USER_SECRET>`                                                |

<hr>
</details>

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

> Note: For addressing-express recommended memory and cpu resource requirements are part of the
> chart [values.yaml](values.yaml) file.

You can adjust the values in [values.yaml](values.yaml), or you can set these parameters in the helm command itself
during installation/up-gradation.

## Geo Addressing Service API Usage

The geo-addressing service exposes different operational-addressing APIs like geocode, verify, reverse-geocode, lookup,
etc.

You can use the [postman collection](../../../scripts/Geo-Addressing-Helm.postman_collection.json) provided in the
repository for hitting the APIs.

Few APIs and sample requests are provided below:

### `/v1/geocode`:

API to geocode the addresses

Sample Request:

```curl
curl -X 'POST' \
  'https://[EXTERNAL-URL]/v1/geocode' \
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

```curl
curl -X 'POST' \
  'https://[EXTERNAL-URL]/v1/geocode' \
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
      ]
    }
  ]
}'
```

### `/v1/verify`:

API to verify the addresses

Sample Request:

```curl
curl -X 'POST' \
  'https://[EXTERNAL-URL]/v1/verify' \
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

### `/v1/reverse-geocode`:

API to reverse-geocode the addresses

Sample Request:

```curl
curl -X 'POST' \
  'https://[EXTERNAL-URL]/v1/reverse-geocode' \
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

### `/v1/lookup`:

API to `lookup` the addresses

Sample Request:

```curl
curl -X 'POST' \
  'https://[EXTERNAL-URL]/v1/lookup' \
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

### `/v1/autocomplete`:

API to autocomplete the addresses

Sample Request:

```curl
curl --location 'https://[EXTERNAL-URL]/v1/autocomplete' --header 'Content-Type: application/json' --data '{
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

### `/v1/express-autocomplete`:

API to autocomplete the addresses

Sample Request:

```curl
curl --location 'http://[EXTERNAL-URL]/v1/express-autocomplete' \
--header 'Content-Type: application/json' \
--data '{
    "preferences": {
        "maxResults": 5,
        "originXY": [
            -71.207799,
            42.483939
        ],
        "distance": {
            "value": 10,
            "distanceUnit": "MILE"
        },
        "customPreferences": {
            "SEARCH_TYPE": "ADDRESS"
        }
    },
    "address": {
        "addressLines": [
            "1700 DISTRICT"
        ],
        "country": "USA"
    }
}'
```

### `/v1/addressing/reference-data/info`:

API to get details of reference data deployed for a country and api

Sample Request:

```
curl --location 'http://[EXTERNAL-URL]/v1/addressing/reference-data/info?country=<country-name>&api=<api>'
```

Example:

```
curl --location 'http://[EXTERNAL-URL]/v1/addressing/reference-data/info?country=usa&api=geocode'
```

[🔗 Return to `Table of Contents` 🔗](../../../README.md#components)
