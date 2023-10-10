[🔗 Return to `Table of Contents` 🔗](../../../README.md#guides)

# Uninstall Guide for EKS

To uninstall the geo-addressing helm chart, run the following command:

```shell
## set the release-name & namespace (must be same as previously installed)
export RELEASE_NAME="geo-addressing"
export RELEASE_NAMESPACE="geo-addressing"

## uninstall the chart
helm uninstall \
  "$RELEASE_NAME" \
  --namespace "$RELEASE_NAMESPACE"
```