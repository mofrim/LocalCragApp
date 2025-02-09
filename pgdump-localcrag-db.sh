#!/usr/bin/env bash
if [ -z "$1" ]
then
    echo "please enter db-image name as 1st arg!"
    exit
fi

echo "Alrighty! Fetching DB backup to ./backup.sql ..."
docker exec $1 pg_dump -U localcrag_user localcrag > backup.sql
echo "done!"
