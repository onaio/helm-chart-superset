#!/bin/sh
INITIALIZE=no
LOAD_EXAMPLES=no
CREATE_SUPERSET_USER=no
NEW_SUPERSET_USER=admin
NEW_SUPERSET_USER_EMAIL=techops@ona.io
NEW_SUPERSET_USER_PASSWORD=admin

while getopts ":ae:ilp:u:" opt; do
    case $opt in
    a)
        CREATE_SUPERSET_USER=yes
        ;;
    e)
        NEW_SUPERSET_USER_EMAIL=$OPTARG
        ;;
    i)
        INITIALIZE=yes
        ;;
    l)
        LOAD_EXAMPLES=yes
        ;;
    u)
        NEW_SUPERSET_USER=$OPTARG
        ;;
    p)
        NEW_SUPERSET_USER_PASSWORD=$OPTARG
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        ;;
    esac
done

echo "$(date) Upgrading DB schema ..."
superset db upgrade

if [ "$INITIALIZE" == "yes" ]; then
    echo "$(date) Initialize Superset ..." >&2
    superset init
fi

if [ "$LOAD_EXAMPLES" == "yes" ]; then
    echo "$(date) Load examples visualizations" >&2
    PYTHONIOENCODING=UTF-8 PYTHONUNBUFFERED=1 superset load-examples
fi

if [ "$CREATE_SUPERSET_USER" == "yes" ]; then
    echo "Creating user $NEW_SUPERSET_USER with password $NEW_SUPERSET_USER_PASSWORD."
    echo "$(date) Create the admin user" >&2
    /usr/local/bin/superset-init --username $NEW_SUPERSET_USER --firstname $NEW_SUPERSET_USER --lastname user --email $NEW_SUPERSET_USER_EMAIL --password "$NEW_SUPERSET_USER_PASSWORD"
fi
