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

ifndef SRCDIR
	SRCDIR	:= $(shell pwd)/../../
endif

include ../common.mk

CONTROL		:= $(SRCDIR)/pkgs/deb/debian/control
VERSION		:= $(MAJOR).$(MINOR).$(PATCH)
PKGSRCDIR	:= $(PKGNAME)-$(VERSION)
PKG		:= $(PKGNAME)_$(VERSION)
TARBALL		:= $(PKGSRCDIR).tar.gz
ARCH		:= $(shell dpkg-architecture -q DEB_BUILD_ARCH)
DEBFILE		:= $(SRCDIR)/$(PKG)_$(ARCH).deb
TARGET		:= $(notdir $(DEBFILE))

default: $(CONTROL)
	if which dpkg-buildpackage; then \
		cp -f $(CONTROL) $(CONTROL).copy; \
		sed -i 's/^Source.*/Source: $(PKGNAME)/' $(CONTROL); \
		sed -i 's/^Package.*/Package: $(PKGNAME)/' $(CONTROL); \
		sed -i 's/^Stanards-Version.*/Standards-Version: $(VERSION)/' $(CONTROL); \
		sed -i '/^Description/c\Description: $(SUMMARY)' $(CONTROL); \
		tail -n1 $(CONTROL) | grep '^Description' && echo "$$DESCRIPTION" >> $(CONTROL); \
		cd $(SRCDIR); ln -sfn pkgs/deb/debian; dpkg-buildpackage -rfakeroot; \
	fi
	mv -f $(CONTROL).copy $(CONTROL)

clean:
	rm -f $(TARGET)

export PKGNAME MAJOR MINOR PATCH VERSION ARCH
