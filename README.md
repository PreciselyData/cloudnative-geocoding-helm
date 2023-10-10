# Geo Addressing Helm Charts

## Motivation

1. **Simplify Deployment:**
    - Streamline the Geo-Addressing SDK deployment process.
    - Ensure an effortless deployment experience.
    - Eliminate complexities for users when setting up the SDK.

2. **Seamless Updates:**
    - Guarantee seamless updates for both data and software.
    - Aim for zero downtime during updates, ensuring uninterrupted service.

3. **Hassle-Free Deployments:**
    - Prioritize user-centric deployment experiences.
    - Minimize potential deployment challenges and issues.

4. **Ready-Made Solution:**
    - Develop a plug-and-play solution for immediate use.
    - Minimize the need for extensive setup or configuration.

5. **Language-Barrier Elimination:**
    - Expose all SDK functionalities as REST endpoints.
    - Allow consumption of these endpoints by any type of client.
    - Eliminate language barriers, enabling broader compatibility.

6. **Microservices Deployment for Scalability:**
    - Create multiple microservices around the SDK.
    - Move away from building a single monolithic application for each SDK functionality.
    - Enhance scalability and flexibility by adopting a microservice architecture.

> This solution is specifically for users who are looking for REST interface to interact with Geo Addressing SDK and Kubernetes based deployments.


> [!IMPORTANT]
> 1. Please consider these helm charts as recommendations only. They come with predefined configurations that may not be the best fit for your needs. Configurations can be tweaked based on the use case and requirements.
> 2. These charts can be taken as a reference on how one can take advantage of the precisely data ecosystem and build a number of services around the same piece of software, creating a collection of microservices that can scale on a need basis.

## Architecture

![img.png](images/geo-addressing-architecture.png)
The core of the geo-addressing helm-chart-based solution relies on the Operational Addressing SDK (OAS). The robust
functionality of OAS forms the backbone of our geo-addressing solution, empowering it to deliver accurate and efficient
geo-addressing services while maintaining data integrity and usability.

The geo-addressing application is designed as a robust microservice-based architecture, utilizing a modular approach to
provide highly optimized, scalable and precise addressing solutions.

### Capabilities

Within this architecture, there are two key types of microservices:

- Regional Addressing Service: This microservice is an interface exposed to user consisting all the endpoints pertaining
  the geo-addressing capabilities:
    - Verify: performs address verification and standardization using the specified processing engine.
    - Geocode: performs forward geocoding using input addresses and returning location data and other information.
    - Reverse Geocode: performs reverse geocoding using input coordinates and returns address information that is the
      best match for that point.
    - Autocomplete: yields matched addresses and place for the given input addresses.
    - Lookup Service: returns geocoded candidates when given a unique key.
- Addressing Service (Country-Specific): These microservices are specialized for individual countries, allowing us to
  cater to unique addressing requirements and regulations in different regions. Each country-based addressing service is
  optimized for accuracy within its specific jurisdiction.

## Components

