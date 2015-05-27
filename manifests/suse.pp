# == Class: jdk_oracle::suse
#
# Creates links, directories and alternatives for Suse
#
# === Parameters
#
class jdk_oracle::suse {

  $java_home_loc = $jdk_oracle::java_home

  # Make the update-alternatives priority integer based on version, version_u, version_b
  $ua_priority = $jdk_oracle::version * 1000000 + $jdk_oracle::version_u * 1000 + $jdk_oracle::version_b

  # These need to be created, and the paths used later
  $libjvm_root = '/usr/lib64/jvm'
  $export_root = '/usr/lib64/jvm-exports'

  file { [ $libjvm_root, $export_root ] :
    ensure  => directory,
    require => Exec['extract_jdk'],
  }

  # To put the update-alternatives links in the right place
  $java_home_basename = inline_template('<%= File.basename(@java_home_loc) %>')
  $export_dir = "${export_root}/${java_home_basename}"

  file { $export_dir:
    ensure  => directory,
    path    => $export_dir,
    require => File[$export_root],
  }

  # Oracle-specific symlinks are versioned like so
  $export_version = "1.${jdk_oracle::version}.0"

  # Do all of the symlinks to jvm-exports
  file { "${export_dir}/jaas-${export_version}_Orac.jar" :
    ensure  => link,
    target  => "${java_home_loc}/jre/lib/rt.jar",
    require => File[ $export_dir ],
  } ->
  file { "${export_dir}/jaas-${export_version}.jar" :
    ensure => link,
    target => "${export_dir}/jaas-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jaas.jar" :
    ensure => link,
    target => "${export_dir}/jaas-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jce-${export_version}_Orac.jar" :
    ensure => link,
    target => "${java_home_loc}/jre/lib/jce.jar",
  } ->
  file { "${export_dir}/jce-${export_version}.jar" :
    ensure => link,
    target => "${export_dir}/jce-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jce.jar" :
    ensure => link,
    target => "${export_dir}/jce-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jdbc-stdext-${export_version}_Orac.jar" :
    ensure => link,
    target => "${java_home_loc}/jre/lib/rt.jar",
  } ->
  file { "${export_dir}/jdbc-stdext-${export_version}.jar" :
    ensure => link,
    target => "${export_dir}/jdbc-stdext-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jdbc-stdext-3.0.jar" :
    ensure => link,
    target => "${export_dir}/jdbc-stdext-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jdbc-stdext.jar" :
    ensure => link,
    target => "${export_dir}/jdbc-stdext-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jndi-${export_version}_Orac.jar" :
    ensure => link,
    target => "${java_home_loc}/jre/lib/rt.jar",
  } ->
  file { "${export_dir}/jndi-${export_version}.jar" :
    ensure => link,
    target => "${export_dir}/jndi-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jndi.jar" :
    ensure => link,
    target => "${export_dir}/jndi-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jndi-cos-${export_version}_Orac.jar" :
    ensure => link,
    target => "${java_home_loc}/jre/lib/rt.jar",
  } ->
  file { "${export_dir}/jndi-cos-${export_version}.jar" :
    ensure => link,
    target => "${export_dir}/jndi-cos-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jndi-cos.jar" :
    ensure => link,
    target => "${export_dir}/jndi-cos-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jndi-ldap-${export_version}_Orac.jar" :
    ensure => link,
    target => "${java_home_loc}/jre/lib/rt.jar",
  } ->
  file { "${export_dir}/jndi-ldap-${export_version}.jar" :
    ensure => link,
    target => "${export_dir}/jndi-ldap-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jndi-ldap.jar" :
    ensure => link,
    target => "${export_dir}/jndi-ldap-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jndi-rmi-${export_version}_Orac.jar" :
    ensure => link,
    target => "${java_home_loc}/jre/lib/rt.jar",
  } ->
  file { "${export_dir}/jndi-rmi-${export_version}.jar" :
    ensure => link,
    target => "${export_dir}/jndi-rmi-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jndi-rmi.jar" :
    ensure => link,
    target => "${export_dir}/jndi-rmi-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jsse-${export_version}_Orac.jar" :
    ensure => link,
    target => "${java_home_loc}/jre/lib/jsse.jar",
  } ->
  file { "${export_dir}/jsse-${export_version}.jar" :
    ensure => link,
    target => "${export_dir}/jsse-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/jsse.jar" :
    ensure => link,
    target => "${export_dir}/jsse-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/sasl-${export_version}_Orac.jar" :
    ensure => link,
    target => "${java_home_loc}/jre/lib/rt.jar",
  } ->
  file { "${export_dir}/sasl-${export_version}.jar" :
    ensure => link,
    target => "${export_dir}/sasl-${export_version}_Orac.jar",
  } ->
  file { "${export_dir}/sasl.jar" :
    ensure => link,
    target => "${export_dir}/sasl-${export_version}_Orac.jar",
  }


