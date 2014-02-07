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

require File.expand_path('../log_helper.rb', __FILE__)

# Simple class used for abstracting interactions with the Linux OS commands
class UNIXCommands
	
	# Runs the sysctl command given a parameter name (e.g. kernel.shmmni), returns
	# the value of that parameter as a string
	def self.sysctl(paramname)
		
		process = Mixlib::ShellOut.new("sysctl -n #{paramname}")
		process.run_command
		
		if process.exitstatus == 0
			# The response comes with a newline tagged on the end
			return process.stdout.rstrip
		else
			IBLogger.instance.log("systcl failed with rc #{process.exitstatus}, with stdout:")
			IBLogger.instance.log(process.stdout)
			return nil
		end
		
	end
	
	# Runs the ulimit command, hard limit is a boolean value, if you want the soft
	# limit set it to false, argument is the letter that represents the value you 
	# want (for example n is the maximum number of open file descriptors)
	def self.ulimit(hardlimit, argument)
		
		prefix = hardlimit ? 'H' : 'S'
		flag = '-' + prefix + argument
		
		process = Mixlib::ShellOut.new("bash -c 'ulimit #{flag}'")
		process.run_command
		
		if process.exitstatus == 0
			return process.stdout.rstrip
		else 
		  	IBLogger.instance.log("ulimit failed with rc #{process.rc}, with stdout:")
		  	IBLogger.instance.log(process.stdout)
		  	return nil
		end
	
	end
	
	# Given a command name this function checks whether it exists on the path for
	# a given user, by default we use the current user
	def self.exists(command_name, user=nil)
		
		which_command = nil;
		
		if(user != nil)
			which_command = Mixlib::ShellOut.new("sudo su - #{user} -c 'which #{command_name}'")
		else
			which_command = MixLib::ShellOut.new("which #{command_name}")
		end
		
		which_command.run_command
		return which_command.exitstatus == 0
		
	end
	
end