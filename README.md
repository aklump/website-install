# Website Install

![install](images/screenshot.jpg)

## Summary

A script to help with installing dependencies and deploying non-versioned files for a website.

**Visit <https://aklump.github.io/install> for full documentation.**

## Quick Start

- Use the following one-liner to install this script.  It should be called from the top directory of the tree above, as indicated in the installation diagram by the `.`
    
        (d="$PWD" && (test -d opt || mkdir opt) && (test -d bin || mkdir bin) && cd opt && cloudy core > /dev/null && (test -d install || (git clone https://github.com/aklump/website-install.git install && rm -rf install/.git)) && (test -s $d/bin/install || ln -s $d/opt/install/install.sh $d/bin/install)) && ./bin/install install

- Open _bin/\_install.yml_ and modify as needed.
- Open _bin/\_install.local.yml_ and ...

## Requirements

You must have [Cloudy](https://github.com/aklump/cloudy) installed on your system to install this package.

## Installation

The installation script above will generate the following structure where `.` is a directory above web root and inside your SCM repository.

    .
    ├── bin
    │   ├── install -> ../opt/install/install.sh
    │   ├── _install.yml
    │   └── _install.local.yml
    └── opt
        ├── cloudy
        └── install

    
### To Update

- Use the following one-liner to update to the latest script version.  It should be called from the top directory of the tree above, as indicated in the diagram by the `.`

        (cd opt && git clone https://github.com/aklump/website-install.git .updating__install && rsync -a --delete --exclude=.git* .updating__install/ install/; rm -rf .updating__install)

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
