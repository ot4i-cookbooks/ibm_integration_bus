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
# Definition IBM_Integration_Bus::iib_install_explorer
# 
# Install the IIB explorer
#
################################################################################
define :iib_install_explorer do
  unpack_dir = "#{Chef::Config[:file_cache_path]}/iib_installer";
  username   = node['ibm_integration_bus']['account_username'];
  home = "/home/#{username}"
  #  
  # Install 32bit libraires because explorer installer requires them
  #
  iib_install_32bit_libs;
  
	log "IBM Integration Explorer install log can be found in the /opt/ibm/mqsi/9.0.0.0 directory" do 
		level :info
	end
	
  execute "Run IBM Integration Explorer installer" do
    user "root"
    returns [0]
    cwd "#{unpack_dir}/IBExplorer"
    command "chmod 775 #{unpack_dir}/IBExplorer/install.bin \n #{unpack_dir}/IBExplorer/install.bin -i silent -DLICENSE_ACCEPTED=TRUE"
  end
  #
  # create a quick start file in the users home directory
  #
  file "#{home}/IBM_Integration_Explorer" do
    user "#{username}"
    mode "755"
    action :create
    content  "/opt/mqm/bin/MQExplorer"
  end
end