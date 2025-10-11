#!/usr/bin/env bash

set -e

if [ -e ./bak ]; then
	echo ">> ./bak dir already exists! Removing it.."
        sudo rm -rf ./bak
elif [ -z "$1" ]; then
	echo ">> usage: $0 MINIO_SECRET_KEY"
	exit 1
fi

mkdir -p bak

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
DBNAME="$(docker ps | grep -- "-db-" | sed 's/.*\(\localcragapp-db.*\)$/\1/')"
set -x
docker exec $DBNAME pg_dump -U localcrag_user localcrag > ./bak/db-backup.sql
cd ../data/
sudo tar -cpzf ../LocalCragApp/bak/localcrag-db.tgz ./postgres-data
cd -
set +x

echo ">> Backing up minio..."
# if [ -n "$(command -v mc)" ]
# then
#   MC="mc"
# elif [ -z "$(command -v mc)" ] && [ ! -e ./mc ]
# then
#   echo ">> Downloading mc...."
#   wget https://dl.min.io/client/mc/release/linux-amd64/mc
#   chmod +x ./mc
#   MC="./mc"
# else
#   MC="./mc"
# fi
set -x
## Old version using mc... does not include hidden dir!!!
# $MC alias set localminio http://localhost:9000 localcrag $1
# $MC mirror localminio/localcrag ./bak/minio-bak
# tar -pczf ./bak/mini-data.tar.gz ./bak/minio-bak
# rm -rf ./bak/minio-bak

## New versions simply copying things to tarball
cd ../data/
sudo tar -cpzf ../LocalCragApp/bak/minio-data.tgz ./minio-data
cd -

set +x

echo ">> Creating final tarball..."
FINALBALLNAME="localcrag-bak-$(date +%Y_%m_%d-%H%M).tar.gz"
set -x
tar -pczf $FINALBALLNAME ./bak
sudo rm -rf ./bak
set +x

echo ">> backup_all.sh done \\o/"
