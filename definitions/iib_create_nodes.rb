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
# Definition IBM_Integration_Bus::iib_create_nodes
# 
# Creates a set of IIBNODES based on the iib_nodes attribute 
#
################################################################################
define :iib_create_nodes do
  username       = node['ibm_integration_bus']['account_username'];
  iib_nodes      = node['ibm_integration_bus']['iib_nodes'];
  # First check to see if the iib_nodes attribute is set. If it is unset then
  # flag that a default configuration setup is required
  createDCW = false;
  if iib_nodes == nil 
    iib_nodes = Array["_dcw_"];
    createDCW = true;
  elsif iib_nodes.kind_of?(Array) == false
    raise "iib_nodes attribute is not an array of data_bag items. It must be an array rather than a single databag item."
  end 
  # define a set to remember all ports used
  portSet = Set.new;
  #
  # now loop through all node definitions and create what is required  
  #
  iib_nodes.each do | iib_node |
    # set the default values up in case they are missing
    iibnode_name   = nil;
    iibqmgr_name   = nil;
    iibqmgr_port   = nil;
    iibserver_names = Array.new;
    iibnode_webadmin_enabled = "true";
    iibnode_webadmin_port = 4414;
    iibnode_httplistener_port = nil;
    iibnode_operationMode = nil;
    iibnode_adminSecurity = nil;
  #
  # if not the default configuration then find the databag item for this node 
    #
  if createDCW == false 
    iib_nodes_item = data_bag_item('iib_nodes', iib_node);
    if iib_nodes_item['node'] == nil
	  raise "node field missing from data bag item.";
	end
    iibnode_name = iib_nodes_item['node']['name'];
    if iib_nodes_item['node']['properties'] != nil
      #
      # loop through all the basic node properties
      #
      if iib_nodes_item['node']['properties']['basicProperties'] != nil
      iib_nodes_item['node']['properties']['basicProperties'].each do | property | 
        if property['name'] == 'AdminSecurity'; 
        iibnode_adminSecurity = property['value'];
        end
        if property['name'] == 'webAdminHTTPListenerPort' 
        iibnode_webadmin_port = property['value'];
        end
        if property['name'] == 'webAdminEnabled' 
          iibnode_webadmin_enabled = property['value'];
        end
      end
      end
      #
      # loop through all the advance node properties
      #
      if iib_nodes_item['node']['properties']['advancedProperties'] != nil
        iib_nodes_item['node']['properties']['advancedProperties'].each do | property | 
          if property['name'] == 'queueManager' 
            iibqmgr_name = property['value'];
          end
          if property['name'] == 'httpListenerPort' 
            iibnode_httplistener_port = property['value'];
          end
          if property['name'] == 'operationMode' 
            iibnode_operationMode = property['value'];
          end
        end
      end
      #  
      # Get the name of all server (executionGroups) that need to be created
      #
      if iib_nodes_item['node']['executionGroups'] != nil
        iib_nodes_item['node']['executionGroups']['executionGroup'].each do | executionGroup | 
		  if executionGroup['name'] == nil
		    raise "executionGroup name is missing";
		  end
          iibserver_names.push(executionGroup['name']);
        end
      end
      # 
      # Find the port listner port if it is present
      #
      if iibqmgr_port = iib_nodes_item['qmgrListenerPort'] != nil
        iibqmgr_port = iib_nodes_item['qmgrListenerPort'];
      end
    end
    else
    #
      # create a setup that is the same as the toolkit default configuration wizard  
    #
      iibnode_name   = "IB9NODE";
      iibqmgr_name   = "IB9QMGR";
      iibserver_names = Array.new;
      iibnode_webadmin_enabled = "true";
      iibnode_webadmin_port = 4414;
      iibnode_httplistener_port = nil;
      iibnode_operationMode = nil;
      iibserver_names.push("default");
      iibqmgr_port   = 2414;
    end
  
   log "Integration Node with the following properties will be created:\n  Name: #{iibnode_name}\n  Queue manager: #{iibqmgr_name}\n  Web admin enabled: #{iibnode_webadmin_enabled}\n  Web admin port: #{iibnode_webadmin_port}\n  httplistener port: #{iibnode_httplistener_port}\n  Operation mode: #{iibnode_operationMode}\n" do
      level :info
    end
  # If web admin is enabled ensure the port is not already used
  if (iibnode_webadmin_enabled.casecmp("true")) && (portSet.add?( iibnode_webadmin_port ) == nil)
    raise "Web admin port: #{iibnode_webadmin_port} is already being used. Check the databag item #{iib_node} has the correct value."
  end
  # If queue manager lisrener is enabled ensure the port is not already used
  if (iibqmgr_port != nil) && (portSet.add?( iibqmgr_port ) == nil)
    raise "Queue manager listener port: #{iibqmgr_port} is already being used. Check the databag item #{iib_node} has the correct value."
  end
  # If http listener is given ensure the port is not already used
  if (iibnode_httplistener_port != nil) && (portSet.add?( iibnode_httplistener_port ) == nil)
    raise "HTTP listener port: #{iibnode_httplistener_port} is already being used. Check the databag item #{iib_node} has the correct value."
  end
  # If queue manager name is not set
  if iibqmgr_name == nil
    raise "Queue manager name missing from the data bag item.";
  end 
  # If queue manager name is not set
  if iibnode_name == nil
    raise "Node name missing from the data bag item.";
  end  
  #
  # Check to see if the queue manger port needs to be set
  #
    qmgr_listener_comment = "";
    if iibqmgr_port == nil
    # comment out listener so it does not run and set it to the default value
      qmgr_listener_comment = "#"
      iibqmgr_port = 1414;
    else
      qmgr_listener_comment = "";
    end
  
    #
    # Create a node service script up front when we know we have access to the chef server. 
    #
    template "/etc/init.d/IIB-#{iibnode_name}" do
      source "IIBService.erb"
      mode 0775
      owner "#{username}"
      group "#{username}"
      variables({
             :user_name             => "#{username}",
             :node_name             => "#{iibnode_name}",
             :qmgr_name             => "#{iibqmgr_name}",
             :qmgr_listener_comment => "#{qmgr_listener_comment}",
             :qmgr_listener_port    => "#{iibqmgr_port}"
           })
    end
    #
    # Create a default node and server making sure any existing one is recreated. 
    #
	
    execute "Stop existing IIB service" do
      user "root"
      returns [0,13,19]
      command "/etc/init.d/IIB-#{iibnode_name} stop"
      ignore_failure true
    end
  
    execute "Stop existing IIB node #{iibnode_name} if it exists" do
      user "root"
      returns [0,13,19]
      command "sudo su - #{username} -c \'mqsistop -i #{iibnode_name}\'"
      ignore_failure true
    end

    execute "Delete existing IIB node #{iibnode_name} if it exists" do
      user "root"
      returns [0,13,19]
      command "sudo su - #{username} -c \'mqsideletebroker #{iibnode_name} -qw \'"
      ignore_failure true
    end
  
  iibnode_httplistener_port_option = "";
    if (iibnode_httplistener_port != nil)
    iibnode_httplistener_port_option = "-P #{iibnode_httplistener_port}";
  end
  
  iibnode_adminSecurity_option = "";
  if iibnode_adminSecurity != nil
      iibnode_adminSecurity_option = "-s #{iibnode_adminSecurity}"; 
  end
  
    execute "Create IIB node #{iibnode_name}" do
      user "root"
      returns [0]
      retries 2
      retry_delay 5
      command "sudo su - #{username} -c \'mqsicreatebroker #{iibnode_name}  -q #{iibqmgr_name} #{iibnode_httplistener_port_option} #{iibnode_adminSecurity_option}\'"
    end

