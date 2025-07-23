# Helm 4 Example plugin types

Example plugins to test [plugin-types](https://github.com/scottrigby/helm/tree/plugin-types) experimental branch as part of for [hip:0026: H4HIP: Wasm plugin system](https://github.com/helm/community/blob/main/hips/hip-0026.md).

That branch only adds the initial plugin types to Helm 4 to identify where to modify the codebase for the new types. Is not yet backwards compatible with Helm 3 plugins, and does not yet add support for additional runtimes (Wasm). Will be merged with Wasm runtime work and Helm 3 plugin backwards-compatibility.

See diff https://github.com/helm/helm/compare/main...scottrigby:helm:plugin-types

## To use

This repo includes a Makefile:

- `make test`
- `make clean`
