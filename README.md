puppet-jdk_oracle
=================

Puppet module to install a JDK from oracle using wget.

There are several puppet modules available that will help install Oracle JDK, but they either use the Debian repository, or depend on the user to manually place the Oracle Java installer in the module's file directory prior to using.  This module will work on Redhat family of OSs, and will use wget with a cookie to automatically grab the installer from Oracle.

This approach was inspired by: http://stackoverflow.com/questions/10268583/how-to-automate-download-and-instalation-of-java-jdk-on-linux

_Note:  By using this module you agree to automatically accept the Oracle agreement to download Java._

Currently Supported:
* RedHat Family (RedHat, Fedora, CentOS)
* Java 7


Installation:
=============

A) Traditional:
* Copy this project into your puppet modules path and rename to "jdk_oracle"

B) Puppet Librarian:
* Put this in your Puppetfile:
```
    mod "jdk_oracle",
      :git => "git://github.com/tylerwalts/puppet-jdk_oracle.git"
```


Usage:
======

A)  Traditional:
```
    include jdk_oracle
```
or
```
    class { 'jdk_oracle': }
```


B) Hiera:
config.json:
```
    {
        classes":[
          "jdk_oracle"
        ]
    }
```
site.pp:
```
    hiera_include("classes", [])
```




