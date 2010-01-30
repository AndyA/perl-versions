#!/bin/bash

version=$1
[ -z "$version" ] && { echo "No version"; exit; }
[ -d $version ] || { echo "Bad version: $version"; exit; }
perl="$PWD/$version/bin/perl"
[ -x $perl ] || { echo "Bad perl: $perl"; exit; }

echo $version | beeb -c cyan

modules="Test-Simple-0.94 \
  File-Path-2.08 \
  File-Temp-0.22 \
  PathTools-3.31 \
  Scalar-List-Utils-1.22 \
  Test-Harness-3.20 \
  ExtUtils-Install-1.54 \
  ExtUtils-MakeMaker-6.56 \
  CPAN-1.9402"

toolchain="$PWD/toolchain"
libs=''

pushd $toolchain > /dev/null
for m in $modules; do

  dist="$toolchain/$m"
  tarball="$dist.tar.gz"
  [ -f $tarball ] || { echo "Can't find $tarball"; echo 1; }

  rm -rf $dist
  echo "Unpacking $tarball to $dist"
  tar zxf $tarball
  lib="$dist/lib"

  if [ -d $lib ] ; then
    [ -z "$libs" ] && libs=$lib || libs="$libs:$lib"
  else
    echo "Can't find $lib"
  fi

done
popd > /dev/null  

export PERL5LIB=$libs

pushd $version > /dev/null
git checkout master
popd > /dev/null  

for m in $modules; do
  echo "Installing $m"

  dist="$toolchain/$m"
  log="$PWD/$m-$version.log"

  pushd $toolchain > /dev/null
  popd > /dev/null  

  pushd $dist > /dev/null
  $perl Makefile.PL && make || { echo "Build failed"; exit 1; }
  echo "Testing $m on $version"
  make test >$log 2>&1 && rm -f $log
  echo "Installing $m on $version"
  make install || { echo "Install failed"; exit 1; }
  popd > /dev/null  

  pushd $version > /dev/null
  git add .
  git commit -m "Installed $m"
  popd > /dev/null  
done

pushd $version > /dev/null
git tag toolchain
popd > /dev/null  

# vim:ts=2:sw=2:sts=2:et:ft=sh
