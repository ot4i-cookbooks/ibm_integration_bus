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

require "net/http"
require "uri"
require "json"

require File.expand_path('../log_helper.rb', __FILE__)
require File.expand_path('../process_helper.rb', __FILE__)

# A node description, essentially a wrapper class for the JSON response returned
# by an Integration Node. Currently we still need to get some properties via 
# commands.
class IBNode
	
	# Create an IBNode with as hostname and the webadmin port of the Integration Node. Up to
	# 10 attempts to connect are made (as the webadmin port takes a while to start up). If the
	# chef run created a user not called "iibuser" then provide that as a third argument. If
	# the node has admin security turned on, provide the fourth flag as true. A web admin user
	# will be created using the username provided
	#
	# No security, with user iibuser: IBNode.new("localhost", 4414)
	# No security, non-default username: IBNode.new("localhost", 4414, "iib2user")
	# Security on, with user iibuser: IBNode.new("localhost", 4414, "iibuser", true)
	def initialize(hostname, webadminport, username = "iibuser", adminsecurity = false)
		
		# Save the username for use later
		@username = username
		
		webusername = nil;
		webpassword = nil;
		
		# If admin security is turned on, we need to create a web user, we never "tear this down"
		# as vagrant will tear the whole box down for us anyway
		if(adminsecurity) 
		
			webusername = "testuser"
			webpassword = "testpassword"
		
			user_create = Mixlib::ShellOut.new("sudo su - #{username} -c 'mqsiwebuseradmin SSNODE -c -u #{webusername} -a #{webpassword} -r #{username}'")
			user_create.run_command
	
			if(user_create.exitstatus != 0)
				IBLogger.instance.log("Error creating webadmin user, stdout below")
				IBLogger.instance.log(user_create.stdout)
			end
			
		end
		
		attempts = 10
		last_attempt_failed = true
		
		# The node can take a few seconds to start listening for WebAdmin HTTP, so we'll make a few attempts
		while (attempts >= 0 && last_attempt_failed) do
			last_attempt_failed = !_make_rest_calls(hostname, webadminport, webusername, webpassword)
			attempts -= 1
			sleep(5)
		end
		
		if(attempts == -1)
			IBLogger.instance.log("")
		  IBLogger.instance.log("Failed to connect to Integration Node")
			IBLogger.instance.log("")
		else
			
			IBLogger.instance.log("")
		  IBLogger.instance.log("Connected to Integration Node on #{hostname}:#{webadminport}")
			IBLogger.instance.log("")
		end
		
	end
	
	def _make_rest_calls(hostname, webadminport, webusername, webpassword)
	
		url_base = URI.parse("http://#{hostname}:#{webadminport}")
		depth_query = "?depth=2"
		
		# Grab the top level json
		top_level_url = URI.parse("#{url_base}/apiv1#{depth_query}")
		@top_level_json = _make_json_rest_call(top_level_url, webusername, webpassword)
		
		# If that comes back succesfully, grab the properties as well
		if(@top_level_json)
			
			properties_link = @top_level_json["propertiesUri"]
			properties_url = URI.parse("#{url_base}#{properties_link}")
			@properties_json = _make_json_rest_call(properties_url, webusername, webpassword)
			
			@properties_json
		
		else
			false
		end
		
	end
	
	def _make_json_rest_call(uri, webusername, webpassword)
	
		request = Net::HTTP::Get.new(uri.to_s)
		request.add_field("Accept", "application/json")
		
		if(webusername != nil && webpassword != nil)
			request.basic_auth(webusername, webpassword)
		end
		
		begin
			
			IBLogger.instance.log("Attempting to connect to node on '#{uri.to_s}'")
			
			response = Net::HTTP.new(uri.host, uri.port).start do
				|http|
				http.request(request)
			end
			
			response_body = response.body
			IBLogger.instance.log("Recieved response, on line below:")
			IBLogger.instance.log(response_body)
			
			JSON.parse(response_body)
			
		rescue Errno::ECONNREFUSED => e
			IBLogger.instance.log("WARNING: Connection to Integration Node was refused")
			IBLogger.instance.log("Please review messages further down the log, it is likely that the Integration Node's WebAdmin listener port hasn't started yet and connection will be made shortly")
			IBLogger.instance.log("Host was: #{uri.host}")
			IBLogger.instance.log("Port was: #{uri.port}")
			IBLogger.instance.log("Full url was: #{uri.to_s}")
			IBLogger.instance.log("Exception message was: '#{e.message}'")
			return false
		end
		
	end
	
	# Returns the name of the Node, as would appear in mqsilist
	def name()
		@top_level_json["name"]
	end
	
	# Returns an array of the names of the Integration Servers
	def servers()
		@top_level_json["executionGroups"]["executionGroup"].map do
			|eg|
			eg["name"]
		end
	end
	
	# Returns the property adminSecurity as "active" or "inactive"
	def admin_security()
		@properties_json["basicProperties"][0]["value"]
	end
	
	# Returns the opertation mode as "standard", "express", "developer", "scale" or "advanced"
	def operation_mode()
		@properties_json["advancedProperties"][2]["value"]
	end
	
	# Returns the name of the Queue Manager associated with this Integration Node, as it would
	# appear in mqsilist
	def queue_manager_name()
		qmname = @properties_json["advancedProperties"][5]["value"]
		IBLogger.instance.log("#{name()} has queue manager #{qmname}")
		qmname
	end
	
	# Returns true if the connection was succesfully made to the Integration Node, false otherwise
	def is_web_admin_enabled()
		!!@top_level_json
	end
	
	# Returns the Integration Node's HTTP Listener port (for HTTP message flows, not webadmin)
	# Have to go through the command line for this one... REST doesn't report it
	def http_listener_port()
	  port_process = Mixlib::ShellOut.new("sudo su - #{@username} -c 'mqsireportproperties #{name()} -b httplistener -o HTTPConnector -n port'")
		port_process.run_command
		output = port_process.stdout
		
		port_arr = output.scan(/\n(\d+)\n/m)
		port_arr[0][0]
		
	end
	
	# Returns the Node's Queue Manager's listener port
	# Even more horrible, but has to be checked
	def qmgr_listener_port()
		find_qmgr_listener_port(queue_manager_name)
	end
	
