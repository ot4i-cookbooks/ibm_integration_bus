ibm\_integration\_bus\_test Cookbook
=================================
This cookbook is used to test the ibm\_integration\_bus cookbook by using Test Kitchen. See the [TESTING document](../../TESTING.md) at the top level of the ibm\_integration\_bus cookbook for instructions on how to run the tests. This cookbook contains:

* Test recipes
* Test scripts 
* Test helper files

The cookbook includes documentation of what the tests currently do. For instructions on how to write your own tests, please refer to the 'Verifying New Function' section of this document.

How the tests run
-----------------

The tests are described in the following different places:

* The `.kitchen.yml` file that is contained at the top level of the `ibm_integration_bus` cookbook. This specifies a set of "suites", each comprising a run-list and a set of attributes. Note that each suite specifies the minitest-handler cookbook, which is used to execute mini-test test cases after the Chef run.
* Some test suites specify the "iib_nodes" attribute of the cookbook, which specifies the data bag items that are descriptions of integration nodes to be created during the Chef run. These data bag items are kept in `ibm_integration_bus/test/integration/data_bags`.
* All test suites specify a recipe in this cookbook. These recipes are run as part of the Chef run, and in turn call recipes in the ibm\_integration\_bus cookbook to create an installation. After the chef run is complete, the Chef handler for minitest looks for the `<recipe_name>_test.rb` file in the `files/default/tests/minitest` directory of this cookbook, and runs the tests specified in that file.
* All test scripts call helper functions that are contained in the `files/default/tests/minitest/support` directory. These must have a `_helper` suffix. They provide useful common services.

Databags used
-------------

The test data bag items are used to test combinations of attributes that can be used by the ibm\_integration\_bus cookbook. These are contained in `ibm_integration_bus/test/integration/data_bags`. A brief description of each data bag item is as follows:

<table>
	<tr>
		<th>Data Bag Item Name</th>
		<th>Description</th>
	</tr>
	<tr>
	</tr>
	<tr>
		<td>default_config</td>
		<td>A minimal description of an integration node in the default configuration. All properties that have default values are not 
		specified, this should create an integration node identical to
		that created by the default configuration wizard in the toolkit.</td>
	</tr>
	<tr>
		<td>no_servers_express</td>
		<td>Deliberately specify no part of the "executionGroups" section of the JSON document. Create the integration node in express mode. Specify custom Queue Manager listener, Web Admin and HTTP Listener ports for the integration node. Instead of using default properties such as "AdminSecurity", specify the properties explicitly as their defaults.</td>
	</tr>
	<tr>
		<td>standard_secure</td>
		<td>Turn admin security on to check that you can create a secure integration node. Create the integration node in standard mode. Change the ports in case there are clashes. Create the default integration server.</td>
	</tr>
	<tr>
		<td>two_servers_scale</td>
		<td>Check that you can create more than one integration server. Create the integration node in scale mode. Change the ports in case there are clashes.</td>
	</tr>
	<tr>
		<td>web_admin_off</td>
		<td>Check that you can create an integration node with Web Admin turned off. This is harder to verify, but all other potential configuration options are tested with the other data bag items.</td>
	</tr>
</table>

Test Suite descriptions
----------------------

Each test suite is specified in the `.kitchen.yml` file, which specifies a run list and a set of attributes.

The table below summarizes the tests that are executed. Each test checks for the following conditions:

* Verify runtime install exists (Including Websphere MQ and Integration Explorer)
* Verify the Toolkit install does exist (if default recipe is called), or doesn't exist (if runtime recipe is called)
* Verify the OS sysctl values have been set correctly
* Verify all the properties (and appropriate defaults) are set for each integration node that is described in a data bag item
* Verify no other nodes exist (done via command 'mqsilist')

<table>
	<tr>
		<th>Test Suite</th>
		<th>Data Bag Items</th>
		<th>Username</th>
		<th>Recipe</th>
		<th>Notes</th>
	</tr>
	<tr>
	</tr>
	<tr>
		<td>default</td>
		<td>Not specified</td>
		<td>iibuser (default)</td>
		<td>runtime</td>
		<td>Running without the "iib_nodes" attribute creates the default configuration for the IBM Integration Toolkit.</td>
	</tr>
	<tr>
		<td>no_nodes</td>
		<td>None (empty list)</td>
		<td>iibuser (default)</td>
		<td>runtime</td>
		<td></td>
	</tr>
	<tr>
		<td>one_node_one_server</td>
		<td>default_config</td>
		<td>iibuser (default)</td>
		<td>runtime</td>
		<td></td>
	</tr>
	<tr>
		<td>two_nodes</td>
		<td>no_servers_express, two_servers_scale</td>
		<td>iibuser (default)</td>
		<td>runtime</td>
		<td></td>
	</tr>
	<tr>
		<td>admin_security</td>
		<td>standard_secure</td>
		<td>iib2user</td>
		<td>runtime</td>
		<td>With admin security is turned on, you must create a web admin user. su to "iib2user" to run mqsilist checks that the integration bus environment is correctly set up for user.
	</tr>
	<tr>
		<td>no_web_admin_default</td>
		<td>web_admin_off</td>
		<td>iibuser (default)</td>
		<td>default</td>
		<td>Installs the toolkit, so you might require a memory override in the .kitchen.yml file. Verification of the integration node goes as far as checking that we can't connect through REST.</td>
	</tr>
