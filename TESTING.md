Testing
-------

The IBM Integration Bus cookbook supports tests through [Test Kitchen](http://kitchen.ci) and [minitest-chef-handler](https://github.com/calavera/minitest-chef-handler). Documentation on how this works, and individual test descriptions are contained in the ibm\_integation\_bus\_test cookbook [README file](./test/cookbooks/ibm_integration_bus_test/README.md)

To run these tests, you must download and install the following prerequisites:

* [Ruby](https://www.ruby-lang.org/en/) (Version 1.9.3 was used for development on Windows and Ubuntu)
* [Vagrant](https://downloads.vagrantup.com/tags/v1.3.5) (Version 1.3.5 was used for development on Windows and Ubuntu)
* [VirtualBox](https://www.virtualbox.org/wiki/Download_Old_Builds_4_1) (On Linux, installing via apt-get works giving version 4.1.12 at time of writing, on Windows install via the downloads page, version 4.1.18 was used for development)

After you install the prerequisites, you must install the vagrant berkshelf plugin:

	vagrant plugin install vagrant-berkshelf

and finally you must install Test Kitchen 1.x, and kitchen-vagrant:

	gem install berkshelf -v 2.0.10 (Windows) 
	gem install berkshelf -v 2.0.13 (Ubuntu) 
	gem install test-kitchen -v 1.0.0
	gem install kitchen-vagrant -v 0.12.0

These both have optional version options to indicate the versions that were used for development.

If you follow the instructions below, the tests will run using Ubuntu 12.04 as the target platform, which is the test-kitchen default. To test on other target platforms, see the notes at the bottom of this page.

To run the tests:

1. Clone the repository (if you aren't already reading these instructions for your local copy of the cookbook!):

		git clone git://github.com/ot4i-cookbooks/ibm_integration_bus

2. Download the latest version of IBM Integration Bus for Developers from [the website](https://www14.software.ibm.com/webapp/iwm/web/signup.do?source=swg-wmbfd&S_TACT=109KA7GW&S_CMP=web_opp_ibm_ws_appint_integrationbus&lang=en_US&S_PKG=dk), and place it in a new directory. For example, I created "C:\ChefCache".

3. Navigate to the root directory of the cookbook:

		cd ibm_integration_bus

4. Edit the "synced_folders" element in the *.kitchen.yml* file, so that the folder that contains your IBM Integration Bus image is available within the virtual machines that are used to run the tests. Edit the first element of the inner array. For example, in my case:

		
		platforms:
		- name: ubuntu-12.04
  		  driver_config:
    	    box: opscode-ubuntu-12.04
    	    box_url: https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box
      	    synced_folders: [ [ "C:/ChefCache", "/mnt/shared" ] ]
		

5. Run:

		kitchen test

If you are having issues with any of this, or the kitchen run appears to fail try reading the [FAQ](./FAQ.md) as it contains some troubleshooting advice.

Notes on running the tests
--------------------------

1. Using VirtualBox synced folders isn't required for running the tests. Alternatively, you can use a HTTP or FTP Server to host the image, as described in the cookbook readme file. Remove the "synced_folders" element from the *.kitchen.yml* file, and for each test case that you want to execute replace the *package\_site\_url* value with the location of your image. For example, the platform element:

		
		- name: ubuntu-12.04
  		  driver_config:
    	    box: opscode-ubuntu-12.04
    	    box_url: https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box
    
	And the suite element:

		- name: default
  		  run_list:
    	    - recipe[minitest-handler]
    	    - recipe[ibm_integration_bus_test]
  		  attributes: {
    	    "ibm_integration_bus": {
      	      "package_site_url": "ftp://my.ftp.server/iib"
    	    }
  		  }

	When I ran the default test by using synced folders, it took 16 minutes. Running the same test by hosting the image on an FTP site took 20 minutes on a fast connection. You might find it faster to use synced folders to run your tests, because otherwise the time required to run includes downloading 3GB + ~15 minutes. 

2. By default a memory size override is set for each platform that the tests are run on. Setting this to 2GB produces stable results without consuming too much of the host's resources. Observe this in the *.kitchen.yml* file:
 
		platforms:
		- name: ubuntu-12.04
  		  driver_config:
    	    box: opscode-ubuntu-12.04
    	    box_url: https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box
      	    synced_folders: [ [ "C:/ChefCache", "/mnt/shared" ] ]
		    customize:
		      memory: 2048

	Before running any tests ensure that your host operating system can afford the loss of resource. The toolkit installation recommends 4GB so consider changing this value when running the final test *no\_web\_admin\_default*.

	For running any of the tests, it is worth configuring the specifications of your virtual machine as high as you can afford!

3. The cookbook supports RedHat 6, and as such the tests were executed on that platform. We do not provide a vagrant base-box for RedHat, but if you want to test on this platform, you can build a vagrant base box. You need a license to use a RedHat 6 ISO image, and there are numerous useful tutorials online to help your base box. I used [this one](http://pyfunc.blogspot.com/2011/11/creating-base-box-from-scratch-for.html).


What tests exist?
-----------------

See the ibm\_integration\_bus_test cookbook's [README file](./test/cookbooks/ibm_integration_bus_test/README.md) for descriptions of the test cases and example data bag items used in testing.

How do I extend the tests to verify my changes?
-----------------------------------------------

See the "Verifying New Function" section of the ibm\_integration\_bus_test cookbook's [README file](./test/cookbooks/ibm_integration_bus_test/README.md)
