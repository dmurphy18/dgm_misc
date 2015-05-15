#!/usr/bin/env sh

# dgmskip
dgmskip=0

## TODO DGM need to pick a diectory 
# currently do this from salt_linux_tools or ibm_linux_tools

deps=`pwd`
freeware=/opt/freeware

specfile=python-2.7.5-2.spec

## IBM AIX Linux pre-build version python 2.7.5-1 has issues with libraries
## wants libtcl8.4 and libtk8.4, were use later versions, hence build it

## DGM
if test $dgmskip -ne 0; then

# Configure rpmbuild
## TDO DGM need to check if we still need this since using pre-built Pyhton 2.7.5
echo "%_topdir $freeware/rpmbuild" >~/.rpmmacros
echo "%_var    $freeware/var" >>~/.rpmmacros
mkdir -p $freeware/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} || exit 1
mkdir -p $freeware/var/tmp || exit 1

# cd to directory containing deps
if test -n "$1"; then
    cd "$1" || exit 1
    deps=`pwd`
fi

if test ! -d "$deps/salt_prereqs"; then
    mkdir "$deps/salt_prereqs"
fi


## TODO DGM
## the folowing are to make life easier
## bash-4.2-3.aix6.1.ppc.rpm
## less-382-1.aix5.1.ppc.rpm
## perl-5.8.2-1.aix5.1.ppc.rpm

# Install RPMs and Python Source RPM
## TODO DGM rpm -Uvh *.rpm --force || exit 1
## Need to install from list since install order can be significant for dependencies

## Install python soruce rpm
rpm -ivh python-2.7.5-1.src.rpm

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

IBM_LINUX_RPMS="m4-1.4.13-1.aix6.1.ppc.rpm
autoconf-2.63-1.aix6.1.noarch.rpm
bzip2-1.0.5-3.aix5.3.ppc.rpm
fontconfig-2.4.2-1.aix5.2.ppc.rpm
freetype2-2.3.9-1.aix5.2.ppc.rpm
gdbm-1.8.3-5.aix5.2.ppc.rpm
gdbm-devel-1.8.3-5.aix5.2.ppc.rpm
info-4.6-1.aix5.1.ppc.rpm
libffi-4.2.0-3.aix6.1.ppc.rpm
libffi-devel-4.2.0-3.aix6.1.ppc.rpm
make-3.81-1.aix6.1.ppc.rpm
ncurses-5.2-3.aix4.3.ppc.rpm
ncurses-devel-5.2-3.aix4.3.ppc.rpm
pkg-config-0.19-6.aix5.2.ppc.rpm
readline-6.1-2.aix6.1.ppc.rpm
readline-devel-6.1-2.aix6.1.ppc.rpm
sed-4.1.1-1.aix5.1.ppc.rpm
unzip-5.51-1.aix5.1.ppc.rpm
"


cdir=`pwd`
cd $freeware/rpmbuild/RPMS/ppc/
for ibm_rpm in $IBM_LINUX_RPMS
do
  test -e $ibm_rpm || exit 1
  rpm -ivh $ibm_rpm
done
cd $cdir

## need to get later gcc and libffi to be able to build python
rpm -ev gcc-locale-4.2.0-3 gcc-4.2.0-3 gcc-c++-4.2.0-3 libgcc-4.2.0-3 libstdc++-4.2.0-3 libstdc++-devel-4.2.0-3
rpm -ivh gcc-4.8.0-2.aix6.1.ppc.rpm
rpm -ivh libgcc-4.8.0-2.aix6.1.ppc.rpm
rpm -ivh gcc-cpp-4.8.0-2.aix6.1.ppc.rpm 
rpm -ivh gcc-4.8.0-2.aix6.1.ppc.rpm
rpm -ivh gcc-4.8.0-2.aix6.1.ppc.rpm gcc-cpp-4.8.0-2.aix6.1.ppc.rpm 
rpm -ivh gcc-c++-4.8.0-2.aix6.1.ppc.rpm
rpm -ivh libstdc++-4.8.0-2.aix6.1.ppc.rpm libstdc++-devel-4.8.0-2.aix6.1.ppc.rpm gcc-c++-4.8.0-2.aix6.1.ppc.rpm


