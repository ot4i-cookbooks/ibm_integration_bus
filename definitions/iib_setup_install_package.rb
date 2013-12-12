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
# Definition IBM_Integration_Bus::iib_setup_install_package
# 
# Unpack and setup the iib instal package
#
################################################################################
define :iib_setup_install_package do
		package_site_url   = node['ibm_integration_bus']['package_site_url'];
        package_name       = node['ibm_integration_bus']['package_name'];
        package_url        = "#{package_site_url}/#{package_name}"; 
        download_path      = "#{Chef::Config[:file_cache_path]}/#{package_name}"; 
        unpack_dir         = "#{Chef::Config[:file_cache_path]}/iib_installer";
		directory "Remove unpacked runtime image if it exists" do
			  action :delete
			  recursive true
			  path "#{unpack_dir}"
		end

		directory "Create directory to unpacked runtime to: #{unpack_dir }" do
			  action :create
			  recursive true
			  path "#{unpack_dir}"
		end 
log "#{:package_url}" do
  level :info
end
		remote_file "Download the install image package from: #{package_url} to: #{download_path}"  do
		  path "#{download_path}"
		  source "#{package_url}"
		  retries 30
		  retry_delay 10
		  if File.exist?("#{download_path}") && File.size("#{download_path}") == 0
			action :create
		  else
			action :create_if_missing
		  end
		  end

		ruby_block "Checking the downloaded install image package from: #{download_path} has content" do
		  action :run
		  block do
			if File.exist?("#{download_path}") && File.size("#{download_path}") == 0
			  raise "Downloaded install package is invalid. Check the URL #{package_url} is correct"
			end
		  end
		end


		execute "Unpack runtime image" do
		  user "root"
		  command "tar -xzf #{download_path} --strip-components=1 -C #{unpack_dir}"
	end
  end