#
# Configure the IIB node to start at boot time
#

  service "Start IIB Node" do
    service_name "IIB-#{iibnode_name}"
    action [:enable,:start]
      ignore_failure true
    end
    #
  # set up all the non-default properties
  #
    if iibnode_webadmin_enabled.casecmp("true") == 0
      execute "Change IIB node #{iibnode_name} web admin port to #{iibnode_webadmin_port}" do
        user "root"
        returns [0]
        command "sudo su - #{username} -c \'mqsichangeproperties #{iibnode_name} -b webadmin -o HTTPConnector -n port -v #{iibnode_webadmin_port}\'"
      end
    else
      execute "Disable IIB node #{iibnode_name}'s web admin" do
        user "root"
        returns [0]
        command "sudo su - #{username} -c \'mqsichangeproperties #{iibnode_name} -b webadmin -o server -n enabled -v  #{iibnode_webadmin_enabled}\'"
      end
    end
    if iibnode_operationMode != nil
      execute "Set operation mode on IIB node #{iibnode_name} to #{iibnode_operationMode}" do
        user "root"
        returns [0]
        command "sudo su - #{username} -c \'mqsimode #{iibnode_name} -o #{iibnode_operationMode}\'"
      end
    end
  #
  # Restart the IIB node to ensure all properties are refreshed
  #
     service "Stop IIB Node" do
    service_name "IIB-#{iibnode_name}"
    action :stop
      ignore_failure true
    end
  
  service "Start IIB Node" do
    service_name "IIB-#{iibnode_name}"
    action :start
      ignore_failure true
    end
  #
  # Create the required servers (executionGroups)
  #
    iibserver_names.each do | iibserver_name | 
      execute "Create IIB node server #{iibserver_name}" do
        user "root"
        returns [0]
        command "sudo su - #{username} -c \'mqsicreateexecutiongroup #{iibnode_name} -e #{iibserver_name} -w 300\'"
      end
    end
  end
end