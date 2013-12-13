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
# Definition IBM_Integration_Bus::iib_install_toolkit
# 
# Install IIB toolkit
#
################################################################################
define :iib_install_toolkit  do
  unpack_dir = "#{Chef::Config[:file_cache_path]}/iib_installer";
  username   = node['ibm_integration_bus']['account_username'];
  home = "/home/#{username}"
  #  
  # Install 32bit libraires because toolkit installer requires them
  #
  iib_install_32bit_libs;
  
	log "IBM Integration Toolkit install log can be found in the /var/ibm/InstallationManager/logs directory" do 
		level :info
	end
	
  # Run the toolkit silent installer
  execute "Run IBM Integration Bus toolkit installer" do
    user "root"
    cwd "#{unpack_dir}/Integration_Toolkit"
    command "sudo ./installToolkit-silent.sh"
  end

  file "#{home}/IBM_Integration_Toolkit" do
    user "#{username}"
    mode "755"
    action :create
    content  "/opt/IBM/IntegrationToolkit90/launcher"
  end
  #
  # Need to create each of the following directories one by one
  # otherwise the owner is set to root
  #
  directory "Create an IBM directory" do
      user "#{username}"
      action :create
      recursive true
      mode 0770
      path "#{home}/IBM"
  end 

  directory "Create an IntegrationToolkit90 directory" do
      user "#{username}"
      action :create
      recursive true
      mode 0770
      path "#{home}/IBM/IntegrationToolkit90"
  end 

  directory "Create a directory for IIB toolkit workspace" do
      user "#{username}"
      action :create
      recursive true
      mode 0770
      path "#{home}/IBM/IntegrationToolkit90/workspace"
  end 
end