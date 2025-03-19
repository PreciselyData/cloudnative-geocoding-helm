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

> This solution is specifically for users who are looking for REST interface to interact with Geo Addressing SDK and
> Kubernetes based deployments.


> [!IMPORTANT]
> 1. Please consider these helm charts as recommendations only. They come with predefined configurations that may not be
     the best fit for your needs. Configurations can be tweaked based on the use case and requirements.
> 2. These charts can be taken as a reference on how one can take advantage of the precisely-data ecosystem and build a
     number of services around the same piece of software, creating a collection of microservices that can scale on a
     need basis.

## Architecture

![architecture.png](images/geoaddressing_architecture.png)

<br>The core of the geo-addressing helm-chart-based solution relies on the Geo-Addressing SDK (GA-SDK). The robust
functionality of GA-SDK forms the backbone of our geo-addressing solution, empowering it to deliver accurate and
efficient
geo-addressing services while maintaining data integrity and usability.

The geo-addressing application is designed as a robust microservice-based architecture, utilizing a modular approach to
provide highly optimized, scalable and precise addressing solutions.

### Capabilities

Within this architecture, there are two key types of microservices:

- _Regional Addressing Service_: This microservice is an interface exposed to user consisting all the endpoints
  pertaining the geo-addressing capabilities:
    - **_Verify_**: performs address verification and standardization using the specified processing engine.
    - **_Geocode_**: performs forward geocoding using input addresses and returning location data and other information.
    - **_Reverse Geocode_**: performs reverse geocoding using input coordinates and returns address information that is
      the best match for that point.
    - **_Autocomplete_**: yields matched addresses and place for the given input addresses.
    - **_Lookup Service_**: returns geocoded candidates when given a unique key.
- _Addressing Service_ (Country-Specific): These microservices are specialized for individual countries, allowing us to
  cater to unique addressing requirements and regulations in different regions. Each country-based addressing service is
  optimized for accuracy within its specific jurisdiction.
- _Addressing Express_: This microservice provides support for Geocoding without Country and new Address AutocompleteV2
  service with enhanced quality & performance.

## Getting Started
> NOTE: We expect users to be familiar with concepts of Kubernetes and Helm in order to use the Geo Addressing Deployment via the Helm Charts.

#### 1. Prepare your environment

Install Client tools required for installation. Follow the guides to get the steps for specific cloud
platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-1-prepare-your-environment)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-1-before-you-begin)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-1-before-you-begin)

#### 2. Create Kubernetes Cluster

Create or use an existing K8s cluster. Follow the guides to get the steps for specific cloud platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-2-create-the-eks-cluster)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-2-create-the-aks-cluster)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-2-create-the-gke-cluster)

#### 3. Download Geo-Addressing Docker Images

Download docker images and upload to your own container registry. Follow the guides to get the steps for specific cloud
platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-3-download-geo-addressing-docker-images)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-3-download-geo-addressing-docker-images)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-3-download-geo-addressing-docker-images)

#### 4. Create a Persistent Volume

Create or use an existing persistent volume for storing geo-addressing reference-data. Follow the guides to get the
steps for specific cloud platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-4-create-elastic-file-system-efs)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-4-create-and-configure-azure-files-share)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-4-create-and-configure-google-filestore)

#### 5. Installation of Geo Addressing reference data

Download and install the geo-addressing reference data in the persistent volume. Follow the guides to get the steps for
specific cloud platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-5-installation-of-reference-data)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-5-installation-of-reference-data)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-5-installation-of-reference-data)

#### 6. Deploy the Geo Addressing application

Deploy the geo-addressing application using helm. Follow the guides to get the steps for specific cloud platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-6-installation-of-geo-addressing-helm-chart)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-6-installation-of-geo-addressing-helm-chart)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-6-installation-of-geo-addressing-helm-chart)

## Components

