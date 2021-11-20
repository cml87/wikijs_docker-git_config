#!/bin/bash

echo "creating volume wikijs-db_vol. Nothing will be done if it already exists, according to docker"
docker volume create wikijs-db_vol

echo "extracting content of data.tar.gz into volume wikijs-db_vol"
docker run --rm -v "$(pwd)"/data.tar.gz:/backup/data.tar.gz -v wikijs-db_vol:/data ubuntu tar -zxvf /backup/data.tar.gz -C /data --strip 1
