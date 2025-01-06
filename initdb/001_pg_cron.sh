#!/bin/bash

. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/postgresql-env.sh

export PGPASSWORD="$POSTGRESQL_PASSWORD"

if [ "${POSTGRESQL_POSTGRES_PASSWORD}" != "" ]; then
    export PGPASSWORD=${POSTGRESQL_POSTGRES_PASSWORD}
fi

# Install pg_cron extension
psql -U postgres -c "CREATE EXTENSION IF NOT EXISTS pg_cron"

# Configure pg_cron to use POSTGRESQL_DATABASE
echo "cron.database_name = '$POSTGRESQL_DATABASE'" > $POSTGRESQL_CONF_DIR/conf.d/pg_cron.conf