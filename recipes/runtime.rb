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
# Recipe IBM-Integratiom-Bus::runtime
# 
# Installs all components required by IBM-Integratiom-Bus except for the 
# Integration Toolkit.

#
################################################################################
log "Installing IBM Integration Bus Runtime" do
  level :info
end

# Define variables for attributes
package_site_url             = node['ibm_integration_bus']['package_site_url'];
package_name                 = node['ibm_integration_bus']['package_name'];
account_username             = node['ibm_integration_bus']['account_username'];
account_home                 = "/home/#{account_username}";

# Define variables for paths used
package_url                = "#{package_site_url}/#{package_name}";
package_download           = "#{Chef::Config[:file_cache_path]}/#{package_name}"; 
unpacked_installer         = "#{Chef::Config[:file_cache_path]}/iib_installer";

# Define names of components to create
iibnode_name   = "IB9NODE";
iibqmgr_name   = "IB9QMGR";
iibqmgr_port   = "2414";
iibserver_name = "default";
#
# Need to ensure apt-get is updated before running the script
#
execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
end

# Install shadow ruby as chef requires this to handle passwords
if node['ibm_integration_bus']['account_password'] 
  gem_package "Install shadow ruby to support user name passwords" do
    package_name "ruby-shadow"
    retries 30
    retry_delay 10
  end
end

user "Create user #{account_username} to be used for administering IIB" do
  action :create
  shell "/bin/bash"
  home "/home/#{account_username}"
  supports :manage_home=> true
  username "#{account_username}"
  if node['ibm_integration_bus']['account_password'] 
    password node['ibm_integration_bus']['account_password'] 
  end
end

# Ensure the user has a bash profile ready for any environment we need to configure
file "#{account_home}/.bash_profile" do
  owner "#{account_username}"
  mode "0755"
  if File.exist?("#{account_home}/.bash_profile") && File.size("#{account_home}/.bash_profile") == 0
    action :create
  else
    action :create_if_missing
  end
  content "# ~/.bash_profile"
end
#
# Create a node service script up front when we know we have access to the chef server.
# If done later the chef sever might have timed us out.
#
template "/etc/init.d/IIB-#{iibnode_name}" do
  source "IIBService.erb"
  mode 0775
  owner "#{account_username}"
  group "#{account_username}"
  variables({
             :user_name          => "#{account_username}",
             :node_name          => "#{iibnode_name}",
             :qmgr_name          => "#{iibqmgr_name}",
             :qmgr_listener_port => "#{iibqmgr_port}"
           })
end

remote_file "Download the install image package from: #{package_url} to: #{package_download}"  do
  path "#{package_download}"
  source "#{package_url}"
  retries 30
  retry_delay 10
  if File.exist?("#{package_download}") && File.size("#{package_download}") == 0
    action :create
  else
    action :create_if_missing
  end
  end

ruby_block "Checking the downloaded install image package from: #{package_download} has content" do
  action :run
  block do
    if File.exist?("#{package_download}") && File.size("#{package_download}") == 0
      raise "Downloaded install package is invalid. Check the URL #{package_url} is correct"
    end
  end
end

directory "Remove unpacked runtime image if it exists" do
      action :delete
      recursive true
	  path "#{unpacked_installer}"
end

directory "Create directory to unpacked runtime to: #{unpacked_installer}" do
      action :create
      recursive true
      path "#{unpacked_installer}"
end 

execute "Unpack runtime image" do
  user "root"
  command "tar -xzf #{package_download} --strip-components=1 -C #{unpacked_installer}"
end
#
# Before starting any installs try every way possible to stop components started by previous runs of this script
# including all the normal stop/end commands plus running the init.d script if it exists.
# Ignore any failures as this step is just there to attempt to clear up before a reinstall. The most
# likely cause of a failure will be that the script is being run for the first time and there is nothing to stop.
#
execute "Stop existing IIB components" do
  user "root"
  returns [0,19]
  command "sudo su - #{account_username} -c \'mqsistop #{iibnode_name} -i \n endmqm  -p #{iibqmgr_name} \n endmqlsr -m #{iibqmgr_name} \n cd .\'"
  ignore_failure true
