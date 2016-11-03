#!/usr/bin/sh
#
# Installer for Salt on AIX
#
# Run the script with -h for usage details
#

VERSION=2016.11.03


############################## HELPER FUNCTIONS ##############################

_timestamp() {
    date "+%Y-%m-%d %H:%M:%S:"
}

_log() {
    timestamp=$(_timestamp)
    echo "$1" | sed "s/^/$(_timestamp) /" >>"${log_file}"
}

# Both echo and log
_display() {
    echo "$1"
    _log "$1"
}

_error() {
    msg="ERROR: $1"
    echo "${msg}" 1>&2
    echo "$(_timestamp) ${msg}" >>"${log_file}"
    echo "One or more errors found. See ${log_file} for details." 1>&2
    exit 1
}

_warning() {
    msg="WARNING: $1"
    echo "${msg}" 1>&2
    echo "$(_timestamp) ${msg}" >>"${log_file}"
}

_tolower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

_yesno() {
    # Don't even prompt if -y was passed
    expr "${assume_yes}" = 1 >/dev/null && return 0

    while getopts p: opt; do
        case "${opt}" in
            p) _prompt=$OPTARG;;
        esac
    done
    OPTIND=1
    _prompt="${_prompt} [yes/no]: "

    while [ 1 ]; do
        case "${kernel}" in
            AIX)
                read answer?"${_prompt}";;
            Linux)
                echo -n "${_prompt}"; read answer;;
        esac
        answer=$(_tolower "${answer}")
        case "${answer}" in
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
    printf "USAGE: $0 [ -h | -y ] [ -u ] [ -f ]

    -h
        Prints this message

    -y
        Answers \"yes\" to all yes/no prompts (use for unattended installs)

    -u uninstall

    -f force new install
        Install Salt overwriting any existing installation

" 1>&2
    exit 2
}

_check_for_existing_services() {
    _log "Checking for existing files in initscript directory"
    for initscript in $initscripts; do
        script_path="${initscript_dir}/${initscript}"
        if test -f "$script_path"; then
            ## _warning "$script_path exists"
            found_initscript=1
            case "${initscript}" in
                'salt-api')
                    ps -e -o %a | grep 'salt-api' | grep -v 'grep'
                    if [  $? -eq 0 ]; then
                        _log "Found service ${initscript} active"
                        eval service_salt_api=1
                    fi
                    continue;;
                'salt-master')
                    ps -e -o %a | grep 'salt-master' | grep -v 'grep'
                    if [  $? -eq 0 ]; then
                        _log "Found service ${initscript} active"
                        eval service_salt_master=1
                    fi
                    continue;;
                'salt-minion')
                    ps -e -o %a | grep 'salt-minion' | grep -v 'grep'
                    if [  $? -eq 0 ]; then
                        _log "Found service ${initscript} active"
                        eval service_salt_minion=1
                    fi
                    continue;;
                'salt-syndic')
                    ps -e -o %a | grep 'salt-syndic' | grep -v 'grep'
                    if [  $? -eq 0 ]; then
                        _log "Found service ${initscript} active"
                        eval service_salt_syndic=1
                    fi
                    continue;;
                *) _warning "Unsupported initscript \"${initscript}\"" 1>&2; exit 2
            esac
        fi
    done
}

_check_for_existing_conf() {
    _log "Checking for files in executable directory"
    for wrapper in $wrappers; do
        wrapper_path="${executable_dir}/${wrapper}"
        if test -f "${wrapper_path}"; then
            ## _warning "$wrapper_path exists"
            found_wrapper=1
        fi
    done
}

_disable_active_services () {
    _log "Checking to disable services found initscript directory"
    for initscript in $initscripts; do
        script_path="${initscript_dir}/${initscript}"
        if test -f "${script_path}"; then
            case "${initscript}" in
                'salt-api')
                    if [ ${service_salt_api} -eq 1 ]; then
                        _log "Stopping service ${initscript}"
                        ${script_path} stop
                    fi
                    continue;;
                'salt-master')
                    if [ ${service_salt_master} -eq 1 ]; then
                        _log "Stopping service ${initscript}"
                        ${script_path} stop
                    fi
                    continue;;
                'salt-minion')
                    if [ ${service_salt_minion} -eq 1 ]; then
                        _log "Stopping service ${initscript}"
                        ${script_path} stop
                    fi
                    continue;;
                'salt-syndic')
                    if [ ${service_salt_syndic} -eq 1 ]; then
                        _log "Stopping service ${initscript}"
                        ${script_path} stop
                    fi
                    continue;;
                *) _warning "Disable active services unsupported initscript \"${initscript}\"" 1>&2; exit 2
            esac
        fi
    done
}

