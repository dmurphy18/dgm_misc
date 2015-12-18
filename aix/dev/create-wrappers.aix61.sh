#!/usr/bin/env sh
#
# build wrappers for Salt on AIX
# 
# Run the script with -h for usage details
#

VERSION=2015.12.11
REL=1
PLATFORM=aix61

############################## HELPER FUNCTIONS ##############################

_timestamp() {
    date "+%Y-%m-%d %H:%M:%S:"
}

_log() {
    timestamp=$(_timestamp)
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

# Overrideable parameters
install_dir=/opt/salt
initscript_dir=/etc/rc.d/init.d
executable_dir=/usr/bin
assume_yes=0
dump_tarball=0

_usage() {
    printf "USAGE: $0 [ -h | -y ] [ -i <install_dir> ] [ -I <initscript_dir> ] [ -e <executable_dir> ]

    Builds wrappers for Salt on AIX, run when present at root of prep_rte_area

    -h
        Prints this message

    -y
        Answers \"yes\" to all yes/no prompts (use for unattended installs)

    -i install_dir
        Path to install salt (default: $install_dir)

    -I initscript_dir
        Path to install initscripts (default: $initscript_dir)

    -e executable_dir
        Path to install salt executables (salt, salt-call, etc.)
        (default: $executable_dir)

" 1>&2
    exit 2
}

#################################### MAIN ####################################

# Non-overrideable globals
orig_cwd="`pwd`"
kernel="`uname -s`"
log_file="${orig_cwd}/salt_install.`date +%Y%m%d%H%M%S`.log"
wrappers="salt salt-api salt-call salt-cloud salt-cp salt-key salt-master salt-minion salt-proxy salt-run salt-ssh salt-syndic salt-unity spm"
initscripts="salt-master salt-minion salt-syndic salt-api"

# Only supported on AIX and Linux
case "$kernel" in
    AIX|Linux) continue;;
    *) echo "Unsupported platform \"$kernel\"" 1>&2; exit 2
esac

while getopts hyi:I:e: opt; do
    case "$opt" in
        y) assume_yes=1;;
        i) install_dir=$OPTARG;;
        I) initscript_dir=$OPTARG;;
        e) executable_dir=$OPTARG;;
        *) _usage
    esac
done
OPTIND=1


echo "Salt will be installed with the following options:

Installation Directory: $install_dir
Initscript Directory:   $initscript_dir
Executable Directory:   $executable_dir
"

_confirm_continue

echo
echo "Progress will be logged in $log_file"
echo

_log "Installation Directory: $install_dir"
_log "Initscript Directory:   $initscript_dir"
_log "Executable Directory:   $executable_dir"

_log "Checking for file conflicts in initscript directory"
for initscript in $initscripts; do
    script_path="${orig_cwd}/${initscript_dir}/${initscript}"
    if test -f "$script_path"; then
        _warning "$script_path exists"
        found_initscript=1
    fi
done

if expr "$found_initscript" = 1 >/dev/null; then
    _warning "One or more file conflicts found in initscript directory"
    echo "
PROCEEDING WITH INSTALLATION WILL OVERWRITE THE CONFLICTING FILES IDENTIFIED
ABOVE.
"
    _confirm_continue
fi

_log "Checking if initscript dir ${initscript_dir} exists in ${orig_cwd}"
test -d "${orig_cwd}/$initscript_dir" || mkdir -p "${orig_cwd}/$initscript_dir" || _error "Unable to create initscript directory"

## pythonpath=`find "${orig_cwd}/${install_dir}/lib" "${orig_cwd}/${install_dir}/lib64" -type d -name 'python?.?' 2>/dev/null | tr '\n' : | sed s/:$//`
## pythonpath=`find "${orig_cwd}/${install_dir}/lib" "${orig_cwd}/${install_dir}/lib64" -type d -name 'python?.?' 2>/dev/null | tr '\n' : | sed s/:$// | sed s/\.// | sed s/:\./:/`
pythonpath=`find ".${install_dir}/lib" ".${install_dir}/lib64" -type d -name 'python?.?' 2>/dev/null | tr '\n' : | sed s/:$// | sed s/\.// | sed s/:\./:/`

_display "python path is '$pythonpath'"

echo
for initscript in $initscripts; do
    case "$kernel" in
        AIX) ld_path=/usr/lib:/lib:/usr/lpp/xlC/lib;;
        Linux) ld_path=/usr/lib:/lib:/usr/lib64:/lib64;;
    esac
    _display "Installing $initscript initscript as ${initscript_dir}/${initscript} in ${orig_cwd}"
    cat <<@EOF >"${orig_cwd}/${initscript_dir}/${initscript}"
#!/bin/sh

PYTHON="${install_dir}/bin/python"
SCRIPT="${install_dir}/bin/${initscript}"

RETVAL=0

start_daemon() {
    echo "Starting $initscript daemon..."
    LD_LIBRARY_PATH=${install_dir}/lib:${install_dir}/lib64:${ld_path} PYTHONPATH=$pythonpath \$PYTHON \$SCRIPT -d >/dev/null
    LIBPATH=${install_dir}/lib:${install_dir}/lib64:${ld_path} PYTHONPATH=$pythonpath \$PYTHON \$SCRIPT -d >/dev/null
    if expr \$? = 0 >/dev/null; then
        echo OK
    else
        echo FAILED
        exit 1
    fi
}

stop_daemon() {
    echo "Stopping $initscript daemon..."
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
    chmod +x "${orig_cwd}/${initscript_dir}/${initscript}"
done

echo
_log "Checking for file conflicts in executable directory"
for wrapper in $wrappers; do
    wrapper_path="${orig_cwd}/${executable_dir}/${wrapper}"
    if test -f "$wrapper_path"; then
        _warning "$wrapper_path exists"
        found_wrapper=1
    fi
done

if expr "$found_wrapper" = 1 >/dev/null; then
    _warning "One or more file conflicts found in executable directory"
    echo "
PROCEEDING WITH INSTALLATION WILL OVERWRITE THE CONFLICTING FILES IDENTIFIED
ABOVE.
"
    _confirm_continue
fi

_log "Checking if executable dir ${executable_dir} exists in ${orig_cwd}"
test -d "${orig_cwd}/$executable_dir" || mkdir -p "${orig_cwd}/$executable_dir" || _error "Unable to create executable directory"

for wrapper in $wrappers; do
    _display "Installing $wrapper executable wrapper as ${executable_dir}/${wrapper} in ${orig_cwd}"
    cat <<@EOF >"${orig_cwd}/${executable_dir}/${wrapper}"
#!/bin/sh

export LD_LIBRARY_PATH=${install_dir}/lib:${install_dir}/lib64:${ld_path}
export LIBPATH=${install_dir}/lib:${install_dir}/lib64:${ld_path}
export PYTHONPATH=$pythonpath

"${install_dir}/bin/python" "${install_dir}/bin/${wrapper}" "\$@"

exit \$?
@EOF
    chmod +x "${orig_cwd}/${executable_dir}/${wrapper}"
done

echo
_display "Done!"



