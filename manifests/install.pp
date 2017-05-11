define jdk_oracle::install(
  $version        = '8',
  $version_update = 'default',
  $version_build  = 'default',
  $install_dir    = '/opt',
  $use_cache      = false,
  $cache_source   = 'puppet:///modules/jdk_oracle/',
  $platform       = 'x64',
  $package        = 'jdk',
  $jce            = false,
  $default_java   = true,
  $create_symlink = true,
  $version_hash   = '',
  $ensure         = 'installed',
) {

  $default_8_update = '121'
  $default_8_build  = '13'
  $default_8_hash = 'e9e7ea248e2c4826b92b3f075a80e441'
  $default_7_update = '80'
  $default_7_build  = '15'
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

    if $package != 'jdk' and $package != 'server-jre' and $package != 'jre' {
      fail("Unsupported package: ${package}.  Implement me?")
    }

    $package_home = $package ? {
      'jre' => 'jre',
      default => 'jdk'
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
        if (($version_update == 'default' or $version_build == 'default') and ($version_hash == '')) {
          # If either version parts are default and hash is empty,
          # Assume, that the user means the default value
          $version_h = $default_8_hash
        } elsif ($version_hash != 'default') {
          $version_h = $version_hash
        } else {
          $version_h = $default_8_hash
        }
        $pkg_name = "${package}-${version}u${version_u}-linux-${plat_filename}.tar.gz"
        # useful to set alternatives priority
        $int_version = "1${version}0${version_u}"
        if ($version_h != '') {
          $java_download_uri = "${jdk_oracle::download_url}/jdk/${version}u${version_u}-b${version_b}/${version_h}/${pkg_name}"
        } else {
          $java_download_uri = "${jdk_oracle::download_url}/jdk/${version}u${version_u}-b${version_b}/${pkg_name}"
        }

        $java_home = "${install_dir}/${package_home}1.${version}.0_${version_u}"
        $jdc_download_uri = "${jdk_oracle::download_url}/jce/8/jce_policy-8.zip"
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
        $pkg_name = "${package}-${version}u${version_u}-linux-${plat_filename}.tar.gz"
        # useful to set alternatives priority
        $int_version = "1${version}0${version_u}"
        $java_download_uri = "${jdk_oracle::download_url}/jdk/${version}u${version_u}-b${version_b}/${pkg_name}"
        $java_home = "${install_dir}/${package_home}1.${version}.0_${version_u}"
        $jdc_download_uri = "${jdk_oracle::download_url}/jce/7/UnlimitedJCEPolicyJDK7.zip"
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
        # not updated to use download url, who's using jdk 6 anyways ?
        $java_download_uri = "https://edelivery.oracle.com/otn-pub/java/jdk/${version}u${version_u}-b${version_b}/${package}-${version}u${version_u}-linux-${plat_filename}.bin"
        $java_home = "${install_dir}/${package_home}1.${version}.0_${version_u}"
        $jdc_download_uri = 'http://download.oracle.com/otn-pub/java/jce_policy/6/jce_policy-6.zip'
      }
      default: {
        fail("Unsupported version: ${version}.  Implement me?")
      }
    }

    if !defined(File[$install_dir]) {
      file { $install_dir:
        ensure => directory,
      }
    }

    $installer_filename = $pkg_name

    if ( $use_cache ){
      file { "${install_dir}/${installer_filename}":
        source  => "${cache_source}${installer_filename}",
        require => File[$install_dir],
      }
      -> exec { "get_${package}_installer_${version}":
        cwd     => $install_dir,
        creates => "${install_dir}/${package}_from_cache",
        command => "touch ${package}_from_cache",
      }
    } else {
      if ( $version in [ '7', '8' ] ) {
        archive { "${install_dir}/${installer_filename}":
          ensure        => present,
          extract       => true,
          source        => $java_download_uri,
          proxy_server  => $jdk_oracle::proxy_host,
          cookie        => 'oraclelicense=accept-securebackup-cookie',
          extract_path  => "${java_home}/..",
          extract_flags => '-xzof',
          creates       => "${java_home}/bin/java",
          cleanup       => true,
          require       => File[$java_home],
          user          => 'root',
          group         => 'root'
        }
      } elsif ( $version == '6' ) {
        exec { "get_${package}_installer_${version}":
          cwd     => $install_dir,
          creates => "${install_dir}/${installer_filename}",
          command => "wget -c --no-cookies --no-check-certificate --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com\" --header \"Cookie: oraclelicense=accept-securebackup-cookie\" \"${java_download_uri}\" -O ${installer_filename}",
          timeout => 600,
          require => Package['wget'],
        }
        exec { "extract_${package}_${version}":
          cwd     => "${install_dir}/",
          command => "${install_dir}/${installer_filename}",
          creates => $java_home,
          require => File["${install_dir}/${installer_filename}"],
        }
        file { "${install_dir}/${installer_filename}":
          mode    => '0755',
          require => Exec["get_${package}_installer_${version}"],
        }

        ensure_packages(['wget'], {'ensure' => 'present'})
      }
    }
    # Ensure that files belong to root
    file { $java_home:
      ensure => directory,
      owner  => root,
      group  => root,
    }

    if ($package == 'jdk' ) {
      alternative_entry { "${java_home}/bin/javac":
        ensure   => present,
        altlink  => '/usr/bin/javac',
        altname  => 'javac',
        priority => $int_version,
        require  => Archive["${install_dir}/${installer_filename}"]
      }
      alternative_entry { "${java_home}/bin/jar":
        ensure   => present,
        altlink  => '/usr/bin/jar',
        altname  => 'jar',
        priority => $int_version,
        require  => Archive["${install_dir}/${installer_filename}"]
      }
    }
    alternative_entry { "${java_home}/bin/java":
      ensure   => present,
      altlink  => '/usr/bin/java',
      altname  => 'java',
      priority => $int_version,
      require  => Archive["${install_dir}/${installer_filename}"]
    }
    # Set links depending on osfamily or operating system fact
    case $::osfamily {
      'RedHat', 'Linux', 'debian': {
        if ( $default_java ) {
          alternatives { 'java':
            path    => "${java_home}/bin/java",
            require => Alternative_entry["${java_home}/bin/java"]
          }
          if $package == 'jdk' {
            alternatives { 'javac':
              path    => "${java_home}/bin/javac",
              require => Alternative_entry["${java_home}/bin/javac"]
            }
            alternatives { 'jar':
              path    => "${java_home}/bin/jar",
              require => Alternative_entry["${java_home}/bin/jar"]
            }
          }
          file { '/etc/profile.d/java.sh':
            ensure  => present,
            content => "export JAVA_HOME=${java_home}; PATH=\${PATH}:${java_home}/bin",
            require => Alternatives['java'],
          }
          if ( $create_symlink ) {
            file { "${install_dir}/java_home":
              ensure  => link,
              target  => $java_home,
              require => Archive["${install_dir}/${installer_filename}"]
            }
            file { "${install_dir}/${package}-${version}":
              ensure  => link,
              target  => $java_home,
              require => Archive["${install_dir}/${installer_filename}"]
            }
          }
        }
      }
      'Suse': {
        if ( $default_java ) {
          include 'jdk_oracle::suse'
        }
      }
      default: { fail("Unsupported OS: ${::osfamily}.  Implement me?") }
    }
    if ( $jce ) {
      $jce_filename = basename($jdc_download_uri)
      $jce_dir = $version ? {
        '8' => 'UnlimitedJCEPolicyJDK8',
        '7' => 'UnlimitedJCEPolicy',
        '6' => 'jce'
      }
      $security_dir = $package ? {
        'jre' => "${java_home}/lib/security",
        default => "${java_home}/jre/lib/security"
      }
      if ( $use_cache ) {
        file { "${install_dir}/${jce_filename}":
          source  => "${cache_source}${jce_filename}",
          require => File[$install_dir],
        }
        -> exec { 'get_jce_package':
          cwd     => $install_dir,
          creates => "${install_dir}/jce_from_cache",
          command => 'touch jce_from_cache',
        }
      } else {
        archive { "${install_dir}/${jce_filename}":
          ensure          => present,
          extract         => true,
          source          => $jdc_download_uri,
          proxy_server    => $jdk_oracle::proxy_host,
          cookie          => 'oraclelicense=accept-securebackup-cookie',
          extract_path    => $security_dir,
          extract_command => "unzip -d ${security_dir} -o -j %s",
          creates         => "${security_dir}/README.txt",
          cleanup         => true,
          require         => [Archive["${install_dir}/${installer_filename}"],File[$java_home]],
          user            => 'root',
          group           => 'root',
        }
      }
    }
  }
}