_restart_disabled_active_services () {
    _log "Checking to restart disabled services found initscript directory"
    for initscript in $initscripts; do
        script_path="${initscript_dir}/${initscript}"
        if test -f "${script_path}"; then
            case "${initscript}" in
                'salt-api')
                    if [ ${service_salt_api} -eq 1 ]; then
                        _log "Restarting stopped service ${initscript}"
                        ${script_path} restart
                    fi
                    continue;;
                'salt-master')
                    if [ ${service_salt_master} -eq 1 ]; then
                        _log "Restarting stopped service ${initscript}"
                        ${script_path} restart
                    fi
                    continue;;
                'salt-minion')
                    if [ ${service_salt_minion} -eq 1 ]; then
                        _log "Restarting stopped service ${initscript}"
                        ${script_path} restart
                    fi
                    continue;;
                'salt-syndic')
                    if [ ${service_salt_syndic} -eq 1 ]; then
                        _log "Restarting stopped service ${initscript}"
                        ${script_path} restart
                    fi
                    continue;;
                *) _warning "Restart disabled service unsupported initscript \"${initscript}\"" 1>&2; exit 2
            esac
        fi
    done
}

#################################### MAIN ####################################

# Non-overrideable globals
install_dir=/opt/salt
initscript_dir=/etc/rc.d/init.d
executable_dir=/usr/bin

# functionality control flags
assume_yes=0
uninstall_flag=0
force_new_flag=0
found_initscript=0
found_wrapper=0


# active services, 0 - off, 1 - on
service_salt_minion=0
service_salt_master=0
service_salt_api=0
service_salt_syndic=0

orig_cwd="$(pwd)"
kernel="$(uname -s)"
log_file="${orig_cwd}/salt_install.`date +%Y%m%d%H%M%S`.log"
wrappers="salt salt-call salt-cloud salt-cp salt-key salt-master salt-minion salt-run salt-ssh salt-syndic salt-unity salt-proxy spm"
initscripts="salt-master salt-minion salt-syndic salt-api"
conf_list="master minion proxy cloud roster"

save_dir="${orig_cwd}/salt_archive"

## salt_bff='salt.15.8.3.1.bff'
salt_all_bffs=$(find ${orig_cwd} -name "salt.*.bff" -print)
salt_bff=$(echo ${salt_all_bffs} | cut -d ' ' -f1)


# Only supported on AIX
case "${kernel}" in
    AIX) continue;;
    *) echo "Unsupported platform \"$kernel\"" 1>&2; exit 2
esac

while getopts hyuf opt; do
    case "${opt}" in
        y) assume_yes=1;;
        u) uninstall_flag=1;;
        f) force_new_flag=1;;
        *) _usage
    esac
done
OPTIND=1


if [ ${uninstall_flag} -eq 1 ]; then
    _display "Salt will be uninstalled"
else
    if [ ${force_new_flag} -eq 1 ]; then
        _display "Salt will be installed over-writing existing configuration "
    else
        _display "Salt will be installed"
    fi
fi

_confirm_continue

echo
echo "Progress will be logged in $log_file"
echo

if [ ${uninstall_flag} -eq 1 ]; then
    ## echo "installp -u salt.rte"
    installp -u salt.rte 2>/dev/null
else
    _check_for_existing_services
    _disable_active_services
    if [ ${force_new_flag} -eq 1 ]; then
        ## echo "installp -acXYg -d . ${salt_bff} salt.rte 2>/dev/null"
        installp -acXYg -d . ${salt_bff} salt.rte 2>/dev/null
    else
        _check_for_existing_conf
        if [ ${found_initscript} -eq 1 -o ${found_wrapper} -eq 1 ]; then
            mkdir -p ${save_dir}
            if [ "$?" -ne 0 ]; then
                 _error "Unable to create salt_archive directory"
            fi
            for idx in ${conf_list}; do
                _log "saving /opt/salt/etc/salt/${idx}"
                cp -f "/opt/salt/etc/salt/${idx}" "${save_dir}/"
            done
            ## echo "install_all_updates -cVYd . 2>/dev/null"
            install_all_updates -cVYd . 2>/dev/null
            for idx in ${conf_list}; do
                _log "restoring ${save_dir}/${idx}"
                cp -f "${save_dir}/${idx}" "/opt/salt/etc/salt/"
            done
            rm -fR ${save_dir}
        else
            ## echo "installp -acXYg -d . ${salt_bff} salt.rte 2>/dev/null"
            installp -acXYg -d . ${salt_bff} salt.rte 2>/dev/null
        fi
    fi
    _restart_disabled_active_services
fi

echo
_display "Done!"



