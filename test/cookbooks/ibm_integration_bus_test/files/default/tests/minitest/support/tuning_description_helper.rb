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

require File.expand_path('../process_helper.rb', __FILE__)

# Check the sysctl values set as part of the cookbook run, all values are documented in
# MQ 7.5
def verify_sysctl_values()
	
	shmmni_actual = UNIXCommands.sysctl("kernel.shmmni")
	shmmni_expected = "4096"
	
	assert_equal(
		shmmni_actual, 
		shmmni_expected,
		"kernel.shmmni set to #{shmmni_actual}, not #{shmmni_expected}"
	)
	
	# Expected: 268,435,456
	shmmax_actual = UNIXCommands.sysctl("kernel.shmmax")
	shmmax_expected = "268435456"
	
	assert_equal(
		shmmax_expected,
		shmmax_actual,
		"kernel.shmmax set to #{shmmax_actual}, not #{shmmax_expected}"
	)
	
	# Expected: 2,097,152
	shmall_actual = UNIXCommands.sysctl("kernel.shmall")
	shmall_expected = "2097152"
			
	assert_equal(
		shmall_expected,
		shmall_actual,
		"kernel.shmall set to #{shmall_actual}, not #{shmall_expected}"
	)
	
	sem_value = UNIXCommands.sysctl("kernel.sem")
	
	# All the different sem values come as a tab separated list, we expect "500 256000 250 1024"
	semmsl_actual, semmns_actual, semopm_actual, semmni_actual = sem_value.split(/\t/)
			
	semmsl_expected = "500"
	semmns_expected = "256000"
	semopm_expected = "250"
	semmni_expected = "1024"

	assert_equal(
	 	semmsl_expected,
		semmsl_actual,
		"semmsl set to #{semmsl_actual}, not #{semmsl_expected}"
	)

	assert_equal(
	 	semmns_expected,
		semmns_actual,
		"semmns set to #{semmns_actual}, not #{semmns_expected}"
	)

	assert_equal(
	 	semopm_expected,
		semopm_actual,
		"semmns set to #{semopm_actual}, not #{semopm_expected}"
	)
	
	assert_equal(
	 	semmni_expected,
		semmni_actual,
		"semmns set to #{semmni_actual}, not #{semmni_expected}"
	)
	
	file_max_actual = UNIXCommands.sysctl("fs.file-max")
	file_max_expected = "524288"
			
	assert_equal(
		file_max_expected,
		file_max_actual,
		"fs.file-max set to #{file_max_actual}, not #{file_max_expected}"
	)
	
end