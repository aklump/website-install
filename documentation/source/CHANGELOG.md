# Changelog

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
- Automatic drupal cache clear.  To achieve this functionality you should now use `scripts`

        scripts:
          post_install:
            - cd web && drush cr
  
## [1.3.0] - 2019-09-18
  
### Changed
- If you wish to run the permission script as part of an installation then you should use the new `scripts` option.  Add the following to your configuration to achieve the previous built-in functionality.

        scripts:
          post_install:
            - sudo ./bin/perms apply
  
### Removed
- The `use_sudo` option.
- Built in integration with [Website Permissions](https://github.com/aklump/website-perms)
  
## [1.1.0]

- To manage Composer dependencies you must add the `path_to.composer` value.  See _init/install.yml_ for an example.
