# Reference Data

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

As a generalized step, the reference data should exist in the following format only:
<br>`[basePath]/[addressing-functionality]/[country]/[vintage]/[data]`


```
basePath/
├── verify-geocode/
│   │── usa/
│   │   └── 202306/
│   │       ├── data-folder-1/
│   │       └── ...
│   │── gbr/
│   │   └── 202307/
│   │       ├── data-folder-1/
│   │       └── ...
│   │── ...
├── autocomplete/
│   │── usa/
│   │   └── 202309/
│   │       ├── data-folder-1/
│   │       └── ...
│   │── aus/
│   │   └── 202308/
│   │       ├── data-folder-1/
│   │       └── ...
│   │── ...
├── lookup/
│   │── usa/
│   │   └── 202309/
│   │       ├── data-folder-1/
│   │       └── ...
│   │── fra/
│   │   └── 202308/
│   │       ├── data-folder-1/
│   │       └── ...
```

# Reference Data Installation

To download the reference data (country-specific data) and all the requirement components to run the Helm Chart,
visit [Precisely Data Portfolio](https://dataguide.precisely.com/) where you can also sign up for a free account and
access files available in [Precisely Data Experience](https://data.precisely.com/).

Additionally, we have provided a miscellaneous helm chart which will download the required reference data SPDs from Precisely Data Experience and extract it to the necessary reference data structure.
Please visit the [reference-data-setup helm chart](../charts/reference-data-setup/README.md).