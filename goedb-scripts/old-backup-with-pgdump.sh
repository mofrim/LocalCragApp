#!/usr/bin/env bash

set -e

if [ -e ./bak ]; then
	echo ">> ./bak dir already exists! Delete or mv it first, plz."
	exit 1
elif [ -z "$1" ]; then
	echo ">> usage: $0 MINIO_SECRET_KEY"
	exit 1
fi

mkdir bak

dled_mc=0
echo ">> Backing up all data for this localcrag instance."


echo ">> Backing up certbot files..."
if [ ! -e ./certbot ]
then
	echo ">>>> cerbot dir not found!"
	exit 1
fi
set -x
sudo tar -pczf ./bak/certbot.tar.gz ./certbot
sudo chown $USER:$USER ./bak/certbot.tar.gz
set +x

# TODO: add error checking
echo ">> Backing up DB..."
DBNAME="$(docker ps | grep db | sed 's/.*\(\localcragapp-db.*\)$/\1/')"
set -x
docker exec $DBNAME pg_dump -U localcrag_user localcrag > ./bak/db-backup.sql
set +x

echo ">> Backing up minio..."
if [ -z "$(command -v mc)" ]
then
	echo ">> Downloading mc...."
	wget https://dl.min.io/client/mc/release/linux-amd64/mc
	chmod +x ./mc
	dled_mc=1
fi
set -x
mc alias set localminio http://localhost:9000 localcrag $1
mc mirror localminio/localcrag ./bak/minio-bak
tar -pczf ./bak/mini-data.tar.gz ./bak/minio-bak
rm -rf ./bak/minio-bak
set +x

echo ">> Creating final tarball..."
FINALBALLNAME="localcrag-bak-$(date +%Y_%m_%d).tar.gz"
set -x
tar -pczf $FINALBALLNAME ./bak
rm -rf ./bak
set +x

if [ $dled_mc -eq 0 ]; then
	echo ">> mc was not downloaded, so there is nothing to do here."
else
	echo ">> mc was downloaded -> deleting it again"
	rm ./mc
fi





