PLUGINS := example-cli example-download example-postrender example-legacy-cli example-legacy-download

helm4:
	$(eval TMP := $(shell mktemp -d))
	@pushd $(TMP) \
		&& git clone git@github.com:scottrigby/helm.git \
		&& cd helm \
		&& git checkout plugin-types \
		&& $(MAKE) build \
		&& popd \
		&& mv $(TMP)/helm/bin/helm helm4

dummy: helm4
	@./helm4 create dummy

.PHONY: install test uninstall clean

clean: uninstall
	@echo "==== Cleaning helm4 binary ===="
	@rm -r helm4 dummy || true

install: helm4
	@echo "==== Installing example plugins ===="
	@$(foreach name,$(PLUGINS),\
		./helm4 plugin install ./$(name) || true; \
	)

uninstall: helm4
	@echo "==== Uninstalling example plugins ===="
	@./helm4 plugin uninstall $(PLUGINS) || true

# TODO make these tests a little less verbose. But they should work
test: install dummy
	@echo "==== Testing example-cli plugin ===="
	@echo
	@./helm4 example-cli foo bar --baz=qux quxx
	@echo
	@echo "You should see 'running command example-cli with subcommand foo and args bar --baz=qux quxx'"
	@echo
	@echo "==== Testing example-download plugin ===="
	@echo
	@./helm4 template example example://does-not-matter/example
	@echo
	@echo "You should see an 'example' chart template"
	@echo
	@echo "==== Testing example-postrender plugin ===="
	@./helm4 template dummy dummy --post-renderer example-postrender
	@echo
	@echo "You should see the label 'foo: bar' on every 'dummy' chart resource"
	@echo
	@echo "==== Testing combined: example-postrender and download plugins ===="
	@./helm4 template example example://does-not-matter/example --post-renderer example-postrender
	@echo
	@echo "You should see the label 'foo: bar' on every 'example' chart resource"
	@echo
	@echo "==== Testing example-legacy-cli plugin ===="
	@echo
	@./helm4 example-legacy-cli foo bar --baz=qux quxx
	@echo
	@echo "You should see 'running command example-legacy-cli with subcommand foo and args bar --baz=qux quxx'"
	@echo
	@echo "==== Testing example-legacy-download plugin ===="
	@echo
	@./helm4 template example example-legacy://does-not-matter/example