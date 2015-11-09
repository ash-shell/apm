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
# from the Ashmodules file when passed no
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
    if [[ "$2" != "--global" && ! -d "$Self_local_modules_directory_path" ]]; then
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

##################################################
# This function will update a global module or
# Ash itself.
#
# @param $1: The global module's `name` as defined
#   in it's ash_config.yaml file.  To update Ash
#   itself, simply just pass `ash` here.
##################################################
Self__callable_update(){
    # Checking if we're passing a module name
    if [[ -z $1 ]]; then
        Logger__error "Requires a valid module name (or \"ash\") to be passed in"
        return
    fi

    # Checking if we're updating ash
    if [[ $1 = 'ash' ]]; then
        cd $Ash__source_directory

        # Updating
        git pull origin master
        git submodule update

        # Checking for success
        if [ $? -eq 0 ]; then
            Logger__success "Ash was updated"
        else
            Logger__error "Something went wrong, Ash was not updated"
            Logger__error "You will have to manually update at $Ash__source_directory"
        fi

        return
    fi

    # Checking if we're passing a valid global module
    local directory="$Ash__source_directory/$Ash_global_modules_directory/$1"
    if [[ -d "$directory" ]]; then
        Logger__log "Updating $1"

        # Updating
        cd "$directory"
        git pull origin master

        # Checking for success
        if [ $? -eq 0 ]; then
            Logger__success "$1 was updated"
        else
            Logger__error "Something went wrong, $1 was not updated"
            Logger__error "You will have to manually update at $directory"
        fi
    else
        Logger__error "Module \"$1\" does not exist"
    fi
}
