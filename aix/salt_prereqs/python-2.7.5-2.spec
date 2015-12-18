%define pybasever 2.7

%define _libdir64 %{_prefix}/lib64

Summary: An interpreted, interactive, object-oriented programming language.
Name: python
Version: 2.7.5
Release: 2
License: Python
Group: Development/Languages
URL: http://www.python.org/
Source0: http://www.python.org/ftp/python/%{version}/Python-%{version}.tar.bz2
Source1: http://www.python.org/ftp/python/%{version}/Python-%{version}.tar.bz2.asc
Source2: pyconfig.h
Patch0: %{name}-%{version}-aix.patch
Patch1: %{name}-%{version}-64bit.patch

Provides: python-abi = %{pybasever}
Provides: python(abi) = %{pybasever}
Provides: python2 = %{version}

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: make
BuildRequires: patch

BuildRequires: bzip2 >= 1.0.2-4
BuildRequires: db4-devel >= 4.7.25-2
BuildRequires: expat-devel >= 2.1.0-1
BuildRequires: gettext >= 0.10.40-6
BuildRequires: gmp-devel >= 4.3.2-2
BuildRequires: gdbm-devel >= 1.8.3-1
BuildRequires: libffi-devel >= 3.0.13-1
BuildRequires: ncurses-devel >= 5.9
BuildRequires: openssl-devel >= 1.0.1
BuildRequires: pkg-config
BuildRequires: readline-devel >= 5.2-3
BuildRequires: tcl-devel >= 8.5.8-2
BuildRequires: tk-devel >= 8.5.8-1
BuildRequires: sqlite-devel >= 3.7.3-1
BuildRequires: zlib-devel >= 1.2.3-3
BuildRequires: sed >= 4.2.0

Requires: %{name}-libs = %{version}

Requires: bzip2 >= 1.0.2-4
Requires: db4 >= 4.7.25-2
Requires: expat >= 2.1.0-1
Requires: gettext >= 0.10.40-6
Requires: gmp >= 4.3.2-2
Requires: gdbm >= 1.8.3-1
Requires: libffi >= 3.0.13-1
Requires: openssl >= 1.0.1
Requires: ncurses >= 5.9
Requires: readline >= 5.2-3
Requires: tcl >= 8.5.8-2
Requires: tk >= 8.5.8-1
Requires: sqlite >= 3.7.3-1
Requires: zlib >= 1.2.3-3

%ifos aix5.1 || %ifos aix5.2 || %ifos aix5.3
Requires: AIX-rpm >= 5.1.0.0
Requires: AIX-rpm < 5.4.0.0
%endif

%ifos aix6.1 || %ifos aix7.1
Requires: AIX-rpm >= 6.1.0.0
%endif

%description
Python is an interpreted, interactive, object-oriented programming
language often compared to Tcl, Perl, Scheme or Java. Python includes
modules, classes, exceptions, very high level dynamic data types and
dynamic typing. Python supports interfaces to many system calls and
libraries, as well as to various windowing systems (X11, Motif, Tk,
Mac and MFC).

Programmers can write new built-in modules for Python in C or C++.
Python can be used as an extension language for applications that need
a programmable interface. This package contains most of the standard
Python modules, as well as modules for interfacing to the Tix widget
set for Tk and RPM.

Note that documentation for Python is provided in the python-docs
package.


%package libs
Summary: The libraries for python runtime
Group: Applications/System

%description libs
The python interpreter can be embedded into applications wanting to 
use python as an embedded scripting language.  The python-libs package 
provides the libraries needed for this.


%package devel
Summary: The libraries and header files needed for Python development.
Group: Development/Libraries
Requires: %{name} = %{version}-%{release}
Conflicts: %{name} < %{version}-%{release}

%description devel
The Python programming language's interpreter can be extended with
dynamically loaded extensions and can be embedded in other programs.
This package contains the header files and libraries needed to do
these types of tasks.

