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
# Definition IBM_Integration_Bus::iib_remove_runtime
# 
# Remove any existing iib runtime
#
################################################################################
define :iib_remove_runtime do

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

end