# Setup GitHub workflows

## 1. Generate GPG keypair

```bash
# build inside a container for isolation
container_id=$(podman build -q -f - . <<'EOF'
FROM debian:stable-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg ca-certificates && \
    rm -rf /var/lib/apt/lists/*
RUN useradd -ms /bin/bash gpguser
USER gpguser
WORKDIR /home/gpguser
ENTRYPOINT ["/bin/bash"]
EOF
)

podman run --rm -it -v $PWD:/home/gpguser/output $container_id

# inside container
read -s passphrase
(paste from 1password)

# check length
wc -c <<< $passphrase
(should be your passphrase length)

# generate GPG key 
gpg --batch --generate-key - <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: Example Plugin Author
Name-Email: example@example.com
Expire-Date: 1y
Passphrase: $passphrase
%commit
EOF

key_id=$(gpg --list-secret-keys --keyid-format=long | awk '/^sec/{print $2}' | cut -d'/' -f2)

# export public key for signing verification
gpg --armor --export $key_id > /home/gpguser/output/public-key.asc
# export private key (keep this secure!)
gpg --armor --export-secret-keys $key_id > /home/gpguser/output/private-key.asc
(paste passphrase from 1password)
```

## 2. Configure GitHub repo

1. **Add Repository Secrets:**
   - Go to Settings → Secrets and variables → Actions → Secrets tab
   - click "New repository secret"
   - Add `GPG_PRIVATE_KEY` containing the private key content from `private-key.asc`
   - Add `GPG_PASSPHRASE` containing the passphrase for the GPG private key

2. **Add Repository Variables:**
   - Go to Settings → Secrets and variables → Actions → Variables tab
   - click "New repository variable"
   - Add `SIGN` with value `true` (or `false` to disable signing)
   - Add `SIGNING_KEY_EMAIL` with your GPG key email address

3. **Add Public Key to Repository:**
   - Copy `public-key.asc` to the repository root
   - Commit and push this file

4. **Enable workflow permissions**
   - Go to Settings → Actions → General → Workflow permissions:
   - Select "Read and write permissions"
   - Check "Allow GitHub Actions to create and approve pull requests"
