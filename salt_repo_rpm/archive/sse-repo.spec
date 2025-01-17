Name: sse-repo
Version:    4.1
Release:    1%{?dist}
Summary:    Salt Enterprise 4.1 installer 

Group:      Development/Tools
License:    ASL 2.0
URL:        http://saltstack.org/
Source0:    %{name}-%{version}.tar.gz

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
## BuildRequires:

%description
Salt Enterprise installer for repo file in /etc/yum.repos.d 
and install gpg key for Salt Enterprise repository

%prep
%setup -q


%build
## %%configure
## make %{?_smp_mflags}


%install
## make install DESTDIR=%%{buildroot}
mkdir -p %{buildroot}%{_sysconfdir}/yum.repos.d/
mkdir -p %{buildroot}%{_sysconfdir}/pki/rpm-gpg/
cp sse-4.1.repo %{buildroot}%{_sysconfdir}/yum.repos.d/sse-4.1.repo
cp RPM-GPG-KEY-sse %{buildroot}%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-sse

## %%if (0%{?rhel} >= 7)
## cp RPM-GPG-KEY-Salt-CentOS-7 %{buildroot}%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-Salt-CentOS-7
## %%endif


%files
## %%doc README
%config(noreplace) %{_sysconfdir}/yum.repos.d/sse-4.1.repo
%config(noreplace) %{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-sse

## %%if (0%{?rhel} >= 7)
## %%config(noreplace) %{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-Salt-CentOS-7
## %%endif


%changelog
* Wed Oct 21 2015 SaltStack Packaging Team <packaging@saltstack.com> - 4.1-1
- Installer for feature release 4.1


