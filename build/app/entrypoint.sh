#!/bin/bash

check_env() {
    local var="$1"

    if [[ ! "${!var:-}" ]]; then
        echo >&2 "ERROR: $var is not set"
        exit 1
    else
        if [[ ${APP_ENV} != "production" ]]; then
            echo "INIT $var : ${!var}"
        fi
    fi
}

envs=(
    APP_ENV
    APP_URL
    BACKEND_FRONTNAME
    DB_HOST
    DB_USERNAME
    DB_PASSWORD
    DB_DATABASE
    ADMIN_USERNAME
    ADMIN_PASSWORD
    ADMIN_FIRSTNAME
    ADMIN_LASTNAME
    ADMIN_EMAIL
    LANGUAGE
    CURRENCY
    TIMEZONE
    SEARCH_ENGINE
    ELASTICSEARCH_INDEX_PREFIX
    ELASTICSEARCH_TIMEOUT
    ELASTICSEARCH_HOST
    ELASTICSEARCH_PORT
)


if [[ ${APP_ENV} != "production" ]]; then
    # loop and print all env variables value
    for env in "${envs[@]}"; do
        echo "$env: ${!env}"
    done
fi

COMMAND="$@"

# Override the default command
if [ -n "${COMMAND}" ]; then
    echo "ENTRYPOINT: Executing override command"
    exec $COMMAND
else

    # Measure the time it takes to bootstrap the container
    START=$(date +%s)

    # Set the base Magento command to bin/magento
    CMD_MAGENTO="bin/magento" && chmod +x $CMD_MAGENTO

    # Set the install command
    CMD_INSTALL="${CMD_MAGENTO} setup:install --base-url="${APP_URL}" \
              --db-host="${DB_HOST}" \
              --db-name="${DB_DATABASE}" \
              --db-user="${DB_USERNAME}" \
              --db-password="${DB_PASSWORD}" \
              --admin-firstname="${ADMIN_FIRSTNAME}" \
              --admin-lastname="${ADMIN_LASTNAME}" \
              --admin-email="${ADMIN_EMAIL}" \
              --admin-user="${ADMIN_USERNAME}" \
              --admin-password="${ADMIN_PASSWORD}" --language="${LANGUAGE}" \
              --language="${LANGUAGE}" \
              --currency="${CURRENCY}" \
              --timezone="${TIMEZONE}" \
              --search-engine="${SEARCH_ENGINE}" \
              --elasticsearch-host="${ELASTICSEARCH_HOST}" \
              --elasticsearch-port="${ELASTICSEARCH_PORT}" \
              --elasticsearch-index-prefix="${ELASTICSEARCH_INDEX_PREFIX}" \
              --elasticsearch-timeout="${ELASTICSEARCH_TIMEOUT}" \
              --use-rewrites=1 --cleanup-database"

    # Set the config command
    CMD_CONFIG="${CMD_MAGENTO} setup:config:set --db-host="${DB_HOST}" \
              --db-name="${DB_DATABASE}" \
              --db-user="${DB_USERNAME}" \
              --db-password="${DB_PASSWORD}" \
              --backend-frontname="${BACKEND_FRONTNAME}" \
              --no-interaction"

    # Set the uninstall command
    CMD_UNINSTALL="${CMD_MAGENTO} setup:uninstall --no-interaction"

    CMD_START_CRON="${CMD_MAGENTO} cron:run"

    # Run configuration command
    $CMD_CONFIG

    # run bash to get number of tables in database
    NUMBER_OF_TABLES=$(mysql -h ${DB_HOST} -u ${DB_USERNAME} -p${DB_PASSWORD} ${DB_DATABASE} -e "SHOW TABLES;" | wc -l)

    # check if number of tables is equal 0
    if [ $NUMBER_OF_TABLES -eq 0 ]; then
        echo "Database is empty, running install command"
        $CMD_UNINSTALL
        $CMD_INSTALL
    fi

    # Run start cron command
    $CMD_START_CRON

    echo "APACHE: Starting webserver"
    exec /usr/local/bin/apache2-foreground
fi
