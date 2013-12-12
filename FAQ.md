FAQ for the `ibm_integration_bus` cookbook
==========================================
##Questions:
[Can I run the `ibm_integration_bus` recipes on a machine that already has IIB installed?](#Q1)

[Can the `ibm_integration_bus` recipes be used to install other editions of IIB other than the Developer's edition?](#Q2)

[Do the `ibm_integration_bus` recipes work on Red Hat Enterprise Linux (RHEL) 5?](#Q2)
    
------------------------------------------
##Answers:
<a name="Q1">Can I run the `ibm_integration_bus` recipes on a machine that already has IIB installed?</a>

Yes, but it is not recommended at the moment. The chef recipes will remove any installs in the standard install location (`/opt/ibm/mqsi`) and then re-install all the required software. The recipes will attempt to stop the default queue manager and node but not any other nodes running on the machine therefore, before rerunning the recipe, it is important to ensure any other IIB nodes and queue managers are stopped. 


<a name="Q2">Can the `ibm_integration_bus` recipes be used to install other editions of IIB other than the Developer's edition?</a>

The current version can install only IBM Integration Bus for Developers. However, this limitation exists only because the installation package for other editions contains .tar files that have a slightly different structure. Support for other editions will be added in the future.


<a name="Q3">Do the `ibm_integration_bus` recipes work on Red Hat Enterprise Linux (RHEL) 5?</a>

The recipes have not been tested on RHEL 5 but there is no reason why they should not work. 



