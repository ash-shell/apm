#!/bin/bash

Self_modules_file_name="ash_modules"
Self_modules_file_path="$Ash__call_directory/$Self_modules_file_name"
Self_modules_directory_name=".ash_modules"
Self_modules_directory_path="$Ash__call_directory/$Self_modules_directory_name"

##################################################
# This function is an alias for `ash self:help`.
##################################################
Self__callable_main() {
    Self__callable_help
}

##################################################
# Displays relavant information on how to use
# this module
##################################################
Self__callable_help() {
    Logger__warning "TODO: self:help"
}

##################################################
# This function will initialize the current
# directory so it can start installing modules
##################################################
Self__callable_init() {
    # Checking if directory is already initialized
    if [[ -e "$Self_modules_file_path" ]]; then
        Logger__error "Directory is already initialized"
        return
    fi

    # Creating our file
    touch "$Self_modules_file_path"
    Logger__success "Directory successfully initialized"
}

##################################################
# This function will install all of the modules
# from the ash_modules file when passed no
# parameters.
#
# When this function is passed a parameter ($1),
# it will install a single module
#
# @param $1: The git HTTP or SSH URL to install
# @param $2: `--global` to install globally
##################################################
Self__callable_install() {
    # If user is passing in URL
    if [[ -n "$1" ]]; then
        Self_install_url "$@"

    # User is not passing URL
    else
        Self_install_modules_file
    fi
}

##################################################
# This function will install a single module
#
# @param $1: The git HTTP or SSH URL to install
# @param $2: `--global` to install globally
##################################################
Self_install_url() {
    local path=""

    # If global flag is passed
    if [[ -n "$2" && "$2" == "--global" ]]; then
        path="$Ash__source_directory/$Ash_global_modules_directory"

    # If no global flag is passed
    else
        path="$Self_modules_directory_path"
    fi

    # Cloning
    Logger__log "Installing $1"
    local success=$(cd $path; git clone "$1" &> /dev/null; echo $?)

    # Success
    if [[ $success -eq 0 ]]; then
        Self_validate_install "$1"

    # Failure
    else
        Logger__error "Failed to clone $1"
    fi
}

##################################################
# Validates an install
##################################################
Self_validate_install() {
    local repo_folder=""

    # SSH
    local ssh_regex="git@.*\:.*/(.*).git"
    if [[ "$1" =~ "$ssh_regex" ]]; then
        repo_folder=${BASH_REMATCH[1]}
    fi

    # HTTP(S)
    local http_regex="https?\://.*/.*/(.*).git"
    if [[ "$1" =~ $http_regex ]]; then
        repo_folder="${BASH_REMATCH[1]}"
    fi

    echo $repo_folder
}

##################################################
# This function will install all of the modules
# from the ash_modules file locally
##################################################
Self_install_modules_file() {
    Logger__log "Install Modules"
}

