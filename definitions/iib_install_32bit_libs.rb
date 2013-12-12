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
# Definition IBM_Integration_Bus::iib_install_32bit_libs
# 
# Install the 32 bit compact libs
#
################################################################################
define :iib_install_32bit_libs do
  #  
  # Install 32bit libraires becuase explorer installer requires them
  #
  if platform?("ubuntu")
    package "Install 32 bit libraries (explorer installer is 32bit only)" do
      package_name "ia32-libs"
      retries 30
      retry_delay 10
    end
  else
    yum_package "Install 32 bit libraries (explorer installer is 32bit only): gtk2.i686" do
      package_name "gtk2.i686"
      retries 30
      retry_delay 10
    end
	
    yum_package "Install 32 bit libraries (explorer installer is 32bit only): libXtst.i686" do
      package_name "libXtst.i686"
      retries 30
      retry_delay 10
    end
	
    yum_package "Install 32 bit libraries (explorer installer is 32bit only): glibc.i686" do
      package_name "glibc.i686"
      retries 30
      retry_delay 10
    end
	
    yum_package "Install 32 bit libraries (explorer installer is 32bit only): libgcc.i686" do
      package_name "libgcc.i686"
      retries 30
      retry_delay 10
    end
	
  end
end