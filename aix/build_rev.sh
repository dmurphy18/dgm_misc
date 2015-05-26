#!/usr/bin/bash

set -o functrace
set -o pipefail

## helper functions

## work functions

_install_needed_opensrc_rpms() {
  ## The following list are items preinstalled with IBM AIX Linux tools
  ##
  ## Pre-installed same 4.2.0-3 of these
  ## gcc-4.2.0-3.aix6.1.ppc.rpm
  ## gcc-cplusplus-4.2.0-3.aix6.1.ppc.rpm
  ## libgcc-4.2.0-3.aix5.3.ppc.rpm
  ## libstdcplusplus-4.2.0-3.aix5.3.ppc.rpm
  ## libstdcplusplus-devel-4.2.0-3.aix5.3.ppc.rpm
  ##
  ## Pre-installed glib2-2.8.1-3
  ## salt's glib2-2.14.6-2.aix5.2.ppc.rpm
  ##
  ## Pre-installed zlib-1.2.3-4
  ## salt's zlib-1.2.7-1.aix6.1.ppc.rpm
  ## salt's zlib-devel-1.2.7-1.aix6.1.ppc.rpm

  ## need to get later gcc and libffi to be able to build python
  ## from perlz
  rpm -ev gcc-locale-4.2.0-3 gcc-4.2.0-3 gcc-c++-4.2.0-3 libgcc-4.2.0-3 libstdc++-4.2.0-3 libstdc++-devel-4.2.0-3
  rpm -ivh gcc-4.8.0-2.aix6.1.ppc.rpm libgcc-4.8.0-2.aix6.1.ppc.rpm gcc-cpp-4.8.0-2.aix6.1.ppc.rpm
  rpm -ivh libstdc++-4.8.0-2.aix6.1.ppc.rpm libstdc++-devel-4.8.0-2.aix6.1.ppc.rpm gcc-c++-4.8.0-2.aix6.1.ppc.rpm
  
  ## from IBM
  # The following list are items preinstalled with IBM AIX Linux tools
  ## upgrade pre-installed expat-1.95.7-4
  ## rpm -Uvh expat-2.0.1-2.aix5.3.ppc.rpm
  ## rpm -Uvh expat-devel-2.0.1-2.aix5.3.ppc.rpm

  ## Salt provided open source rpms (form Perlz)

  SALT_PRELOAD_RPMS="info-5.1-2.aix5.1.ppc.rpm
  gmp-5.0.5-1.aix5.1.ppc.rpm
  gmp-devel-5.0.5-1.aix5.1.ppc.rpm
  libiconv-1.14-2.aix5.1.ppc.rpm
  libsigsegv-2.6-1.aix5.2.ppc.rpm
  pkg-config-0.28-1.aix5.1.ppc.rpm
  libffi-3.0.13-1.aix5.1.ppc.rpm
  libffi-devel-3.0.13-1.aix5.1.ppc.rpm
  libyaml-0.1.6-1.aix5.1.ppc.rpm
  libyaml-devel-0.1.6-1.aix5.1.ppc.rpm
  mpfr-3.1.2-1.aix5.1.ppc.rpm
  mpfr-devel-3.1.2-1.aix5.1.ppc.rpm
  patch-2.7.3-1.aix5.1.ppc.rpm
  swig-1.3.40-1.aix5.1.ppc.rpm
  libmpc-1.0.1-2.aix5.1.ppc.rpm
  libmpc-devel-1.0.1-2.aix5.1.ppc.rpm
  readline-6.3-5.aix5.1.ppc.rpm
  readline-devel-6.3-5.aix5.1.ppc.rpm
  bzip2-1.0.5-3.aix5.3.ppc.rpm
  sqlite-3.8.7.1-1.aix5.1.ppc.rpm
  sqlite-devel-3.8.7.1-1.aix5.1.ppc.rpm
  libpng-1.6.9-1.aix5.1.ppc.rpm
  expat-2.1.0-1.aix5.1.ppc.rpm
  expat-devel-2.1.0-1.aix5.1.ppc.rpm
  openssl-1.0.1l-1.aix5.1.ppc.rpm
  openssl-devel-1.0.1l-1.aix5.1.ppc.rpm
  freetype2-2.5.3-1.aix5.1.ppc.rpm
  fontconfig-2.8.0-2.aix5.1.ppc.rpm
  glib2-2.34.3-1.aix5.1.ppc.rpm
  unzip-6.0-2.aix5.1.ppc.rpm
  pkg-config-0.28-1.aix5.1.ppc.rpm
  "

  ## cdir=`pwd`
  ## cd $freeware/rpmbuild/RPMS/ppc/
  for salt_rpm in $SALT_PRELOAD_RPMS
  do
    test -e $salt_rpm || exit 1
    rpm -Uivh $salt_rpm
  done
  ## cd $cdir
  
  rpm -Uivh libXrender-0.9.7-2.aix6.1.ppc.rpm --force
  rpm -Uivh libXft-2.3.1-1.aix5.1.ppc.rpm --force

  ## Pre-installed tcl-8.3.3-8, tk-8.3.3-8, need >= 8.5.8-2
  ## remove pre-installed  and install newer
  rpm -ev expect-5.45-1
  rpm -ev expect-5.34-8
  rpm -ev tk-8.3.3-8
  rpm -ev tcl-8.3.3-8

  ##rpm -ev expat-devel-2.0.1-2
  ##rpm -ev expat-devel-2.1.0-1

  rpm -Uivh tcl-8.5.17-1.aix5.1.ppc.rpm
  rpm -Uivh tcl-devel-8.5.17-1.aix5.1.ppc.rpm
  rpm -Uivh tk-8.5.17-1.aix5.1.ppc.rpm
  rpm -Uivh tk-devel-8.5.17-1.aix5.1.ppc.rpm
  rpm -Uivh expect-5.45-1.aix5.1.ppc.rpm

  ## Note db4 should be installed after tcl, since they hook into tcl
  rpm -Uivh db4-4.7.25-2.aix5.1.ppc.rpm
  rpm -Uivh db4-devel-4.7.25-2.aix5.1.ppc.rpm

  rpm -ev ncurses-devel-5.2-3
  rpm -Uivh ncurses-5.9-1.aix5.1.ppc.rpm
  rpm -Uivh ncurses-devel-5.9-1.aix5.1.ppc.rpm

  rpm -Uivh zlib-1.2.8-1.aix5.1.ppc.rpm
  rpm -Uivh zlib-devel-1.2.8-1.aix5.1.ppc.rpm
  rpm -Uivh sed-4.2.2-1.aix5.1.ppc.rpm

  rpm -ev gdbm-devel-1.8.3-5
  rpm -Uivh gdbm-1.9.1-1.aix5.1.ppc.rpm
  rpm -Uivh gdbm-devel-1.9.1-1.aix5.1.ppc.rpm

  #Clean up old versions of packages now superseded by libXft and libXrender
  rpm -e xft xrender

  # additional rpm to try to get zeromq and pyzmq to build
  rpm -Uivh m4-1.4.17-1.aix5.1.ppc.rpm
  rpm -Uivh autoconf-2.69-2.aix5.1.ppc.rpm
  rpm -Uivh make-4.1-1.aix5.3.ppc.rpm

  rpm -Uivh perl-5.8.8-2.aix5.1.ppc.rpm
  rpm -Uivh automake-1.15-2.aix5.1.ppc.rpm
  
  rpm -Uivh pcre-8.36-1.aix5.1.ppc.rpm
  rpm -Uivh grep-2.21-1.aix5.1.ppc.rpm
  rpm -Uivh libtool-2.4.6-1.aix5.1.ppc.rpm

}


