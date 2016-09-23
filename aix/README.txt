=================================
Salt Packages for AIX 6.1 and 7.x
=================================

Version: salt.16.3.3.2.bff (2016.3.3)
Date: 2016-09-16

To Install:
-----------
Salt is installed mainly into the /opt/salt directory, and a minimum of 2GBytes
of disk space is required to install. Wrapper scripts for the command-line
interfaces are installed in the /usr/bin directory (see the "Usage on AIX"
section below).

1. Browse to https://erepo.saltstack.com/aix and download the *.gz installation
file for your OS version.

2. Run the following commands to extract the installation file into a directory:

gzip --decompress salt_2016.3.3.tar.gz
tar -xvf salt_2016.3.3.tar
cd salt_2016.3.3

3. Run the following command to install:

./install_salt.sh

To Uninstall:
-------------
1. Run the following command:

./install_salt.sh -u

Note: If install_salt.sh fails to uninstall Salt and you intend to install a new
version, you must uninstall using an alternate method. Otherwise the previous
package remains in the cache.

The install script install_salt.sh as a number of self-explanatory options,
which can be examined using the -h option:

    ./install_salt.sh -h


Usage on AIX
------------
Wrapper scripts are provided to access the Salt command-line interfaces. These
wrapper scripts execute with environmental variable overrides for library and
python paths. These wrapper scripts are provided in /usr/bin, which is typically
included in the environmental variable PATH.

The following wrapper scripts are available:

  salt-cp
  salt-cloud
  salt-call
  salt-api
  salt
  salt-unity
  salt-syndic
  salt-ssh
  salt-run
  salt-proxy
  salt-minion
  salt-master*
  salt-key

*salt-master functionality is not currently supported on AIX.

Salt command line functionality is available through the use of 
these wrapper scripts. For example, to start the salt-minion as a daemon:

[/usr/bin/]salt-minion -d

