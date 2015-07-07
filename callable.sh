#!/bin/bash

Self_modules_file_name="Ashmodules"
Self_modules_clone_directory=".ash_modules_tmp"
Self_modules_file_path="$Ash__call_directory/$Self_modules_file_name"
Self_local_modules_directory_path="$Ash__call_directory/$Ash__modules_foldername"
Self_local_modules_clone_path="$Ash__call_directory/$Self_modules_clone_directory"

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
    more "$Ash__active_module_directory/HELP.txt"
}

##################################################
# This function will initialize the current
# directory so it can start installing modules
##################################################
Self__callable_init() {
    # Hasn't been created
    if [[ ! -f "$Self_modules_file_path" ]]; then
        touch "$Self_modules_file_path"
        Logger__success "Directory successfully initialized"

    # Has already been created
    else
        Logger__error "Directory is already initialized"
    fi
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
    # Creating modules directory
    if [[ ! -d "$Self_local_modules_directory_path" ]]; then
        mkdir "$Self_local_modules_directory_path"
    fi

    # Importing install helper
    . "$Ash__active_module_directory/helper/install.sh"

    # If user is passing in URL
    if [[ -n "$1" ]]; then
        Self_install_url "$@"

    # User is not passing URL
    else
        Self_install_modules_file
    fi
}
