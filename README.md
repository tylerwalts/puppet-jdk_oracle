# puppet-jdk_oracle

[![Build Status](https://travis-ci.org/tylerwalts/puppet-jdk_oracle.png?branch=master)](https://travis-ci.org/tylerwalts/puppet-jdk_oracle)

## Overview

Puppet module to automate fetching and installing the Oracle JDK from the Oracle-hosted download site located here: http://www.oracle.com/technetwork/java/javase/downloads/index.html

_Note:  By using this module you will automatically accept the Oracle agreement to download Java._

There are several puppet modules available that will help install Oracle JDK, but they either use the local package manager repository, or depend on the user to manually place the Oracle Java installer in the module's file directory prior to using.  This module will use wget with a cookie to automatically grab the installer from Oracle.

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
    mod "jdk_oracle",
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

* version
    *  Java Version to install
* version_update
    *  Java Version update to install
* version_build
    *  Java Version build to install
*  install_dir
    *  Java Installation Directory
*  use_cache
    *  Optionally host the installer file locally instead of fetching it each time, for faster dev & test
*  platform
    *  The platform to use
*  jce
    * Boolean to optionally install Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files (Java 8 only)
*  default_java
    * Boolean to indicate if the installed java version is linked as the default java, javac etc...
*  ensure
    * Boolean to disable anything from happening (absent/removal not supported yet)
