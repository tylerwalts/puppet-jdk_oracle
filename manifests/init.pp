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
# [* java_install_dir *]
#   String.  Java Installation Directory
#   Defaults to <tt>/opt</tt>.
#
# [* use_cache *]
#   String.  Optionally host the installer file locally instead of fetching it each time (for faster dev & test)
#   The puppet cache flag is for faster local vagrant development, to
#   locally host the tarball from oracle instead of fetching it each time.
#   Defaults to <tt>false</tt>.
#
# [* platform *]
#   String.  The platform to use
#   Defaults to <tt>x64</tt>.
#
# [* ensure *]
#   String.  Specifies if jdk should be installed or absent
#   Defaults to <tt>installed</tt>.
#
class jdk_oracle(
  $version        = hiera('jdk_oracle::version',        '8' ),
  $version_update = hiera('jdk_oracle::version_update', 'default' ),
  $version_build  = hiera('jdk_oracle::version_build',  'default' ),
  $install_dir    = hiera('jdk_oracle::install_dir',    '/opt' ),
  $use_cache      = hiera('jdk_oracle::use_cache',      false ),
  $cache_source   = 'puppet:///modules/jdk_oracle/',
  $platform       = hiera('jdk_oracle::platform',       'x64' ),
  $ensure         = 'installed'
  ) {

  $default_8_update = '11'
  $default_8_build  = '12'
  $default_7_update = '67'
  $default_7_build  = '01'
  $default_6_update = '45'
  $default_6_build  = '06'

  if $ensure == 'installed' {
    # Set default exec path for this module
    Exec { path  => ['/usr/bin', '/usr/sbin', '/bin'] }

    case $platform {
      'x64': { $plat_filename = 'x64' }
      'x86': { $plat_filename = 'i586' }
      default: { fail("Unsupported platform: ${platform}.  Implement me?") }
    }

    case $version {
      '8': {
        if ($version_update != 'default') {
          $version_u = $version_update
        } else {
          $version_u = $default_8_update
        }
        if ($version_build != 'default'){
          $version_b = $version_build
        } else {
          $version_b = $default_8_build
        }
        $javaDownloadURI = "http://download.oracle.com/otn-pub/java/jdk/${version}u${version_u}-b${version_b}/jdk-${version}u${version_u}-linux-${plat_filename}.tar.gz"
        $java_home = "${install_dir}/jdk1.${version}.0_${version_u}"
      }
      '7': {
        if ($version_update != 'default'){
          $version_u = $version_update
        } else {
          $version_u = $default_7_update
        }
        if ($version_build != 'default'){
          $version_b = $version_build
        } else {
          $version_b = $default_7_build
        }
        $javaDownloadURI = "http://download.oracle.com/otn-pub/java/jdk/${version}u${version_u}-b${version_b}/jdk-${version}u${version_u}-linux-${plat_filename}.tar.gz"
        $java_home = "${install_dir}/jdk1.${version}.0_${version_u}"
      }
      '6': {
        if ($version_update != 'default'){
          $version_u = $version_update
        } else {
          $version_u = $default_6_update
        }
        if ($version_build != 'default'){
          $version_b = $version_build
        } else {
          $version_b = $default_6_build
        }
        $javaDownloadURI = "https://edelivery.oracle.com/otn-pub/java/jdk/${version}u${version_u}-b${version_b}/jdk-${version}u${version_u}-linux-${plat_filename}.bin"
        $java_home = "${install_dir}/jdk1.${version}.0_${version_u}"
      }
      default: {
        fail("Unsupported version: ${version}.  Implement me?")
      }
    }

    if ! defined(File["${install_dir}"]) {
      file { "${install_dir}":
        ensure  => directory,
      }
    }

    $installerFilename = inline_template('<%= File.basename(@javaDownloadURI) %>')

    if ( $use_cache ){
      notify { 'Using local cache for oracle java': }
      file { "${install_dir}/${installerFilename}":
        source  => "${cache_source}${installerFilename}",
        require => File["${install_dir}"],
      } ->
      exec { 'get_jdk_installer':
        cwd     => $install_dir,
        creates => "${install_dir}/jdk_from_cache",
        command => 'touch jdk_from_cache',
      }
    } else {
      exec { 'get_jdk_installer':
        cwd     => $install_dir,
        creates => "${install_dir}/${installerFilename}",
        command => "wget -c --no-cookies --no-check-certificate --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com\" --header \"Cookie: oraclelicense=accept-securebackup-cookie\" \"${javaDownloadURI}\" -O ${installerFilename}",
        timeout => 600,
        require => Package['wget'],
      }

      file { "${install_dir}/${installerFilename}":
        mode    => '0755',
        require => Exec['get_jdk_installer'],
      }

      if ! defined(Package['wget']) {
        package { 'wget':
          ensure =>  present,
        }
      }
    }

    # Java 7/8 comes in a tarball so just extract it.
    if ( $version in [ '7', '8' ] ) {
      exec { 'extract_jdk':
        cwd     => "${install_dir}/",
        command => "tar -xf ${installerFilename}",
        creates => $java_home,
        require => Exec['get_jdk_installer'],
      }
    }
    # Java 6 comes as a self-extracting binary
    if ( $version == '6' ) {
      exec { 'extract_jdk':
        cwd     => "${install_dir}/",
        command => "${install_dir}/${installerFilename}",
        creates => $java_home,
        require => File["${install_dir}/${installerFilename}"],
      }
    }

    # Set links depending on osfamily or operating system fact
    case $::osfamily {
      RedHat, Linux: {
        file { '/etc/alternatives/java':
          ensure  => link,
          target  => "${java_home}/bin/java",
          require => Exec['extract_jdk'],
        }
        file { '/etc/alternatives/javac':
          ensure  => link,
          target  => "${java_home}/bin/javac",
          require => Exec['extract_jdk'],
        }
        file { '/usr/sbin/java':
          ensure  => link,
          target  => '/etc/alternatives/java',
          require => File['/etc/alternatives/java'],
        }
        file { '/usr/sbin/javac':
          ensure  => link,
          target  => '/etc/alternatives/javac',
          require => File['/etc/alternatives/javac'],
        }
        file { "${install_dir}/java_home":
          ensure  => link,
          target  => $java_home,
          require => Exec['extract_jdk'],
        }
        file { "${install_dir}/jdk-${version}":
          ensure  => link,
          target  => $java_home,
          require => Exec['extract_jdk'],
        }
      }
      Debian:  {
        exec { "/usr/sbin/update-alternatives --install /usr/bin/java java ${java_home}/bin/java 20000":
          require => Exec['extract_jdk'],
          unless => "test $(readlink /etc/alternatives/java) = '${java_home}/bin/java'",
        }
        exec { "/usr/sbin/update-alternatives --install /usr/bin/javac javac ${java_home}/bin/javac 20000":
          require => Exec['extract_jdk'],
          unless => "test $(/bin/readlink /etc/alternatives/javac) = '${java_home}/bin/javac'",
        }
        augeas { 'environment':
          context => '/files/etc/environment',
          changes => [
            "set JAVA_HOME ${java_home}",
          ],
        }
      }
      default:   { fail('Unsupported OS, implement me?') }
    }
  }
}