</table>

Helpers
-------

Test helper files are contained in `files/default/tests/minitest/support`, and all have the suffix `_helper` before the file extension.

The helpers should be documented at code level wherever possible. A brief overview is provided here:

<table>
	<tr>
		<th>Helper Name</th>
		<th>Description</th>
	</tr>
	<tr>
	</tr>
	<tr>
		<td>log_helper.rb</td>
		<td>Used for test logging. Currently prints to stdout only, but you can place all log statements through here, in case in the future you would like to redirect to a file.</td>
	</tr>
	<tr>
		<td>process_helper.rb</td>
		<td>Wrapper for certain UNIX commands.</td>
	</tr>
	<tr>
		<td>node_helper.rb</td>
		<td>Wrapper for getting information out of an integration node via the REST interface. Connect by using ip and port, and optional username and password, and you can use to test the Web Admin port value. If information that you require isn't currently exposed, extend node_helper.rb with more methods.</td>
	</tr>
	<tr>
	</tr>
	<tr>
		<td>install_description_helper.rb</td>
		<td>Contains methods for verifying the install by checking whether or not certain commands and directories exist.</td>
	</tr>
	<tr>
		<td>tuning_description_helper.rb</td>
		<td>Contains a method that initiates verification of the sysctl values that are set as part of the Chef client run.</td>
	</tr>
	<tr>
		<td>node_description_helper.rb</td>
		<td>For each data bag item that is used in the tests, there is a method in this file that verifies the state of the integration node that is described. Consider whether previous descriptions can be reused oro extended in this file before adding a new data bag item.</td>
	</tr>
</table>

Verifying New Function
----------------------

First consider whether your new function needs a new test suite, or if you can modify an existing test case, common service, data bag item, or combination of the above, in order to do the required verification, while keeping the test-suites the same. Keeping the test-suites the same usually takes less time to run the tests than creating a new test suite.

For example, if you wanted to be able to set the integration server specific HTTP Listener port, you would have to make changes to the cookbook, and change the format of the JSON document as well. It might be easier to change one of the data bag items, and some of the common services, to verify the changes in one of the existing suites.

If you want to add a new suite, here are the required steps:

* Create a new recipe in the `recipes` directory of this cookbook. From the recipe, call whichever recipes in the ibm\_integration\_bus cookbook that you require.
* Consider whether it would be helpful to extend existing or write new common services as part of your testing effort.
* Write your test-script in `files/default/tests/minitest/<recipe_name>_test.rb`.
* Create a new stanza in the `.kitchen.yml` file, similar to the existing stanzas. Include both the minitest-handler and your new recipe in the run-list, and specify any attributes that your test run requires.
* Run `kitchen list` to check that your new suite exists.
* Run `kitchen converge <new_suite_name>` to run your test.

Verifying New Environments
--------------------------
If you wish to verify the function of the `ibm_integration_bus` cookbook on platforms other than those documented in the top-level [README](../../../README.md) file, you need to build or acquire a vagrant base box for the platform you wish to test on. 

A series of free base boxes can be found [here](http://www.vagrantbox.es/). However, IBM Integration Bus itself may not be supported on all platforms; check its platform support at [IIB system requirements](http://www-01.ibm.com/software/integration/wbimessagebroker/requirements/). The [Bento tool](https://github.com/opscode/bento) can be useful for creating your own base boxes. There is also a link to an article on how to build a base box manually the the top-level [TESTING](../../../TESTING.md) file.

Requirements
------------
This cookbook requires the ibm\_integration\_bus cookbook to run, so it should always be in the directory `ibm_integration_bus/test/cookbooks`. It also requires that the minitest-handler cookbook is run before you run any recipes, in order to run the test cases after the recipes.

Attributes
----------
No attributes are defined for this cookbook.

Usage
-----
Include whichever test case you want to run in your integration node's run list, after the default recipe in the minitest-handler cookbook. An example from the .kitchen.yml file:

```
{
  "run_list": [
    "recipe[minitest-handler]",
    "recipe[ibm_integration_bus_test]"
  ]
}
```

Platforms
---------

The cookbook currently supports:

* Ubuntu 12.04 LTS x86-64
* Red Hat Enterprise Linux (RHEL) Server 6 x86-64

This is because the tests are required to run on the same platforms as the ibm\_integration\_bus cookbook itself.

License and Authors
-------------------
Copyright 2013 IBM Corp. under the [Eclipse Public license](http://www.eclipse.org/legal/epl-v10.html).

* Author:: Imran Shakir <SHAKIMRA@uk.ibm.com>
* Author:: John Reeve <jreeve@uk.ibm.com>
* Author:: Charlotte Nash <charshy_nash@uk.ibm.com>
