## Troubleshooting

These are some debugging steps you can take while working with the `octoml` cli and the tutorials.

### Clean Environment

You can entirely clean up and start fresh with the `clean` command:

```bash
octoml clean -a
rm -fr .octoml_cache
```

### Image not re-building

If the image is not re-creating try first deleting it `docker rmi critterblock` and cleaning `octoml clean -a` before building again.

### Port in use

Verify with `docker ps` that you don't have a docker container already running with the same ports in use.

### Model name

To verify the name of the model in your container you can use curl:

```
$ curl -s -X POST localhost:8000/v2/repository/index

[{"name":"critterblock","version":"1","state":"READY"}]
```
