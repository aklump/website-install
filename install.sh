#!/usr/bin/env bash

#
# @file
# Controller for the install project.
#

# Define the configuration file relative to this script.
CONFIG="install.core.yml"

# Uncomment this line to enable file logging.
#LOGFILE="install.log"

function on_pre_config() {
  [[ "$(get_command)" == "init" ]] && exit_with_init
}

function on_execute_scripts() {
  local name="$1"

  local status
  eval $(get_config_as -a items "scripts.$name")
  if [[ "${#items[@]}" -gt 0 ]]; then
    for item in "${items[@]}"; do
      list_add_item "$item"
      if [[ -f $item ]]; then
        (cd "$APP_ROOT" && . "$item")
        status=$?
      else
        (cd "$APP_ROOT" && eval "$item")
        status=$?
      fi
      if [ $status -ne 0 ]; then
        fail_because "Script exited with $status for: \"$item\"."
        fail_because "$output"
        exit_with_failure
      fi
    done
  fi
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

  if ! test -f $installed_file; then
    mkdir -p "$(dirname "$installed_file")"
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
    list_add_item "$(path_unresolve "$APP_ROOT" "$installed_file") ... $(echo_green "[Copied from $(path_unresolve "$APP_ROOT" "$source")]")"
  else
    list_add_item "$(path_unresolve "$APP_ROOT" "$installed_file") ... $(echo_green "[Already present]")"
  fi
  return 0
}

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";source "$r/../../cloudy/cloudy/cloudy.sh";[[ "$ROOT" != "$r" ]] && echo "$(tput setaf 7)$(tput setab 1)Bootstrap failure, cannot load cloudy.sh$(tput sgr0)" && exit 1
# End Cloudy Bootstrap

# Input validation.
validate_input || exit_with_failure "Input validation failed."

implement_cloudy_basic

# Import configuration as variables.
eval $(get_config_path -a "path_to")
eval $(get_config_keys_as "path_to_keys" "path_to")

# Validate all path_to keys as actual paths.
for key in "${path_to_keys[@]}"; do
  exit_with_failure_if_config_is_not_path "path_to.$key"
done

#
# Load configuration.
#
has_failed && exit_with_failure

eval $(get_config_path "master_dir")
exit_with_failure_if_config_is_not_path "master_dir"
eval $(get_config -a "master_files")
eval $(get_config_path -a "installed_files")

[ ${#master_files[@]} -ne ${#installed_files[@]} ] && exit_with_failure "Configuration problem.  The number of items in \"master_files\" must equal the number of items in \"installed_files\"."

command=$(get_command)

#
# Process for an environment
#

ROLE=$command || exit_with_failure "Call with: prod, dev, or staging."

echo_title "Installation environment: $ROLE"

list_clear
echo_heading "Handling early scripts"
event_dispatch "execute_scripts" "pre_install"
event_dispatch "execute_scripts" "pre_install_$ROLE"
has_option verbose && echo_list && echo

echo_heading "Ensuring non-SCM files are in place"
index=0
list_clear
for file in "${master_files[@]}"; do
  # If the files are not found by environment then we use dev, which is created at
  # the beginning of local development.
  master_fallback=${master_dir}/${file/__ROLE/dev}
  master_file=${master_dir}/${file/__ROLE/$ROLE}
  installed_file=${installed_files[$index]}
  installed_file=${installed_file/__ROLE/$ROLE}
  install_file "$installed_file" "$master_file" "$master_fallback" || exit_with_failure
  let index++
done
has_option verbose && echo_list && echo
has_failed && exit_with_failure

list_clear
echo_heading "Handling late scripts"
event_dispatch "execute_scripts" "post_install"
event_dispatch "execute_scripts" "post_install_$ROLE"
has_option verbose && echo_list && echo

has_failed && exit_with_failure
exit_with_success_elapsed
