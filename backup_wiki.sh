#!/bin/bash

echo "creating file data.tar.gz with content of volume wikijs-db_vol ..."
docker run --rm -v wikijs-db_vol:/data -v $(pwd):/backup ubuntu:20.04 tar -zcf /backup/data.tar.gz /data