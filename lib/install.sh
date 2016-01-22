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
        Self_clone_path="$Ash__source_directory/$Self_modules_clone_directory"

    # If no global flag is passed
    else
        Self_install_path="$Self_local_modules_directory_path"
        Self_clone_path="$Self_local_modules_clone_path"
    fi

    # Creating temporary clone path
    if [[ -d "$Self_clone_path" ]]; then
        rm -rf "$Self_clone_path"
    fi
    mkdir "$Self_clone_path"

    # Cloning
    Logger__log "Installing $1"
    local success=$(cd $Self_clone_path; git clone "$1" &> /dev/null; echo $?)

    # Success
    if [[ $success -eq 0 ]]; then
        Self_install_validate "$1"

    # Failure
    else
        Logger__error "Failed to clone $1"
    fi

    # Removing temporary clone path
    if [[ -d "$Self_clone_path" ]]; then
        rm -rf "$Self_clone_path"
    fi
}

##################################################
# Validates an install
##################################################
Self_install_validate() {
    local repo_folder=$(Self_install_get_folder "$1")
    local repo_path="$Self_clone_path/$repo_folder"
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

    # Loading config
    eval $(YamlParse__parse "$repo_config" "Self_install_validate_")
    local module_package="$Self_install_validate_package"
    local module_directory="${module_package%/*}"
    local new_path="$Self_install_path/$module_package"

    # Determining if alias already installed
    local alias_file="$Self_install_path/$Ash_module_aliases_file"
    local module_alias_name="$Self_install_validate_default_alias"
    local has_key=$(YamlParse__has_key "$alias_file" "$module_alias_name")

    # If package path already exists
    if [[ -d "$new_path" ]]; then
        Logger__error "Module '$module_package' is already installed"
        rm -rf "$repo_path"
        return
    fi

    # If there is already a package with that alias
    if [[ "$has_key" == $Ash__true ]]; then
        Logger__error "There is already a module with alias '$module_alias_name'"
        Logger__prompt "Would you like to supply a new alias? (y/n): "; read resp
        if [[ "$resp" == "y" ]]; then
            Logger__prompt "Enter alias: "; read newAlias
            module_alias_name="$newAlias"
        else
            Logger__log "Install cancelled"
            return
        fi
    fi

    # OK
    mkdir -p $module_directory
    mv "$repo_path" "$new_path"
    echo "$module_alias_name: $module_package" >> "$alias_file"
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
