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
if platform?("ubuntu")
  execute "apt-get-update" do
    command "apt-get update"
    ignore_failure true
  end
else
  execute "Update yum packages" do
    user "root"
    returns [0]
    command "yum update -y"
  end
end

log "Installing IBM Integration Bus Runtime" do
  level :info
end

# Remove anything already installed
iib_remove_components;
iib_remove_runtime; 
iib_remove_mq;

# Set up install environment
iib_create_user;
iib_setup_install_package;

# Do the installs
iib_install_mq;
iib_install_runtime;
iib_install_explorer;

# Set up the system
iib_tune_os;
iib_create_nodes;

log "Finished installing IBM Integration Bus Runtime" do
  level :info
end

log "Installing IBM Integration Toolkit" do
  level :info
end

iib_install_toolkit;

log "Finished installing IBM Integration Toolkit " do
  level :info
end

iib_remove_install_package;

log "Finshed installing full development environment for IBM Integration Bus" do
  level :info
end
log "To start using the IBM Integration Bus login as user #{node['ibm_integration_bus']['account_username']} and start the IBM Integration toolkit either:" do
  level :info
end
log "Run /home/#{node['ibm_integration_bus']['account_username']}/IBM_Integration_Toolkit" do
  level :info
end
log "Or type Integration in the application laucher and select \"IBM Integration Toolkit\"." do
  level :info
end
