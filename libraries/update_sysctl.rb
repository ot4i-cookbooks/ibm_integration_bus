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
# Library IBM_Integration_Bus::update_sysctl,update_sysctl_min, update_sysctl_max
# 
# Updates kernal parameters
#
################################################################################
require 'chef/resource/package'
class Chef::Recipe::IBMIntegrationBus
  def self.update_sysctl(name,value)
	`sed -i '/#{name}/d' /etc/sysctl.conf`
    `echo "#{name} = #{value}" >> /etc/sysctl.conf`
  end
  
  def self.update_sysctl_min(name,min_value)
    file = File.open("/etc/sysctl.conf", "rb")
    testString = file.read
    firstMatch = testString.match(/#{name}\w*=\w*(\d*)/m);
	if firstMatch != nil
      actual_value = firstMatch[1];
	else
	  actual_value = 0;
	end
	if actual_value.to_i < min_value.to_i
	  `sed -i '/#{name}/d' /etc/sysctl.conf`
      `echo "#{name} = #{min_value}" >> /etc/sysctl.conf`
	end
  end
  
  def self.update_sysctl_max(name,max_value)
    file = File.open("/etc/sysctl.conf", "rb")
    testString = file.read
    firstMatch = testString.match(/#{name}\w*=\w*(\d*)/m);
	if firstMatch != nil
      actual_value = firstMatch[1];
	else
	  actual_value = 1000000000;
	end
	if actual_value.to_i > max_value.to_i
	  `sed -i '/#{name}/d' /etc/sysctl.conf`
      `echo "#{name} = #{max_value}" >> /etc/sysctl.conf`
	end
  end
end