Salt Packages for AIX 6.1 and 7.1

New packages have been developed for AIX in the operating system native format
(that is BFF packages).  The packages have been developed on AIX 6.1 and are
forward compatible with AIX 7.1. The packages used by Salt are AIX BFF files
(AIX normal packages, containing salt[-enterprise].rte), the rte extension is
RunTime Environment.

Two versions of Salt packagers for AIX are available, as follows:

salt-enterprise.3.2.0.5.bff
salt.15.5.1.1.bff
salt.15.8.3.1.bff

AIX has limitations as to version information in its packages: it has to be of
the form: vv.rr.mmmm.ffff OR vv.rr.mmmm.fffff.ppppppppp

Hence dropping of the century, otherwise the following error:

l59fvp018_pub[/home/u0015070] > installp -ld salt.2015.5.1.1.bff
0503-005 installp:  The format of the toc file is invalid.
0503-019 installp:  salt 2015.5.1.1 is an invalid level. 
        ALL levels must be in one of the following formats:  
                vv.rr.mmmm.ffff OR vv.rr.mmmm.fffff.ppppppppp
0503-005 installp:  The format of the toc file is invalid.


To Install:
installp -acXYg -d . salt-enterprise.3.2.0.5.bff salt-enterprise.rte

installp -acXYg -d . salt-15.5.1.1.bff salt.rte

installp -acXYg -d . salt-15.8.3.1.bff salt.rte

Example is from the directory where the BFF package file is located.

To remove:
installp -u salt-enterprise.rte

installp -u salt.rte

Note, if installp fails due to whatever reason, you still need to uninstall,
otherwise the bad package is still in the machine's cache.

The files are currently available from SaltStack's Enterprise Repo
(https://erepo.saltstack.com). They must be un-gzipped before installed, this
is achieved by the following command on the AIX machine:

gzip --decompress salt-enterprise.3.2.0.5.bff.gz

gzip --decompress salt.15.5.1.1.bff.gz

gzip --decompress salt.15.8.3.1.bff.gz

6.1 and 7.1 versions of the package are identical.
