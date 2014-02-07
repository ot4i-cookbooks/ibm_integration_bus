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

require 'singleton'

# Just a place for us to centralize 'puts' incase we want to re-direct it later
class IBLogger

	include Singleton
	
	def log(message)
		puts(message)
	end
	
end