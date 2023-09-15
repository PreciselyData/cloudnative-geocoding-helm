#!/bin/bash

IFS=',' read -ra COUNTRIES <<< "$1"
data_path=$2

buildComposeYaml() {
  cat <<HEADER
version: "3.9"
networks:
  preciselyaddressing:
    name: geo-addressing
services:
  precisely-regional-addressing:
    image: regional-addressing-service:latest
    platform: linux/amd64
    deploy:
      resources:
        reservations:
          cpus: '1'
          memory: 1500M
    ports:
      - "8080:8080"
    environment:
      - ADDRESSING_BASE_URL=http://precisely-addressing-<region>:8080
      - LOOKUP_BASE_URL=http://precisely-addressing-<region>:8080
      - AUTOCOMPLETE_BASE_URL=http://precisely-addressing-<region>:8080
      - REVERSE_GEOCODE_BASE_URL=http://precisely-addressing-<region>:8080
      - SUPPORTED_COUNTRIES_GEOCODE=usa,gbr,deu,aus,fra,can,mex,bra,arg,rus,ind,sgp,nzl,jpn,tgl,world
      - SUPPORTED_REGIONS_GEOCODE=amer,emea1,emea2,emea3,emea4,emea5,emea6,apac1,apac2
      - AUTH_ENABLED=false
    networks:
      - preciselyaddressing
    restart: always
HEADER
  for country in "${COUNTRIES[@]}"; do
    cat <<BLOCK
  precisely-addressing-${country}:
    image: addressing-service:latest
    platform: linux/amd64
    deploy:
      resources:
        reservations:
          cpus: '1'
          memory: 4G
    volumes:
      - ${data_path}/${country}/:/mnt/data/extracted
    environment:
      - DATA_PATH=/mnt/data/extracted
      - ENABLED_ENDPOINTS=verify,geocode,autocomplete,lookup,reverse-geocode
      - DATA_REGION=${country}
    networks:
      - preciselyaddressing
    restart: always
BLOCK
  done
}

buildComposeYaml | docker-compose -f- "${@:3}"