Install python-devel if you want to develop Python extensions.  The
python package will also need to be installed.  You'll probably also
want to install the python-docs package, which contains Python
documentation.


%package tools
Summary: A collection of development tools included with Python.
Group: Development/Tools
Requires: %{name} = %{version}-%{release}
Requires: tkinter = %{version}-%{release}

%description tools
The Python package includes several development tools that are used
to build python programs.


%package -n tkinter
Summary: A graphical user interface for the Python scripting language.
Group: Development/Languages
BuildRequires: tcl-devel >= 8.5.8-2
BuildRequires: tk-devel >= 8.5.8-1
Requires: tcl >= 8.5.8-2
Requires: tk >= 8.5.8-1
Requires: %{name} = %{version}-%{release}

%description -n tkinter
The Tkinter (Tk interface) program is an graphical user interface for
the Python scripting language.

You should install the tkinter package if you'd like to use a graphical
user interface for Python programming.


%package test
Summary: The test modules from the main python package
Group: Development/Languages
Requires: %{name} = %{version}-%{release}

%description test
The test modules from the main python package: %{name}
These have been removed to save space, as they are never or almost
never used in production.

You might want to install the python-test package if you're developing python
code that uses more than just unittest and/or test_support.py.


%prep
export PATH=/opt/freeware/bin:$PATH
%setup -q -n Python-%{version}
%patch0
rm -rf Modules/expat Modules/zlib
mkdir ../32bit
mv * ../32bit
mv ../32bit .
mkdir 64bit
cd 32bit && tar cf - . | (cd ../64bit ; tar xpf -)
cd ../64bit
%patch1


%build
# setup environment for 32-bit and 64-bit builds
export AR="ar -X32_64"
export NM="nm -X32_64"

# for 64-bit applications
export OBJECT_MODE=64
export CONFIG_SHELL=/opt/freeware/bin/bash
export CONFIG_ENV_ARGS=/opt/freeware/bin/bash
export CC=gcc
export CFLAGS="-maix64 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I/opt/freeware/include $(pkg-config --cflags ncurses)"
export CXX=g++
export CXXFLAGS=$CFLAGS
export F77=xlf
export FFLAGS="-O -I/opt/freeware/include"
export LD=ld
export LDFLAGS="-maix64 -L/opt/freeware/lib64 $(pkg-config --libs ncurses) -Wl,-blibpath:/opt/freeware/lib64:/opt/freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000"
export PATH="/usr/bin:/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:/usr/vac/bin:/usr/vacpp/bin:/usr/ccs/bin:/usr/dt/bin:/usr/opt/perl5/bin:/opt/freeware/bin:/opt/freeware/sbin:/usr/local/bin:/usr/lib/instl"

cd 64bit
./configure \
    --prefix=%{_prefix} \
    --libdir=%{_libdir64} \
    --mandir=%{_mandir} \
    --enable-shared \
%ifos aix5.1 || %ifos aix5.2 || %ifos aix5.3
    --disable-ipv6 \
%else
    --enable-ipv6 \
%endif
    --with-threads \
    --with-system-expat \
    --with-system-ffi \
    OPT="-O"

gmake %{?_smp_mflags} lib%{name}%{pybasever}.a
gmake %{?_smp_mflags}
find . -name _sysconfigdata.py -exec /opt/freeware/bin/sed -i "s/\.\/Modules\//\/opt\/freeware\/lib64\/python2.7\/config\//g" {} \;

# build 32-bit version
export OBJECT_MODE=32
export CFLAGS="-maix32 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I/opt/freeware/include $(pkg-config --cflags ncurses)"
export LDFLAGS="-L/opt/freeware/lib $(pkg-config --libs ncurses) -Wl,-blibpath:/opt/freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000"
cd ../32bit

./configure \
    --prefix=%{_prefix} \
    --mandir=%{_mandir} \
    --enable-shared \