1. [Reference Data](#reference-data)
2. [Docker Images](#docker-images)
3. [Helm Charts](#helm-charts)

### Reference Data

Precisely offers a large variety of datasets, which can be utilized depending of the use case.

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

To download the reference data (country-specific data) and all the requirement components to run the Helm Chart,
visit [Precisely Data Portfolio](https://dataguide.precisely.com/) where you can also sign up for a free account and
access files available in [Precisely Data Experience](https://data.precisely.com/).

### Docker Images

The successful deployment of the geo-addressing helm chart relies on the availability of Docker images for several
essential microservices, all of which are conveniently obtainable from Precisely Data Experience. The required docker
images include:

1. Regional Addressing Service Docker Image
2. Addressing Service Docker Image

> [!NOTE]:  
> Contact Precisely for buying subscription to docker image

### Helm charts

The geo-addressing helm chart compromises of following components:

1. Parent Chart

- The parent chart is responsible for the deployment of `regional-addressing-service`.
- Additionally, it contains all the necessary helm components responsible for deploying geo-addressing application.

2. Sub-Charts

- addressing-svc:
    - deploys country-specific addressing services for `verify`, `geocode` capabilities.
- autocomplete-svc:
    - If enabled, it deploys country-specific addressing services for `autocomplete` capability.
- lookup-svc:
    - If enabled, it deploys country-specific addressing services for `lookup` capability.
- reverse-svc:
    - If enabled, it deploys country-specific addressing services for `reverse-geocode` capability.

3. Ingress
4. Horizontal Autoscaler (HPA)
5. Persistent Volume

> For more information related to geo-addressing helm chart, visit [this link](charts/geo-addressing/README.md).

## Setup

1. [Local Setup](#local-setup)
2. [Kubernetes Setup](#kubernetes-setup)

### Local Setup

The geo-addressing application can be setup locally for test purpose.

1. Download Docker Images:

- As mentioned in the [reference data](#reference-data) and [docker-images](#docker-images) sections, ensure that you've
  downloaded the reference data and required docker images from Precisely Data Experience.

2. Running Docker Images Locally:

- Follow [this section](docker-desktop/README.md) for more information on the local setup of geo-addressing application.

### Kubernetes Setup

The geo-addressing helm chart can be deployed on any kubernetes environment.
> NOTE: As of now, geo-addressing helm chart is only supported for AWS EKS.

Follow the following instructions on deploying the Helm Chart:

1. Geo-Addressing Helm Chart Details

- For more information on the geo-addressing helm chart, including its configuration options and usage, refer to
  the [geo-addressing helm chart documentation](charts/geo-addressing).

2. Access the Quick Start Guide

- To deploy the geo-addressing Helm chart in an AWS EKS cluster, please follow the step-by-step instructions outlined in
  our [Quick Start Guide](docs/guides/eks/QuickStartEKS.md)

## Guides

- [Reference Data Installation](charts/reference-data-setup/README.md)
- [Quickstart Guide for EKS](docs/guides/eks/QuickStartEKS.md)
- [Upgrade Guide for EKS](docs/guides/eks/UpgradeGuide.md)
- [Uninstall Guide for EKS](docs/guides/eks/UninstallGuide.md)

## Miscellaneous

### Observability

#### Metrics

The geo-addressing application microservices expose metrics which can be used for monitoring and troubleshooting the
performance and behavior of the geo-addressing application.

Depending on your alerting setup, you can set up alerts based on these metrics to proactively respond to the issues in
your application.

Refer to the following sections for Metrics:

- [Exposed Metrics](docs/guides/MetricsAndTraces.md#exposed-metrics)
- [Configuring Metrics Monitoring](docs/guides/MetricsAndTraces.md#configuring-metrics-monitoring)

#### Application Tracing

By default, Geo-Addressing generates, collects and exports the traces
using [OpenTelemetry Instrumentation](https://opentelemetry.io/).

These traces can then be easily monitored using Microservice Trace Monitoring tools
like [Jaeger](https://www.jaegertracing.io/docs/1.49/), [Zipkin](https://zipkin.io/)
, [Datadog](https://www.datadoghq.com/).

Refer to the following sections for Application Tracing:

- [Application Tracing using Jaeger](docs/guides/MetricsAndTraces.md#application-tracing)

#### Logs and Monitoring

The Geo-Addressing Application generates logs for all its services, such as regional-addressing, country-based
addressing, autocomplete, lookup, and reverse-geocode, and outputs them in JSON format to stdout.

Refer to the following sections for Logs and Monitoring:

- [Application Logs Monitoring](docs/guides/MetricsAndTraces.md#logs-and-monitoring)

### FAQs

If you encounter any challenges or have questions during the deployment of the geo-addressing helm chart, we recommend
checking our [FAQs section](docs/faq/FAQs.md). This resource provides answers to common questions and solutions to known
issues, offering assistance in troubleshooting any deployment-related difficulties you may encounter. If your question
is not covered in the FAQs, feel free to reach out to our support team for personalized assistance.

## References

- Parameters for Helm Chart
    - [Environment Variables](charts/geo-addressing/README.md#environment-variables)
    - [Helm Values](charts/geo-addressing/README.md#helm-values)
- [Memory Recommendations](charts/geo-addressing/README.md#memory-recommendations)
- [Geo-Addressing Service API Usage](charts/geo-addressing/README.md#geo-addressing-service-api-usage)

## Links

- [Geo-Addressing API Guide](https://docs.precisely.com/docs/sftw/ggs/5.0/en/webhelp/GeoAddressingSDKDeveloperGuide/GlobalGeocodingGuide/source/AddressingAPI/addressing_api_title.html)
- [Geo-Addressing Helm Chart Design](charts/geo-addressing)
- [Reference Data Installation](charts/reference-data-setup/README.md)
- [Trying out on Local Docker Desktop](docker-desktop/README.md)
- [FAQs](docs/faq/FAQs.md)