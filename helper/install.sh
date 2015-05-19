#!/bin/bash

Self_install_path="" # TBD at runtime

##################################################
# This function will install all of the modules
# from the ash_modules file locally
##################################################
Self_install_modules_file() {
    while read line; do
        if [[ "$line" != "" ]]; then
            Self_install_url "$line"
        fi
    done < "$Self_modules_file_path"
}

##################################################
# This function will install a single module
#
# @param $1: The git HTTP or SSH URL to install
# @param $2: `--global` to install globally
##################################################
Self_install_url() {
    # If global flag is passed
    if [[ -n "$2" && "$2" == "--global" ]]; then
        Self_install_path="$Ash__source_directory/$Ash_global_modules_directory"

    # If no global flag is passed
    else
        Self_install_path="$Self_modules_directory_path"
    fi

    # Cloning
    Logger__log "Installing $1"
    local success=$(cd $Self_install_path; git clone "$1" &> /dev/null; echo $?)

    # Success
    if [[ $success -eq 0 ]]; then
        Self_install_validate "$1"

    # Failure
    else
        Logger__error "Failed to clone $1"
    fi
}

##################################################
# Validates an install
##################################################
Self_install_validate() {
    local repo_folder=$(Self_install_get_folder "$1")
    local repo_path="$Self_install_path/$repo_folder"
    local repo_config="$repo_path/$Ash_config_filename"

    # Invalid path
    if [[ ! -d "$repo_path" ]]; then
        Logger__error "Failed to clone $1"
        return
    fi

    # No ash_config file
    if [[ ! -f "$repo_config" ]]; then
        rm -rf "$repo_path"
        Logger__error "$1 is not a valid ash module"
        return
    fi

    # Importing slugify
    Ash__import "slugify"

    # Renaming git module to proper place
    eval $(YamlParse__parse "$repo_config" "Self_install_validate_")
    local folder_name="$(Slugify__slugify "$Self_install_validate_name")"
    local new_path="$Self_install_path/$folder_name"
    if [[ -d $new_path ]]; then
        Logger__error "Module '$Self_install_validate_name' is already installed"
        rm -rf "$repo_path"
    else
        mv "$repo_path" "$new_path"
    fi
}

##################################################
# Gets the repo folder name from a git clone URL
##################################################
Self_install_get_folder() {
    local repo_folder=""

    # SSH
    local ssh_regex="git@.*\:.*/(.*).git"
    if [[ "$1" =~ $ssh_regex ]]; then
        repo_folder=${BASH_REMATCH[1]}
    fi

    # HTTP(S)
    local http_regex="https?\://.*/.*/(.*).git"
    if [[ "$1" =~ $http_regex ]]; then
        repo_folder="${BASH_REMATCH[1]}"
    fi

    echo $repo_folder
}
