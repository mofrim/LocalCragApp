#!/bin/bash

export PATH="$PATH:/home/mofrim/.local/share/virtualenvs/server-L4gSl8bs/bin"

export LCDIR="/home/mofrim/goewald/LocalCragApp/server/src"
export SRVDIR="/home/mofrim/goewald/LocalCragApp/server"
export SQLALCHEMY_DATABASE_URI="postgresql://localcrag_user:password@localhost/localcrag"
export LOCALCRAG_CONFIG="$LCDIR/config/dev.cfg"
export PYTHONPATH="$LCDIR"
export BINDIR="/home/mofrim/.local/share/virtualenvs/server-L4gSl8bs/bin"
export FLASK_APP="app.py"
cd $LCDIR
/usr/bin/pipenv run flask db upgrade
sleep 1
/usr/bin/pipenv run python util/scripts/database_setup.py
/usr/bin/pipenv run flask run --host=0.0.0.0
