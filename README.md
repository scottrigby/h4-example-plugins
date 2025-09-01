# Helm 4 Example Plugins

Example plugins demonstrating the Helm 4 plugin system as implemented in [HIP:0026: Wasm plugin system](https://github.com/helm/community/blob/main/hips/hip-0026.md).

## To use

This repo includes a Makefile for building and testing plugins:

- `make test` - Install and test all example plugins
- `make install` - Install all example plugins
- `make uninstall` - Remove all example plugins
- `make clean` - Clean built artifacts and uninstall plugins

The Makefile will automatically build Helm 4 from source if needed.


## Plugin Verification

This repository supports signed plugin releases. To verify plugin authenticity:

Optionally build and run from inside a container with the minimum necessary requirements:

```bash
podman build -t helm-verify -f - . <<'EOF'
FROM debian:stable-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg ca-certificates git make golang build-essential curl && \
    rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 https://github.com/helm/helm.git && \
    make -C helm build && \
    cp ./helm/bin/helm /usr/local/bin/helm && \
    rm -rf helm
RUN useradd -ms /bin/bash gpguser
USER gpguser
WORKDIR /home/gpguser
ENTRYPOINT ["/bin/bash"]
EOF

podman run --rm -it helm-verify
```

Verify:

```bash
# Import the public key
curl -s https://github.com/scottrigby/h4-example-plugins/raw/refs/heads/main/public-key.asc | gpg --import

# Convert your keyring to the legacy gpg format
# See https://helm.sh/docs/topics/provenance/
gpg --export > ~/.gnupg/pubring.gpg

# Download and verify a plugin
helm plugin install https://github.com/scottrigby/h4-example-plugins/releases/download/example-cli-0.1.0/example-cli-0.1.0.tgz
```
