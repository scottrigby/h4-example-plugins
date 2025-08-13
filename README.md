# Helm 4 Example plugin types

Example plugins to test [plugin-types](https://github.com/scottrigby/helm/tree/plugin-types) experimental branch as part of for [hip:0026: H4HIP: Wasm plugin system](https://github.com/helm/community/blob/main/hips/hip-0026.md).

That branch only adds the initial plugin types to Helm 4 to identify where to modify the codebase for the new types. Is not yet backwards compatible with Helm 3 plugins, and does not yet add support for additional runtimes (Wasm). Will be merged with Wasm runtime work and Helm 3 plugin backwards-compatibility.

See diff https://github.com/helm/helm/compare/main...scottrigby:helm:plugin-types

## To use

This repo includes a Makefile:

- `make test PATH="$(pwd):${PATH}"`
- `make clean`

## Manual testing

### Manualy package a plugin

Helm will have commands for this, but in the meantime:

```sh
# plugin files must be a folder with the plugin name
# and tarballed with .gz extension
tar -czvf example-cli.tgz example-cli

# check tarball contains the right files
tar -ztvf example-cli.tgz

# push to a registry
oras push ghcr.io/scottrigby/example-cli:v0.2.0 --artifact-type application/vnd.helm.plugin.v1+json example-cli.tgz

# check push contains the tarball
oras manifest fetch ghcr.io/scottrigby/example-cli:v0.2.0 --pretty

# pull
oras pull -o . ghcr.io/scottrigby/example-cli:v0.2.0
```

### Local registry to test --plain-http

ensure `~/.config/containers/registries.conf` contains:

```ini
[[registry]]
location = "localhost:5001"
insecure = true
```

then start local insecure registry:

```sh
podman run -d --name podman-registry -p 5001:5000 -v ~/.local/share/containers/registry:/var/lib/registry --restart=always registry:2
```

check that it works:

```console
% curl -I localhost:5001/v2/
HTTP/1.1 200 OK
Content-Length: 2
Content-Type: application/json; charset=utf-8
Docker-Distribution-Api-Version: registry/2.0
X-Content-Type-Options: nosniff
```

you can then run the same commands above but to the local registry:

```sh
oras push localhost:5001/example-cli:v0.2.0 --artifact-type application/vnd.helm.plugin.v1+json example-cli.tgz
oras manifest fetch localhost:5001/example-cli:v0.2.0 --pretty
etc
```

and run helm plugin commands with `--plain-http` flag:

```sh
go run ./cmd/helm plugin install --plain-http oci://localhost:5001/example-cli:v0.2.0
```
