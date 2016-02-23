#!/bin/bash

Apm_install_path="" # TBD at runtime

##################################################
# This function will install all of the modules
# from the ash_modules file locally
##################################################
Apm_install_modules_file() {
    while read line; do
        if [[ "$line" != "" ]]; then
            Apm_install_url "$line"
        fi
    done < "$Apm_MODULES_FILE_PATH"
}

##################################################
# This function will install a single module
#
# @param $1: The git HTTP or SSH URL to install
# @param $2: `--global` to install globally
##################################################
Apm_install_url() {
    # If global flag is passed
    if [[ -n "$2" && "$2" == "--global" ]]; then
        Apm_install_path="$Ash__source_directory/$Ash_global_modules_directory"
        Apm_clone_path="$Ash__source_directory/$Apm_MODULES_CLONE_DIRECTORY"

    # If no global flag is passed
    else
        Apm_install_path="$Apm_LOCAL_MODULES_DIRECTORY_PATH"
        Apm_clone_path="$Apm_LOCAL_MODULES_CLONE_PATH"
    fi

    # Creating temporary clone path
    if [[ -d "$Apm_clone_path" ]]; then
        rm -rf "$Apm_clone_path"
    fi
    mkdir "$Apm_clone_path"

    # Cloning
    Logger__log "Installing $1"
    local success=$(cd $Apm_clone_path; git clone "$1" &> /dev/null; echo $?)

    # Success
    if [[ $success -eq 0 ]]; then
        Apm_install_validate "$1"

    # Failure
    else
        Logger__error "Failed to clone $1"
    fi

    # Removing temporary clone path
    if [[ -d "$Apm_clone_path" ]]; then
        rm -rf "$Apm_clone_path"
    fi
}

##################################################
# Validates an install
##################################################
Apm_install_validate() {
    local repo_folder=$(Apm_install_get_folder "$1")
    local repo_path="$Apm_clone_path/$repo_folder"
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
    eval $(YamlParse__parse "$repo_config" "Apm_install_validate_")
    local module_package="$Apm_install_validate_package"
    local module_directory="$Apm_install_path/${module_package%/*}"
    local new_path="$Apm_install_path/$module_package"

    # If package wasn't supplied in the ash_config.yaml file
    if [[ "$module_package" == "" ]]; then
        Logger__error "Failed to install module as it failed to provide a 'package' in it's $Ash_config_filename"
        rm -rf "$repo_path"
        return
    fi

    # If package path already exists
    if [[ -d "$new_path" ]]; then
        Logger__error "Module '$module_package' is already installed"
        rm -rf "$repo_path"
        return
    fi

    # Getting alias
    local alias_file="$Apm_install_path/$Ash_module_aliases_file"
    local module_alias_name="$Apm_install_validate_default_alias"
    local has_key=$(YamlParse__has_key "$alias_file" "$module_alias_name")
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
    if [[ "$module_alias_name" != "" ]]; then
        echo "$module_alias_name: $module_package" >> "$alias_file"
    fi
}

##################################################
# Gets the repo folder name from a git clone URL
##################################################
Apm_install_get_folder() {
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
