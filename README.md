# Example simple Helm 4 plugin types

## To test

Make commands:

- install
- test
- uninstall
- clean

# Context

Example plugins for [scottrigby/simple-plugin-types](https://github.com/scottrigby/helm/tree/simple-plugin-types) experimental branch to add new plugin types to Helm 4.

The branch only includes the initial planned types, and does not include adding new runtimes (example Wasm).

It also does not include backwards-compatibility with Helm 3 style plugins (there is a new `type` field added).

This will be merged with Wasm plugin work for [hip:0026: H4HIP: Wasm plugin system](https://github.com/helm/community/blob/main/hips/hip-0026.md) to add the new runtime and Helm 3 plugin backwards-compatibility.
