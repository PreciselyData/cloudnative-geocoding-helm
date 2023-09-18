# Precisely Geo-Addressing Service Setup on Local Docker Desktop

This section describes how to test docker images downloaded from PDX locally on Docker Desktop environment. If you have not already downloaded docker images from PDX follow the link. [Download Docker Images](../charts/README.md#uploading-docker-images-to-ecr)

## Running Service Locally

### There are two ways of running the services locally

1. Running the single instance of service with data of One Country

        
    Modify the below variables in ****.env**** file and run the mentioned command.


    _DATA_REGION -> country region for the service (one from usa,gbr,deu,aus,fra,can,mex,bra,arg,rus,ind,sgp,nzl,jpn,tgl,world)
    <br>

    _DATA_PATH -> path to the **extracted** data of a country mentioned in *_DATA_REGION* variable
    <br>

    _SERVICE_PORT -> port at which service should be started (Example 8080)
    <br>

    _ENABLED_API -> API enpoints to enable (Possible values: verify,geocode,autocomplete,lookup,reverse-geocode)


    ***Sample Values:***

    *below values will enable autocomplete API endpoints.*
    ```shell
    _DATA_REGION=usa
    _DATA_PATH=/data/autocomplete/usa/202307
    _SERVICE_PORT=8080
    _ENABLED_API=autocomplete
    ```
    <br>

    *below values will enable verify/geocode API endpoints.*
    ```shell
    _DATA_REGION=usa
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

2. Running multiple instances of service for multiple countries.

    For this to work the reference data should be present on the local system in format ***[data_path]/[country_name]/*** with just single vintage

    ```shell
    ./build-docker-compose.sh [COUNTRIES] [REFERENCE_DATA_BASE_PATH] -p [PROJECT_NAME] up -d
    ```
    *Example:*
    ```shell
    ./build-docker-compose.sh gbr,usa /data -p geo-addressing up -d
    ```

    After executing the above command the service will start at http://localhost:8080



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
[Sample API Usage](../README.md#geo-addressing-service-api-usage)