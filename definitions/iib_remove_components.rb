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
# Definition IBM_Integration_Bus::iib_remove_components
# 
# Remove any IIB nodes
#
################################################################################
define :iib_remove_components do
  username = node['ibm_integration_bus']['account_username'];
  testString = `sudo su - #{username} -c \'mqsilist -d 0\'` 
  scanMatch = testString.scan(/BIP8099I:\ Broker:\ ([^\ ]*)\ \ -\ \ ([^\n]*)/m);
  scanMatch.each do | match_entry |
    iib_node_name     = match_entry[0];
    iib_queue_manager = match_entry[1];
    
    execute "stop mq listener" do
      user "root"
      returns [0,13,19]
      command "sudo su - #{username} -c \'endmqlsr -m #{iib_queue_manager}\'"
      ignore_failure true
    end
	
	if File.exist?("/etc/init.d/IIB-#{iib_node_name}") 
      execute "Stop existing IIB service" do
        user "root"
        returns [0,13,19]
        command "/etc/init.d/IIB-#{iib_node_name} stop"
        ignore_failure true
      end
	end 
	
    execute "Stop existing IIB components" do
      user "root"
      returns [0,13,19]
      command "sudo su - #{username} -c \'mqsistop -i #{iib_node_name} \'"
      ignore_failure true
    end

    execute "Delete existing IIB components" do
      user "root"
      returns [0,13,19]
      command "sudo su - #{username} -c \'mqsideletebroker #{iib_node_name} -qw \'"
      ignore_failure true
    end
    
    file "Delete any IIB service scripts" do
      action :delete
      path "/etc/init.d/IIB-*"
    end
  end
end