#!/bin/bash

for v in 5.*; do
  if [ -d $v/.git ] ; then
    pushd $v > /dev/null
    git checkout master
    git reset --hard baseline
    git tag | grep -v baseline | while read tag ; do
      echo "Removing $tag"
      git tag -d $tag
    done
    git branch | perl -pe 's/^..//g' | grep -v master | while read branch ; do
      echo "Removing $branch"
      git branch -D $branch
    done
    popd > /dev/null
  fi
done

# vim:ts=2:sw=2:sts=2:et:ft=sh

