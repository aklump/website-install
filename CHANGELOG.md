# Changelog

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
