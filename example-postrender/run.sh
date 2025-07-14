#!/usr/bin/env sh

# set -e

cat <&0 | yq '.metadata.labels.foo = "bar"'

# cat <<EOF
# foo: bar
# baz: qux
# EOF
