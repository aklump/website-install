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
    [[ "$(get_command)" == "init" ]] && exit_with_install
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

# TODO: Event handlers and other functions go here or source another file.

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";source "$r/../../cloudy/cloudy/cloudy.sh";[[ "$ROOT" != "$r" ]] && echo "$(tput setaf 7)$(tput setab 1)Bootstrap failure, cannot load cloudy.sh$(tput sgr0)" && exit 1
# End Cloudy Bootstrap

# Input validation.
validate_input || exit_with_failure "Input validation failed."

implement_cloudy_basic

#
# Process the installation
#
eval $(get_config "drush")
exit_with_failure_if_empty_config "drush"
eval $(get_config "composer")
exit_with_failure_if_empty_config "composer"

project_root="$(cd -P "$ROOT/.." && pwd)"
web_root="$(cd -P "$ROOT/../web" && pwd)"
install_assets="$(cd -P "$ROOT/../install/default" && pwd)"
drupal_env_role=$(get_command)  || exit_with_failure "Call with: prod, dev, or staging."

# If the files are not found by environment then we use dev, which is created at the beginning of local development.
echo_headline "Checking non-versioned files..."

# FINAL, SOURCE, FALLBACK SOURCE
install_file "$ROOT/install.local.yml" "$install_assets/_install.$drupal_env_role.yml" "$install_assets/_install.dev.yml" || exit_with_failure
install_file "$ROOT/_config.local.php" "$install_assets/_config.$drupal_env_role.php" "$install_assets/_config.dev.php" || exit_with_failure
install_file "$ROOT/_perms.local.yml" "$install_assets/_perms.$drupal_env_role.yml" "$install_assets/_perms.dev.yml" || exit_with_failure
install_file "$web_root/.htaccess" "$install_assets/.htaccess.$drupal_env_role" "$install_assets/.htaccess.dev" || exit_with_failure
install_file "$web_root/sites/default/settings.env.php" "$install_assets/settings.env.$drupal_env_role.php" "$install_assets/settings.env.dev.php" || exit_with_failure
install_file "$web_root/sites/default/settings.local.php" "$install_assets/settings.local.$drupal_env_role.php" "$install_assets/settings.local.dev.php" || exit_with_failure
echo "$LIL $(echo_green Done.)"

## Apply perms.
if [[ "$(get_config use_sudo)" == true ]]; then
    sudo $ROOT/perms.sh apply
else
    $ROOT/perms.sh apply
fi

# Update to the latest composer version.
if [ "$drupal_env_role" == "prod" ]; then
    composer_flag="--no-dev"
fi

# Developers should manage their local Composer installation.
if [ "$drupal_env_role" != 'dev' ]; then
    $composer self-update || fail_because "Composer self-update failed."
fi

# Install composer dependencies.
echo_headline "Installing dependencies with Composer..."
cd "$project_root" && $composer -v install $composer_flag || fail_because "Composer install failed."

# Update configuration management, except on dev, where it should be handled by the developer.
if [ "$drupal_env_role" != 'dev' ]; then
    echo_headline "Importing Drupal configuration"
    $drush config-import -y || fail_because "Drush config-import failed"
fi

echo_headline "Rebuilding Drupal cache..."
$drush rebuild || fail_because "Could not rebuild Drupal cache."

has_failed && exit_with_failure
exit_with_success_elapsed