end

ruby_block "Sleep for a short while to wait for any components to stop" do
  block do
    sleep 10;
  end
end

#
# Ensure rpm is installed because MQ using rpm for it's install process.
# Note: MQ does not support the use of alien so the rpm's must be used.
#
package "Install rpm which is required to install MQ rpms" do
  package_name "rpm"
  retries 30
  retry_delay 10
end
#
# Before installing MQ several steps are executed to remove any existing
# MQ components. This will ensure the install will not fail due to existing
# components.
#
execute "Remove any previous install of IBM MQ in dpkg" do
  user "root"
  returns [0,31]
  retries 30
  retry_delay 10
  command "dpkg --purge mqseries\\*"
end

execute "Remove any previous install of IBM MQ in rpm" do
  user "root"
  returns [0,1]
  retries 30
  retry_delay 10
  command "sudo rpm --force-debian -e `sudo rpm -qa | grep MQSeries`"
end

directory "Clear up MQ install directory if it exists" do
  action :delete
  recursive true
  path "/opt/mqm"
end
#
# Every thing is clear now so the MQ RPM install can be started
#
bash "Install IBM MQ" do
  user "root"
  flags "-e"
  returns [0,31]
  code <<-EOS
  cd "#{unpacked_installer}/WebSphere_MQ_V7.5.0.1"
  ./mqlicense.sh -accept -text_only
  sudo rpm -ivh --force-debian --nodeps MQSeriesRuntime-*.x86_64.rpm
  sudo rpm -ivh --force-debian --nodeps MQSeriesServer-*.x86_64.rpm
  sudo rpm -ivh --force-debian --nodeps MQSeriesXRClients-*.x86_64.rpm
  sudo rpm -ivh --force-debian --nodeps MQSeriesClient-*.x86_64.rpm
  sudo rpm -ivh --force-debian --nodeps MQSeriesAMS-*.x86_64.rpm 
  sudo rpm -ivh --force-debian --nodeps MQSeriesGSKit-*.x86_64.rpm 
  sudo rpm -ivh --force-debian --nodeps MQSeriesJRE-*.x86_64.rpm 
  sudo rpm -ivh --force-debian --nodeps MQSeriesSDK-*.x86_64.rpm 
  sudo rpm -ivh --force-debian --nodeps MQSeriesJava-*.x86_64.rpm 
  sudo rpm -ivh --force-debian --nodeps MQSeriesSamples-*.x86_64.rpm
  sudo rpm -ivh --force-debian --nodeps MQSeriesMan-*.x86_64.rpm
  sudo rpm -ivh --force-debian --nodeps MQSeriesMsg_*.x86_64.rpm 
  sudo rpm -ivh --force-debian --nodeps MQSeriesExplorer-*.x86_64.rpm
# Leave the FT components uninstalled as IIB has it's own built in version.
# sudo rpm -ivh --force-debian --nodeps MQSeriesFT*.x86_64.rpm 
EOS
end
#
# Set up the runtime user to have the correct permissions and environment
#
group "Add user #{account_username} to MQ admin group mqm" do
  action :modify
  members "#{account_username}"
  append true
  group_name "mqm"
end

execute "Remove existing MQ environment from users .bashc_profile (setmqenv)" do
  user "#{account_username}"
  returns [0]
  command "sed -i '/setmqenv/d' #{account_home}/.bash_profile"
end

execute "Update .bash_profile for user #{account_home} to include mq environment (setmqenv)" do
  user "#{account_username}"
  returns [0]
  command "sed -i '$a source /opt/mqm/bin/setmqenv -s' /home/#{account_username}/.bash_profile"
end

