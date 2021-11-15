# Website Install

![install](images/screenshot.jpg)

## Summary

* Wraps repeated and multiple deployment tasks into one, convenient command.
* Simplifies the management of non-versioned files (settings, composer dependencies, etc.) for the different website environments, dev, staging, prod.
* Consists of two elements: scripts and files.
* May be executed as often as you like, as it simple ensures that everything is updated and in place.

### Scripts

The configuration allows you to setup commands or scripts to run per environment so that when for example, you call `install dev`, the development scripts only will fire. As a suggestion, only include scripts and commands that support the aim of this project, that is to put files and state in place so that your website is ready. You can use these to do things like:

```bash
drush cr
composer install
drush config-import
drush updb
./bin/perms apply
git pull
```

If you are using Composer to manage dependencies, you can add the appropriate `composer install` command to the `scripts` configuration and then calling `install <role>` will grab the dependencies as well. You might do something like this so that production does not get dev dependencies.

```yaml
scripts:
  post_install_staging:
    - composer install --no-dev
  post_install_prod:
    - composer install --no-dev
  post_install_dev:
    - composer install        
```

#### Configuration

In _install.yml_ are the script definitions. You may run specific bash commands before or after installation, for all or a given environment. Use the script configuration, see _install.yml_ for how this works. This example runs three commands before installing in the dev environment. Each line must return 0 or installation will fail. Each line runs in a separate subshell having `$APP_ROOT` as the working directory.

```yaml
scripts:
  pre_install_dev:
    - mkdir -p web/modules/dev
    - rm web/modules/dev/se_dev || return 0
    - cd web/modules/dev/ && ln -s ../../../install/default/modules/se_dev .    
```

Alternately, you could point to files to be run instead. Each file must exit with 0 or installation will fail. Each file runs in a separate subshell having `$APP_ROOT` as the working directory.

```yaml
scripts:
  pre_install_dev:
    - install/scripts/before.sh
    - install/scripts/before.php
```

### Files

The files element gives you the ability to define environment-specific files, which are then copied to the correct location when running `install <role>`. For example, a Drupal website has files that do not end up in version control: _.htaccess, settings.local.php_, etc. This project provides a means of putting those in source control by storing environment-specific versions of them in a directory and then copying the appropriate version to it's runtime location.

If a file already exists in it's runtime location, nothing happens, but if it's missing then the file is copied from the appropriate environment source.

#### Configuration

The basic configuration in _install.yml_ consists of two lists. The master files and the destination paths. Notice the use of the token `__ROLE`, which will be substituted for the role. You must have the same number of items in each list.

```yaml
master_dir: install/default
master_files:
    - install.__ROLE.yml
installed_files:
    - bin/config/install.local.yml
```

**Visit <https://aklump.github.io/website-install> for full documentation.**

## Quick Start

- Install in your repository root using `cloudy pm-install aklump/install`.
- Create your `master_dir` to hold your source files, e.g. _install/default/_.
- Place source files in this folder.
- Open _bin/config/install.local.yml_ and define your environment; do not add this file to source control.
- Open _bin/config/install.yml_ and map your files.
- Define any scripts that you would like to associate with an environment.

## Requirements

You must have [Cloudy](https://github.com/aklump/cloudy) installed on your system to install this package.

## Installation

The installation script above will generate the following structure where `.` is your repository root.

```text
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
```

### To Update

- Update to the latest version from your repo root: `cloudy pm-update aklump/install`

## Configuration Files

| Filename | Description | VCS |
|----------|----------|---|
| _install.local.yml_ | Defines the local environment  | no |
| _install.yml_ | Configuration shared across all server environments: prod, staging, dev  | yes |

## Usage

In the example above we would expect to find the following in source control:

```text
.
├── bin
│   └── config
└── install
    └── default
        ├── install.dev.yml
        ├── install.prod.yml
        └── install.staging.yml

When we ran this script with `prod` then we would have the following, where _bin/config/install.local.yml_ is a copy of _install/default/install.prod.yml_.
```

```text
.
├── bin
│   └── config
│       └── install.local.yml
└── install
    └── default
        ├── install.dev.yml
        ├── install.prod.yml
        └── install.staging.yml
```

* To see all commands use `./bin/install help`

## Contributing

If you find this project useful... please consider [making a donation](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4E5KZHDQCEUV8&item_name=Gratitude%20for%20aklump%2Fwebsite-install).