- [Understanding Geo Addressing Helm Chart](charts/component-charts/geo-addressing-generic/README.md#understanding-geo-addressing-helm-charts)
- [Reference Data Structure](docs/ReferenceData.md)
- [Pushing Docker Images (AWS ECR)](docs/guides/eks/QuickStartEKS.md#step-3-download-geo-addressing-docker-images)
- [Pushing Docker Images (Microsoft ACR)](docs/guides/aks/QuickStartAKS.md#step-3-download-geo-addressing-docker-images)
- [Pushing Docker Images (Google Artifact Registry)](docs/guides/gke/QuickStartGKE.md#step-3-download-geo-addressing-docker-images)
- [Custom Data Import Job (Optional)](charts/component-charts/custom-data-importer/README.md)

## Guides

- [Reference Data Installation Helm Chart](charts/component-charts/reference-data-setup-generic/README.md)
- [Quickstart Guide For AWS EKS](docs/guides/eks/QuickStartEKS.md)
- [Quickstart Guide For Microsoft AKS](docs/guides/aks/QuickStartAKS.md)
- [Quickstart Guide For Google GKE](docs/guides/gke/QuickStartGKE.md)

## Setup

- [Local Setup](docker-desktop/README.md)
- [Kubernetes Setup](charts/component-charts/geo-addressing-generic/README.md)

> NOTE: As of now, geo-addressing helm chart is supported for AWS EKS, Microsoft AKS and Google's GKE cloud platforms.

## Geo-Addressing Helm Version Chart

Following is the helm version chart against geo-addressing PDX docker image version and GA-SDK version.

| Docker Image PDX Version & GA-SDK Version   | Helm Chart Version |
|---------------------------------------------|--------------------|
| `0.4.0/2023.9/Sept 12,2023` & `5.1.488`     | `0.1.0` - `0.4.0`️ |
| `0.5.0/2024.2/Feb 20,2024` & `5.1.644`      | `0.5.0`️           |
| `1.0.0/2024.3/Mar 31,2024` & `5.1.682`      | `1.0.0`️           |
| `1.0.0/2024.5/May 10,2024` & `5.1.682`      | `1.0.1`️           |
| `1.0.0/2024.6/June 14,2024` & `5.1.682`     | `2.0.1`️           |
| `1.0.0/2024.10/October 10 2024` & `5.1.854` | `2.0.2` - `3.0.0`  |
| `1.0.0/2025.3/March 04 2025` & `5.1.1044`   | `3.0.1` - latest   |

> NOTE: The docker images pushed to the image repository should be tagged with the current helm chart version.

Refer Downloading Geo Addressing Docker Images
for [[EKS](docs/guides/eks/QuickStartEKS.md#step-3-download-geo-addressing-docker-images) |[AKS](/docs/guides/aks/QuickStartAKS.md#step-3-download-geo-addressing-docker-images) |[GKE](/docs/guides/gke/QuickStartGKE.md#step-3-download-geo-addressing-docker-images)]
for more information.

## Miscellaneous

- [Metrics](docs/MetricsAndTraces.md#generating-insights-from-metrics)
- [Application Tracing](docs/MetricsAndTraces.md#generating-insights-from-metrics)
- [Logs and Monitoring](docs/MetricsAndTraces.md#generating-insights-from-metrics)
- [FAQs](docs/faq/FAQs.md)

## References

- [Releases](https://github.com/PreciselyData/cloudnative-geocoding-helm/releases)
- [Helm Values](charts/component-charts/geo-addressing-generic/README.md#helm-values)
- [Environment Variables](charts/component-charts/geo-addressing-generic/README.md#environment-variables)
- [Geo Addressing Service API Usage](charts/component-charts/geo-addressing-generic/README.md#geo-addressing-service-api-usage)

## Links

- [Geo-Addressing API Guide](https://docs.precisely.com/docs/sftw/ggs/5.0/en/webhelp/GeoAddressingSDKDeveloperGuide/GlobalGeocodingGuide/source/AddressingAPI/addressing_api_title.html)
- [Geo-Addressing Custom Output Fields](https://docs.precisely.com/docs/sftw/ggs/5.0/en/webhelp/GeoAddressingSDKDeveloperGuide/GlobalGeocodingGuide/source/CustomFields/global_custom_output_fields_all_countries.html)
- [Helm Chart Tricks](https://helm.sh/docs/howto/charts_tips_and_tricks/)
- [Nginx Ingress Controller](https://docs.nginx.com/nginx-ingress-controller/)
