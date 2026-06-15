# how i migrated my postgres15 db to postgres17.4 bc i stupidly launched a whole website on the old version

## the setting

i have a website with a frontend, backend, db (of course), and some other stuff.
all these services are launched together from one `docker-compose.yml` on my
VPS. the section describing my db-service in the `docker-compose.yml` looks like
this:

```dockerfile
  db:
    image: postgres:15-alpine
    container_name: db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=foo
      - POSTGRES_USER=bar
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    networks:
      - my-network
```
the site has already been running for a couple of month so there was already
quite some stuff inside the db. so i wanted to be extra careful when upgrading
the db. i made the following migration plan:

1) backup everything. this expecially means the postgres-data dir.
2) shutdown all services and run a container where i would have pg15 and pg17
   parallel installed but with pg15 serving the database. i would then use the
   pg17 `pg_dump` to export my database.
3) `docker compose down -v` the db container again.
4) change the db to pg17 in compose file, `rm -rf *` from the postgres-data dir.
5) run the pg17 db-container. `pg_restore` the backup file there.

## the detailed process

1) for backing things up i simply ran `sudo cp -a postgres-data pg-upgrade-bak`.
2) then i wrote the following dockerfile (`Dockerfile-pg1517`) for the
   simultaneous pg15 and pg17 container:

   ```dockerfile
    FROM postgres:17-alpine AS pg17-source
    FROM postgres:15-alpine
    COPY --from=pg17-source /usr/local/bin/pg_dump /usr/local/bin/pg_dump17
    COPY --from=pg17-source /usr/local/bin/psql /usr/local/bin/psql17  
    COPY --from=pg17-source /usr/local/bin/pg_restore /usr/local/bin/pg_restore17
    COPY --from=pg17-source /usr/local/lib/libpq.so* /usr/local/lib/
    RUN apk add --no-cache libssl3 libcrypto3 libldap libxml2 libxslt
    EXPOSE 5432
    CMD ["postgres"]
   ```
   in the `docker-compose.yml` i changed the following:

   ```dockerfile
    db:
      build:
        dockerfile: Dockerfile-pg1517
      # image: postgres:15-alpine
      # ...
   ```
   i ran only the db service with `docker compose up db`
3) afterwards i ran the pg_dump using `docker exec db pg_dump17 -U foo -h
   localhost -d bar -Fc -f db_migration.backup` and then `docker cp
   db:/db_migration.backup .` to copy the dump from the container to my host.
4) then i ran `docker compose down -v` an emptied the postgres-data dir.
5) then i put the upgraded pg-image  in the docker-compose:

    ```dockerfile
    db:
      image: postgres:17.4-alpine
      # ...
    ```
    and started the db service again using `docker compose up db`.

6) in my case i needed to install one extension to the database: `docker exec db
psql -U foo -d bar -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;"` but after
that i could finally run: `pg_restore -U foo -d bar -v /var/lib/postgresql/data/db_migration.backup`. of course you have to copy the `db_migration.backup` to the data-dir which is shared with the container on the host system.

c'est ca!

## scratchpad

```bash
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
# podman exec localcragapp-db-1 pg_dump17 -U localcrag_user -h localhost -d localcrag -Fc -f localcrag_migration.backup
docker exec db pg_dump17 -U localcrag_user -h localhost -d localcrag -Fc -f localcrag_migration.backup

# using the empty postgres:17-alpine container
psql -U postgres -c "CREATE USER localcrag_user WITH PASSWORD 'G0ewaldinismus09123849';"
# createdb -U postgres localcrag
psql -U postgres -c "CREATE USER localcrag_user WITH PASSWORD 'your_password';"
psql -U postgres -c "CREATE DATABASE localcrag;"
psql -U postgres -c "ALTER DATABASE localcrag OWNER TO localcrag_user;"

# THIS!!!! was missing for levenshtein-whatever-searching to work!
# psql -U postgres -d localcrag -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;"
psql -U localcrag_user -d localcrag -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;"

pg_restore -U localcrag_user -d localcrag -v /var/lib/postgres/data/localcrag_migration.backup

## this wasn't enough:
# psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE localcrag TO localcrag_user;"


## these were also granting the correct permissions in the end:
# psql -U postgres -d localcrag -c "GRANT ALL ON SCHEMA public TO localcrag_user;"
# psql -U postgres -d localcrag -c "GRANT CREATE ON SCHEMA public TO localcrag_user;"
# psql -U postgres -d localcrag -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO localcrag_user;"
# psql -U postgres -d localcrag -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO localcrag_user;"

```
