# Website Install

![install](images/screenshot.jpg)

## Summary

A script to help with installing dependencies and deploying non-versioned files for a website.

A Drupal website has files that do not end up in version control: _.htaccess, settings.local.php_, etc.  This script provides a means of putting those in source control by storing environment-specific versions of them in a directory and then copying the appropriate version to it's runtime location.

If you are using Composer to manage dependencies, this script will run `composer install` or `composer install --no-dev` as appropriate for the environment.

**Visit <https://aklump.github.io/website-install> for full documentation.**

## Quick Start

- Install in your repository root using `cloudy pm-install aklump/install`
- Open _bin/config/install.yml_ and make your configuration.
- Make sure to SCM ignore _config/*.local.yml_ files.
- Open _bin/config/install.local.yml_ and ...

## Requirements

You must have [Cloudy](https://github.com/aklump/cloudy) installed on your system to install this package.

## Installation

The installation script above will generate the following structure where `.` is your repository root.

    .
    ├── bin
    │   ├── install -> ../opt/install/install.sh
    │   └── config
    │       ├── install.yml
    │       └── install.local.yml
    ├── opt
    │   ├── cloudy
    │   └── aklump
    │       └── install
    └── {public web root}

    
### To Update

- Update to the latest version from your repo root: `cloudy pm-update aklump/install`

## Configuration Files

| Filename | Description | VCS |
|----------|----------|---|
| _install.yml_ | Configuration shared across all server environments: prod, staging, dev  | yes |
| _install.local.yml_ | Configuration overrides for a single environment; not version controlled. | no |

### Custom Configuration

The basic configuration in _install.yml_ consists of two lists.  The master files and the destination paths.  Notice the use of the token `__ROLE`, which will be substituted for the role.

    master_dir: install/default
    master_files:
        - install.__ROLE.yml
    installed_files:
        - bin/config/install.local.yml

Environment specific options can be set in _install.local.yml_:

| option | description |
|----------|----------|
| use_sudo | Set to `true` to execute permissions with `sudo`. |
| composer_self_update | Set to true to run `composer self-update`, should be false on production environments, generally. |
| drupal_config_import | Set to true to automatically run `drush config import` |
| drush | (optional) Path to the Drush command |
| composer | (optional) Path to the composer command |

Optional configuration, e.g., 

    drush: /Users/aklump/.composer/vendor/bin/drush
    composer: /Users/aklump/bin/composer

## Scripts

You may run specific bash commands before or after installation, for all or a given environment.  Use the script configuration, see _install.yml_ for how this works.  This example runs three commands before installing in the dev environment.  Each must return 0.  Each runs in a subshell.
    
        ...
        scripts:
          pre_install_dev:
            - mkdir -p web/modules/dev
            - rm web/modules/dev/se_dev || return 0
            - cd web/modules/dev/ && ln -s ../../../install/default/modules/se_dev .    

Alternately, you could point to files to be run instead.

        ...
        scripts:
          pre_install_dev:
            - install/scripts/before.sh
            - install/scripts/before.php
            
## Usage

In the example above we would expect to find the following in source control:

    .
    ├── bin
    │   └── config
    └── install
        └── default
            ├── install.dev.yml
            ├── install.prod.yml
            └── install.staging.yml

When we ran this script with `prod` then we would have the following, where _bin/config/install.local.yml_ is a copy of _install/default/install.prod.yml_.

    .
    ├── bin
    │   └── config
    │       └── install.local.yml
    └── install
        └── default
            ├── install.dev.yml
            ├── install.prod.yml
            └── install.staging.yml


* To see all commands use `./bin/install help`

## Contributing

If you find this project useful... please consider [making a donation](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4E5KZHDQCEUV8&item_name=Gratitude%20for%20aklump%2Fwebsite-install).
