# Website Install

![install](images/screenshot.jpg)

## Summary

A script to help with installing dependencies and deploying non-versioned files for a website.

**Visit <https://aklump.github.io/website-install> for full documentation.**

## Quick Start

- Install in your repository root using `cloudy pm-install aklump/install`
- Open _bin/\_install.yml_ and modify as needed.
- Open _bin/\_install.local.yml_ and ...

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
| _\_install.yml_ | Configuration shared across all server environments: prod, staging, dev  | yes |
| _\_install.local.yml_ | Configuration overrides for a single environment; not version controlled. | no |

### Custom Configuration

* lorem
* ipsum

## Usage

* To see all commands use `./bin/install help`

## Contributing

If you find this project useful... please consider [making a donation](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4E5KZHDQCEUV8&item_name=Gratitude%20for%20aklump%2Fwebsite-install).