# The following list are items preinstalled with IBM AIX Linux tools
## upgrade pre-installed expat-1.95.7-4
rpm -Uvh expat-2.0.1-2.aix5.3.ppc.rpm
rpm -Uvh expat-devel-2.0.1-2.aix5.3.ppc.rpm


## Salt provided rpms

SALT_PRELOAD_RPMS="gmp-5.0.5-1.aix5.1.ppc.rpm
gmp-devel-5.0.5-1.aix5.1.ppc.rpm
libiconv-1.14-2.aix5.1.ppc.rpm
libsigsegv-2.6-1.aix5.2.ppc.rpm
libyaml-0.1.6-1.aix5.1.ppc.rpm
libyaml-devel-0.1.6-1.aix5.1.ppc.rpm
mpfr-3.1.2-1.aix5.1.ppc.rpm
mpfr-devel-3.1.2-1.aix5.1.ppc.rpm
patch-2.7.3-1.aix5.1.ppc.rpm
swig-1.3.40-1.aix5.1.ppc.rpm
libmpc-1.0.1-2.aix5.1.ppc.rpm
libmpc-devel-1.0.1-2.aix5.1.ppc.rpm
"

cdir=`pwd`
cd $freeware/rpmbuild/RPMS/ppc/
for salt_rpm in $SALT_PRELOAD_RPMS
do
  test -e $salt_rpm || exit 1
  rpm -ivh $salt_rpm
done
cd $cdir


## TODO DGM
## remove  readline < 6.3-5 and install readline-6.3-5
## same for readline-devel < 6.3-5 and install readline-devel-6.3-5
rpm -Uvh readline-6.3-5.aix5.1.ppc.rpm --force
rpm -Uvh readline-devel-6.3-5.aix5.1.ppc.rpm --force

rpm -Uvh sqlite-3.8.7.1-1.aix5.1.ppc.rpm
rpm -Uvh sqlite-devel-3.8.7.1-1.aix5.1.ppc.rpm

## Upgrade pre-installed libpng-1.2.32-2
rpm -Uvh libpng-1.6.9-1.aix5.1.ppc.rpm

## upgrade pre-installed openssl-0.9.7g-1
rpm -Uvh openssl-1.0.1l-1.aix5.1.ppc.rpm
rpm -Uvh openssl-devel-1.0.1l-1.aix5.1.ppc.rpm

# fix xft and xrender issues
## Pre-installed libXrender-0.9.1-2 need >=0.9.5
rpm -Uvh freetype2-2.5.3-1.aix5.1.ppc.rpm
rpm -Uvh fontconfig-2.8.0-2.aix5.1.ppc.rpm
rpn -Uvh libXrender-0.9.7-2.aix6.1.ppc.rpm --force
rpn -Uvh libXft-2.3.1-1.aix5.1.ppc.rpm --force

## Pre-installed tcl-8.3.3-8, tk-8.3.3-8, need >= 8.5.8-2
## remove pre-installed  and install newer
rpm -ev expect-5.45-1
rpm -ev tk-8.3.3-8
rpm -ev tcl-8.3.3-8

rpm -ivh tcl-8.5.17-1.aix5.1.ppc.rpm
rpm -ivh tcl-devel-8.5.17-1.aix5.1.ppc.rpm
rpm -ivh tk-8.5.17-1.aix5.1.ppc.rpm
rpm -ivh tk-devel-8.5.17-1.aix5.1.ppc.rpm
rpm -ivh expect-5.45-1.aix5.1.ppc.rpm

## these should be installed after tcl, since they hook into tcl
rpm -ivh db4-4.7.25-2.aix5.1.ppc.rpm
rpm -ivh db4-devel-4.7.25-2.aix5.1.ppc.rpm

