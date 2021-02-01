# White-labeling example

The release in this directory is intended to be a minimal example of white-labeling functionality for the superset chart.

You can run the example by first bringing up a KIND cluster via `test/kind/ensure_kind_cluster.sh` and then running:

```
$ ../../kind/env.sh helm upgrade --install \
    --values=values.yaml \
    --set-file initFile=init.sh \
    --set-file configFile=config.py \
    --set-file init.initFile=init.init.sh \
    --values=large-assets.yaml \
    --set assets.images.favicon\\.png=$(cat assets/images/favicon.png | base64 -w 0) \
    --set assets.images.superset-logo-horiz\\.png=$(cat assets/images/superset-logo-horiz.png | base64 -w 0) \
    --set assets.images.superset\\.png=$(cat assets/images/superset.png | base64 -w 0) \
    test-whitelabel ../../..
```

Once up, you can access the superset pod via:

```
$ ../../kind/env.sh kubectl port-forward test-whitelabel-superset-<pod suffix> 8088:8088 & \
  sensible-browser localhost:8088
```

and ensure the new logos and (red) colors have been applied.

## How it works

The superset release here is customized with our own (Canopy discover) icons and logos as well as themed with a primary color of `#ff0000`.

In order to make these changes, the files in `/usr/local/lib/python3.6/site-packages/superset/static/assets` must be overridden with files embedded in part of a Helm-managed asset ConfigMap.

To embed the file data in a ConfigMap, we need to configure the `assets` variable with a (nested) set of filename key / file data value pairs.   For binary files (detected by file extension) the file data must be base64-encoded.  It's usually easiest to load the data on the command-line at release time, but for >100k files this fails and the file data must be embedded in yaml (`large-assets.yaml`).

### Rebuilding CSS

Unfortunately superset is unable to recompile CSS assets (from `.less` source files) once containerized.  In order to rebuild these assets, a compatible superset source repository must be checked out, and the following steps taken:

```bash
$ git clone https://github.com/apache/superset.git
$ cd superset/superset-frontend
$ npm install
[ edit ./stylesheet/less files ]
$ npm prod
$ cp ../superset/static/assets/[theme|welcome].<hash>.entry.css path/to/whitelabel/assets
```

 At this point, the newly-compiled CSS asset needs to be renamed to match the existing hash of the current superset CSS asset (this can be found by exec'ing into the example whitelabel superset instance).  Once the asset is renamed, the content can be added to the `large-assets.yaml` file (as theming CSS in particular is too large for the command-line). 

It's also possible to rebuild the superset container with modified asset files - this is possible, but much less dynamic than overriding files in a customized helm release.  Longer-term a source-included container would allow for runtime re-initialization and arguably is the best option.