_build_python() {

  cd "$deps/salt_prereqs"
  
  # Configure rpmbuild
  ## TODO DGM need to check if we still need this since using pre-built Pyhton 2.7.5
  echo "%_topdir $freeware/rpmbuild" >~/.rpmmacros
  echo "%_var    $freeware/var" >>~/.rpmmacros
  echo "%_initddir $freeware/etc/rc.d/init.d" >>~/.rpmmacros

  mkdir -p $freeware/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} || exit 1
  mkdir -p $freeware/var/tmp || exit 1


  # Install Python Source RPM
  ## Install python soruce rpm
  rpm -ivh python-2.7.5-1.src.rpm

  # Copy modified SPEC into place
  cp $specfile $freeware/rpmbuild/SPECS/ || exit 1

  # Python build process looks for libffi headers in the wrong place, fix this
  # with a symlink
  if ! test -f "$freeware/lib/libffi-3.0.13/include/ffi.h"; then
      mkdir -p $freeware/lib/libffi-3.0.13 || exit 1
      cd $freeware/lib/libffi-3.0.13 || exit 1
      ln -s ../../include . || exit 1
  fi

  # Build Python
  rpm -bb $freeware/rpmbuild/SPECS/$specfile || exit 1

}


_install_python() {

  python_rpms_list="python-libs-2.7.5-2.aix6.1.ppc.rpm
  python-2.7.5-2.aix6.1.ppc.rpm
  tkinter-2.7.5-2.aix6.1.ppc.rpm
  python-tools-2.7.5-2.aix6.1.ppc.rpm
  python-devel-2.7.5-2.aix6.1.ppc.rpm
  python-test-2.7.5-2.aix6.1.ppc.rpm
  "
  cdir=`pwd`
  cd $freeware/rpmbuild/RPMS/ppc/
  for py_rpm in $python_rpms_list
  do
    test -e $py_rpm || exit 1
    rpm -ivh $py_rpm
  done
  cd $cdir

}


