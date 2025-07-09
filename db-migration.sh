#!/bin/bash
OLD_HOST="localhost"
NEW_HOST="localhost" 
DB_NAME="localcrag"
USERNAME="localcrag_user"
PASSWORD="your_password"

# 1. Create user first
psql -U postgres -h $NEW_HOST -c "CREATE USER $USERNAME WITH PASSWORD '$PASSWORD';"

# 2. Create the database and grant permissions
createdb -U postgres -h $NEW_HOST $DB_NAME
psql -U postgres -h $NEW_HOST -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $USERNAME;"

# 3. Dump from old server
pg_dump -U $USERNAME -h $OLD_HOST -d $DB_NAME -Fc -f ${DB_NAME}_migration.backup

# 4. Restore to new server
pg_restore -U $USERNAME -h $NEW_HOST -d $DB_NAME -v ${DB_NAME}_migration.backup


##########################################
## what i really do / did:
##########################################

# using the combined postgres15 & 17 dockerfile
podman exec localcragapp-db-1 pg_dump17 -U localcrag_user -h localhost -d localcrag -Fc -f localcrag_migration.backup

# using the empty postgres:17-alpine container
psql -U postgres -c "CREATE USER localcrag_user WITH PASSWORD 'G0ewaldinismus09123849';"
# createdb -U postgres localcrag
psql -U postgres -c "CREATE USER localcrag_user WITH PASSWORD 'your_password';"
psql -U postgres -c "CREATE DATABASE localcrag;"
psql -U postgres -c "ALTER DATABASE localcrag OWNER TO localcrag_user;"

# THIS!!!! was missing for levenshtein-whatever-searching to work!
psql -U postgres -d localcrag -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;"

pg_restore -U localcrag_user -d localcrag -v /var/lib/postgres/data/localcrag_migration.backup

## this wasn't enough:
# psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE localcrag TO localcrag_user;"


## these were also granting the correct permissions in the end:
# psql -U postgres -d localcrag -c "GRANT ALL ON SCHEMA public TO localcrag_user;"
# psql -U postgres -d localcrag -c "GRANT CREATE ON SCHEMA public TO localcrag_user;"
# psql -U postgres -d localcrag -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO localcrag_user;"
# psql -U postgres -d localcrag -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO localcrag_user;"