execute "Remove existing MQ environment from user #{account_home}'s .bashrc (setmqenv)" do
  user "#{account_username}"
  returns [0]
  command "sed -i '/setmqenv/d' #{account_home}/.bashrc"
end

execute "Update .bashrc for user #{account_username} to include mq environment (setmqenv)" do
  user "#{account_username}"
  returns [0]
  command "sed -i '$a source /opt/mqm/bin/setmqenv -s' #{account_home}/.bashrc"
end
#
# MQ install has finished and now start the install of the Integration Bus.
# Firstly, clear any existing installs.
#
directory "Remove IBM Integration Bus install directory if it exists" do
  action :delete
  recursive true
  path "/opt/ibm/mqsi"
end

directory "Remove IE02 if it exists" do
  action :delete
  recursive true
  path "/opt/ibm/IE02"
end
#
# Make the mqbrkrs group. the installer will do this anyway but there are some cases where it might fail
# so create the group up front.
#
group "Create IIB admin group mqbrkrs" do
  group_name "mqbrkrs"
  action :create
  members "#{account_username}"
  append true
end
#
# Everything is cleared and the IIB slient installer can be run
#
execute "Run IBM Integration Bus installer" do
  user "root"
  returns [0,127]
  cwd "#{unpacked_installer}"
  command "#{unpacked_installer}/setuplinuxx64 -i silent -DLICENSE_ACCEPTED=TRUE"
end
#
# Set up the runtime user to have the correct permissions and environment
#
execute "Remove existing IIB environment from users profile (mqsiprofile)" do
  user "root"
  returns [0]
  command "sed -i '/mqsiprofile/d' /home/#{account_username}/.bash_profile"
end

execute "Update users profile to include curent IIB environment (mqsiprofile)" do
  user "root"
  returns [0]
  command "sed -i '$a source /opt/ibm/mqsi/9.0.0.0/bin/mqsiprofile' #{account_home}/.bash_profile"
end

execute "Remove existing IIB environment from users .bashrc (mqsiprofile)" do
  user "root"
  returns [0]
  command "sed -i '/mqsiprofile/d' #{account_home}/.bashrc"
end

execute "Update users .bashrc to include curent IIB environment (mqsiprofile)" do
  user "root"
  returns [0]
  command "sed -i '$a source /opt/ibm/mqsi/9.0.0.0/bin/mqsiprofile' #{account_home}/.bashrc"
end
#
# The operating system needs to be tuned correctly to run both MQ and IIB.
#
bash "Tune operating system for running both IIB and MQ" do
  user "root"
  flags "-e"
  returns [0]
  code <<-EOS
# ulimit - for HVE
sed -i '/End of file/i\#{account_username} hard   nofile'/d               /etc/security/limits.conf
sed -i '/End of file/i\#{account_username} hard   nofile           8192'  /etc/security/limits.conf
sed -i '/End of file/i\#{account_username} soft   nofile'/d               /etc/security/limits.conf
sed -i '/End of file/i\#{account_username} soft   nofile           8192'  /etc/security/limits.conf

# ulimit - for MQ
sed -i '/End of file/i\mqm              hard   nofile'/d               /etc/security/limits.conf
sed -i '/End of file/i\mqm              hard   nofile           10240' /etc/security/limits.conf
sed -i '/End of file/i\mqm              soft   nofile'/d               /etc/security/limits.conf
sed -i '/End of file/i\mqm              soft   nofile           10240' /etc/security/limits.conf
sed -i '/End of file/i\mqm              hard   nproc'/d                /etc/security/limits.conf
sed -i '/End of file/i\mqm              hard   nproc            4096'  /etc/security/limits.conf
sed -i '/End of file/i\mqm              soft   nproc'/d                /etc/security/limits.conf
sed -i '/End of file/i\mqm              soft   nproc            4096'  /etc/security/limits.conf

