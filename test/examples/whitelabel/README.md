# White-labeling example

The release in this directory is intended to be a minimal example of white-labeling functionality for the superset chart.

You can run the example by first bringing up a KIND cluster via `test/kind/ensure_kind_cluster.sh` and then running:

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

Once up, you can access the superset pod via:

```
$ ../../kind/env.sh kubectl port-forward test-whitelabel-superset-<pod suffix> 8088:8088 & \
  sensible-browser localhost:8088
```

and ensure the new logos and icons have been applied.

