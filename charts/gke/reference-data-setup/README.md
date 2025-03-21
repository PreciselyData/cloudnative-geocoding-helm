# Reference Data Setup on GKE

The Geo Addressing Application requires reference data installed in the worker nodes for running geo-addressing capabilities. This reference data should be deployed
using [persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). This persistent volume is
backed by Network File Storage so that the data is ready to use immediately when the volume is mounted to
the pods.

Refer to the following documentation for more information:
- [reference data and structure](../../../docs/ReferenceData.md)
- [reference data quick start guide for gke](../../../docs/guides/gke/QuickStartReferenceDataGKE.md)


[🔗 Return to `Table of Contents` 🔗](../../../README.md#guides)