  $alt_java = "\
/usr/sbin/update-alternatives --install /usr/bin/java java ${java_home_loc}/bin/java ${ua_priority} \
 --slave /usr/lib64/jvm/jre jre ${java_home_loc}/jre \
 --slave /usr/lib64/jvm-exports/jre jre_exports /usr/lib64/jvm-exports/${java_home_basename} \
 --slave /usr/bin/keytool keytool ${java_home_loc}/bin/keytool \
 --slave /usr/bin/orbd orbd ${java_home_loc}/bin/orbd \
 --slave /usr/bin/policytool policytool ${java_home_loc}/bin/policytool \
 --slave /usr/bin/rmid rmid ${java_home_loc}/bin/rmid \
 --slave /usr/bin/rmiregistry rmiregistry ${java_home_loc}/bin/rmiregistry \
 --slave /usr/bin/servertool servertool ${java_home_loc}/bin/servertool \
 --slave /usr/bin/tnameserv tnameserv ${java_home_loc}/bin/tnameserv \
 --slave /usr/share/man/man1/java.1 java.1 ${java_home_loc}/man/man1/java.1 \
 --slave /usr/share/man/man1/keytool.1 keytool.1 ${java_home_loc}/man/man1/keytool.1 \
 --slave /usr/share/man/man1/orbd.1 orbd.1 ${java_home_loc}/man/man1/orbd.1 \
 --slave /usr/share/man/man1/policytool.1 policytool.1 ${java_home_loc}/man/man1/policytool.1 \
 --slave /usr/share/man/man1/rmid.1 rmid.1 ${java_home_loc}/man/man1/rmid.1 \
 --slave /usr/share/man/man1/rmiregistry.1 rmiregistry.1 ${java_home_loc}/man/man1/rmiregistry.1 \
 --slave /usr/share/man/man1/servertool.1 servertool.1 ${java_home_loc}/man/man1/servertool.1 \
 --slave /usr/share/man/man1/tnameserv.1 tnameserv.1 ${java_home_loc}/man/man1/tnameserv.1 \
"

