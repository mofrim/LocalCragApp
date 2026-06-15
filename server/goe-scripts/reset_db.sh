#!/bin/bash

## for setting / changing the postgres user's pw first... 

# sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'your_new_password';"

## another approach that would also work because postgres uses 'peer authentication', meaning it takes
## your current uid as the user of the db you can use `sudo -u postgres psql...` to run all cmds

echo -e "\e[31mDANGER DANGER! You are about to completely reset your localcrag DB !!\e[0m"
echo -n "Ctrl-C to stop here!"; read -r
echo

psql "postgresql://postgres:password@localhost" -c "DROP DATABASE IF EXISTS localcrag"
psql "postgresql://postgres:password@localhost" -c "CREATE DATABASE localcrag;"
psql "postgresql://postgres:password@localhost" -c "DROP USER IF EXISTS localcrag_user"
psql "postgresql://postgres:password@localhost" -c "CREATE USER localcrag_user WITH PASSWORD 'password';"
psql "postgresql://postgres:password@localhost" -c " GRANT ALL PRIVILEGES ON DATABASE localcrag TO localcrag_user;"

psql "postgresql://postgres:password@localhost/localcrag" -c "DROP SCHEMA public CASCADE"
psql "postgresql://postgres:password@localhost/localcrag" -c "CREATE SCHEMA public;"

# Connect to the localcrag database specifically to set schema permissions
psql "postgresql://postgres:password@localhost/localcrag" -c " GRANT USAGE ON SCHEMA public TO localcrag_user; GRANT CREATE ON SCHEMA public TO localcrag_user; GRANT ALL ON ALL TABLES IN SCHEMA public TO localcrag_user; GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO localcrag_user; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO localcrag_user; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO localcrag_user;"

# run fresh migrations:
# pipenv run flask db upgrade