# additonal upgrades needed to build python-2.7.5-2
rpm -ev expat-devel-2.0.1-2
rpm -Uvh expat-2.1.0-1.aix5.1.ppc.rpm
rpm -Uvh expat-devel-2.1.0-1.aix5.1.ppc.rpm

rpm -ev ncurses-devel-5.2-3
rpm -Uvh ncurses-5.9-1.aix5.1.ppc.rpm
rpm -Uvh ncurses-devel-5.9-1.aix5.1.ppc.rpm

rpm -Uvh zlib-1.2.8-1.aix5.1.ppc.rpm
rpm -Uvh zlib-devel-1.2.8-1.aix5.1.ppc.rpm
rpm -Uvh sed-4.2.2-1.aix5.1.ppc.rpm

rpm -ev gdbm-devel-1.8.3-5
rpm -Uvh gdbm-1.9.1-1.aix5.1.ppc.rpm
rpm -Uvh gdbm-devel-1.9.1-1.aix5.1.ppc.rpm

#Clean up old versions of packages now superseded by libXft and libXrender
rpm -e xft xrender

# additional rpm to try to get zeromq and pyzmq to build
rpm -Uvh m4-1.4.17-1.aix5.1.ppc.rpm
rpm -Uvh autoconf-2.69-2.aix5.1.ppc.rpm
rpm -Uvh make-4.1-1.aix5.3.ppc.rpm

rpm -Uvh pcre-8.36-1.aix5.1.ppc.rpm
rpm -Uvh grep-2.21-1.aix5.1.ppc.rpm
rpm -Uvh libtool-2.4.6-1.aix5.1.ppc.rpm

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


# Install Python
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

fi  # DGM end fi dgmskip

# install distribute
unzip distribute-0.7.3.zip
python setup.py install


# Set a PYTHONPATH to include the newly-built python
export PYTHONPATH=$freeware/lib64/python2.7:$freeware/lib64/python2.7/site-packages:$freeware/lib/python2.7:$freeware/lib/python2.7/site-packages

# Set env vars for compiled components of salt prereqs
## export OBJECT_MODE=64
## export CC=gcc
## export CFLAGS="-maix64 -g -mminimal-toc -DSYSV -D_AIX -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I$freeware/include"
## export CXX=g++
## export CXXFLAGS="$CFLAGS -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.2.0/include  -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.2.0/include/c++ -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.2.0/include/c++/powerpc-ibm-aix6.1.0.0 -I$freeware/include"
## export F77=xlf
## export FFLAGS="-O -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.2.0/include -I$freeware/include"
## export LD=ld
## export LDFLAGS="-L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.2.0/ppc64 -L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.2.0 -L$freeware/lib -Wl,-blibpath:$freeware/lib64:$freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000 -Wl,-bnoquiet -Wl,-bloadmap:mymap.log -v"
## export PATH="$freeware/bin:$freeware/sbin:/usr/local/bin:/usr/lib/instl:/usr/bin:/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:/usr/vac/bin:/usr/vacpp/bin:/usr/ccs/bin:/usr/dt/bin:/usr/opt/perl5/bin"
## 

export OBJECT_MODE=64
export CC=gcc
export CFLAGS="-maix64 -g -mminimal-toc -DSYSV -D_AIX -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I$freeware/include"
export CXX=g++
export CXXFLAGS="$CFLAGS -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include  -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++ -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++/powerpc-ibm-aix6.1.0.0 -I$freeware/include"
export F77=xlf
export FFLAGS="-O  -I$freeware/include"
export LD=ld
export LDFLAGS="-L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/ppc64 -L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0 -L$freeware/lib -Wl,-blibpath:$freeware/lib64:$freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000 -Wl,-bnoquiet -Wl,-bloadmap:mymap.log -v"
export PATH="$freeware/bin:$freeware/sbin:/usr/local/bin:/usr/lib/instl:/usr/bin:/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:/usr/vac/bin:/usr/vacpp/bin:/usr/ccs/bin:/usr/dt/bin:/usr/opt/perl5/bin"



############################# INSTALL SALT DEPS ##############################

## DGM
if test $dgmskip -ne 0; then

