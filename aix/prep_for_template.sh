#!/usr/bin/env bash

SCRIPT_VERSION=2015.05.20.1

## Helper script to move generated/built code to template prep area
## ignoring any temporary files (for example: .pyc, .pyo) and setup
## scripts,wrappers and enviroments to allow a template to be generated
## from the files present

############################## HELPER FUNCTIONS ##############################

_timestamp() {
    date "+%Y-%m-%d %H:%M:%S:"
}

_log() {
    echo "$1" | sed "s/^/$(_timestamp) /" >>"$log_file"
}

# Both echo and log
_display() {
    echo "$1"
    _log "$1"
}

_error() {
    msg="ERROR: $1"
    echo "$msg" 1>&2
    echo "$(_timestamp) $msg" >>"$log_file"
    echo "One or more errors found. See $log_file for details." 1>&2
    exit 1
}

_warning() {
    msg="WARNING: $1"
    echo "$msg" 1>&2
    echo "$(_timestamp) $msg" >>"$log_file"
}

_empty_dir() {
    test -z "$1" && _error "Directory required"
    # If the dir is empty, the find command will only return a single line of
    # output. If the directory doesn't exist, there will be zero lines of
    # output. We will consider both of these a true result. Using head will
    # speed up the command by ignoring the rest of the files if there were a
    # ton of files in the specified dir.
    count=`find "$1" 2>/dev/null | head -n2 | wc -l`
    test $count -le 1 && return 0 || return 1
}

_tolower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

_yesno() {
    # Don't even prompt if -y was passed
    expr "$assume_yes" = 1 >/dev/null && return 0

    while getopts p: opt; do
        case "$opt" in
            p) _prompt=$OPTARG;;
        esac
    done
    OPTIND=1
    _prompt="$_prompt [yes/no]: "

    while [ 1 ]; do
        case "$kernel" in
            AIX)
                read answer?"$_prompt";;
            Linux)
                echo -n "$_prompt"; read answer;;
        esac
        answer=$(_tolower "$answer")
        case "$answer" in
            yes)
                return 0;;
            no)
                return 1;;
            *)
                _prompt="Please answer 'yes' or 'no': "
        esac
    done
}

_confirm_continue() {
    if ! _yesno -p "Are you sure you wish to proceed?"; then
        echo
        _display "Aborted installation on user input."
        exit 3
    fi
}

_usage() {
    echo "USAGE: $0 [ -V | -h | -y ] -s <source_root_dir> [ -i <prep_area_dir> ] 

    -V Prints install script version
    -h Prints this message
    -y Answers \"yes\" to all yes/no prompts (use for unattended installs)
    -s source_root_dir
        Path to the root of the source directory for built/generated code (default: $built_dir)
    -i prep_area_dir
        Path to prep area to build AIX mkinstall template for salt (default: $prep_dir)
" 1>&2
    exit 2
}

#################################### MAIN ####################################

# Non-overrideable globals
orig_cwd="`pwd`"
kernel="`uname -s`"
wrappers="salt salt-call salt-cloud salt-cp salt-key salt-master salt-minion salt-run salt-ssh salt-syndic"
initscripts="salt-master salt-minion salt-syndic"

tarball_name="salt_built"

install_dir=/opt/salt
initscript_dir=/etc/rc.d/init.d
executable_dir=/usr/bin
log_file_format="${orig_cwd}/prep_templ.%Y%m%d%H%M%S.log"
log_file="`date \"+${log_file_format}\"`"
assume_yes=0

# Overrideable parameters
built_dir="/opt/freeware"
prep_dir="${HOME}/prep_rte_area"

# Only supported on AIX and Linux
if test "$kernel" != "AIX"; then
    _error "Unsupported platform '$kernel'"
fi

while getopts Vhys:i: opt; do
    case "$opt" in
        V) echo $SCRIPT_VERSION && exit 0;;
        h) _usage;;
        y) assume_yes=1;;
        s) built_dir=$OPTARG;;
        i) prep_dir=$OPTARG;;
        *) _usage
    esac
