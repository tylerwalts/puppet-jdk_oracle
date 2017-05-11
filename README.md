# puppet-jdk_oracle

[![Build Status](https://travis-ci.org/tylerwalts/puppet-jdk_oracle.png?branch=master)](https://travis-ci.org/tylerwalts/puppet-jdk_oracle)

## Overview

Puppet module to automate fetching and installing the Oracle JDK/JRE/Server-JRE from the Oracle-hosted download site located here: http://www.oracle.com/technetwork/java/javase/downloads/index.html

_Note:  By using this module you will automatically accept the Oracle agreement to download Java._

There are several puppet modules available that will help install Oracle JDK/JRE/Server-JRE, but they either use the local package manager repository, or depend on the user to manually place the Oracle Java installer in the module's file directory prior to using.  This module will use wget with a cookie to automatically grab the installer from Oracle.

This approach was inspired by: http://stackoverflow.com/questions/10268583/how-to-automate-download-and-instalation-of-java-jdk-on-linux

### Supported Operating Systems:
* RedHat Family (RedHat, Fedora, CentOS)
* Debian Family (Ubuntu)
* SUSE
* _This may work on other linux flavors but more testing is needed.  Please send feedback!_

### Supported Java Versions:
* Java 6, 7, 8
* Build versions should be specified as parameters (see below)

#### Reasons you may want to use this module:

1. You do not control or trust your package repository to host the version of Oracle Java that you want.
1. You want to lock in the version that gets installed.
1. You want to use Oracle’s CDN to host the binary instead of hosting it yourself.

#### Reasons why you would not want to use this module:

1. If you want to use package management (.deb, .rpm) instead of extracting a generic archive.
  1. Consider schrepfler’s fork which does RPM without v6:  https://github.com/schrepfler/puppet-jdk_oracle
1. If you want to rely on your package repository to host the binary, not Oracle.
1. If your target configuration server does not have access to the Internet.  Assumes the server can pull it.


## Installation:

### A) Traditional:
* Copy this project into your puppet modules path and rename to "jdk_oracle"

### B) Puppet Librarian:
* Put this in your Puppetfile:
From Forge:
```
mod "tylerwalts/jdk_oracle"
```

From Source:
```
mod "tylerwalts/jdk_oracle",
    :git => "git://github.com/tylerwalts/puppet-jdk_oracle.git"
```


## Usage:

### A)  Traditional:
```
    include jdk_oracle
```
or
```
    class { 'jdk_oracle': }
```


### B) Hiera:
config.json:
```
    {
        classes":[
          "jdk_oracle"
        ]
    }
```
OR
config.yaml:
```
---
  classes:
    - "jdk_oracle"
  jdk_oracle::version: "6"
```

site.pp:
```
    hiera_include("classes", [])
```


## Parameters:
### Class jdk_oracle
* version
    *  Java Version to install
* version_update
    *  Java Version update to install
* version_build
    *  Java Version build to install
* version_hash
    * The hash in more current Oracle download URLs
*  install_dir
    *  Java Installation Directory
*  use_cache
    *  Optionally host the installer file locally instead of fetching it each time, for faster dev & test
*  platform
    *  The platform to use
*  package
    *  The package to install. Can be one of the following: jdk, jre, server-jre
*  jce
    * Boolean to optionally install Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files (Java 8 only)
*  default_java
    * Boolean to indicate if the installed java version is linked as the default java, javac etc. Defaults to true.
*  ensure
    * Boolean to disable anything from happening (absent/removal not supported yet)
*  download_url
    * string: the download base url to use. default to oracle cdn. should contain the jdk directory. eg : https://custom_host -> https://custom_host/jdk/8u11-b12/jdk-8u11-linux-x64.tar.gz
* proxy_host
    * a proxy host use. Default to undef.
    
### jdk_oracle::install
Basicaly the same option as class jdk_oracle.
* version
    *  Java Version to install
* version_update
    *  Java Version update to install
* version_build
    *  Java Version build to install
* version_hash
    * The hash in more current Oracle download URLs
*  install_dir
    *  Java Installation Directory
*  use_cache
    *  Optionally host the installer file locally instead of fetching it each time, for faster dev & test
*  platform
    *  The platform to use
*  package
    *  The package to install. Can be one of the following: jdk, jre, server-jre
*  jce
    * Boolean to optionally install Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files (Java 8 only)
*  default_java
    * Boolean to indicate if the installed java version is linked as the default java, javac etc. Defaults to true.
*  create_symlink:
    * Boolean to indicate if we have to create a symlink of java_home to the default java_home. Defaults to true.
*  proxy

## Example Usage.

to install the default jdk8u11 plus jdk8u102 as default with JCE with default parameters :

```puppet
class { 'jdk_oracle':
  jce        => true
}

jdk_oracle::install { 'jdk_11u102':
  version_update => '102',
  version_build  => '14',
  default_java   => true,
  jce            => true,
  install_dir    => '/usr/java'
}
```

to install only jdk8u102 as default with jce, with custom repository and proxy
```puppet
class { 'jdk_oracle':
  jce            => true,
  default        => true,
  download_url   => 'https://nexus.corp/java',
  proxy_host     => 'http://proxyhost:3128',
  version_update => '102',
  version_build  => '14',
}
```