cd "$deps/salt_prereqs" || exit 1
gzip --decompress --stdout setuptools-12.2.tar.gz | tar -xvf - || exit 1
cd setuptools-12.2 || exit 1
python setup.py install || exit 1

cd "$deps/salt_prereqs" || exit 1
gzip --decompress --stdout PyYAML-3.11.tar.gz | tar -xvf - || exit 1
cd PyYAML-3.11 || exit 1
python setup.py install || exit 1

cd "$deps/salt_prereqs" || exit 1
gzip --decompress --stdout MarkupSafe-0.23.tar.gz | tar -xvf - || exit 1
cd MarkupSafe-0.23 || exit 1
python setup.py install || exit 1

cd "$deps/salt_prereqs" || exit 1
gzip --decompress --stdout msgpack-python-0.4.5.tar.gz | tar -xvf - || exit 1
cd msgpack-python-0.4.5 || exit 1
python setup.py install || exit 1

cd "$deps/salt_prereqs" || exit 1
gzip --decompress --stdout Jinja2-2.7.3.tar.gz | tar -xvf - || exit 1
cd Jinja2-2.7.3 || exit 1
python setup.py install || exit 1

cd "$deps/salt_prereqs" || exit 1
gzip --decompress --stdout backports.ssl_match_hostname-3.4.0.2.tar.gz | tar -xvf - || exit 1
cd backports.ssl_match_hostname-3.4.0.2 || exit 1
python setup.py install || exit 1

cd "$deps/salt_prereqs" || exit 1
gzip --decompress --stdout apache-libcloud-0.17.0.tar.gz | tar -xvf - || exit 1
cd apache-libcloud-0.17.0 || exit 1
python setup.py install || exit 1

{
  ## TODO - DGM can only get it to build in 32-bit mode
  OBJECT_MODE=32
  CFLAGS="-maix32 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include  -I$freeware/include"
  CXXFLAGS="$CFLAGS -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++ -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++/powerpc-ibm-aix6.1.0.0 -I$freeware/include"
  FFLAGS="-O -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include -I$freeware/include"
  LDFLAGS="-L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/ppc64 -L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0 -L$freeware/lib -Wl,-blibpath:$freeware/lib64:$freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000 -Wl,-bnoquiet -Wl,-bloadmap:mymap.log -v"

  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout M2Crypto-0.22.3.tar.gz | tar -xvf - || exit 1
  cd M2Crypto-0.22.3 || exit 1
  python setup.py build build_ext --openssl=$freeware || exit 1
  python setup.py install || exit 1
}

{
  ## TODO - DGM can only get it to build in 32-bit mode
  OBJECT_MODE=32
  CFLAGS="-maix32 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include  -I$freeware/include"
  CXXFLAGS="$CFLAGS -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++ -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++/powerpc-ibm-aix6.1.0.0 -I$freeware/include"
  FFLAGS="-O -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include -I$freeware/include"
  LDFLAGS="-L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/ppc64 -L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0 -L$freeware/lib -Wl,-blibpath:$freeware/lib64:$freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000 -Wl,-bnoquiet -Wl,-bloadmap:mymap.log -v"

  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout pycrypto-2.6.1.tar.gz | tar -xvf - || exit 1
  cd pycrypto-2.6.1 || exit 1
  # Patch source
  patch -Np1 -i "$deps/pycrypto-2.6.1.patch" || exit 1
  python setup.py install || exit 1
}

cd "$deps/salt_prereqs" || exit 1
gzip --decompress --stdout libsodium-1.0.2.tar.gz | tar -xvf - || exit 1
cd libsodium-1.0.2 || exit 1
./configure --prefix=$freeware || exit 1
make || exit 1
make install || exit 1

fi  # DGM end fi dgmskip

