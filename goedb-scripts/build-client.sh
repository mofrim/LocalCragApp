#!/usr/bin/env bash

if [ -e ./client ]
then
	cd client
	npm run build
	cd -
else
	echo ">>> ./client dir not found!"
fi
