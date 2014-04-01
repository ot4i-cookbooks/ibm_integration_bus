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
# Definition IBM_Integration_Bus::iib_install_runtime
# 
# Install IIB runtime
#
################################################################################
define :iib_install_runtime  do
  unpack_dir = "#{Chef::Config[:file_cache_path]}/iib_installer";
  username   = node['ibm_integration_bus']['account_username'];
  home = "/home/#{username}"

  #
  # Make the mqbrkrs group. the installer will do this anyway but there are some cases where it might fail
  # so create the group up front.
  #
  group "Create IIB admin group mqbrkrs" do
    group_name "mqbrkrs"
    action :create
    members "#{username}"
    append true
  end
	
	log "IBM Integration Bus runtime install log can be found in the /var/mqsi directory" do 
		level :info
	end
	
  #
  # Everything is cleared and the IIB slient installer can be run
  # override the default install location which varies by fixpack
  #
  execute "Run IBM Integration Bus installer" do
    user "root"
    returns [0,1,127]
    cwd "#{unpack_dir}"
    command "#{unpack_dir}/setuplinuxx64 -i silent -DLICENSE_ACCEPTED=TRUE -DUSER_INSTALL_DIR=/opt/ibm/mqsi/9.0"
  end
  #
  # Set up the runtime user to have the correct permissions and environment
  #
  execute "Remove existing IIB environment from users profile (mqsiprofile)" do
    user "root"
    returns [0]
    command "sed -i '/mqsiprofile/d' /home/#{username}/.bash_profile"
  end

  execute "Update users profile to include curent IIB environment (mqsiprofile)" do
    user "root"
    returns [0]
    command "sed -i '$a source /opt/ibm/mqsi/9.0/bin/mqsiprofile' #{home}/.bash_profile"
  end

  execute "Remove existing IIB environment from users .bashrc (mqsiprofile)" do
    user "root"
    returns [0]
    command "sed -i '/mqsiprofile/d' #{home}/.bashrc"
  end

  execute "Update users .bashrc to include curent IIB environment (mqsiprofile)" do
    user "root"
    returns [0]
    command "sed -i '$a source /opt/ibm/mqsi/9.0/bin/mqsiprofile' #{home}/.bashrc"
end
end
