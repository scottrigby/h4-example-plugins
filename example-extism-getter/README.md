# example-extism-getter

Example "getter" plugin for Helm 4 using the Extism runtime.

## Usage

```sh
make -C ../../helm && make && rm -rf dummy /Users/gjenkins8/Library/helm/plugins/example-extism-getter; ../helm4 plugin install . &&  HELM_DEBUG=1 ../helm4 template example examplewasm://does-not-matter/example2
```
