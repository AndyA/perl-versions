#!/bin/bash

branch=$1
[ -z "$branch" ] && branch="master"

for v in 5.*; do
  if [ -d $v/.git ] ; then
    echo "Switching to $v $branch"
    pushd $v > /dev/null
    git checkout $branch
    popd > /dev/null
  fi
done


# vim:ts=2:sw=2:sts=2:et:ft=sh

