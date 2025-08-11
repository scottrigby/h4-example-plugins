#!/usr/bin/env sh

set -e

URI=$@

TMPDIR="$(mktemp -d)"
cd $TMPDIR

# make a fake chart for testing with the passed URL basename
FILENAME=$(basename -- $URI)
helm4 create $FILENAME 1>/dev/null
helm4 package $FILENAME 1>/dev/null
# cat $FILENAME-0.1.0.tgz
# just to not need to know the chart version
rm -r $FILENAME 1>/dev/null
cat $FILENAME-*

# echo "error in test plugin: TMPDIR=$TMPDIR, 1=$1, 2=$2, 3=$3, 4=$4" >&2
# exit 1

# remove the temporary dir
rm -rf $TMPDIR
