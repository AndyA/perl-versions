#!/bin/bash

function die() {
  echo "$*" >&2
  echo "Stopping"
  exit 1
}

version=$1; shift
[ -z "$version" ] && die "Syntax: cpan.sh <version>"
perl="$version/bin/perl"
[ -x $perl ] || die "No perl $version"
cpan="cpan/$version"
[ -d $cpan ] || die "No cpan config $version"

pushd $version > /dev/null
git branch
popd > /dev/null

$perl -I$cpan -MCPAN::MyConfig -MCPAN -e shell $*

# vim:ts=2:sw=2:sts=2:et:ft=sh
