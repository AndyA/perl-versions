#!/bin/sh

for v in 5.*; do
  if [ ! -d $v/.git ] ; then
    echo "Creating $v baseline"
    pushd $v > /dev/null
    git init
    git add .
    git commit -m 'Initial check in'
    git tag baseline
    popd > /dev/null
  fi
done

# vim:ts=2:sw=2:sts=2:et:ft=sh

