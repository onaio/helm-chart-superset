if [ "$1" == "development-mode" ]; then
    /usr/local/bin/superset-init --username admin --firstname admin --lastname user --email admin@fab.org --password admin
    superset run --host 0.0.0.0 --port 8088
elif [ "$1" == "production-mode" ]; then
    uwsgi \
        --socket 0.0.0:8088 \
        --protocol http \
        --master \
        --module "superset.app:create_app()" \
        --mount "/=superset:app" \
        --env FLASK=superset \
        --env FLASK_ENV=production \
        --single-interpreter \
        --lazy-apps \
        --stats /tmp/superset.stats.sock \
        --memory-report \
        --thunder-lock \
        --buffer-size 20480 \
        --reload-on-rss 255 \
        --enable-threads \
        --vacuum \
        --processes 10 \
        --chdir /home/superset
else
    echo "You need to specify which mode to start in by setting production-mode"
    echo "or development-mode in extraArguments."
    exit 1
fi