end

# Supply an array of expected Integration Node names and the username of the Integration Bus
# user, this method will check the Integration Nodes on the system (via mqsilist) and return
# true if they match the node names provided in the array, and false otherwise
def nodes_on_machine_are(expected_nodes, username = "iibuser")
	
	mqsilist = Mixlib::ShellOut.new("sudo su - #{username} -c 'mqsilist -d 0'")
	mqsilist.run_command
	
	output = mqsilist.stdout
	matches = output.scan(/BIP8099I:\ Broker:\ ([^\ ]*)\ \ -\ \ ([^\n]*)/m)
	
	# Form an array of the actual nodes on the machine
	actual_nodes = Array.new
	matches.each do
		|match| 
		actual_nodes.push(match[0])
	end
	
	# Neither of these lists are huge, so let's just sort and compare
	assert(
		actual_nodes.sort == expected_nodes.sort,
		"Expected to find '#{expected_nodes.join(",")}' on machine, but actually found '#{actual_nodes.join(",")}"
	)
	
end

# Given a queue manager name, return the port it's listener was started on
# Horrible, we need to find the command line flag from ps
def find_qmgr_listener_port(qmgr_name)
	
	IBLogger.instance.log("Looking for listener port of queue manager #{qmgr_name}")
	
	# We look for the runmqlsr command and see what port that was kicked off against
	process = Mixlib::ShellOut.new("ps -ef | grep runmqlsr")
	process.run_command
	output = process.stdout
	
	runmqslsr_regex = /runmqlsr									# Look for runmqlsr
											\s+                     
															-(m|t|p)        # The first command line flag
											\s+
															(\S+)           # Extract also it's value
											\s+
															-(m|t|p)        # Do the same with the next two command line flags
											\s+
															(\S+)
											\s+
															-(m|t|p)
											\s+
															(\S+)
										/mx
	
	results = output.scan(runmqslsr_regex)
	
	# results should be an array of arrays of length 6 ["m", queue_manager_name, "t", transport_type, "p", port_number]
	results.each {
	
		|result|
		
		# Split into pairs of [flag, value]
		pairs = result.each_slice(2)
		
		queue_manager = nil;
		port = nil;
		
		# For each pair set the queue_manager or port value if it corresponds to
		# one of the relevant flags
		pairs.each {

			|pair|
			
			if(pair[0] == "p")
				port = pair[1]
			elsif(pair[0] == "m")
				queue_manager = pair[1]
			end
			
		}
		
		if(queue_manager == qmgr_name)
			IBLogger.instance.log("Found port to be #{port}")
			return port
		end
		
	}
	
	IBLogger.instance.log("Could not find port")
	false
	
end