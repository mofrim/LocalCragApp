#!/usr/bin/env bash

set -e

if [ $# -ne 1 ] || [ ! -e "$1" ] || [ ! -e ../../data/postgres-data ]; then
  echo "$# Important things are missing!"
  echo "usage (in lc-repo root!): $0 tarball"
  exit 1
fi

echo ">> Unpacking tarball & goto bak dir...."
set -x
sudo tar -xzvpf $1
cd ./bak
set +x

echo ">> Restoring DB..."
# cat ./db-backup.sql | docker exec -t db psql -U localcrag_user localcrag
set -x
sudo tar -xzvpf localcrag-db.tgz
sudo rm -rf ../../postgres-data.old
sudo mv ../../data/postgres-data ../../postgres-data.old
sudo mv ./postgres-data ../../data/postgres-data
set +x

echo ">> Continue with restoring minio data ?!"
read -r
# mc alias set localminio http://localhost:9000 localcrag $1
# mc mirror --overwrite ./minio-bak localminio/localcrag
set -x
sudo tar -xzvpf minio-data.tgz
sudo rm -rf ../../minio-data.old
sudo mv ../../data/minio-data ../../minio-data.old
sudo mv ./minio-data ../../data/minio-data
set +x

echo ">> done restoring backups!"
set -x
cd -
set +x
