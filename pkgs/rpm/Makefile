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
	SRCDIR	:= $(shell pwd)/../..
endif

include ../common.mk

SPEC		:= rpm.spec
VERSION		:= $(MAJOR).$(MINOR).$(PATCH)
PKGSRCDIR	:= $(PKGNAME)-$(VERSION)
PKG		:= $(PKGNAME)-$(VERSION)-$(RELEASE)
TARBALL		:= $(PKGSRCDIR).tar.gz
RPMBUILD	:= $(shell pwd)/.rpmbuild
ARCH		:= $(shell rpmbuild -E %{_arch})
DIST		:= $(shell rpmbuild -E %{dist})
RPMFILE		:= $(RPMBUILD)/RPMS/$(ARCH)/$(PKG)$(DIST).$(ARCH).rpm
TARGET		:= $(notdir $(RPMFILE))

default: $(SPEC)
	cd $(SRCDIR)/..; ln -sfn $(SRCDIR) $(PKGSRCDIR);\
	tar --exclude .git* --exclude .svn* -cvzhf $(TARBALL) $(PKGSRCDIR); rm -f $(PKGSRCDIR)
	rpmbuild -ba --rmsource --clean \
		--define "_topdir $(RPMBUILD)" \
		--define "_sourcedir $(SRCDIR)/.." \
		--define "__arch_install_post %{nil}" \
		--define "PKGNAME $(PKGNAME)" \
		--define "VERSION $(VERSION)" \
		--define "SUMMARY $$SUMMARY" \
		--define "DESCRIPTION $$DESCRIPTION" \
		--define "RELEASE $(RELEASE)" $(SPEC)
	mv $(RPMFILE) $(TARGET)
		
clean:
	rm *.rpm
	rm -rf $(RPMBUILD)

.PHONE: clean
