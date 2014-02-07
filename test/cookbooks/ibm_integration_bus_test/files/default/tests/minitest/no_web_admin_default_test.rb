################################################################################
#
# Copyright (c) 2013 IBM Corporation and other Contributors
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#     IBM - initial implementation
#
#################################################################################

require 'minitest/spec'

require File.expand_path('../support/node_helper.rb', __FILE__)
require File.expand_path('../support/tuning_description_helper.rb', __FILE__)
require File.expand_path('../support/install_description_helper.rb', __FILE__)
require File.expand_path('../support/log_helper.rb', __FILE__)

describe_recipe 'ibm_integration_bus::runtime' do
	
	describe 'the os tuning' do
		
		it 'appropriately sets sysctl values' do
			verify_sysctl_values
		end
		
	end
	
	describe 'the install' do
	
		it 'installs runtime components' do
			verify_runtime_install
		end
		
		it 'installs toolkit components' do
			verify_toolkit_install
		end
	
	end
	
	describe 'the node setup' do
		
		it 'creates no other nodes' do
			nodes_on_machine_are(["WAONODE"])
		end
		
		it 'isnt accessible through webadmin' do
			
			assert(
				!IBNode.new("localhost", 4419).is_web_admin_enabled,
				"ERROR: Able to access node through web admin, but it should be disabled!"
			)
			
			IBLogger.instance.log("SUCCESS! Failed to connect to Integration Node, as Web Admin is (correctly) disabled")
			
		end
	
	end
	
end