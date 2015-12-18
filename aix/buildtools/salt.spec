%global with_python27 1
%define pybasever 2.7
%define __python_ver 27
%define __python %{_bindir}/python%{?pybasever}

%global include_tests 0

%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")}

%define _salttesting SaltTesting
%define _salttesting_ver 2015.7.10

%define srcname salt
Name: %{srcname}
Version: 2015.8.3
Release: 1%{?dist}
Summary: A parallel remote execution system

Group:   System Environment/Daemons
License: ASL 2.0
URL:     http://saltstack.org/
Source0: %{srcname}-%{version}.tar.gz
Source1: %{_salttesting}-%{_salttesting_ver}.tar.gz
Source2: %{srcname}-master
Source3: %{srcname}-syndic
Source4: %{srcname}-minion
Source5: %{srcname}-api
Source6: %{srcname}-master.service
Source7: %{srcname}-syndic.service
Source8: %{srcname}-minion.service
Source9: %{srcname}-api.service
Source10: %{srcname}-common.logrotate
Source11: %{srcname}.bash

## Patch0:  salt-%{version}-tests.patch

## Conflicts: %{srcname}

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch: noarch

## TODO DGM parseBoolanExpression causing issues
## %if (0%{?include_tests})
## BuildRequires: python-crypto
## BuildRequires: python-jinja2
## BuildRequires: python-msgpack
## BuildRequires: python-pip
## BuildRequires: python-zmq
## BuildRequires: PyYAML
## BuildRequires: python-requests
## BuildRequires: python-unittest2
## # this BR causes windows tests to happen
## # clearly, that's not desired
## # https://github.com/saltstack/salt/issues/3749
## BuildRequires: python-mock
## BuildRequires: git
## BuildRequires: python-libcloud
## # argparse now a salt-testing requirement
## BuildRequires: python-argparse
## %endif
##
## BuildRequires: python-devel
## BuildRequires: python-tornado >= 4.2.1
## BuildRequires: python-futures >= 2.0
## Requires: python-crypto >= 2.6.1
## Requires: python-jinja2
## Requires: python-msgpack > 0.3
## Requires: PyYAML
## Requires: python-requests >= 1.0.0
## Requires: python-zmq
## Requires: python-markupsafe
## Requires: python-tornado >= 4.2.1
## Requires: python-futures >= 2.0
## Requires: python-six


%description
Salt is a distributed remote execution system used to execute commands and
query data. It was developed in order to bring the best solutions found in
the world of remote execution together and make them better, faster and more
malleable. Salt accomplishes this via its ability to handle larger loads of
information, and not just dozens, but hundreds or even thousands of individual
servers, handle them quickly and through a simple and manageable interface.

%package master
Summary: Management component for salt, a parallel remote execution system
Group:   System Environment/Daemons
Requires: %{name} = %{version}-%{release}

%description master
The Salt master is the central server to which all minions connect.

%package minion
Summary: Client component for Salt, a parallel remote execution system
Group:   System Environment/Daemons
Requires: %{name} = %{version}-%{release}
## DGM Requires: systemd-python

%description minion
The Salt minion is the agent component of Salt. It listens for instructions
from the master, runs jobs, and returns results back to the master.

%package syndic
Summary: Master-of-master component for Salt, a parallel remote execution system
Group:   System Environment/Daemons
Requires: %{name} = %{version}-%{release}

%description syndic
The Salt syndic is a master daemon which can receive instruction from a
higher-level master, allowing for tiered organization of your Salt
infrastructure.

%package api
Summary: REST API for Salt, a parallel remote execution system
Group:   System administration tools
Requires: %{name}-master = %{version}-%{release}
## Requires: python-cherrypy

%description api
salt-api provides a REST interface to the Salt master.

%package cloud
Summary: Cloud provisioner for Salt, a parallel remote execution system
Group:   System administration tools
Requires: %{name}-master = %{version}-%{release}
## Requires: python-libcloud

%description cloud
The salt-cloud tool provisions new cloud VMs, installs salt-minion on them, and
adds them to the master's collection of controllable minions.

%package ssh
Summary: Agentless SSH-based version of Salt, a parallel remote execution system
Group:   System administration tools
Requires: %{name} = %{version}-%{release}

%description ssh
The salt-ssh tool can run remote execution functions and states without the use
of an agent (salt-minion) service.

%prep
%setup -c
%setup -T -D -a 1

cd %{srcname}-%{version}
## %patch0 -p1

%build


