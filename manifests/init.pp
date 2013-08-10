# Installs the Oracle Java 7 JDK
class jdk_oracle(
    $java_install_dir   ="/opt",
    $java_home_dir      ="/opt/jdk1.7.0"
    ) {

    # Set in this scope to be accessible from elsewhere
    $java_home = $java_home_dir

    exec { 'get_jdk_tarball':
        cwd     => "/opt",
        creates => "/opt/jdk-7-linux-x64.tar.gz",
        path    => ["/usr/bin", "/usr/sbin", "/bin"],
        command => "wget -c --no-cookies --no-check-certificate --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com\" \"http://download.oracle.com/otn-pub/java/jdk/7/jdk-7-linux-x64.tar.gz\" -O jdk-7-linux-x64.tar.gz",
        timeout => 600,
        require => Package['wget'],
    }

    exec { 'extract_jdk':
        cwd     => "/opt/",
        command => "tar -xf jdk-7-linux-x64.tar.gz",
        creates => "/opt/jdk1.7.0",
        path    => ["/usr/bin", "/usr/sbin", "/bin"],
        require => Exec['get_jdk_tarball'],
    }

    # Set links
    case $::osfamily {
        "RedHat":    {
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
        }
        "Debian":    { fail("TODO: Implement me!") }
        "Suse":      { fail("TODO: Implement me!") }
        "Solaris":   { fail("TODO: Implement me!") }
        "Gentoo":    { fail("TODO: Implement me!") }
        "Archlinux": { fail("TODO: Implement me!") }
        "Mandrake":  { fail("TODO: Implement me!") }
        default:     { fail("Unsupported osfamily") }
    }

}
