# Precisely Geo-Addressing Service Setup on Local Docker Desktop

This section explains how to test Docker images downloaded from PDX locally in a Docker Desktop environment.

## Step 1: Download Reference Data and Required Docker Images

To run the docker images locally, reference data and docker images should be downloaded from Precisely Data Experience.
For more information on reference data and downloading docker images, follow [this section](../README.md#reference-data).

## Step 2: Running Service Locally

Modify the below variables in ****.env**** file and run the mentioned command.

_DATA_PATH -> path to the **extracted** data

_SERVICE_PORT -> port at which service should be started (Example 8080)

_ENABLED_API -> API endpoints to enable. Note:Only add those endpoints for which data is configured, else service
startup will fail.
(Possible values: verify,geocode,autocomplete,lookup,reverse-geocode)

***Sample Values:***

*below values will enable autocomplete API endpoints.*

 ```shell
 _DATA_PATH=/data/autocomplete/usa/202307
 _SERVICE_PORT=8080
 _ENABLED_API=autocomplete
 ```

*below values will enable verify/geocode API endpoints.*

 ```shell
 _DATA_PATH=/data/verify-geocode/usa/202307
 _SERVICE_PORT=8080
 _ENABLED_API=verify,geocode
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

[🔗 Return to `Table of Contents` 🔗](../README.md#local-setup)