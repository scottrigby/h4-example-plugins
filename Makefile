.PHONY: install test uninstall clean

PLUGINS := example-cli example-download example-postrender

helm4:
	@dir=$$(mktmp -d) \
		&& pushd $${dir} \
		&& git clone git@github.com:scottrigby/helm.git \
		&& git checkout simple-plugin-types \
		&& $(MAKE) build \
		&& popd \
		&& mv $${dir}/bin/helm helm4

clean:
	@rm ./helm4

install:
	@./helm4 plugin install $(PLUGINS)

uninstall:
	@./helm4 plugin uninstall $(PLUGINS)

test:
# 	@out=$$(./helm4 example-cli foo bar --baz=qux quxx)
	@echo "==== Testing example-cli plugin ===="
	@./helm4 example-cli foo bar --baz=qux quxx
	@echo
	@echo "You should see 'OUTPUT'"
	@echo
	@echo "==== Testing example-download plugin ===="
	@./helm4 template example example://does-not-matter/example
	@echo
	@echo "You should see an 'example' chart template"
	@echo
	@echo "==== Testing example-postrender plugin ===="
	@./helm4 create dummy
	@./helm4 template dummy dummy --post-renderer postr1
	@echo
	@echo "You should see the label 'foo: bar' on every 'dummy' chart resource"
	@echo
	@echo "==== Testing combined: example-postrender and download plugins ===="
	@./helm4 template example foo://does-not-matter/example --post-renderer postr1
	@echo
	@echo "You should see the label 'foo: bar' on every 'example' chart resource"