  $alt_javac = "\
/usr/sbin/update-alternatives --install /usr/bin/javac javac ${java_home_loc}/bin/javac ${ua_priority} \
--slave /usr/bin/appletviewer appletviewer ${java_home_loc}/bin/appletviewer \
--slave /usr/bin/apt apt ${java_home_loc}/bin/apt \
--slave /usr/bin/extcheck extcheck ${java_home_loc}/bin/extcheck \
--slave /usr/bin/jar jar ${java_home_loc}/bin/jar \
--slave /usr/bin/jarsigner jarsigner ${java_home_loc}/bin/jarsigner \
--slave /usr/lib64/jvm/java java_sdk ${java_home_loc} \
--slave /usr/lib64/jvm-exports/java java_sdk_exports /usr/lib64/jvm-exports/${java_home_basename} \
--slave /usr/bin/javadoc javadoc ${java_home_loc}/bin/javadoc \
--slave /usr/bin/javah javah ${java_home_loc}/bin/javah \
--slave /usr/bin/javap javap ${java_home_loc}/bin/javap \
--slave /usr/bin/jconsole jconsole ${java_home_loc}/bin/jconsole \
--slave /usr/bin/jdb jdb ${java_home_loc}/bin/jdb \
--slave /usr/bin/jhat jhat ${java_home_loc}/bin/jhat \
--slave /usr/bin/jinfo jinfo ${java_home_loc}/bin/jinfo \
--slave /usr/bin/jmap jmap ${java_home_loc}/bin/jmap \
--slave /usr/bin/jps jps ${java_home_loc}/bin/jps \
--slave /usr/bin/jrunscript jrunscript ${java_home_loc}/bin/jrunscript \
--slave /usr/bin/jsadebugd jsadebugd ${java_home_loc}/bin/jsadebugd \
--slave /usr/bin/jstack jstack ${java_home_loc}/bin/jstack \
--slave /usr/bin/jstat jstat ${java_home_loc}/bin/jstat \
--slave /usr/bin/jstatd jstatd ${java_home_loc}/bin/jstatd \
--slave /usr/bin/native2ascii native2ascii ${java_home_loc}/bin/native2ascii \
--slave /usr/bin/pack200 pack200 ${java_home_loc}/bin/pack200 \
--slave /usr/bin/rmic rmic ${java_home_loc}/bin/rmic \
--slave /usr/bin/schemagen schemagen ${java_home_loc}/bin/schemagen \
--slave /usr/bin/serialver serialver ${java_home_loc}/bin/serialver \
--slave /usr/bin/unpack200 unpack200 ${java_home_loc}/bin/unpack200 \
--slave /usr/bin/wsgen wsgen ${java_home_loc}/bin/wsgen \
--slave /usr/bin/wsimport wsimport ${java_home_loc}/bin/wsimport \
--slave /usr/bin/xjc xjc ${java_home_loc}/bin/xjc \
--slave /usr/share/man/man1/appletviewer.1 appletviewer.1 ${java_home_loc}/man/man1/appletviewer.1 \
--slave /usr/share/man/man1/apt.1 apt.1 ${java_home_loc}/man/man1/apt.1 \
--slave /usr/share/man/man1/extcheck.1 extcheck.1 ${java_home_loc}/man/man1/extcheck.1 \
--slave /usr/share/man/man1/jar.1 jar.1 ${java_home_loc}/man/man1/jar.1 \
--slave /usr/share/man/man1/jarsigner.1 jarsigner.1 ${java_home_loc}/man/man1/jarsigner.1 \
--slave /usr/share/man/man1/javac.1 javac.1 ${java_home_loc}/man/man1/javac.1 \
--slave /usr/share/man/man1/javadoc.1 javadoc.1 ${java_home_loc}/man/man1/javadoc.1 \
--slave /usr/share/man/man1/javah.1 javah.1 ${java_home_loc}/man/man1/javah.1 \
--slave /usr/share/man/man1/javap.1 javap.1 ${java_home_loc}/man/man1/javap.1 \
--slave /usr/share/man/man1/jcmd.1 jcmd.1 ${java_home_loc}/man/man1/jcmd.1 \
--slave /usr/share/man/man1/jconsole.1 jconsole.1 ${java_home_loc}/man/man1/jconsole.1 \
--slave /usr/share/man/man1/jdb.1 jdb.1 ${java_home_loc}/man/man1/jdb.1 \
--slave /usr/share/man/man1/jhat.1 jhat.1 ${java_home_loc}/man/man1/jhat.1 \
--slave /usr/share/man/man1/jinfo.1 jinfo.1 ${java_home_loc}/man/man1/jinfo.1 \
--slave /usr/share/man/man1/jmap.1 jmap.1 ${java_home_loc}/man/man1/jmap.1 \
--slave /usr/share/man/man1/jps.1 jps.1 ${java_home_loc}/man/man1/jps.1 \
--slave /usr/share/man/man1/jrunscript.1 jrunscript.1 ${java_home_loc}/man/man1/jrunscript.1 \
--slave /usr/share/man/man1/jsadebugd.1 jsadebugd.1 ${java_home_loc}/man/man1/jsadebugd.1 \
--slave /usr/share/man/man1/jstack.1 jstack.1 ${java_home_loc}/man/man1/jstack.1 \
--slave /usr/share/man/man1/jstat.1 jstat.1 ${java_home_loc}/man/man1/jstat.1 \
--slave /usr/share/man/man1/jstatd.1 jstatd.1 ${java_home_loc}/man/man1/jstatd.1 \
--slave /usr/share/man/man1/native2ascii.1 native2ascii.1 ${java_home_loc}/man/man1/native2ascii.1 \
--slave /usr/share/man/man1/pack200.1 pack200.1 ${java_home_loc}/man/man1/pack200.1 \
--slave /usr/share/man/man1/rmic.1 rmic.1 ${java_home_loc}/man/man1/rmic.1 \
--slave /usr/share/man/man1/schemagen.1 schemagen.1 ${java_home_loc}/man/man1/schemagen.1 \
--slave /usr/share/man/man1/serialver.1 serialver.1 ${java_home_loc}/man/man1/serialver.1 \
--slave /usr/share/man/man1/unpack200.1 unpack200.1 ${java_home_loc}/man/man1/unpack200.1 \
--slave /usr/share/man/man1/wsgen.1 wsgen.1 ${java_home_loc}/man/man1/wsgen.1 \
--slave /usr/share/man/man1/wsimport.1 wsimport.1 ${java_home_loc}/man/man1/wsimport.1 \
--slave /usr/share/man/man1/xjc.1 xjc.1 ${java_home_loc}/man/man1/xjc.1 \
"

  exec { 'update_alternatives_java' :
    command => $alt_java,
    require => [ File[$libjvm_root], Exec['extract_jdk'] ],
    unless  => "test $(readlink /etc/alternatives/java) = '${java_home_loc}/bin/java'",
  }
  exec { 'update_alternatives_javac' :
    command => $alt_javac,
    require => [ File[$libjvm_root], Exec['extract_jdk'] ],
    unless  => "test $(readlink /etc/alternatives/java) = '${java_home_loc}/bin/java'",
  }
}