%install
rm -rf %{buildroot}
cd $RPM_BUILD_DIR/%{name}-%{version}/%{srcname}-%{version}
%{__python} setup.py install -O1 --root %{buildroot}

# Add some directories
mkdir -p %{buildroot}%{_var}/log/salt
mkdir -p %{buildroot}%{_var}/cache/salt
mkdir -p %{buildroot}%{_sysconfdir}/salt
mkdir -p %{buildroot}%{_sysconfdir}/salt/pki
mkdir -p %{buildroot}%{_sysconfdir}/salt/cloud.conf.d
mkdir -p %{buildroot}%{_sysconfdir}/salt/cloud.deploy.d
mkdir -p %{buildroot}%{_sysconfdir}/salt/cloud.maps.d
mkdir -p %{buildroot}%{_sysconfdir}/salt/cloud.profiles.d
mkdir -p %{buildroot}%{_sysconfdir}/salt/cloud.providers.d

# Add the config files
mkdir -p %{buildroot}%{_sysconfdir}/salt
cp -f conf/minion %{buildroot}%{_sysconfdir}/salt/minion
cp -f conf/master %{buildroot}%{_sysconfdir}/salt/master
cp -f conf/cloud  %{buildroot}%{_sysconfdir}/salt/cloud
cp -f conf/roster %{buildroot}%{_sysconfdir}/salt/roster
cp -f conf/proxy  %{buildroot}%{_sysconfdir}/salt/proxy
chmod 0640 %{buildroot}%{_sysconfdir}/salt/minion
chmod 0640 %{buildroot}%{_sysconfdir}/salt/master
chmod 0640 %{buildroot}%{_sysconfdir}/salt/cloud
chmod 0640 %{buildroot}%{_sysconfdir}/salt/roster
chmod 0640 %{buildroot}%{_sysconfdir}/salt/proxy

mkdir -p %{buildroot}%{_initddir}
cp -f -p %{SOURCE2} %{buildroot}%{_initddir}/
cp -f -p %{SOURCE3} %{buildroot}%{_initddir}/
cp -f -p %{SOURCE4} %{buildroot}%{_initddir}/
cp -f -p %{SOURCE5} %{buildroot}%{_initddir}/

# Logrotate
mkdir -p %{buildroot}%{_sysconfdir}/logrotate.d
cp -f %{SOURCE10} %{buildroot}%{_sysconfdir}/logrotate.d/salt
chmod 0644 %{buildroot}%{_sysconfdir}/logrotate.d/salt

# Bash completion
mkdir -p %{buildroot}%{_sysconfdir}/bash.completion.d
cp -f %{SOURCE11} %{buildroot}%{_sysconfdir}/bash.completion.d/
chmod 0644 %{buildroot}%{_sysconfdir}/bash.completion.d/salt.bash


# Add the man pages
mkdir -p %{buildroot}%{_mandir}/man7
mkdir -p %{buildroot}%{_mandir}/man1
cp -R doc/man/salt.7* %{buildroot}%{_mandir}/man7/
cp -R doc/man/salt-cp.1* %{buildroot}%{_mandir}/man1/
cp -R doc/man/salt-key.1* %{buildroot}%{_mandir}/man1/
cp -R doc/man/salt-master.1* %{buildroot}%{_mandir}/man1/
cp -R doc/man/salt-run.1* %{buildroot}%{_mandir}/man1/
cp -R doc/man/salt-unity.1* %{buildroot}%{_mandir}/man1/
cp -R doc/man/salt-call.1* %{buildroot}%{_mandir}/man1/
cp -R doc/man/salt-minion.1* %{buildroot}%{_mandir}/man1/
cp -R doc/man/salt-syndic.1* %{buildroot}%{_mandir}/man1/
cp -R doc/man/salt-api.1* %{buildroot}%{_mandir}/man1/
cp -R doc/man/salt-cloud.1* %{buildroot}%{_mandir}/man1/
cp -R doc/man/salt-ssh.1* %{buildroot}%{_mandir}/man1/
cp -R doc/man/salt-proxy.1* %{buildroot}%{_mandir}/man1/


