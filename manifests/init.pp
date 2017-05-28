# == Class: jdk_oracle
#
# Installs the Oracle Java JDK, from the Oracle servers
#
# === Parameters
#
# [*version*]
#   String.  Java Version to install
#   Defaults to <tt>8</tt>.
#
# [*version_update*]
#   String.  Java Version Update to install
#   Defaults to <tt>Defaults based on major version</tt>.
#
# [*version_build*]
#   String.  Java Version build to install
#   Defaults to <tt>Defaults based on major version</tt>.
#
# [*version_hash*]
#   String. Hash from the Oracle download URL. Must be specified for more
#   current Java versions. If set to an empty string, the hash is ignored
#   in the URL. Defaults to an empty string, but if version_update or
#   version_build are set to "default", the most current hash is used.
#
# [* java_install_dir *]
#   String.  Java Installation Directory
#   Defaults to <tt>/opt</tt>.
#
# [* use_cache *]
#   Boolean.  Optionally host the installer file locally instead of fetching it each time (for faster dev & test)
#   The puppet cache flag is for faster local vagrant development, to
#   locally host the tarball from oracle instead of fetching it each time.
#   Defaults to <tt>false</tt>.
#
# [* platform *]
#   String.  The platform to use
#   Defaults to <tt>x64</tt>.
#
# [* package *]
#   String.  Which package to install.  Can be one of the following: jdk, jre, server-jre
#   Defaults to <tt>jdk</tt>.
#
# [* jce *]
#   Boolean.  Optionally install Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files
#   Defaults to <tt>false</tt>.
#
# [* default_java *]
#   Boolean.  If the installed java version is linked as the default java, javac etc...
#   Defaults to <tt>true</tt>.
#
# [* ensure *]
#   String.  Specifies if jdk should be installed or absent
#   Defaults to <tt>installed</tt>.
#
class jdk_oracle (
  $version        = hiera('jdk_oracle::version',        '8' ),
  $version_update = hiera('jdk_oracle::version_update', 'default' ),
  $version_build  = hiera('jdk_oracle::version_build',  'default' ),
  $install_dir    = hiera('jdk_oracle::install_dir',    '/opt' ),
  $use_cache      = hiera('jdk_oracle::use_cache',      false ),
  $cache_source   = 'puppet:///modules/jdk_oracle/',
  $platform       = hiera('jdk_oracle::platform',       'x64' ),
  $package        = hiera('jdk_oracle::package',        'jdk' ),
  $jce            = hiera('jdk_oracle::jce',            false ),
  $default_java   = hiera('jdk_oracle::default_java',   true ),
  $download_url   = hiera('jdk_oracle::download_url',   'http://download.oracle.com/otn-pub/java'),
  $proxy_host     = hiera('jdk_oracle::proxy_host',     false ),
  $version_hash   = hiera('jdk_oracle::version_hash',   '' ),
  $ensure         = 'installed'
  ) {

  jdk_oracle::install { 'jdk_oracle':
    ensure         => $ensure,
    version        => $version,
    version_update => $version_update,
    version_build  => $version_build,
    install_dir    => $install_dir,
    use_cache      => $use_cache,
    cache_source   => $cache_source,
    platform       => $platform,
    package        => $package,
    jce            => $jce,
    version_hash   => $version_hash,
    default_java   => $default_java,
  }

  if ! defined(Package['curl']) {
    package { 'curl':
      ensure =>  present,
    }
  }

  if ! defined(Package['unzip']) {
    package { 'unzip':
      ensure =>  present,
    }
  }

}
