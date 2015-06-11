define jdk_oracle::package(
  $version        = '8',
  $version_update = 'default',
  $version_build  = 'default',
  $install_dir    = '/opt',
  $use_cache      = false,
  $cache_source   = 'puppet:///modules/jdk_oracle/',
  $platform       = 'x64',
  $default_java   = true,
  $create_symlink = true,
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
        $javaDownloadURI = "http://download.oracle.com/otn-pub/java/jdk/${version}u${version_u}-b${v$
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
        $javaDownloadURI = "http://download.oracle.com/otn-pub/java/jdk/${version}u${version_u}-b${v$
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
        $javaDownloadURI = "https://edelivery.oracle.com/otn-pub/java/jdk/${version}u${version_u}-b$$
        $java_home = "${install_dir}/jdk1.${version}.0_${version_u}"
      }
      default: {
        fail("Unsupported version: ${version}.  Implement me?")
      }
    }

    if ! defined(File[$install_dir]) {
      file { $install_dir:
        ensure  => directory,
      }
    }

    $installerFilename = inline_template('<%= File.basename(@javaDownloadURI) %>')

    if ( $use_cache ){
      file { "${install_dir}/${installerFilename}":
        source  => "${cache_source}${installerFilename}",
        require => File[$install_dir],
      } ->
      exec { "get_jdk_installer_${version}":
        cwd     => $install_dir,
        creates => "${install_dir}/jdk_from_cache",
        command => 'touch jdk_from_cache',
      }
    } else {
      exec { "get_jdk_installer_${version}":
        cwd     => $install_dir,
        creates => "${install_dir}/${installerFilename}",
        command => "wget -c --no-cookies --no-check-certificate --header \"Cookie: gpw_e24=http%3A%2$
        timeout => 600,
        require => Package['wget'],
      }

      file { "${install_dir}/${installerFilename}":
        mode    => '0755',
        require => Exec["get_jdk_installer_${version}"],
      }

      if ! defined(Package['wget']) {
        package { 'wget':
          ensure =>  present,
        }
      }
    }

    # Java 7/8 comes in a tarball so just extract it.
    if ( $version in [ '7', '8' ] ) {
      exec { "extract_jdk_${version}":
        cwd     => "${install_dir}/",
        command => "tar -xf ${installerFilename}",
        creates => $java_home,
        require => Exec["get_jdk_installer_${version}"],
      }
    }
    # Java 6 comes as a self-extracting binary
    if ( $version == '6' ) {
      exec { "extract_jdk_${version}":
        cwd     => "${install_dir}/",
        command => "${install_dir}/${installerFilename}",
        creates => $java_home,
        require => File["${install_dir}/${installerFilename}"],
      }
    }

    # Ensure that files belong to root
    file {$java_home:
      recurse   => true,
      owner     => root,
      group     => root,
      subscribe => Exec["extract_jdk_${version}"],
    }

    # Set links depending on osfamily or operating system fact
    case $::osfamily {
      'RedHat', Linux: {
        if ( $default_java ) {
          file { '/etc/alternatives/java':
            ensure  => link,
            target  => "${java_home}/bin/java",
            require => Exec["extract_jdk_${version}"],
          }
          file { '/etc/alternatives/javac':
            ensure  => link,
            target  => "${java_home}/bin/javac",
            require => Exec["extract_jdk_${version}"],
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
        }
        if ( $create_symlink ) {
          file { "${install_dir}/java_home":
            ensure  => link,
            target  => $java_home,
            require => Exec["extract_jdk_${version}"],
          }
          file { "${install_dir}/jdk-${version}":
            ensure  => link,
            target  => $java_home,
            require => Exec["extract_jdk_${version}"],
          }
        }
      }
      Debian:  {
        #Accommodate variations in default install locations for some variants of Debian
        $path_to_updatealternatives_tool = $::lsbdistdescription ? {
          /Ubuntu 14\.04.*/ => '/usr/bin/update-alternatives',
          default           => '/usr/sbin/update-alternatives',
        }

        if ( $default_java ) {
          exec { "${path_to_updatealternatives_tool} --install /usr/bin/java java ${java_home}/bin/j$
            require => Exec["extract_jdk_${version}"],
            unless  => "test $(readlink /etc/alternatives/java) = '${java_home}/bin/java'",
          }
          exec { "${path_to_updatealternatives_tool} --install /usr/bin/javac javac ${java_home}/bin$
            require => Exec["extract_jdk_${version}"],
            unless  => "test $(/bin/readlink /etc/alternatives/javac) = '${java_home}/bin/javac'",
          }
          augeas { 'environment':
            context => '/files/etc/environment',
            changes => [
              "set JAVA_HOME ${java_home}",
            ],
          }
        }
      }
      Suse: {
        if ( $default_java ) {
          class { 'jdk_oracle::suse' :
            version   => $version,
            version_u => $version_u,
            version_b => $version_b,
            java_home => $java_home,
          }
        }
      }

      default:   { fail('Unsupported OS, implement me?') }
    }
  }
}
