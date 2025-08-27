
.DEFAULT: build
.PHONY: build test vet

PKG_SOURCE_FILES=$(shell go list -f '{{ $$dir := .Dir }}{{ range .GoFiles }}{{ printf "%s/%s " $$dir . }}{{ end }}' ./...)

plugin.wasm: $(PKG_SOURCE_FILES) go.mod go.sum
	GOOS=wasip1 GOARCH=wasm go build -buildmode=c-shared -o plugin.wasm .

build: plugin.wasm

vet:
	GOOS=wasip1 GOARCH=wasm go vet ./...

test: build
	go test ./testdriver