done
OPTIND=1

if test ! -d "${built_dir}"; then
    _error "code building area for salt package does not exist"
fi

# cleanout prep area, delete and create
rm -fR ${prep_dir}
mkdir -p ${prep_dir}

# create tarball of built/generated code in prep area
# maintaining symbolic links (AIX has issue with symbolic links)
# but ignore generated python code and other unrelated directories

rm "${prep_dir}/excl.txt"
touch "${prep_dir}/excl.txt"
echo "*.pyc" >> "${prep_dir}/excl.txt"
echo "*.pyo" >> "${prep_dir}/excl.txt"
echo "lost+found" >> "${prep_dir}/excl.txt"
echo "vnc" >> "${prep_dir}/excl.txt"
echo "rpmbuild" >> "${prep_dir}/excl.txt"
## echo "packages" >> "${prep_dir}/excl.txt"
echo "GNUPro" >> "${prep_dir}/excl.txt"
echo "man/man3" >> "${prep_dir}/excl.txt"
echo "man/man5" >> "${prep_dir}/excl.txt"
echo "man/man8" >> "${prep_dir}/excl.txt"
echo "man/mann" >> "${prep_dir}/excl.txt"
echo "share/vim" >> "${prep_dir}/excl.txt"
echo "bin/vim" >> "${prep_dir}/excl.txt"
echo "bin/vimtutor" >> "${prep_dir}/excl.txt"
echo "bin/vncpasswd" >> "${prep_dir}/excl.txt"
echo "bin/vncserver" >> "${prep_dir}/excl.txt"
echo "bin/vncviewer" >> "${prep_dir}/excl.txt"
echo "src" >> "${prep_dir}/excl.txt"
echo "var" >> "${prep_dir}/excl.txt"
echo "tmp" >> "${prep_dir}/excl.txt"
echo "lib/libffi-3.0.13" >> "${prep_dir}/excl.txt"

cd ${built_dir}
tar -c -X "${prep_dir}/excl.txt" -f "${prep_dir}/${tarball_name}.tar" *

## rm -f ${prep_dir}/excl.txt
mv -f ${prep_dir}/excl.txt  ${HOME}/excl_d.txt

_log "Installation Directory: ${install_dir} in prep area ${prep_dir}"
_log "Initscript Directory:   ${initscript_dir} in prep area ${prep_dir}"
_log "Executable Directory:   ${executable_dir} in prep area ${prep_dir}"

_log "Making installation directory ${install_dir} in prep area ${prep_dir}"
mkdir -p "${prep_dir}/${install_dir}" || _error "Unable to make installation directory ${install_dir} in prep area ${prep_dir}"
mkdir -p "${prep_dir}/${initscript_dir}" || _error "Unable to make installation directory ${initscript_dir} in prep area ${prep_dir}"
mkdir -p "${prep_dir}/${executable_dir}" || _error "Unable to make installation directory ${executable_dir} in prep area ${prep_dir}"

# expand tar ball, maintaining symbolic links
cd ${prep_dir}
_display "Unpacking ${tarball_name} into ${install_dir} in prep area ${prep_dir}"
err="Unable to unpack package tarball '${tarball_name}'"
mv ${tarball_name}.tar ${prep_dir}/${install_dir}
cd ${prep_dir}/${install_dir}
tar -xf ${tarball_name}.tar || _error "$err"

## rm -f ${tarball_name}.tar
mv -f ${tarball_name}.tar "${HOME}/${tarball_name}_d.tar"

cd ${prep_dir}

_log "Checking for file conflicts in initscript directory"
for initscript in ${initscripts}; do
    script_path="${prep_dir}/${initscript_dir}/${initscript}"
    if test -f "${script_path}"; then
        _warning "${script_path} exists"
        found_initscript=1
    fi
