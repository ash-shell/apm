#!/bin/bash

Apm_MODULES_FILE_NAME="Ashmodules"
Apm_MODULES_CLONE_DIRECTORY=".ash_modules_tmp"
Apm_MODULES_FILE_PATH="$Ash__call_directory/$Apm_MODULES_FILE_NAME"
Apm_LOCAL_MODULES_DIRECTORY_PATH="$Ash__call_directory/$Ash__modules_foldername"
Apm_LOCAL_MODULES_CLONE_PATH="$Ash__call_directory/$Apm_MODULES_CLONE_DIRECTORY"

##################################################
# This function is an alias for `ash self:help`.
##################################################
Apm__callable_main() {
    Apm__callable_help
}

##################################################
# Displays relavant information on how to use
# this module
##################################################
Apm__callable_help() {
    more "$Ash__active_module_directory/HELP.txt"
}

##################################################
# This function will initialize the current
# directory so it can start installing modules
##################################################
Apm__callable_init() {
    # Hasn't been created
    if [[ ! -f "$Apm_MODULES_FILE_PATH" ]]; then
        touch "$Apm_MODULES_FILE_PATH"
        Logger__success "Directory successfully initialized"

    # Has already been created
    else
        Logger__error "Directory is already initialized"
    fi
}

##################################################
# This function will install all of the modules
# from the Ashmodules file when passed no
# parameters.
#
# When this function is passed a parameter ($1),
# it will install a single module
#
# @param $1: The git HTTP or SSH URL to install
# @param $2: `--global` to install globally
##################################################
Apm__callable_install() {
    # Creating modules directory
    if [[ "$2" != "--global" && ! -d "$Apm_LOCAL_MODULES_DIRECTORY_PATH" ]]; then
        mkdir "$Apm_LOCAL_MODULES_DIRECTORY_PATH"
        touch "$Apm_LOCAL_MODULES_DIRECTORY_PATH/$Ash_module_aliases_file"
    fi

    # If user is passing in URL
    if [[ -n "$1" ]]; then
        Apm_install_url "$@"

    # User is not passing URL
    else
        Apm_install_modules_file
    fi
}

##################################################
# This function will display a list of all of the
# global modules that are currently installed.
##################################################
Apm__callable_modules() {
    local line=""
    local global_aliases="$Ash__source_directory/$Ash_global_modules_directory/$Ash_module_aliases_file"
    while read line; do
        echo "${line//:/ =>}"
    done < "$global_aliases"
}

##################################################
# This function will update a global module or
# Ash itself.
#
# @param $1: The alias or package of a global
# module. To update Ash itself, simply just pass
# `ash` here.
##################################################
Apm__callable_update(){
    local module_name="$1"

    # Checking if we're passing a module name
    if [[ -z "$module_name" ]]; then
        Logger__error "Requires a valid module name (or \"ash\") to be passed in"
        return
    fi

    # Update
    if [[ "$module_name" = 'ash' ]]; then
        Apm_update_ash
        return
    else
        Apm_update_module "$module_name"
    fi
}
