###########################################################################
#
# libsparse.spec
#
# This spec file is intended to be invoked only from a Makefile that has
# correctly defined the directory tree in which this will be built.
# The make defines the following make variables and redefines the rpmbuild
# directory macros to correspond to the build environment.
#
#	RPMBUILD	:= /usr/bin/rpmbuild
#	SPARSEDIR	:= /work/sparse
#	SPARSESRC	:= $(SPARSEDIR)/src
#	REDHAT		:= $(SPARSEDIR)/redhat
#	RPM		:= $(REDHAT)/rpm
#	SOURCES 	:= $(RPM)/SOURCES
#	BUILD		:= $(RPM)/BUILD
#	RPMS		:= $(RPM)/RPMS
#	SRPMS		:= $(RPM)/SRPMS
#	SPECS		:= $(RPM)/SPECS
#	ARCH		:= $(shell uname -i)
#
#	RPMFLAGS = $(RPMBUILD)
#		--define "_topdir	$(RPM)" \
#		--define "_sourcedir	$(SOURCES)" \
#		--define "_builddir	$(BUILD)" \
#		--define "_srcrpmdir	$(SRPMS)" \
#		--define "_rpmdir	$(RPMS)" \
#		--define "_specdir	$(SPECS)" \
#
# The Makefile also creates the libsparse.tar.gz archive from whatever is
# in the $(SPARSESRC) directory. Because this archive file is not named
# according to the rpm standard {name)-{version}, the setup macro must
# be informed accordingly.
#
###########################################################################

Name:		libsparse
Version:	0.5.0
Release:	1%{?dist}
Summary:	Library of Sparse Routines
BuildRoot:	%{_topdir}/BUILDROOT/

License:        GPLv2
URL:		http://git.kernel.org/cgit/devel/sparse/sparse.git/
Source0:	%{_srcdir}/libsparse.tar.gz

BuildRequires:	gcc >= 4.8
Requires:	gcc >= 4.8

%description
Installs libsparse.a, the static library of the sparse project.

%global debug_package %{nil}

# The archive does not have the form name-version, just the name.
# The -c tells %setup to create the directory named, rather than the
# default. The -n tells %setup the name of the directory to cd into in
# order to perform the build.
#
%prep
%setup -q -c libsparse -n libsparse

%build
cd %{_builddir}/%{name}
make %{?_smp_mflags} libsparse.a

%install
mkdir -p $RPM_BUILD_ROOT%{_libdir}
cp %{_topdir}/BUILD/%{name}/libsparse.a $RPM_BUILD_ROOT%{_libdir}

%files
%defattr(-,root,root)
%{_libdir}/libsparse.a

%changelog
* Wed Nov 16 2016 Tony Camuso <tcamuso@redhat.com> - 0.5.0-1
- Initial spec for building libsparse.a