done

if expr "${found_initscript}" = 1 >/dev/null; then
    _warning "One or more file conflicts found in initscript directory"
    echo "
PROCEEDING WITH INSTALLATION WILL OVERWRITE THE CONFLICTING FILES IDENTIFIED
ABOVE.
"
    _confirm_continue
fi

_log "Checking if initscript dir ${prep_dir}/${initscript_dir} exists"
test -d "${prep_dir}/${initscript_dir}" || mkdir -p "${prep_dir}/${initscript_dir}" || _error "Unable to create initscript directory"

pythonpath=
for pythondir in `find ".${install_dir}/lib" ".${install_dir}/lib64" -type d -name python\?.\?`; do
    pythonpath="${pythonpath}:${pythondir}:${pythondir}/lib-dynload"
done
pythonpath=`echo "${pythonpath}"| sed "s/:\./:/g" | cut -c2-`

echo
for initscript in ${initscripts}; do
    ld_path="/usr/lib:/lib:/usr/lpp/xlC/lib"
    _display "Installing ${initscript} initscript as ${prep_dir}/${initscript_dir}/${initscript}"
    cat <<@EOF >"${prep_dir}/${initscript_dir}/${initscript}"
#!/bin/sh

PYTHON="${install_dir}/bin/python"
SCRIPT="${install_dir}/bin/${initscript}"

RETVAL=0

start_daemon() {
    echo "Starting ${initscript} daemon..."
    LD_LIBRARY_PATH=${install_dir}/lib:${install_dir}/lib64:${ld_path} PYTHONPATH=$pythonpath \$PYTHON \$SCRIPT -d >/dev/null
    if expr \$? = 0 >/dev/null; then
        echo OK
    else
        echo FAILED
        exit 1
    fi
}

stop_daemon() {
    echo "Stopping ${initscript} daemon..."
    if ps -ef | fgrep "\$PYTHON \$SCRIPT" | grep -v grep | awk '{print \$2}' | xargs kill >/dev/null; then
        echo OK
    else
        echo FAILED
        exit 1
    fi
}

restart_daemon() {
   stop_daemon
   start_daemon
}

case "\$1" in
    start|stop|restart)
        \${1}_daemon
        ;;
    *)
        echo "Usage: \$0 {start|stop|restart}"
        exit 1
        ;;
esac
exit 0
@EOF
    chmod +x "${prep_dir}/${initscript_dir}/${initscript}"
done

echo
_log "Checking for file conflicts in executable directory"
for wrapper in ${wrappers}; do
    wrapper_path="${prep_dir}/${executable_dir}/${wrapper}"
    if test -f "${wrapper_path}"; then
        _warning "${wrapper_path} exists"
        found_wrapper=1
    fi
done

if expr "${found_wrapper}" = 1 >/dev/null; then
    _warning "One or more file conflicts found in executable directory"
    echo "
PROCEEDING WITH INSTALLATION WILL OVERWRITE THE CONFLICTING FILES IDENTIFIED
ABOVE.
"
    _confirm_continue
fi

_log "Checking if executable dir ${prep_dir}/${executable_dir} exists"
test -d "${prep_dir}/${executable_dir}" || mkdir -p "${prep_dir}/${executable_dir}" || _error "Unable to create executable directory"

for wrapper in ${wrappers}; do
    _display "Installing ${wrapper} executable wrapper as ${prep_dir}/${executable_dir}/${wrapper}"
    cat <<@EOF >"${prep_dir}/${executable_dir}/${wrapper}"
#!/bin/sh

export LD_LIBRARY_PATH=${install_dir}/lib:${install_dir}/lib64:${ld_path}
export PYTHONPATH=$pythonpath

"${install_dir}/bin/python" "${install_dir}/bin/${wrapper}" "\$@"

exit \$?
@EOF
    chmod +x "${prep_dir}/${executable_dir}/${wrapper}"
done

echo
_display "Done!"

