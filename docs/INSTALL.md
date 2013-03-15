
# Short installation procedure


As root:

```
    gem install nagira
    nagira-setup config:test:install
    nagira-setup config:all
    nagira-setup config:test:prod
```    


More detailed description of installation procedure below.


# Install from gem

Starting from version 0.2.2 Nagira is packaged as Ruby Gem with simplified installation procedure as well as run time commands. If you are using Nagira version pre-0.2.2, or are not using it as a gem please refer to {file:INSTALL_pre0.2.2.md older installation instructions}.


## Installation procedure


### Install gem

Install gem as `root` user or using sudo command. If your Ruby was installed by RVM please make sure to use `-i` sudo option:

    [sudo -i] gem install nagira
    
#### Test installation

Use `nagira-setup` script for testing. Run following command to test installation.

```
    nagira-setup config:test:install
```    

This command will try to parse known to work files included with the distribution. If there are any errors reported by this test, something is not right with the installation. Please try to rectify these errors before going further.

#### Run application

You can run Nagira service form command line: `nagira` This starts Nagira application in foreground with log output to `STDOUT`. 

If you intend to run Nagira as system service, read further.
    
### Create start-up files

This will put start-up files for Nagira in `/etc` directory. 

Nagira start-up files are tested only on Linux, they will probably work on other UNIX'es with minimal changes. Currently supported distros are RedHat, Debian and their derivatives like CentOS and Ubuntu. 

Helper script `nagira-setup` assists in creating and placing config files into correct location.

These files are `/etc/init.d/nagira` start-up file and defaults file. Location of defaults file depends on type of the Linux distribution. It is `/etc/sysconfig` for RedHat type distros and `/etc/default` for Debian and Ubuntu.


#### Nagira-setup command

    sudo -i nagira-setup [task]

**Note** Running `nagira-setup` without any command line options produces list of tasks with help message.

Following tasks are included with nagira-setup:

```
    nagira-setup config:all           # Create Nagira configuration, allow start on boot and start it
    nagira-setup config:chkconfig     # Configure Nagira to start on system boot
    nagira-setup config:config        # Create configuration for Nagira in /etc
    nagira-setup config:start         # Start Nagira API service
    nagira-setup config:test:install  # Test Nagira installation: test Nagios files and parse
    nagira-setup config:test:prod     # Test Nagira production config: Nagios files in proper locations adn parseable
    nagira-setup doc:yard             # Generate YARD documentation
```

For single step configuration run `nagira-setup config:all`. This task combines following ones:

- **config:config** -- Create configuration for Nagira in /etc. This will copy `init.d` start up file and defaults file into proper locations.    
- **config:chkconfig** -- Enable Nagira service to start on system boot  
- **config:start** -- Starts Nagira API service


#### Configuration file

Run-time configuration variables can be adjusted by editing *defaults* file:

- RedHat Linux : `/etc/sysconfig/nagira`
- Debian Linux : `/etc/default/nagira`

After editing *defaults* you need to restart Nagira.


## See also

* See more on {file:CONFIGURATION.rdoc}

* If you are getting malformed XML errors, please look at
  {file:nagios_objects.rdoc}
