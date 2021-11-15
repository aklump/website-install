# Changelog

## [1.6.0] - 2021-11-15

1. After upgrading run `./bin/install init` in each installed environment, this will create _bin/config/install.local.yml_ for that environement.
2. Open _install.local.yml_ and update the value for `environment` as appropriate.
3. Continue using as before, omitting the script argument.

### Added

- You must add `environment: ENV` in _bin/config/install.local.yml_ instead of providing it to the script. Do not commit _install.local.yml_ to version control.

### Changed

- How local environment is identified.

### Removed

- Environment as a command argument. Instead of calling `./bin/install dev`, you now just call `./bin/install` after having added `environment: dev` to _bin/config/install.local.yml_.

## [1.5.0] - 2019-09-19

### Removed

- Automatic `composer self-update` (use `scripts` instead)
- Automatic `composer update`
- Automatic `drush config-import`
- Certain config options removed; you may delete from _install.local.yml_:
    - `path_to.web_root`
    - `path_to.composer`
    - `drush`
    - `composer`
    - `composer_self_update`
    - `drupal_config_import`

## [1.4.0] - 2019-09-18

### Removed

- Automatic drupal cache clear. To achieve this functionality you should now use `scripts`

        scripts:
          post_install:
            - cd web && drush cr

## [1.3.0] - 2019-09-18

### Changed

- If you wish to run the permission script as part of an installation then you should use the new `scripts` option. Add the following to your configuration to achieve the previous built-in functionality.

        scripts:
          post_install:
            - sudo ./bin/perms apply

### Removed

- The `use_sudo` option.
- Built in integration with [Website Permissions](https://github.com/aklump/website-perms)

## [1.1.0]

- To manage Composer dependencies you must add the `path_to.composer` value. See _init/install.yml_ for an example.
