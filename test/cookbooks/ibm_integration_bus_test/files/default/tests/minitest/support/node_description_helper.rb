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

require "minitest/spec"

require File.expand_path('../node_helper.rb', __FILE__)
require File.expand_path('../process_helper.rb', __FILE__)
require File.expand_path('../log_helper.rb', __FILE__)

# Verify that the default node, as created if the "iib_nodes" attribute isn't supplied
# and as described by the data bag item default_config.json, has the expected properties
def verify_default_config()
	
	# Implicit test that webadmin port is set correctly
	default_node = IBNode.new("localhost", 4414)
	
	assert_equal(
		"IB9NODE",
		default_node.name,
		"Default node named '#{default_node.name}', not 'IB9NODE'!"
	)
	
	assert_equal(
		"IB9QMGR",
		default_node.queue_manager_name,
		"Default node's queue manager named '#{default_node.queue_manager_name}', not 'IB9QMGR'!"
	)
	
	assert_equal(
		"developer",
		default_node.operation_mode,
		"Default node's operation mode is '#{default_node.operation_mode}', not 'developer'!"
	)
	
	assert_equal(
		"inactive",
		default_node.admin_security,
		"Default node has admin security set to '#{default_node.admin_security}', not 'inactive'!"
	)
	
	assert_equal(
		1,
		default_node.servers.length,
		"Found #{default_node.servers.length} servers on default node, not 1!"
	)
	
	assert(
		default_node.servers.include?('default'),
		"Found no server named 'default' on default node, those found are #{default_node.servers.join(",")}"
	)
	
	assert_equal(
		"7080",
		default_node.http_listener_port,
		"Found http listener port on default node to be #{default_node.http_listener_port}, not 7080!"
	)
	
	assert_equal(
		"2414",
		default_node.qmgr_listener_port,
		"Found queue manager listener port on default node to be #{default_node.qmgr_listener_port}, not 2414!"
	)
	
	service("IIB-IB9NODE").must_be_enabled
	
end

# Verify that the no_servers_express node, as described by the data bag item no_servers_express.json, 
# has the expected properties
def verify_no_servers()
	
	# Implicit test that webadmin port is set correctly
	created_node = IBNode.new("localhost", 4417)
	
	assert_equal(
		"NSENODE",
		created_node.name,
		"Created node named '#{created_node.name}', not 'NSENODE'!"
	)
	
	assert_equal(
		"NSEQMGR",
		created_node.queue_manager_name,
		"Created node's queue manager named '#{created_node.queue_manager_name}', not 'NSEQMGR'!"
	)
	
	assert_equal(
		"express",
		created_node.operation_mode,
		"Created node's operation mode is '#{created_node.operation_mode}', not 'express'!"
	)
	
	assert_equal(
		"inactive",
		created_node.admin_security,
		"Created node has admin security set to '#{created_node.admin_security}', not 'inactive'!"
	)
	
	assert_equal(
		0,
		created_node.servers.length,
		"Found #{created_node.servers.length} servers on created node, not 0!"
	)
	
	assert_equal(
		"7082",
		created_node.http_listener_port,
		"Found http listener port on default node to be #{created_node.http_listener_port}, not 7082!"
	)
	
	assert_equal(
		"3414",
		created_node.qmgr_listener_port,
		"Found queue manager listener port on default node to be #{created_node.qmgr_listener_port}, not 3414!"
	)
	
	service("IIB-NSENODE").must_be_enabled
	
end

# Verify that the two_servers_scale node, as described by the data bag item two_servers_scale.json, 
# has the expected properties
def verify_two_servers()
	
	# Implicit test that webadmin port is set correctly
	created_node = IBNode.new("localhost", 4415)
	
	assert_equal(
		"TSSNODE",
		created_node.name,
		"Created node named '#{created_node.name}', not 'TSSNODE'!"
	)
	
	assert_equal(
		"TSSQMGR",
		created_node.queue_manager_name,
		"Created node's queue manager named '#{created_node.queue_manager_name}', not 'TSSQMGR'!"
	)
	
	assert_equal(
		"scale",
		created_node.operation_mode,
		"Created node's operation mode is '#{created_node.operation_mode}', not 'scale'!"
	)
	
	assert_equal(
		"inactive",
		created_node.admin_security,
		"Created node has admin security set to '#{created_node.admin_security}', not 'inactive'!"
	)
	
	assert_equal(
		2,
		created_node.servers.length,
		"Found #{created_node.servers.length} servers on created node, not 2!"
	)
	
	assert(
		created_node.servers.include?('srv_1'),
		"Found no server named 'srv_1' on created node, those found are #{created_node.servers.join(",")}"
	)
	assert(
		created_node.servers.include?('srv_2'),
		"Found no server named 'srv_2' on created node, those found are #{created_node.servers.join(",")}"
	)
	
	assert_equal(
		"7081",
		created_node.http_listener_port,
		"Found http listener port on default node to be #{created_node.http_listener_port}, not 7081!"
	)
	
	assert_equal(
		"1414",
		created_node.qmgr_listener_port,
		"Found queue manager listener port on default node to be #{created_node.qmgr_listener_port}, not 1414!"
	)
	
	service("IIB-TSSNODE").must_be_enabled
	
end

# Verify that the standard_secure node, as described by the data bag item standard_secure.json, 
# has the expected properties
def verify_standard_secure(username = "iibuser")
	
	# Implicit test that webadmin port is set correctly
	created_node = IBNode.new("localhost", 4418, username, true)
	
	assert_equal(
		"SSNODE",
		created_node.name,
		"Created node named '#{created_node.name}', not 'SSNODE'!"
	)
	
	assert_equal(
		"SSQMGR",
		created_node.queue_manager_name,
		"Created node's queue manager named '#{created_node.queue_manager_name}', not 'SSQMGR'!"
	)
	
	assert_equal(
		"standard",
		created_node.operation_mode,
		"Created node's operation mode is '#{created_node.operation_mode}', not 'standard'!"
	)
	
	assert_equal(
		"active",
		created_node.admin_security,
		"Created node has admin security set to '#{created_node.admin_security}', not 'active'!"
	)
	
	assert_equal(
		1,
		created_node.servers.length,
		"Found #{created_node.servers.length} servers on created node, not 1!"
	)
	
	assert(
		created_node.servers.include?('default'),
		"Found no server named 'default' on created node, those found are #{created_node.servers.join(",")}"
	)
	
	assert_equal(
		"7083",
		created_node.http_listener_port,
		"Found http listener port on default node to be #{created_node.http_listener_port}, not 7082!"
	)
	
	assert_equal(
		"5414",
		created_node.qmgr_listener_port,
		"Found queue manager listener port on default node to be #{created_node.qmgr_listener_port}, not 5414!"
	)
	
	service("IIB-SSNODE").must_be_enabled
	
end