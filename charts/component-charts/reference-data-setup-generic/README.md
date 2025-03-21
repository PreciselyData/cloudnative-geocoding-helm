# Reference Data Setup

The Geo Addressing Application requires reference data installed in the worker nodes for running geo-addressing
capabilities. This reference data should be deployed
using [persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). This persistent volume is
backed by Network File Storage so that the data is ready to use immediately when the volume is mounted to
the pods.

For more information on reference data and reference data structure, please
visit [this link](../../../docs/ReferenceData.md).


[🔗 Return to `Table of Contents` 🔗](../../../README.md#guides)
