package main_test

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"testing"

	extism "github.com/extism/go-sdk"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

var input []byte = []byte(`{
    "options": {
	},
    "href": "examplewasm://does-not-matter/example2"
}`)

type GetterPluginOutput struct {
	Data []byte `json:"data"`
}

func TestGetter(t *testing.T) {
	// TODO: switch to using Helm plugin runtime
	exampleGetterPluginBytes, err := os.ReadFile("../plugin.wasm")
	require.Nil(t, err)

	tmpDir, err := os.MkdirTemp(os.TempDir(), "helm-plugin-")
	require.NoError(t, err)

	manifest := extism.Manifest{
		Wasm: []extism.Wasm{
			extism.WasmData{
				Data: exampleGetterPluginBytes,
				Name: "example-extism-getter/plugin.wasm",
			},
		},
		Memory: &extism.ManifestMemory{
			MaxPages:             65535,
			MaxHttpResponseBytes: 1024 * 1024 * 10,
			MaxVarBytes:          1024 * 1024 * 10,
		},
		Config:       map[string]string{},
		AllowedHosts: []string{},
		AllowedPaths: map[string]string{
			tmpDir: "/tmp",
		},
		Timeout: 0,
	}

	ctx := context.Background()
	config := extism.PluginConfig{
		EnableWasi:                true,
		EnableHttpResponseHeaders: true,
	}
	plugin, err := extism.NewPlugin(ctx, manifest, config, []extism.HostFunction{})
	plugin.SetLogger(func(logLevel extism.LogLevel, s string) {
		fmt.Println(s)
	})

	if err != nil {
		fmt.Printf("Failed to initialize plugin: %v\n", err)
		os.Exit(1)
	}

	exitCode, outputData, err := plugin.Call("helm_plugin_main", input)
	require.Nil(t, err)
	assert.Equal(t, uint32(0), exitCode)

	output := GetterPluginOutput{}
	if err := json.Unmarshal(outputData, &output); err != nil {
		assert.Nil(t, err)
	}

	os.WriteFile("output.tar.gz", output.Data, 0o666)

	h := sha256.New()
	h.Write(output.Data)
	assert.Equal(t, "9a71dd5ec961947dd10fc012199f867e2fbea578c3981d5416380a1765d3a96f", hex.EncodeToString(h.Sum(nil)))
}
