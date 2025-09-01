#!/usr/bin/env sh

set -e

URI=$@

TMPDIR="$(mktemp -d)"

# make a fake chart for testing with the passed URL basename
FILENAME=$(basename -- $URI)
./helm4 create $TMPDIR/$FILENAME 1>/dev/null
./helm4 package $TMPDIR/$FILENAME -d $TMPDIR 1>/dev/null
# cat $FILENAME-0.1.0.tgz
# just to not need to know the chart version
rm -r $TMPDIR/$FILENAME 1>/dev/null
cat $TMPDIR/$FILENAME-*
