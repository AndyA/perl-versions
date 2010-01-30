#!/usr/bin/env perl

use strict;
use warnings;

use File::chdir;
use File::Spec;

my ( $version, @modules ) = @ARGV;
die "Syntax: cpan.pl <version>\n" unless defined $version;

my $perl = File::Spec->catfile( $version, 'bin', 'perl' );
die "No $perl\n" unless -x $perl;

my $cpan = File::Spec->catdir( 'cpan', $version );
die "No $cpan\n" unless -d $cpan;

my ( $current, @branches ) = get_branches();
my @tags      = get_tags();
my %is_branch = map { $_ => 1 } @branches;
my %is_tag    = map { $_ => 1 } @tags;

print defined $current
 ? "On branch: $current\n"
 : "On no branch\n";

if ( @modules ) {
  if ( @modules == 1 ) {
    my $module = shift @modules;
    my $branch = branch_from_module( $module );

    git_branch( $branch );
    cpan_install( $module );

    my $newver = module_version( $module );
    die "No version for $module\n" unless defined $newver;

    print "Installed $module $newver\n";
    my $tag = "$branch/$newver";

    if ( $is_tag{$tag} ) {
      print "Already tagged\n";
    }
    else {
      git_commit( "Installed $module $newver" );
      git( tag => $tag );
    }
  }
  else {
    die "Don't know what to do with multiple modules\n";
  }
}
else {
  cpan( 'shell' );
}

sub git_commit {
  my $msg = shift;
  git( add => '.' );
  git( commit => '-m', $msg );
}

sub module_version {
  my $module  = shift;
  my $version = undef;
  with_cmd(
    $perl,
    "-M$module",
    '-e',
    "print \"\$${module}::VERSION\\n\"",
    sub {
      $version = $_;
    }
  );
  return $version;
}

sub git_branch {
  my $branch = shift;
  if ( $is_branch{$branch} ) {
    git( checkout => $branch );
  }
  else {
    git( checkout => 'baseline' );
    git( checkout => '-b', $branch );
  }
}

sub cpan_install {
  cpan( 'install("' . join( '", "', @_ ) . '")' );
}

sub cpan {
  my ( $cmd, @args ) = @_;
  cmd( $perl, "-I$cpan", '-MCPAN::MyConfig', '-MCPAN', '-e', $cmd,
    @args );
}

sub branch_from_module {
  ( my $mod = lc shift ) =~ s/::/-/g;
  return $mod;
}

sub git {
  local $CWD = $version;
  cmd( git => @_ );
}

sub cmd {
  my @cmd = @_;
  my $cmd = join ' ', @cmd;
  print ">> $cmd\n";
  system @cmd and die "$cmd failed; $?\n";
}

sub get_tags {
  my @tags = ();
  with_git( tag => sub { push @tags, $_ } );
  return @tags;
}

sub get_branches {
  my @branches = ();
  my $current  = undef;

  with_git(
    branch => sub {
      return unless /^(.).(.+)$/;
      my ( $state, $name ) = ( $1, $2 );
      $current = $name if $state eq '*';
      push @branches, $name;
    }
  );

  return $current, @branches;
}

sub tidy {
  my $s = shift;
  $s =~ s/^\s+//;
  $s =~ s/\s+$//;
  return $s;
}

sub with_git {
  my @cmd = @_;
  local $CWD = $version;
  return with_cmd( git => @cmd );
}

sub with_cmd {
  my @cmd  = @_;
  my $code = pop @cmd;
  my $cmd  = join ' ', @cmd;
  open my $sh, '-|', @cmd or die "Can't $cmd ($?)\n";
  while ( <$sh> ) { chomp; $code->() }
  close $sh or warn "Can't $cmd ($?) -- at exit\n";
  return $?;
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