_install_distribute() {
  unzip distribute-0.7.3.zip
  cd distribute-0.7.3
  python setup.py install
}


_install_setuptools() {
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout setuptools-12.2.tar.gz | tar -xvf - || exit 1
  cd setuptools-12.2 || exit 1
  python setup.py install || exit 1
}


_install_pyyaml() {
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout PyYAML-3.11.tar.gz | tar -xvf - || exit 1
  cd PyYAML-3.11 || exit 1
  python setup.py install || exit 1
}

_install_markupSafe() {
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout MarkupSafe-0.23.tar.gz | tar -xvf - || exit 1
  cd MarkupSafe-0.23 || exit 1
  python setup.py install || exit 1
}

_install_msgpack() {
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout msgpack-python-0.4.5.tar.gz | tar -xvf - || exit 1
  cd msgpack-python-0.4.5 || exit 1
  python setup.py install || exit 1
}

_install_jinja() {
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout Jinja2-2.7.3.tar.gz | tar -xvf - || exit 1
  cd Jinja2-2.7.3 || exit 1
  python setup.py install || exit 1
}

_install_backports() {
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout backports.ssl_match_hostname-3.4.0.2.tar.gz | tar -xvf - || exit 1
  cd backports.ssl_match_hostname-3.4.0.2 || exit 1
  python setup.py install || exit 1
}

_install_libcloud() {
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout apache-libcloud-0.17.0.tar.gz | tar -xvf - || exit 1
  cd apache-libcloud-0.17.0 || exit 1
  python setup.py install || exit 1
}

 _install_cherrypy() {
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout CherryPy-3.2.3.tar.gz | tar -xvf - || exit 1
  cd CherryPy-3.2.3 || exit 1
  python setup.py install || exit 1
 }
 
_install_request() {
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout requests-2.7.0.tar.gz | tar -xvf - || exit 1
  cd requests-2.7.0 || exit 1
  python setup.py install || exit 1
}

_install_m2crypto() {
  ## TODO - DGM can only get it to build in 32-bit mode
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout M2Crypto-0.22.3.tar.gz | tar -xvf - || exit 1
  cd M2Crypto-0.22.3 || exit 1
  python setup.py build_ext --openssl=$freeware || exit 1
  python setup.py install || exit 1
}

_install_pycrypto() {
  ##   ## TODO - DGM can only get it to build in 32-bit mode
  cd "$deps/salt_prereqs" || exit 1
  mv "$deps/salt_prereqs/pycrypto-2.6.1.patch" "$deps"
  gzip --decompress --stdout pycrypto-2.6.1.tar.gz | tar -xvf - || exit 1
  cd pycrypto-2.6.1 || exit 1
  # Patch source
  patch -Np1 -i "$deps/pycrypto-2.6.1.patch" || exit 1
  python setup.py install || exit 1
}

_install_libsodium() {
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout libsodium-1.0.2.tar.gz | tar -xvf - || exit 1
  cd libsodium-1.0.2 || exit 1
  ./configure --prefix=$freeware || exit 1
  make || exit 1
  make install || exit 1
}

_install_zeromq() {
  cd "$deps/salt_prereqs" || exit 1

  ## gzip --decompress --stdout zeromq-gz | tar -xvf - || exit 1
  ## cd zeromq-3.2.3 || exit 1
  gzip --decompress --stdout zeromq-4.0.5.tar.gz | tar -xvf - || exit 1
  cd zeromq-4.0.5 || exit 1

  # clean out any old libraries
  rm  -f $freeware/lib/libzmq.*
  rm  -f $freeware/lib64/libzmq.*

  ./configure --prefix=$freeware
  ## $freeware/bin/bash ./configure --with-gcc --prefix=$freeware
  make || exit 1
  make install || exit 1
}

_install_pyzmq() {
  ## TODO - DGM can only get it to build in 32-bit mode
  cd "$deps/salt_prereqs" || exit 1
  ## gzip --decompress --stdout pyzmq-14.5.0.tar.gz | tar -xvf - || exit 1
  ## cd pyzmq-14.5.0 || exit 1
  gzip --decompress --stdout pyzmq-14.3.1.tar.gz | tar -xvf - || exit 1
  cd pyzmq-14.3.1 || exit 1
  python setup.py build --zmq=$freeware || exit 1
  python setup.py install || exit 1
}


