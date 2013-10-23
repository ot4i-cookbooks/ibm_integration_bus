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
################################################################################
#
# Recipe IBM_Integratiom_Bus::default
#
# Installs all components required by IBM Integration Bus.
#
################################################################################

log "Installing full development environment for IBM Integration Bus" do
  level :info
end

#
# Need to ensure apt-get is updated before running the script
#
execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
end
#
# include the runtime recipe which will install everything except the toolkit
#
include_recipe( "ibm_integration_bus::runtime" );
#
# Install the toolkit after the runtime has finished being installed
# The following code relies on the runtime recipe being run first to 
# create the required user and to unpack the install package.
# If this ever needs to be moved to a separate recipe then the parts from the runtime
# recipe will need to be included.
#
log "Installing IBM Integration Toolkit" do
  level :info
end

# Define variables for attributes
package_site_url             = node['ibm_integration_bus']['package_site_url'];
package_name                 = node['ibm_integration_bus']['package_name'];
account_username             = node['ibm_integration_bus']['account_username'];
account_home                 = "/home/#{account_username}";

# Define variables for paths used
package_url          = "#{package_site_url}/#{package_name}";
package_download     = "#{Chef::Config[:file_cache_path]}/#{package_name}"; 
unpacked_installer   = "#{Chef::Config[:file_cache_path]}/iib_installer";

# Install 32bit libraires becuase toolkit installer requires them
package "Install 32 bit libraries (toolkit installer is 32bit only)" do
  package_name "ia32-libs"
  retries 30
  retry_delay 10
end

# Run the toolkit silent installer
execute "Run IBM Integration Bus toolkit installer" do
  user "root"
  cwd "#{unpacked_installer}/Integration_Toolkit"
  command "sudo ./installToolkit-silent.sh"
end

file "#{account_home}/IBM_Integration_Toolkit" do
  user "#{account_username}"
  mode "755"
  action :create
  content  "/opt/IBM/IntegrationToolkit90/launcher"
end

#
# Need to create each of the following directories one by one
# otherwise the owner is set to root
#
directory "Create an IBM directory" do
      user "#{account_username}"
      action :create
      recursive true
      mode 0770
      path "#{account_home}/IBM"
end 

directory "Create an IntegrationToolkit90 directory" do
      user "#{account_username}"
      action :create
      recursive true
      mode 0770
      path "#{account_home}/IBM/IntegrationToolkit90"
end 

directory "Create a directory for IIB toolkit workspace" do
      user "#{account_username}"
      action :create
      recursive true
      mode 0770
      path "#{account_home}/IBM/IntegrationToolkit90/workspace"
end 

directory "Remove unpacked tool image" do
      action :delete
      recursive true
	  path "#{unpacked_installer}"
end

log "Finished installing IBM Integration Toolkit " do
  level :info
end

log "Finshed installing full development environment for IBM Integration Bus" do
  level :info
end
log "To start using the IBM Integration Bus login as user #{account_username} and start the IBM Integration toolkit either:" do
  level :info
end
log "Run #{account_home}/IBM_Integration_Toolkit" do
  level :info
end
log "Or type Integration in the application laucher and select \"IBM Integration Toolkit\"." do
  level :info
end
