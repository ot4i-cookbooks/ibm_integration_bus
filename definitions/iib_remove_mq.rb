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
# Definition IBM_Integration_Bus::iib_remove_mq
# 
# Remove any existing mq
#
################################################################################
define :iib_remove_mq do 
  testString = `ps -ef | grep -e /opt/mqm/bin` ;
  scanMatch = testString.scan(/mqm\ *(\d*)[^\n]*/m);
  scanMatch.each do |match_entry|
    if match_entry[0] != ""
      `kill -9 #{match_entry[0]}`
      log "Killing MQ process: #{match_entry[0]}" do
        level :info
      end
    end
  end
  testString = `ps -ef | grep -e runmqlsr` ;
  scanMatch = testString.scan(/mqm\ *(\d*)[^\n]*/m);
  scanMatch.each do |match_entry|
    if match_entry[0] != ""
      `kill -9 #{match_entry[0]}`
      log "Killing MQ process: #{match_entry[0]}" do
        level :info
      end
    end
  end

  if platform?("ubuntu")
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

  else
  execute "Remove any previous install of IBM MQ in rpm" do
    user "root"
    returns [0,1]
    retries 30
    retry_delay 10
    command "sudo rpm -e `sudo rpm -qa | grep MQSeries`"
  end
  
  end
  
  directory "Clear up MQ install directory if it exists" do
    action :delete
    recursive true
    path "/opt/mqm"
  end
end