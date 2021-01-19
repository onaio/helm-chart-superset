```
$ ../../kind/env.sh helm upgrade --install \
    --values=values.yaml \
    --set-file initFile=init.sh \
    --set-file configFile=config.py \
    --set-file init.initFile=init.init.sh \
    --set imageAssets.favicon\\.png=$(cat assets/images/favicon.png | base64 -w 0) \
    --set imageAssets.superset-logo-horiz\\.png=$(cat assets/images/superset-logo-horiz.png | base64 -w 0) \
    --set imageAssets.superset\\.png=$(cat assets/images/superset.png | base64 -w 0) \
    test-whitelabel ../../..
```