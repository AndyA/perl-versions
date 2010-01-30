#!/bin/sh

proto="cpan/prototype"
for v in 5.*; do
  cpan="cpan/$v"
  if [ ! -d $cpan ] ; then
    echo CPAN config for $v
    cp -r $proto $cpan
    perl -pi -e "s/%VERSION%/$v/g" "$cpan/CPAN/MyConfig.pm"
  fi
done

# vim:ts=2:sw=2:sts=2:et:ft=sh

