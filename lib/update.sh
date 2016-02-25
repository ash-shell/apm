#!/bin/bash

##################################################
# This function updates Ash itself
##################################################
Apm_update_ash() {
    cd $Ash__SOURCE_DIRECTORY

    # Updating
    git pull origin master
    git submodule update

    # Checking for success
    if [ $? -eq 0 ]; then
        Logger__success "Ash was updated"
    else
        Logger__error "Something went wrong, Ash was not updated"
        Logger__error "You will have to manually update at $Ash__SOURCE_DIRECTORY"
    fi
}

##################################################
# This function updates a global module by either
# its package or alias.
#
# @param $1: The alias or package of a module
##################################################
Apm_update_module() {
    local module_name="$1"

    # Expanding alias
    local alias_file="$Ash__SOURCE_DIRECTORY/$Ash__GLOBAL_MODULES_DIRECTORY/$Ash__MODULE_ALIASES_FILE"
    local has_key=$(YamlParse__has_key "$alias_file" "$module_name")
    if [[ "$has_key" == $Ash__TRUE ]]; then
        eval $(YamlParse__parse "$alias_file" "Apm_update_")
        local variable="Apm_update_$module_name"
        module_name=${!variable}
    fi

    # Checking if we're passing a valid global module
    local directory="$Ash__SOURCE_DIRECTORY/$Ash__GLOBAL_MODULES_DIRECTORY/$module_name"
    local directory_config="$directory/$Ash__CONFIG_FILENAME"
    if [[ -f "$directory_config" ]]; then
        Logger__log "Updating $module_name"

        # Updating
        cd "$directory"
        git pull origin master

        # Checking for success
        if [ $? -eq 0 ]; then
            Logger__success "$module_name was updated"
        else
            Logger__error "Something went wrong, $module_name was not updated"
            Logger__error "You will have to manually update at $directory"
        fi
    else
        Logger__error "Module \"$module_name\" does not exist"
    fi
}
