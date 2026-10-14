#!/usr/bin/env bash

set -eou pipefail

list_databases() {
    psql \
        --dbname="postgres" \
        -Atc "SELECT array_to_json(array_agg(datname)) FROM pg_database WHERE datistemplate = false OR datname = 'template1';" \
      | jq -cre '.[]'
}

reindex_tables() {
    local db=$1
    >&2 echo "Reindexing database '$db'"
    psql --dbname="$db" -c "REINDEX DATABASE \"$db\";"
}

refresh_collation_version() {
    local db="$1"
    >&2 echo "Refreshing collation version for database: '$db'"
    psql --dbname="$db" -c "ALTER DATABASE \"$db\" REFRESH COLLATION VERSION;"
}

list_databases | while read -r db; do
    reindex_tables "$db"
    refresh_collation_version "$db"
done

