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
# Definition IBM_Integration_Bus::iib_install_mq
# 
# Install MQ
#
################################################################################
define :iib_install_mq do
    unpack_dir = "#{Chef::Config[:file_cache_path]}/iib_installer";
    username   = node['ibm_integration_bus']['account_username'];
    home = "/home/#{username}"
	#
	# Ensure rpm is installed because MQ using rpm for it's install process.
	# Note: MQ does not support the use of alien so the rpm's must be used.
	#
	package "Install rpm which is required to install MQ rpms" do
	  package_name "rpm"
	  retries 30
	  retry_delay 10
	end
    extra_rpm_options = "";
    if platform?("ubuntu")
	  extra_rpm_options = "--force-debian --nodeps";
	else
	  extra_rpm_options = "--nodeps";
    end
		
	#
	# Every thing is clear now so the MQ RPM install can be started
	#
	bash "Install IBM MQ" do
	  user "root"
	  flags "-e"
	  returns [0,31]
	  code <<-EOS
	  cd "#{unpack_dir}/WebSphere_MQ_V7.5.0.1"
	  ./mqlicense.sh -accept -text_only
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesRuntime-*.x86_64.rpm
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesServer-*.x86_64.rpm
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesXRClients-*.x86_64.rpm
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesClient-*.x86_64.rpm
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesAMS-*.x86_64.rpm 
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesJRE-*.x86_64.rpm 
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesSDK-*.x86_64.rpm 
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesJava-*.x86_64.rpm 
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesGSKit-*.x86_64.rpm 
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesSamples-*.x86_64.rpm
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesMan-*.x86_64.rpm
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesMsg_*.x86_64.rpm 
	  sudo rpm -ivh #{extra_rpm_options} MQSeriesExplorer-*.x86_64.rpm
	# Leave the FT components uninstalled as IIB has it's own built in version.
	# sudo rpm -ivh #{extra_rpm_options} MQSeriesFT*.x86_64.rpm 
	EOS
	end
	#
	# Set up the runtime user to have the correct permissions and environment
	#
	group "Add user #{username} to MQ admin group mqm" do
	  action :modify
	  members "#{username}"
	  append true
	  group_name "mqm"
	end

	execute "Remove existing MQ environment from users .bashc_profile (setmqenv)" do
	  user "#{username}"
	  returns [0]
	  command "sed -i '/setmqenv/d' #{home}/.bash_profile"
	end

	execute "Update .bash_profile for user #{home} to include mq environment (setmqenv)" do
	  user "#{username}"
	  returns [0]
	  command "sed -i '$a source /opt/mqm/bin/setmqenv -s' /home/#{username}/.bash_profile"
	end

	execute "Remove existing MQ environment from user #{home}'s .bashrc (setmqenv)" do
	  user "#{username}"
	  returns [0]
	  command "sed -i '/setmqenv/d' #{home}/.bashrc"
	end

	execute "Update .bashrc for user #{username} to include mq environment (setmqenv)" do
	  user "#{username}"
	  returns [0]
	  command "sed -i '$a source /opt/mqm/bin/setmqenv -s' #{home}/.bashrc"
	end
end