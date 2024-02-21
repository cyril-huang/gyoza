#
# Copyright (C) 2023 Gyoza Associate, Inc - All Rights Reserved
# GPLv3
#
%define pkg_name %(echo $PKGNAME)
%define pkg_version %(echo $VERSION)
%define pkg_release %(echo $RELEASE)
%define pkg_summary %(echo $SUMMARY)
%define pkg_description %(echo $DESCRIPTION)

Name: %{pkg_name}
Version: %{pkg_version}
Release: %{pkg_release}%{?dist}
Summary: %{pkg_summary}
License: GPLv3
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{BUILDROOT}
Requires: udisks2 util-linux parted python3-libs qemu-kvm qemu-img edk2-ovmf wget grub2-efi-x64-modules grub2-pc-modules dosfstools 
Suggests: wimtools dialog

%description
%{pkg_description}

%global debug_package %{nil}

%prep
%setup -q
%build
make
%install
make prefix=$RPM_BUILD_ROOT install
%clean
[ $RPM_BUILD_ROOT != "/" ] && rm -rf $RPM_BUILD_ROOT

%pre
echo "performing %{name} pre-install"
%post
echo "performing %{name} post-install"
%preun
echo "performing %{name} pre-uninstall"
%postun
echo "performing %{name} post-uninstall"

%files
%attr(0755, root, root) %{_bindir}/%{name}
%attr(0644, root, root) %{_mandir}/man8/%{name}.8.gz

%changelog
* Thu Feb 15 2024 Cyril Huang <cyril_huang@gmx.com>
- Init commit 0.0.1 version