%ifos aix5.1 || %ifos aix5.2 || %ifos aix5.3
    --disable-ipv6 \
%else
    --enable-ipv6 \
%endif
    --with-threads \
    --with-system-expat \
    --with-system-ffi \
    OPT="-O"

gmake %{?_smp_mflags} lib%{name}%{pybasever}.a
gmake %{?_smp_mflags}
find . -name _sysconfigdata.py -exec /opt/freeware/bin/sed -i "s/\.\/Modules\//\/opt\/freeware\/lib\/python2.7\/config\//g" {} \;


%install
[ "${RPM_BUILD_ROOT}" != "/" ] && rm -rf ${RPM_BUILD_ROOT}

cd 64bit
export OBJECT_MODE=64
gmake DESTDIR=${RPM_BUILD_ROOT} install

cp ${RPM_BUILD_ROOT}%{_includedir}/%{name}%{pybasever}/pyconfig.h ${RPM_BUILD_ROOT}%{_includedir}/%{name}%{pybasever}/pyconfig-ppc64.h 

(
  cd ${RPM_BUILD_ROOT}%{_bindir}

  for f in * ; do
    mv ${f} ${f}_64
  done
  mv smtpd.py_64 smtpd_64.py
  mv %{name}%{pybasever}-config_64 %{name}%{pybasever}_64-config

  rm -f %{name}-config_64
  ln -sf %{name}%{pybasever}_64-config %{name}_64-config

  for f in 2to3_64 idle_64 pydoc_64 python2.7_64-config smtpd_64.py ; do
    cat ${f} | \
      sed 's|\/opt\/freeware\/bin\/python2.7|\/opt\/freeware\/bin\/python2.7_64|' \
      > tmpfile.tmp
    mv -f tmpfile.tmp ${f}
  done
  rm -f tmpfile.tmp
)

cd ../32bit
export OBJECT_MODE=32
gmake DESTDIR=${RPM_BUILD_ROOT} install

cp ${RPM_BUILD_ROOT}%{_includedir}/%{name}%{pybasever}/pyconfig.h ${RPM_BUILD_ROOT}%{_includedir}/%{name}%{pybasever}/pyconfig-ppc32.h 
cp %{SOURCE2} ${RPM_BUILD_ROOT}%{_includedir}/%{name}%{pybasever}/pyconfig.h 