_build_install_salt() {

  ## build Salt RPMs
  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout salt-${salt_ver}.tar.gz | tar -xvf - || exit 1

  ## TODO remove
  mv -f sse salt
  
  cd salt
  python setup.py sdist
  cp -f dist/salt-${salt_ver}.tar.gz $freeware/rpmbuild/SOURCES
  cp -f rpm/pkg/salt-* $freeware/rpmbuild/SOURCES
  cp -f rpm/pkg/*.salt $freeware/rpmbuild/SOURCES

  ## TODO  DGM need to get from github
  ## cp SaltTesting.2015.2.6.tar.gz $freeware/rpmbuild/SOURCES
  ## cp salt.spec  from pkg_updates to $freeware/rpmbuild/SPECS
  ## cp skip_tests_3.2.0.patch from pkg_updates to $freeware/rpmbuild/SOURCES

  cp -f $deps/salt.spec $freeware/rpmbuild/SPECS
  rpm -bb $freeware/rpmbuild/SPECS/salt.spec

  cd $freeware/rpmbuild/RPMS/noarch
  ## rpm -ivh salt-enterprise-${salt_ver}-${salt_relver}.aix6.1.noarch.rpm salt-enterprise-minion-${salt_ver}-${salt_relver}.aix6.1.noarch.rpma

  ## rpm -Uivh salt-enterprise-3.2.0-5.aix6.1.noarch.rpm salt-enterprise-minion-3.2.0-5.aix6.1.noarch.rpm salt-enterprise-master-3.2.0-5.aix6.1.noarch.rpm salt-enterprise-ssh-3.2.0-5.aix6.1.noarch.rpm salt-enterprise-syndic-3.2.0-5.aix6.1.noarch.rpm
  ##  rpm -Uivh salt-enterprise-cloud-3.2.0-5.aix6.1.noarch.rpm
  ##  rpm -Uivh salt-enterprise-api-3.2.0-5.aix6.1.noarch.rpm
}



#################################### MAIN ####################################

## static definitions

## TODO DGM need to pick a directory
# currently do this from salt_linux_tools or ibm_linux_tools

## SALT Version and relative version
salt_ver="3.2.0"
salt_relver="5"

## expects dependency has salt_prereqs as sub-dir
deps=`pwd`
freeware=/opt/freeware


# cd to directory containing deps
if test -n "$1"; then
    cd "$1" || exit 1
    deps=`pwd`
fi

if test ! -d "$deps/salt_prereqs"; then
    mkdir "$deps/salt_prereqs"
fi

cd "$deps/salt_prereqs" || exit 1

specfile="python-2.7.5-2.spec"

## TODO DGM
## the folowing are to make life easier
## IBM
## bash-4.2-3.aix6.1.ppc.rpm
## less-382-1.aix5.1.ppc.rpm
## perl-5.8.2-1.aix5.1.ppc.rpm


# start the build process
## DGM _install_needed_opensrc_rpms
## DGM _build_python
## DGM _install_python


## tom's setting from i
## https://github.com/thatch45/blaagposts/blob/master/setting-up-salt-dev-aix.md
export OBJECT_MODE=32
export CC=gcc
export CFLAGS="-maix32 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I$freeware/include"
export CXX=g++
export CXXFLAGS=$CFLAGS
export F77=xlf
export FFLAGS="-O -I$freeware/include"
export LD=ld
export LDFLAGS="-L$freeware/lib -Wl,-blibpath:$freeware/lib64:$freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000"
export PATH="$freeware/bin:$freeware/sbin:/usr/local/bin:/usr/lib/instl:/usr/bin:/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:/usr/vac/bin:/usr/vacpp/bin:/usr/ccs/bin:/usr/dt/bin:/usr/opt/perl5/bin"

## if doing 32-bit then adjust PYTHONPATH too
export PYTHONPATH=$freeware/lib/python2.7:$freeware/lib/python2.7/site-packages

############################# INSTALL SALT DEPS ##############################

## DGM _install_distribute
## DGM _install_setuptools
## DGM _install_pyyaml
## DGM _install_markupSafe
## DGM _install_msgpack
## DGM _install_jinja
## DGM _install_backports
## DGM _install_libcloud
## DGM _install_cherrypy
## DGM _install_request
## DGM _install_m2crypto
## DGM _install_pycrypto
## DGM _install_libsodium
## DGM _install_zeromq
## DGM _install_pyzmq
_build_install_salt