# network - for HVE
sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 3000" >> /etc/sysctl.conf
sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
echo "net.core.somaxconn = 3000" >> /etc/sysctl.conf
sed -i '/net.ipv4.tcp_keepalive_intvl/d' /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_intvl = 15" >> /etc/sysctl.conf
sed -i '/net.ipv4.tcp_keepalive_probes/d' /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_probes = 5" >> /etc/sysctl.conf

# Kernel - for MQ
sed -i '/kernel.msgmni/d' /etc/sysctl.conf
echo "kernel.msgmni = 1024" >> /etc/sysctl.conf
sed -i '/kernel.shmmni/d' /etc/sysctl.conf
echo "kernel.shmmni = 4096" >> /etc/sysctl.conf
sed -i '/kernel.shmall/d' /etc/sysctl.conf
echo "kernel.shmall = 2097152" >> /etc/sysctl.conf
sed -i '/kernel.shmmax/d' /etc/sysctl.conf
echo "kernel.shmmax = 268435456" >> /etc/sysctl.conf
sed -i '/kernel.sem/d' /etc/sysctl.conf
echo "kernel.sem = 500 256000 250 1024" >> /etc/sysctl.conf
sed -i '/fs.file-max/d' /etc/sysctl.conf
echo "fs.file-max = 524288" >> /etc/sysctl.conf
sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_time = 300" >> /etc/sysctl.conf

# sudoers - for MQ
if [ -f /etc/sudoers ]; then
    sed -i '/requiretty/ s/^.*$/#Defaults requiretty/g' /etc/sudoers
    fi

sysctl -p

EOS
end


#
# Create a default node and server making sure any existing one is recreated. 
#
execute "Stop IIB Node" do
  user "root"
  returns [0,19]
  command "/etc/init.d/IIB-IB9Node stop \n cd ."
  ignore_failure true
end

execute "Stop existing IIB node #{iibnode_name} if it exists" do
  user "root"
  returns [0,19]
  command "sudo su - #{account_username} -c \'mqsistop #{iibnode_name} \n cd .\'"
  ignore_failure true
end

execute "Delete existing IIB node #{iibnode_name} if it exists" do
  user "root"
  returns [0,19]
  command "sudo su - #{account_username} -c \'mqsideletebroker #{iibnode_name} \n endmqm -p #{iibqmgr_name} \n dltmqm #{iibqmgr_name} \n cd .\'"
  ignore_failure true
end

execute "Create IIB node #{iibnode_name}" do
  user "root"
  returns [0]
  command "sudo su - #{account_username} -c \'mqsicreatebroker #{iibnode_name}  -q #{iibqmgr_name}\'"
end

#
# Configure the IIB node to start at boot time
#
execute "Setup IIB node to start at boot up time" do
  user "root"
  returns [0]
  command "update-rc.d IIB-#{iibnode_name} defaults"
end
#
# Start the IIB node now ready for use
#
execute "Start IIB Node" do
  user "root"
  returns [0]
  command "/etc/init.d/IIB-#{iibnode_name} start"
end

execute "Create IIB node server #{iibserver_name}" do
  user "root"
  returns [0]
  command "sudo su - #{account_username} -c \'mqsicreateexecutiongroup #{iibnode_name} -e #{iibserver_name}\'"
end

# Install 32bit libraires becuase explorer installer requires them
package "Install 32 bit libraries (explorer installer is 32bit only)" do
  package_name "ia32-libs"
  retries 30
  retry_delay 10
end

execute "Run IBM Integration Explorer installer" do
  user "root"
  returns [0]
  cwd "#{unpacked_installer}/IBExplorer"
  command "chmod 775 #{unpacked_installer}/IBExplorer/install.bin \n #{unpacked_installer}/IBExplorer/install.bin -i silent -DLICENSE_ACCEPTED=TRUE"
end

file "#{account_home}/IBM_Integration_Explorer" do
  user "#{account_username}"
  mode "755"
  action :create
  content  "/opt/mqm/bin/MQExplorer"
end

log "Finished installing IBM Integration Bus Runtime" do
  level :info
end