%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{python_sitelib}/%{srcname}/*
%{python_sitelib}/%{srcname}-*-py?.?.egg-info
%{_sysconfdir}/logrotate.d/salt
%{_sysconfdir}/bash.completion.d/salt.bash
%{_var}/cache/salt
%{_var}/log/salt
%{_bindir}/spm
%config(noreplace) %{_sysconfdir}/salt/

%files master
%defattr(-,root,root)
%doc %{_mandir}/man7/salt.7
%doc %{_mandir}/man1/salt-cp.1
%doc %{_mandir}/man1/salt-key.1
%doc %{_mandir}/man1/salt-master.1
%doc %{_mandir}/man1/salt-run.1
%doc %{_mandir}/man1/salt-unity.1
%{_bindir}/salt
%{_bindir}/salt-cp
%{_bindir}/salt-key
%{_bindir}/salt-master
%{_bindir}/salt-run
%{_bindir}/salt-unity
%attr(0755, root, root) %{_initddir}/salt-master
%config(noreplace) %{_sysconfdir}/salt/master

%files minion
%defattr(-,root,root)
%doc %{_mandir}/man1/salt-call.1
%doc %{_mandir}/man1/salt-minion.1
%doc %{_mandir}/man1/salt-proxy.1
%{_bindir}/salt-minion
%{_bindir}/salt-call
%{_bindir}/salt-proxy
%attr(0755, root, root) %{_initddir}/salt-minion
%config(noreplace) %{_sysconfdir}/salt/minion
%config(noreplace) %{_sysconfdir}/salt/proxy

%files syndic
%doc %{_mandir}/man1/salt-syndic.1
%{_bindir}/salt-syndic
%attr(0755, root, root) %{_initddir}/salt-syndic

%files api
%defattr(-,root,root)
%doc %{_mandir}/man1/salt-api.1
%{_bindir}/salt-api
%attr(0755, root, root) %{_initddir}/salt-api

%files cloud
%doc %{_mandir}/man1/salt-cloud.1
%{_bindir}/salt-cloud
%{_sysconfdir}/salt/cloud.conf.d
%{_sysconfdir}/salt/cloud.deploy.d
%{_sysconfdir}/salt/cloud.maps.d
%{_sysconfdir}/salt/cloud.profiles.d
%{_sysconfdir}/salt/cloud.providers.d
%config(noreplace) %{_sysconfdir}/salt/cloud

%files ssh
%doc %{_mandir}/man1/salt-ssh.1
%{_bindir}/salt-ssh
%{_sysconfdir}/salt/roster

## TODO DGM need AIX equivalent of below
## 
## %preun master
## %if 0%{?systemd_preun:1}
##   %systemd_preun salt-master.service
## %else
##   if [ $1 -eq 0 ] ; then
##     # Package removal, not upgrade
##     /bin/systemctl --no-reload disable salt-master.service > /dev/null 2>&1 || :
##     /bin/systemctl stop salt-master.service > /dev/null 2>&1 || :
## 
##     /bin/systemctl --no-reload disable salt-syndic.service > /dev/null 2>&1 || :
##     /bin/systemctl stop salt-syndic.service > /dev/null 2>&1 || :
##   fi
## %endif
## 
## %preun minion
## %if 0%{?systemd_preun:1}
##   %systemd_preun salt-minion.service
## %else
##   if [ $1 -eq 0 ] ; then
##       # Package removal, not upgrade
##       /bin/systemctl --no-reload disable salt-minion.service > /dev/null 2>&1 || :
##       /bin/systemctl stop salt-minion.service > /dev/null 2>&1 || :
##   fi
## %endif
## 
## %post master
## %if 0%{?systemd_post:1}
##   %systemd_post salt-master.service
## %else
##   /bin/systemctl daemon-reload &>/dev/null || :
## %endif
## 
## %post minion
## %if 0%{?systemd_post:1}
##   %systemd_post salt-minion.service
## %else
##   /bin/systemctl daemon-reload &>/dev/null || :
## %endif
## 
## %postun master
## %if 0%{?systemd_post:1}
##   %systemd_postun salt-master.service
## %else
##   /bin/systemctl daemon-reload &>/dev/null
##   [ $1 -gt 0 ] && /bin/systemctl try-restart salt-master.service &>/dev/null || :
##   [ $1 -gt 0 ] && /bin/systemctl try-restart salt-syndic.service &>/dev/null || :
## %endif
## 
## %postun minion
## %if 0%{?systemd_post:1}
##   %systemd_postun salt-minion.service
## %else
##   /bin/systemctl daemon-reload &>/dev/null
##   [ $1 -gt 0 ] && /bin/systemctl try-restart salt-minion.service &>/dev/null || :
## %endif

%changelog
* Mon Dec  7 2015 SaltStack Packaging Team <packaging@saltstack.com>  2015.8.3-1
- Feature Release 2015.8.3-1 for AIX

* Mon May 27 2015 David Murphy <dmurphy@saltstack.com>  2015.5.1-1
- Feature Release for AIX, fork from Kistian Berg and SSE 3.2 for AIX rpm spec