/usr/bin/strip -X32_64 ${RPM_BUILD_ROOT}%{_bindir}/* || :

cd ..

cp 32bit/lib%{name}%{pybasever}.a ${RPM_BUILD_ROOT}%{_libdir}/lib%{name}%{pybasever}.a
cp 64bit/lib%{name}%{pybasever}.a ${RPM_BUILD_ROOT}%{_libdir64}/lib%{name}%{pybasever}.a
chmod 0644 ${RPM_BUILD_ROOT}%{_libdir}/lib%{name}%{pybasever}.a
chmod 0644 ${RPM_BUILD_ROOT}%{_libdir64}/lib%{name}%{pybasever}.a

find ${RPM_BUILD_ROOT}%{_libdir}/%{name}%{pybasever}/lib-dynload -type d | sed "s|${RPM_BUILD_ROOT}|%dir |" > dynfiles
find ${RPM_BUILD_ROOT}%{_libdir64}/%{name}%{pybasever}/lib-dynload -type d | sed "s|${RPM_BUILD_ROOT}|%dir |" >> dynfiles
find ${RPM_BUILD_ROOT}%{_libdir}/%{name}%{pybasever}/lib-dynload -type f | \
  grep -v "_tkinter.so$" | \
  grep -v "_ctypes_test.so$" | \
  grep -v "_testcapi.so$" | \
  sed "s|${RPM_BUILD_ROOT}||" >> dynfiles
find ${RPM_BUILD_ROOT}%{_libdir64}/%{name}%{pybasever}/lib-dynload -type f | \
  grep -v "_tkinter.so$" | \
  grep -v "_ctypes_test.so$" | \
  grep -v "_testcapi.so$" | \
  sed "s|${RPM_BUILD_ROOT}||" >> dynfiles

ln -sf ../../lib%{name}%{pybasever}.a ${RPM_BUILD_ROOT}%{_libdir}/%{name}%{pybasever}/config/lib%{name}%{pybasever}.a
ln -sf ../../lib%{name}%{pybasever}.a ${RPM_BUILD_ROOT}%{_libdir64}/%{name}%{pybasever}/config/lib%{name}%{pybasever}.a
ln -sf ../../lib%{name}%{pybasever}.so ${RPM_BUILD_ROOT}%{_libdir}/%{name}%{pybasever}/config/lib%{name}%{pybasever}.so
ln -sf ../../lib%{name}%{pybasever}.so ${RPM_BUILD_ROOT}%{_libdir64}/%{name}%{pybasever}/config/lib%{name}%{pybasever}.so

(
  cd ${RPM_BUILD_ROOT}
  for dir in bin include lib lib64
  do
    mkdir -p usr/$dir
    cd usr/$dir
    ln -sf ../..%{_prefix}/$dir/* .
    cd -
  done
)


%clean
[ "${RPM_BUILD_ROOT}" != "/" ] && rm -rf ${RPM_BUILD_ROOT}


%files -f dynfiles
%defattr(-,root,system)
%doc 32bit/LICENSE 32bit/README
%{_bindir}/pydoc*
%{_bindir}/python*
%{_mandir}/man?/*
%dir %{_libdir}/%{name}%{pybasever}
%dir %{_libdir64}/%{name}%{pybasever}
%{_libdir}/%{name}%{pybasever}/LICENSE.txt
%{_libdir64}/%{name}%{pybasever}/LICENSE.txt
%dir %{_libdir}/%{name}%{pybasever}/site-packages
%dir %{_libdir64}/%{name}%{pybasever}/site-packages
%{_libdir}/%{name}%{pybasever}/site-packages/README
%{_libdir64}/%{name}%{pybasever}/site-packages/README
%{_libdir}/%{name}%{pybasever}/*.py*
%{_libdir64}/%{name}%{pybasever}/*.py*
%{_libdir}/%{name}%{pybasever}/*.doc
%{_libdir64}/%{name}%{pybasever}/*.doc
%dir %{_libdir}/%{name}%{pybasever}/bsddb
%dir %{_libdir64}/%{name}%{pybasever}/bsddb
%{_libdir}/%{name}%{pybasever}/bsddb/*.py*
%{_libdir64}/%{name}%{pybasever}/bsddb/*.py*
%{_libdir}/%{name}%{pybasever}/compiler
%{_libdir64}/%{name}%{pybasever}/compiler
%dir %{_libdir}/%{name}%{pybasever}/ctypes
%dir %{_libdir64}/%{name}%{pybasever}/ctypes
%{_libdir}/%{name}%{pybasever}/ctypes/*.py*
%{_libdir64}/%{name}%{pybasever}/ctypes/*.py*
%{_libdir}/%{name}%{pybasever}/ctypes/macholib
%{_libdir64}/%{name}%{pybasever}/ctypes/macholib
%{_libdir}/%{name}%{pybasever}/curses
%{_libdir64}/%{name}%{pybasever}/curses
%dir %{_libdir}/%{name}%{pybasever}/distutils
%dir %{_libdir64}/%{name}%{pybasever}/distutils
%{_libdir}/%{name}%{pybasever}/distutils/*.py*
%{_libdir64}/%{name}%{pybasever}/distutils/*.py*
%{_libdir}/%{name}%{pybasever}/distutils/README
%{_libdir64}/%{name}%{pybasever}/distutils/README
%{_libdir}/%{name}%{pybasever}/distutils/command
%{_libdir64}/%{name}%{pybasever}/distutils/command
%dir %{_libdir}/%{name}%{pybasever}/email
%dir %{_libdir64}/%{name}%{pybasever}/email
%{_libdir}/%{name}%{pybasever}/email/*.py*
%{_libdir64}/%{name}%{pybasever}/email/*.py*
%{_libdir}/%{name}%{pybasever}/email/mime
%{_libdir64}/%{name}%{pybasever}/email/mime
%{_libdir}/%{name}%{pybasever}/encodings
%{_libdir64}/%{name}%{pybasever}/encodings
%{_libdir}/%{name}%{pybasever}/hotshot
%{_libdir64}/%{name}%{pybasever}/hotshot
%{_libdir}/%{name}%{pybasever}/idlelib
%{_libdir64}/%{name}%{pybasever}/idlelib
%{_libdir}/%{name}%{pybasever}/importlib
%{_libdir64}/%{name}%{pybasever}/importlib
%dir %{_libdir}/%{name}%{pybasever}/json
%dir %{_libdir64}/%{name}%{pybasever}/json
%{_libdir}/%{name}%{pybasever}/json/*.py*
%{_libdir64}/%{name}%{pybasever}/json/*.py*
%dir %{_libdir}/%{name}%{pybasever}/lib2to3
%dir %{_libdir64}/%{name}%{pybasever}/lib2to3
%{_libdir}/%{name}%{pybasever}/lib2to3/*.py*
%{_libdir64}/%{name}%{pybasever}/lib2to3/*.py*
%{_libdir}/%{name}%{pybasever}/lib2to3/Grammar*
%{_libdir64}/%{name}%{pybasever}/lib2to3/Grammar*
%{_libdir}/%{name}%{pybasever}/lib2to3/Pattern*
%{_libdir64}/%{name}%{pybasever}/lib2to3/Pattern*
%{_libdir}/%{name}%{pybasever}/lib2to3/fixes
%{_libdir64}/%{name}%{pybasever}/lib2to3/fixes
%{_libdir}/%{name}%{pybasever}/lib2to3/pgen2
%{_libdir64}/%{name}%{pybasever}/lib2to3/pgen2
%{_libdir}/%{name}%{pybasever}/logging
%{_libdir64}/%{name}%{pybasever}/logging
%{_libdir}/%{name}%{pybasever}/multiprocessing
%{_libdir64}/%{name}%{pybasever}/multiprocessing
%{_libdir}/%{name}%{pybasever}/plat-aix?
%{_libdir64}/%{name}%{pybasever}/plat-aix?
%{_libdir}/%{name}%{pybasever}/pydoc_data
%{_libdir64}/%{name}%{pybasever}/pydoc_data
%dir %{_libdir}/%{name}%{pybasever}/sqlite3
%dir %{_libdir64}/%{name}%{pybasever}/sqlite3
%{_libdir}/%{name}%{pybasever}/sqlite3/*.py*
%{_libdir64}/%{name}%{pybasever}/sqlite3/*.py*
%dir %{_libdir}/%{name}%{pybasever}/unittest
%dir %{_libdir64}/%{name}%{pybasever}/unittest
%{_libdir}/%{name}%{pybasever}/unittest/*.py*
%{_libdir64}/%{name}%{pybasever}/unittest/*.py*
%{_libdir}/%{name}%{pybasever}/wsgiref*
%{_libdir64}/%{name}%{pybasever}/wsgiref*
%{_libdir}/%{name}%{pybasever}/xml
%{_libdir64}/%{name}%{pybasever}/xml
/usr/bin/pydoc*
/usr/bin/python*


%files libs
%defattr(-,root,system)
%doc 32bit/LICENSE 32bit/README
%{_libdir}/lib%{name}%{pybasever}.a
%{_libdir64}/lib%{name}%{pybasever}.a
%{_libdir}/lib%{name}%{pybasever}.so
%{_libdir64}/lib%{name}%{pybasever}.so
/usr/lib/lib%{name}%{pybasever}.a
/usr/lib64/lib%{name}%{pybasever}.a
/usr/lib/lib%{name}%{pybasever}.so
/usr/lib64/lib%{name}%{pybasever}.so


%files devel
%defattr(-,root,system)
%doc 32bit/Misc/README.valgrind 32bit/Misc/valgrind-python.supp
%doc 32bit/Misc/gdbinit
%{_includedir}/*
%{_libdir}/pkgconfig/*
%{_libdir64}/pkgconfig/*
%{_libdir}/%{name}%{pybasever}/config
%{_libdir64}/%{name}%{pybasever}/config
/usr/include/*


%files tools
%defattr(-,root,system,-)
%{_bindir}/2to3*
%{_bindir}/idle*
%{_bindir}/smtpd*.py*
/usr/bin/2to3*
/usr/bin/idle*
/usr/bin/smtpd*.py*


%files -n tkinter
%defattr(-,root,system,-)
%{_libdir}/%{name}%{pybasever}/lib-tk
%{_libdir64}/%{name}%{pybasever}/lib-tk
%{_libdir}/%{name}%{pybasever}/lib-dynload/_tkinter.so
%{_libdir64}/%{name}%{pybasever}/lib-dynload/_tkinter.so


%files test
%defattr(-,root,system)
%{_libdir}/%{name}%{pybasever}/bsddb/test
%{_libdir64}/%{name}%{pybasever}/bsddb/test
%{_libdir}/%{name}%{pybasever}/ctypes/test
%{_libdir64}/%{name}%{pybasever}/ctypes/test
%{_libdir}/%{name}%{pybasever}/distutils/tests
%{_libdir64}/%{name}%{pybasever}/distutils/tests
%{_libdir}/%{name}%{pybasever}/email/test
%{_libdir64}/%{name}%{pybasever}/email/test
%{_libdir}/%{name}%{pybasever}/lib2to3/tests
%{_libdir64}/%{name}%{pybasever}/lib2to3/tests
%{_libdir}/%{name}%{pybasever}/json/tests
%{_libdir64}/%{name}%{pybasever}/json/tests
%{_libdir}/%{name}%{pybasever}/sqlite3/test
%{_libdir64}/%{name}%{pybasever}/sqlite3/test
%{_libdir}/%{name}%{pybasever}/unittest/test
%{_libdir64}/%{name}%{pybasever}/unittest/test
%{_libdir}/%{name}%{pybasever}/test
%{_libdir64}/%{name}%{pybasever}/test
%{_libdir}/%{name}%{pybasever}/lib-dynload/_ctypes_test.so
%{_libdir64}/%{name}%{pybasever}/lib-dynload/_ctypes_test.so
%{_libdir}/%{name}%{pybasever}/lib-dynload/_testcapi.so
%{_libdir64}/%{name}%{pybasever}/lib-dynload/_testcapi.so


%changelog
* Mon Aug 26 2013 Kristian Berg <kriberg@tihlde.org> - 2.7.5-2
- Altered to compile with gcc

* Fri Aug 02 2013 Michael Perzl <michael@perzl.org> - 2.7.5-1
- updated to version 2.7.5

* Mon Jul 29 2013 Michael Perzl <michael@perzl.org> - 2.7.2-1
- updated to version 2.7.2

* Mon Jul 29 2013 Michael Perzl <michael@perzl.org> - 2.6.8-1
- updated to version 2.6.8

* Mon Jul 29 2013 Michael Perzl <michael@perzl.org> - 2.6.7-2
- fixed missing dependency of 'python-libs' to 'python'
- enable IPV6 on AIX version 6.1 and higher

* Sat Nov 19 2011 Michael Perzl <michael@perzl.org> - 2.6.7-1
- updated to version 2.6.7

* Wed Aug 26 2009 Michael Perzl <michael@perzl.org> - 2.6.2-1
- first version for AIX V5.1 and higher