# Copyright (C) 2023 Gyoza Associate,Inc - All Rights Reserved
# GPLv3
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

ifndef PKGNAME
	PKGNAME := gyoza
endif
ifndef MAJOR
	MAJOR := 0
endif
ifndef MINOR
	MINOR := 0
endif
ifndef PATCH
	PATCH := 1
endif

ifndef VERSION
	VERSION := $(MAJOR).$(MINOR).$(PATCH)
endif

ifndef BUILDMETADATA
	BUILDMETADATA := $(shell date +"%Y%m%d_%H%M%S")
endif

ifndef SUMMARY
	SUMMARY := Utility to create USB booting device with multiple OS
endif

ifndef DESCRIPTION
define DESCRIPTION
 A utility to create USB booting device with pre-defined supported Linux, BSD,
 SystemV, FreeDOS and other commercial OS such as VMware ESXi and Microsoft
 DOS and Windows.
endef
endif

ifeq (,$(RELEASE))
	ifneq (,$(and $(PRERELEASE), $(BUILDMETADATA)))
		RELEASE := $(PRERELEASE)+$(BUILDMETADATA)
	else
		RELEASE := $(PRERELEASE)$(BUILDMETADATA)
	endif
endif

export PKGNAME MAJOR MINOR PATCH VERSION RELEASE PRERELEASE BUILDMETADATA SUMMARY DESCRIPTION
