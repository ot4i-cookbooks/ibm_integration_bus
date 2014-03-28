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

include MiniTest::Chef::Assertions

require File.expand_path('../process_helper.rb', __FILE__)

# Briefly check that some of the main components of the relevant
# installs exist. We're not going to start poking around inside
# these directories - we're not testing the installers!
def verify_runtime_install()
	
	# Check MQ install exists
	assert(
		File.directory?("/opt/mqm"),
		"ERROR: MQ install directory doesn't exist"
	)
	
	# Check IBExplorer directory exists
	assert(
		File.directory?("/opt/IBM/IBExplorer"),
		"ERROR: IBExplorer install directory doesn't exist"
	)
	
	# Check Integration Bus install directory exists
	assert(
		File.directory?("/opt/ibm/mqsi/9.0"),
		"ERROR: Integration Bus install directory doesn't exist in expected location"
	)
	
end

# Quick check the toolkit isn't findable on the system. No 
# install directory and mqsicreatebar isn't on PATH (or system)
def verify_no_toolkit_install(username = "iibuser")

	# Check the install directory hasn't been created
	assert(
		!File.exists?("/opt/IBM/IntegrationToolkit90"),
		"ERROR: Integration Toolkit directory exists when it shouldn't!"
	)
	
	# If the toolkit has been installed then mqsicreatebar will be on the
	# created users path, so let's check it's not
	assert(
		!UNIXCommands.exists("mqsicreatebar", username),
		"ERROR: Found mqsicreatebar as #{username}, expecting it not to exist!"
	)

end

# The reverse of the above, we intend to find the install 
# directory of the toolkit and mqsicreatebar on PATH, again
# just a quick check, we're not testing installers.
def verify_toolkit_install(username = "iibuser")

	# Check Toolkit install exists
	assert(
		File.directory?("/opt/IBM/IntegrationToolkit90"),
		"ERROR: Integration Toolkit install directory doesn't exist"
	)
	
	# If the toolkit has been installed then mqsicreatebar will be on the 
	# created users path
	assert(
		UNIXCommands.exists("mqsicreatebar", username),
		"ERROR: Cannot find mqsicreatebar as #{username}"
	)

end
