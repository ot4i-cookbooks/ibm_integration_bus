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
# Definition IBM_Integration_Bus::iib_tune_os
# 
# Modifies the OS parameters to recommended values for running IIB
#
################################################################################
define :iib_tune_os do
  username   = node['ibm_integration_bus']['account_username'];
  # set values if above the max value or if not in file
  Chef::Recipe::IBMIntegrationBus.update_sysctl_max("net.ipv4.tcp_fin_timeout","30");
  Chef::Recipe::IBMIntegrationBus.update_sysctl_max("net.ipv4.tcp_keepalive_time","300");
  # set values no matter what the current value is
  Chef::Recipe::IBMIntegrationBus.update_sysctl("net.ipv4.tcp_keepalive_intvl","15");
  Chef::Recipe::IBMIntegrationBus.update_sysctl("net.ipv4.tcp_keepalive_probes","5");
  Chef::Recipe::IBMIntegrationBus.update_sysctl("kernel.sem","500 256000 250 1024");
  # set values if below a min value or not in the file
  Chef::Recipe::IBMIntegrationBus.update_sysctl_min("kernel.shmmni","4096");
  Chef::Recipe::IBMIntegrationBus.update_sysctl_min("kernel.shmall","2097152");
  Chef::Recipe::IBMIntegrationBus.update_sysctl_min("kernel.shmmax","268435456");
  Chef::Recipe::IBMIntegrationBus.update_sysctl_min("fs.file-max","524288");
  Chef::Recipe::IBMIntegrationBus.update_sysctl_min("kernel.shmall","2097152");
  Chef::Recipe::IBMIntegrationBus.update_sysctl_min("net.core.netdev_max_backlog","3000");
  Chef::Recipe::IBMIntegrationBus.update_sysctl_min("net.core.somaxconn","3000");
#
# The operating system needs to be tuned correctly to run both MQ and IIB.
#
bash "Tune operating system for running both IIB and MQ" do
  user "root"
  flags "-e"
  returns [0]
  code <<-EOS
# ulimit - for IIB user
sed -i '/#{username} hard   nofile'/d               /etc/security/limits.conf
sed -i '/End of file/i#{username} hard   nofile           8192'  /etc/security/limits.conf
sed -i '/#{username} soft   nofile'/d               /etc/security/limits.conf
sed -i '/End of file/i#{username} soft   nofile           8192'  /etc/security/limits.conf

# ulimit - for MQ
sed -i '/mqm              hard   nofile'/d               /etc/security/limits.conf
sed -i '/End of file/i\mqm              hard   nofile           10240' /etc/security/limits.conf
sed -i '/mqm              soft   nofile'/d               /etc/security/limits.conf
sed -i '/End of file/i\mqm              soft   nofile           10240' /etc/security/limits.conf
sed -i '/mqm              hard   nproc'/d                /etc/security/limits.conf
sed -i '/End of file/i\mqm              hard   nproc            4096'  /etc/security/limits.conf
sed -i '/mqm              soft   nproc'/d                /etc/security/limits.conf
sed -i '/End of file/i\mqm              soft   nproc            4096'  /etc/security/limits.conf

# comment out net bridge params as these cause sysctl -p to fail
sed -i '/net.bridge.bridge-nf-call.*/ s/^/#/g' /etc/sysctl.conf
# now update the parameters on the system dynamically
sysctl -p
sed -i '/net.bridge.bridge-nf-call.*/ s/#//g' /etc/sysctl.conf

# sudoers - for MQ
if [ -f /etc/sudoers ]; then
    sed -i '/requiretty/ s/^.*$/#Defaults requiretty/g' /etc/sudoers
fi

EOS
end
end