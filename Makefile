PLUGINS := $(notdir $(wildcard plugins/*))

HELM_BINARY := ./helm4

helm4:
	@if [ -f "$(HELM_BINARY)" ]; then \
		echo "Using existing helm4 binary"; \
	else \
		echo "Building Helm 4 from source..."; \
		TEMP_DIR=$$(mktemp -d); \
		git clone --depth 1 https://github.com/helm/helm.git "$$TEMP_DIR"; \
		make -C "$$TEMP_DIR" build; \
		cp "$$TEMP_DIR/bin/helm" $(HELM_BINARY); \
		echo "Helm 4 built and copied to $(HELM_BINARY)"; \
	fi

dummy: helm4
	@./helm4 create dummy

.PHONY: install test uninstall clean lint help

help:
	@echo "Available targets:"
	@echo "  install   - Build and install all example plugins"
	@echo "  test      - Run comprehensive plugin tests"
	@echo "  uninstall - Remove all installed plugins"
	@echo "  clean     - Clean built artifacts and uninstall plugins"
	@echo "  lint      - Run linting on plugin code"

lint:
	@echo "==== Linting plugin code ===="
	@for plugin in $(PLUGINS); do \
		if [ -f "plugins/$$plugin/go.mod" ]; then \
			echo "Linting Go plugin: $$plugin"; \
			(cd plugins/$$plugin && go fmt ./... && go vet ./...); \
		fi; \
	done


clean: uninstall
	@echo "==== Cleaning helm4 binary ===="
	@rm -rf helm4 dummy

install: helm4
	@echo "==== Building plugins that need building ===="
	@for plugin in $(PLUGINS); do \
		if [ -f "plugins/$$plugin/Makefile" ]; then \
			echo "Building $$plugin..."; \
			make -C plugins/$$plugin build; \
		fi; \
	done
	@echo "==== Installing example plugins ===="
	@for plugin in $(PLUGINS); do \
		echo "Installing $$plugin..."; \
		./helm4 plugin install ./plugins/$$plugin || { echo "Failed to install $$plugin"; exit 1; }; \
	done

uninstall: helm4
	@echo "==== Uninstalling example plugins ===="
	@for plugin in $(PLUGINS); do \
		echo "Uninstalling $$plugin..."; \
		./helm4 plugin uninstall $$plugin 2>/dev/null || true; \
	done

test: uninstall install dummy
	@echo "==== Testing plugins ===="
	@./helm4 example-cli foo bar --baz=qux quxx | grep -q "running command example-cli with subcommand foo and args bar --baz=qux quxx" && echo "✅ example-cli works" || echo "❌ example-cli failed"
	@./helm4 template example2 examplewasm://does-not-matter/example2 | grep -q "Source: example2/templates/serviceaccount.yaml" && echo "✅ example-extism-getter works" || echo "❌ example-extism-getter failed"
	@./helm4 template example example://does-not-matter/example | grep -q "Source: example/templates/serviceaccount.yaml" && echo "✅ example-getter works" || echo "❌ example-getter failed"
	@./helm4 example-legacy-cli foo bar --baz=qux quxx | grep -q "running command example-legacy-cli with subcommand foo and args bar --baz=qux quxx" && echo "✅ example-legacy-cli works" || echo "❌ example-legacy-cli failed"
	@./helm4 template example3 example-legacy://does-not-matter/example3 | grep -q "Source: example3/templates/serviceaccount.yaml" && echo "✅ example-legacy-downloader works" || echo "❌ example-legacy-downloader failed"
	@./helm4 template dummy dummy --post-renderer example-postrenderer | grep -q "foo: bar" && echo "✅ example-postrenderer works" || echo "❌ example-postrenderer failed"
	@OUTPUT=$$(./helm4 template example example://does-not-matter/example --post-renderer example-postrenderer); echo "$$OUTPUT" | grep -q "Source: example/templates/serviceaccount.yaml" && echo "$$OUTPUT" | grep -q "foo: bar" && echo "✅ combined getter+postrenderer works" || echo "❌ combined test failed"
	@echo "==== All plugin tests completed ====="