{
##   ## TODO - DGM can only get it to build in 32-bit mode
##   OBJECT_MODE=32
##   CFLAGS="-maix32 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include  -I$freeware/include"
##   CXXFLAGS="$CFLAGS -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++ -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++/powerpc-ibm-aix6.1.0.0 -I$freeware/include"
##   FFLAGS="-O -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include -I$freeware/include"
##   LDFLAGS="-L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/ppc64 -L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0 -L$freeware/lib -Wl,-blibpath:$freeware/lib64:$freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000 -Wl,-bnoquiet -Wl,-bloadmap:mymap.log -lsodium -lc -v"
##

##   OBJECT_MODE=32
##   CFLAGS='-maix32 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I/opt/freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include  -I/opt/freeware/include'
##   CXXFLAGS='-maix32 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE     -DFUNCPROTO=15 -O2 -I/opt/freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include  -I/opt/freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++ -I/opt/freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++/powerpc-ibm-aix6.1.0.0 -I/opt/freeware/include'
##   FFLAGS='-O -I/opt/freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include -I/opt/freeware/include'
##   LDFLAGS='-L/opt/freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/ppc -L/opt/freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0 -L/opt/freeware/lib -Wl,-blibpath:/opt/freeware/lib64:/opt/freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000 -Wl,-bnoquiet -Wl,-bloadmap:mymap.log -lsodium -lc -v'
##

##   ## Other setting to try
##   export OBJECT_MODE=32
##   export CC=gcc
##   export CFLAGS="-maix32 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I/opt/freeware/include"
##   export CXX=g++
##   export CXXFLAGS=$CFLAGS
##   export F77=xlf
##   export FFLAGS="-O -I/opt/freeware/include"
##   export LD=ld
##   export LDFLAGS="-L/opt/freeware/lib -Wl,-blibpath:/opt/freeware/lib64:/opt/freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000"
##   export PATH="/opt/freeware/bin:/opt/freeware/sbin:/usr/local/bin:/usr/lib/instl:/usr/bin:/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:/usr/vac/bin:/usr/vacpp/bin:/usr/ccs/bin:/usr/dt/bin:/usr/opt/perl5/bin"

  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout zeromq-4.0.5.tar.gz | tar -xvf - || exit 1
  cd zeromq-4.0.5 || exit 1

  # clean out any old libraries
  rm  -f /opt/freeware/libzmq.*

  ## ./configure --prefix=$freeware
  /opt/freeware/bin/bash ./configure --with-gcc --prefix=/opt/freeware
  make || exit 1
  make install || exit 1
}

{
  ## TODO - DGM can only get it to build in 32-bit mode
 OBJECT_MODE=32
 CFLAGS="-maix32 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include  -I$freeware/include"
 CXXFLAGS="$CFLAGS -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++ -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++/powerpc-ibm-aix6.1.0.0 -I$freeware/include"
 FFLAGS="-O -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include -I$freeware/include"
 LDFLAGS="-L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/ppc64 -L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0 -L$freeware/lib -Wl,-blibpath:$freeware/lib64:$freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000 -Wl,-bnoquiet -Wl,-bloadmap:mymap.log -lsodium -lc -v"

  OBJECT_MODE=32
  CFLAGS="-maix32 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I$freeware/include"
  CXXFLAGS="-maix32 -g -mminimal-toc -DSYSV -D_AIX -D_AIX32 -D_AIX41 -D_AIX43 -D_AIX51 -D_ALL_SOURCE -DFUNCPROTO=15 -O2 -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++ -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include -I$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0/include/c++/powerpc-ibm-aix6.1.0.0 -I$freeware/include"
  FFLAGS="-O -I$freeware/include"
  LDFLAGS="-L$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0 -L$freeware/lib -Wl,-blibpath:$freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/4.8.0:$freeware/lib:/usr/lib:/lib -Wl,-bmaxdata:0x80000000 -Wl,-bnoquiet -Wl,-bloadmap:mymap.log -v"

  cd "$deps/salt_prereqs" || exit 1
  gzip --decompress --stdout pyzmq-14.5.0.tar.gz | tar -xvf - || exit 1
  cd pyzmq-14.5.0 || exit 1
  python setup.py build --zmq=$freeware || exit 1
  python setup.py install || exit 1
}
