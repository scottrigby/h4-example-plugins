package main

import (
	"archive/tar"
	"bytes"
	"compress/gzip"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"time"

	pdk "github.com/extism/go-pdk"
	"github.com/scottrigby/h4-example-plugin-types/example-extism-getter/chartutil"
)

type GetterOptionsV1 struct {
	URL                   string
	CertFile              string
	KeyFile               string
	CAFile                string
	UNTar                 bool
	InsecureSkipVerifyTLS bool
	PlainHTTP             bool
	AcceptHeader          string
	Username              string
	Password              string
	PassCredentialsAll    bool
	UserAgent             string
	Version               string
	Timeout               time.Duration
}

type InputMessageGetterV1 struct {
	Href     string          `json:"href"`
	Protocol string          `json:"protocol"`
	Options  GetterOptionsV1 `json:"options"`
}

type OutputMessageGetterV1 struct {
	Data []byte `json:"data"`
}

// createTarGz recursively reads all files in dir and writes their contents to buf as a tar.gz stream
func createTarGz(dir, prefix string) (*bytes.Buffer, error) {

	buf := &bytes.Buffer{}

	gw := gzip.NewWriter(buf)
	defer gw.Close()

	tw := tar.NewWriter(gw)
	defer tw.Close()

	if err := filepath.WalkDir(dir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}

		f, err := os.Open(path)
		if err != nil {
			return err
		}
		defer f.Close()

		fstat, err := f.Stat()
		if err != nil {
			return err
		}

		header := &tar.Header{
			Name: strings.TrimPrefix(path, prefix+"/"),
			Size: fstat.Size(),
			Mode: int64(fstat.Mode()),
		}

		if err := tw.WriteHeader(header); err != nil {
			return err
		}

		_, err = io.Copy(tw, f)
		if err != nil {
			return err
		}

		return nil
	}); err != nil {
		return nil, err
	}

	return buf, nil
}

func impl(input InputMessageGetterV1) (*OutputMessageGetterV1, error) {

	chartname := filepath.Base(input.Href)

	outputDirPrefix, err := os.MkdirTemp(os.TempDir(), "extism-getter-")
	if err != nil {
		return nil, fmt.Errorf("failed to create temp directory: %w", err)
	}
	defer os.RemoveAll(outputDirPrefix) // Comment to leave the directory for debugging

	pdk.Log(pdk.LogInfo, fmt.Sprintf("Creating chart %s in directory %s", chartname, outputDirPrefix))

	outputDir, err := chartutil.Create(chartname, outputDirPrefix)
	if err != nil {
		return nil, fmt.Errorf("failed to create chart: %w", err)
	}

	data, err := createTarGz(outputDir, outputDirPrefix)
	if err != nil {
		return nil, fmt.Errorf("failed to read files from output directory %s: %w", outputDir, err)
	}

	if data.Len() == 0 {
		panic("data buffer is empty, this should not happen")
	}

	return &OutputMessageGetterV1{
		Data: data.Bytes(),
	}, nil
}

func RunGetterPlugin() error {
	var input InputMessageGetterV1
	if err := pdk.InputJSON(&input); err != nil {
		return fmt.Errorf("failed to parse input json: %w", err)
	}

	pdk.Log(pdk.LogDebug, fmt.Sprintf("Received input: %+v", input))
	output, err := impl(input)
	if err != nil {
		pdk.Log(pdk.LogError, fmt.Sprintf("failed: %s", err.Error()))
		return err
	}

	pdk.Log(pdk.LogDebug, fmt.Sprintf("Sending output: %+v", output))
	if err := pdk.OutputJSON(output); err != nil {
		return fmt.Errorf("failed to write output json: %w", err)
	}

	return nil
}

//go:wasmexport helm_plugin_main
func HelmPlugin() uint32 {
	pdk.Log(pdk.LogDebug, "running example-extism-getter plugin")

	if err := RunGetterPlugin(); err != nil {
		pdk.Log(pdk.LogError, err.Error())
		pdk.SetError(err)
		return 1
	}

	return 0
}

func main() {}
