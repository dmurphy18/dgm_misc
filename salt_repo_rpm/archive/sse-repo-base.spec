Name: sse-repo-base
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
## Requires: Dcentos-release-7

%description
Salt Enterprise base dependencies installer for repo file 
in /etc/yum.repos.d and install gpg key for base repository

%prep
%setup -q

%build
## %%configure
## make %{?_smp_mflags}

%install
## make install DESTDIR=%%{buildroot}
mkdir -p %{buildroot}%{_sysconfdir}/pki/rpm-gpg/
%if (0%{?rhel} == 7)
cp RPM-GPG-KEY-CentOS-7 %{buildroot}%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
%endif

%files
## %%doc README
%if (0%{?rhel} == 7)
%config(noreplace) %{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
%endif

%changelog
* Mon Oct 19 2015 SaltStack Packaging Team <packaging@saltstack.com> - 4.1-1
- Base Dependencies installer for feature release 4.1


