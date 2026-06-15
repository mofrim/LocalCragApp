#!/usr/bin/env bash

doggerfile="./docker-compose-localdev.yml"
if [ -e $doggerfile ]
then
	docker compose -f $doggerfile up
else
	echo ">>> $doggerfile not found!"
fi
