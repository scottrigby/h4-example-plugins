PLUGINS := example-cli example-getter example-postrenderer example-legacy-cli example-legacy-downloader

HELM_BINARY := ../helm/bin/helm

helm4:
    # A suitable version of Helm source needs to be checked out and built at ../helm
    # e.g.
    # git clone https://github.com/scottrigby/helm -b plugin-types --depth 1 ../helm
    # make -C ../helm
	test -f $(HELM_BINARY) # need to ensure helm git is checked out ../helm, and helm has been built e.g. make -C ../helm
	ln -s $(HELM_BINARY) helm4

dummy: helm4
	@./helm4 create dummy

.PHONY: install test uninstall clean

clean: uninstall
	@echo "==== Cleaning helm4 binary ===="
	@rm -rf helm4 dummy

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
	@echo "==== Testing example-getter plugin ===="
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
	@echo "==== Testing combined: example-postrender and getter plugins ===="
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
	@echo "==== Testing example-legacy-downloader plugin ===="
	@echo
	@./helm4 template example example-legacy://does-not-matter/example
