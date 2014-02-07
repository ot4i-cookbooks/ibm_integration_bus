FAQ for the `ibm_integration_bus` cookbook
==========================================
##Questions:
[Can I run the `ibm_integration_bus` recipes on a machine that already has IIB installed?](#Q1)

[Can the `ibm_integration_bus` recipes be used to install other editions of IIB other than the Developer's edition?](#Q2)

[Do the `ibm_integration_bus` recipes work on Red Hat Enterprise Linux (RHEL) 5?](#Q2)

[How do I install Ruby for running chef-solo and test-kitchen?](#Q4)

[Why does running test-kitchen give me an error "Timeout on booting machine"?](#Q5)
    
------------------------------------------
##Answers:
<a name="Q1">Can I run the `ibm_integration_bus` recipes on a machine that already has IIB installed?</a>

Yes, but it is not recommended at the moment. The chef recipes will remove any installs in the standard install location (`/opt/ibm/mqsi`) and then re-install all the required software. The recipes will attempt to stop the default queue manager and node but not any other nodes running on the machine therefore, before rerunning the recipe, it is important to ensure any other IIB nodes and queue managers are stopped. 


<a name="Q2">Can the `ibm_integration_bus` recipes be used to install other editions of IIB other than the Developer's edition?</a>

The current version can install only IBM Integration Bus for Developers. However, this limitation exists only because the installation package for other editions contains .tar files that have a slightly different structure. Support for other editions will be added in the future.


<a name="Q3">Do the `ibm_integration_bus` recipes work on Red Hat Enterprise Linux (RHEL) 5?</a>

The recipes have not been tested on RHEL 5 but there is no reason why they should not work. 


<a name="Q4">How do I install Ruby for running chef-solo and test-kitchen?</a>

Windows: 

1. Install [ruby](http://rubyinstaller.org/) from [here](http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-1.9.3-p484.exe?direct)
2. Get Devkit from [here](https://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe). Run the executable to install.
3. Change into the devkit install directory
4. Run `ruby dk.rb init` to generate the config.yml file
5. Run `ruby dk.rb install`

Ubuntu: 

1. Install curl, if you don't already have it `sudo apt-get install curl`
2. Install [rvm](https://rvm.io/rvm/install), follow the instructions for "Install RVM (development edition)"
3. Restart the terminal and run `rvm install 1.9.3`
4. Add the following lines to the `.bashrc` file in your users home directory. These set the version of ruby to 1.9.3 when you create a terminal:

`source ~/.rvm/scripts/rvm`

`type rvm | head -n 1`

`rvm use 1.9.3`

Finally install the ruby dev kit:

`apt-get install ruby1.9.1-dev`

<a name="Q5">Why does running test-kitchen give me an error "Timeout on booting machine"?</a>

This has known to be caused by a BIOS setting. Enabling the setting from "Intel VT-x/EPT or AMD-V/RVI" should remove this issue.