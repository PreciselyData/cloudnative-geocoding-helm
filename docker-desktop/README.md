# Precisely Geo-Addressing Service Setup on Local Docker Desktop

The geo-addressing application can be setup locally for test purpose.

## Step 1: Download Reference Data and Required Docker Images

To run the docker images locally, reference data and docker images should be downloaded from Precisely Data Experience.
> For more information on downloading the docker images, follow [this section](../scripts/images-to-ecr-uploader/README.md#download-and-upload-docker-images-to-ecr).
> 
> For more information on reference data and downloading docker images, follow [this section](../docs/ReferenceData.md).
>

## Step 2: Running Service Locally

> Note: addressing-express service should not be run locally.

Modify the below variables in ****.env**** file and run the mentioned command.

_DATA_PATH -> path to the **extracted** data

_SERVICE_PORT -> port at which service should be started (Example 8080)


_GEOCODE_VERIFY_ENABLED -> Set to true to enable geocode and verify endpoints.
_LOOKUP_ENABLED -> Set to true to enable lookup endpoint.
_REVERSEGEOCODE_ENABLED -> Set to true to enable reverse geocode endpoint.
_AUTOCOMPLETE_ENABLED -> Set to true to enable autocomplete endpoint.

```Note: Only enable those endpoints for which data is configured, else service startup will fail.```

***Sample Values:***

*below values will enable autocomplete API endpoints.*

 ```shell
 _DATA_PATH=/data/autocomplete/usa/202307
 _SERVICE_PORT=8080
 _GEOCODE_VERIFY_ENABLED=false
 _LOOKUP_ENABLED=false
 _REVERSEGEOCODE_ENABLED=false
 _AUTOCOMPLETE_ENABLED=true
 ```

*below values will enable verify/geocode API endpoints.*

 ```shell
 _DATA_PATH=/data/verify-geocode/usa/202307
 _SERVICE_PORT=8080
 _GEOCODE_VERIFY_ENABLED=true
 _LOOKUP_ENABLED=false
 _REVERSEGEOCODE_ENABLED=false
 _AUTOCOMPLETE_ENABLED=false
 ```

    ```shell
    docker compose -p [PROJECT_NAME] -f ./docker-compose.yml up -d
    ```

    *Example:*
    ```shell
    docker compose -p geo-addressing -f ./docker-compose.yml up -d
    ```

    After executing the above command the service will start at http://localhost:[_SERVICE_PORT]

## Cleanup of local services

    Regardless of any above method of running the services locally below cleanup command will be same.

    ```shell
    docker compose -p [PROJECT_NAME] down
    ```

    *Example:*
    ```shell
    docker compose -p geo-addressing down
    ```

## References

- [Sample API Usage](../charts/geo-addressing/README.md#geo-addressing-service-api-usage)

[🔗 Return to `Table of Contents` 🔗](../README.md#setup)