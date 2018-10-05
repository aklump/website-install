#!/usr/bin/env bash

#
# @file
# Lorem ipsum dolar sit amet consectador.
#

# Define the configuration file relative to this script.
CONFIG="install.core.yml";

# Uncomment this line to enable file logging.
#LOGFILE="install.log"

# TODO: Event handlers and other functions go here or source another file.

function on_pre_config() {
    [[ "$(get_command)" == "init" ]] && exit_with_init
}

##
 # Install a non-versioned file to it's correct location.
 #
 # @param string $1
 #   The path to the final location.
 # @param string $2
 #   The source path of the preferred file.
 # @param string $3
 #   The source path of the fallback file.
 #
function install_file() {
    local installed_file="$1"
    local preferred_source="$2"
    local fallback_source="$3"
    local source
    echo "$LI $installed_file"

    if ! test -f $installed_file; then
        write_log_notice "Installing missing file: $installed_file."
        if test -f "$preferred_source"; then
            write_log_info "Using preferred source: $preferred_source"
            cp "$preferred_source" "$installed_file"
            [ $? -ne 0 ] && fail_because "Could not copy $preferred_source to $installed_file" && return 1
            source="$preferred_source"
        elif ! test -e "$fallback_source"; then
            fail_because "Missing required file: $fallback_source" && return 1
        else
            write_log_info "Using fallback source: $fallback_source"
            cp "$fallback_source" "$installed_file"
            [ $? -ne 0 ] && fail_because "Could not copy $fallback_source to $installed_file" && return 1
            source="$fallback_source"
        fi
        echo "$LIL2 $(echo_green "Copied from") $source" && return 0
    else
        echo "$LIL2 Found." && return 0
    fi
}

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";source "$r/../../cloudy/cloudy/cloudy.sh";[[ "$ROOT" != "$r" ]] && echo "$(tput setaf 7)$(tput setab 1)Bootstrap failure, cannot load cloudy.sh$(tput sgr0)" && exit 1
# End Cloudy Bootstrap

# Input validation.
validate_input || exit_with_failure "Input validation failed."

implement_cloudy_basic


#
# Load configuration.
#
eval $(get_config "drush" $(get_installed "drush"))
exit_with_failure_if_empty_config "drush"
is_installed $drush || fail_because "Drush is not installed at \"$drush\"."

eval $(get_config "composer" $(get_installed "composer"))
exit_with_failure_if_empty_config "composer"
is_installed $composer || fail_because "Composer is not installed at \"$composer\"."

has_failed && exit_with_failure

eval $(get_config_path "master_dir")
exit_with_failure_if_config_is_not_path "master_dir"
eval $(get_config -a "master_files")
eval $(get_config_path -a "installed_files")

eval $(get_config "composer_self_update" false)
eval $(get_config "drupal_config_import" false)
eval $(get_config "use_sudo" false)

[ ${#master_files[@]} -ne ${#installed_files[@]} ] && exit_with_failure "Configuration problem.  The number of items in \"master_files\" must equal the number of items in \"installed_files\"."

command=$(get_command)
case $command in
info)
    echo_heading "Settings Info"
    table_clear
    table_set_header "setting" "value"
    table_add_row "Composer self-update" "$composer_self_update"
    table_add_row "Drush config import" "$drupal_config_import"
    table_add_row "Use sudo for permissions" "$use_sudo"
    echo_slim_table
    exit_with_success "Configuration okay."
   ;;
esac


#
# Process for an environment
#

ROLE=$command || exit_with_failure "Call with: prod, dev, or staging."

# If the files are not found by environment then we use dev, which is created at the beginning of local development.
echo_heading "Checking non-versioned files..."
index=0
for master_file in "${master_files[@]}"; do
    master_file=${master_dir}/${master_file/__ROLE/$ROLE}
    master_fallback=${master_dir}/${master_fallback/__ROLE/dev}
    installed_file=${installed_files[$i]}
    installed_file=${installed_file/__ROLE/$ROLE}
    install_file "$installed_file" "$master_file" "$master_fallback" || exit_with_failure
    let index++
done
echo "$LIL $(echo_green Done.)"

## Apply perms.
if [[ "$use_sudo" == true ]]; then
    sudo $ROOT/perms.sh apply
else
    $ROOT/perms.sh apply
fi

# Developers should manage their local Composer installation.
if [[ "$composer_self_update" == true ]]; then
    echo_heading "Running Composer self update."
    $composer self-update || fail_because "Composer self-update failed."
fi

# Install composer dependencies.
echo_heading "Installing dependencies with Composer..."
[ "$ROLE" == "prod" ] && composer_flag="--no-dev"
cd "$project_root" && $composer -v install $composer_flag || fail_because "Composer install failed."

# Update configuration management, except on dev, where it should be handled by the developer.

if [[ "$drupal_config_import" == true ]; then
    echo_heading "Importing Drupal configuration"
    $drush config-import -y || fail_because "Drush config-import failed"
fi

echo_heading "Rebuilding Drupal cache..."
$drush rebuild || fail_because "Could not rebuild Drupal cache."

has_failed && exit_with_failure
exit_with_success_elapsed
