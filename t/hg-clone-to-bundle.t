#!/usr/bin/env bash

# Copyright © 2022 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u
pdir="${0%/*}/.."
prog="$pdir/hg-clone-to-bundle"
echo 1..1
tmpdir=$(mktemp -d -t hg-toolbox.test.XXXXXX)
hg init "$tmpdir/foo"
echo foo > "$tmpdir/foo/foo"
hg --cwd "$tmpdir/foo" add foo
hg --cwd "$tmpdir/foo" commit -m FOO
echo bar > "$tmpdir/foo/foo"
hg --cwd "$tmpdir/foo" commit -m BAR
"$prog" -o "$tmpdir/foo.hg" "$tmpdir/foo" >/dev/null
hg clone --quiet "$tmpdir/foo.hg" "$tmpdir/foo2"
hg --cwd "$tmpdir/foo" log -v > "$tmpdir/log"
hg --cwd "$tmpdir/foo2" log -v > "$tmpdir/log2"
diff=$(diff -u "$tmpdir/log" "$tmpdir/log2") || true
if [ -z "$diff" ]
then
    echo 'ok 1'
else
    # shellcheck disable=SC2001
    sed -e 's/^/# /' <<< "$diff"
    echo 'not ok 1'
fi
rm -rf "$tmpdir"

# vim:ts=4 sts=4 sw=4 et ft=sh
