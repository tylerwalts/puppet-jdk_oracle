# Installs the Oracle Java JDK
#
# The puppet cache flag is for faster local vagrant development, to
# locally host the tarball from oracle instead of fetching it each time.
#
class jdk_oracle(
    $version      = hiera('jdk_oracle::version',     "7" ),
    $install_dir  = hiera('jdk_oracle::install_dir', "/opt" ),
    $use_cache    = hiera('jdk_oracle::use_cache',   "false" ),
    ) {

    case $version {
        "7": {
            $javaDownloadURI="http://download.oracle.com/otn-pub/java/jdk/7/jdk-7-linux-x64.tar.gz"
            $java_home = "$install_dir/jdk1.7.0"
        }
        "6": {
            $javaDownloadURI="http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-x64.bin"
            $java_home = "$install_dir/jdk1.6.0_45"
        }
    }

    $installerFilename = inline_template('<%= File.basename(@javaDownloadURI) %>')

    if ( "$use_cache" == "true" ){
        notify { 'Using local cache for oracle java': }
        file { "$install_dir/jdk-${version}-linux-x64.tar.gz":
            source  => 'puppet:///modules/jdk_oracle/jdk-${version}-linux-x64.tar.gz'
        }
        exec { 'get_jdk_installer':
            cwd     => "$install_dir",
            creates => "$install_dir/jdk_from_cache",
            command => "touch jdk_from_cache",
            path    => ["/usr/bin", "/usr/sbin", "/bin"],
            require => File["$install_dir/jdk-${version}-linux-x64.tar.gz"],
        }
    } else {
        exec { 'get_jdk_installer':
            cwd     => "$install_dir",
            creates => "${install_dir}/${installerFilename}",
            path    => ["/usr/bin", "/usr/sbin", "/bin"],
            command => "wget -c --no-cookies --no-check-certificate --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com\" \"$javaDownloadURI\" -O ${installerFilename}",
            timeout => 600,
            require => Package['wget'],
        }
    }

    # Java 7 comes in a tarball so just extract it.
    if ( $version == "7" ) {
        exec { 'extract_jdk':
            cwd     => "$install_dir/",
            command => "tar -xf ${installerFilename}",
            creates => $java_home,
            path    => ["/usr/bin", "/usr/sbin", "/bin"],
            require => Exec['get_jdk_installer'],
        }
    }
    # Java 6 comes as a self-extracting binary
    if ( $version == "6" ) {
        file { "$install_dir/${installerFilename}":
            mode    => 0755,
            require => Exec['get_jdk_installer'],
        }
        exec { 'extract_jdk':
            cwd     => "$install_dir/",
            command => "$install_dir/${installerFilename}",
            creates => $java_home,
            path    => ["/usr/bin", "/usr/sbin", "/bin"],
            require => File["$install_dir/${installerFilename}"],
        }
    }

    # Set links depending on osfamily or operating system fact
    case $::osfamily {
        RedHat, Linux: {
            file { "/etc/alternatives/java":
                ensure  => link,
                target  => "${java_home}/bin/java",
                require => Exec['extract_jdk'],
            }
            file { "/etc/alternatives/javac":
                ensure  => link,
                target  => "${java_home}/bin/javac",
                require => Exec['extract_jdk'],
            }
            file { "/usr/sbin/java":
                ensure  => link,
                target  => "/etc/alternatives/java",
                require => File['/etc/alternatives/java'],
            }
            file { "/usr/sbin/javac":
                ensure  => link,
                target  => "/etc/alternatives/javac",
                require => File['/etc/alternatives/javac'],
            }
            file { "/opt/java_home":
                ensure  => link,
                target  => "$java_home",
                require => Exec['extract_jdk'],
            }
        }
        Debian:    { fail("TODO: Implement me!") }
        Suse:      { fail("TODO: Implement me!") }
        Solaris:   { fail("TODO: Implement me!") }
        Gentoo:    { fail("TODO: Implement me!") }
        Archlinux: { fail("TODO: Implement me!") }
        Mandrake:  { fail("TODO: Implement me!") }
        default:     { fail("Unsupported OS") }
    }

}
