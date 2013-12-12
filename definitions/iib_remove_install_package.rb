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
# Definition IBM_Integration_Bus::iib_remove_install_package
# 
# Remove unpacked files
#
################################################################################
define :iib_remove_install_package do
	unpack_dir     = "#{params[:unpack_dir]}"	
	directory "Remove unpacked tool image" do
		  action :delete
		  recursive true
		  path "#{unpack_dir}"
	end
end