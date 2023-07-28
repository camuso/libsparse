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
Version:	0.6.4
Release:	1%{?dist}
Summary:	Library of Sparse Routines
BuildRoot:	%{_topdir}/BUILDROOT/

License:        GPLv2
URL:		https://git.kernel.org/pub/scm/devel/sparse/sparse.git/
Source0:        sparse-latest.tar.xz
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
CFLAGS="%{optflags}"; export CFLAGS
LDFLAGS="%{build_ldflags}"; export LDFLAGS
cd %{_builddir}/%{name}/sparse-%{version}
echo "**** PWD: ${PWD} ****"
make %{?_smp_mflags} libsparse.a

%install
cd %{_builddir}/%{name}/sparse-%{version}
mkdir -p $RPM_BUILD_ROOT%{_libdir}
mkdir -p $RPM_BUILD_ROOT%{_includedir}/sparse
cp %{_topdir}/BUILD/%{name}/sparse-%{version}/libsparse.a $RPM_BUILD_ROOT%{_libdir}
cp %{_topdir}/BUILD/libsparse/sparse-%{version}/*.h $RPM_BUILD_ROOT%{_includedir}/sparse

%files
%defattr(-,root,root)
%{_libdir}/libsparse.a
%{_includedir}/sparse/*.h

%changelog
* Fri Jul 28 2023 Tony Camuso <tcamuso@redhat.com> - 0.6.4-1
- Build it all in the libsparse directory instead of having a separate
  directory for the sparse sources.
- Omit i686, ppc64le, and s390x from the build.
* Wed Jul 22 2020 Tony Camuso <tcamuso@redhat.com> - 0.6.2-1
- Integrate latest pull from sparse repo.
- Rework on the Wall_off patch.
* Fri May 17 2019 Tony Camuso <tcamuso@redhat.com> - 0.6.1-2
- Install the .h files to %{_includedir}/sparse (/usr/include/sparse)
* Thu May 16 2019 Tony Camuso <tcamuso@redhat.com> - 0.6.1-1
- Did a git pull from the upstream repo.
- Reworked the Wall_off patch to make it apply cleanly to the
  latest sparse pull.
- Updated the NVR to reflect the upstream 0.6.1-rc1
* Thu Mar 30 2017 Tony Camuso <tcamuso@redhat.com> - 0.5.0-2
- Add patch to quell warnings
* Wed Nov 16 2016 Tony Camuso <tcamuso@redhat.com> - 0.5.0-1
- Initial spec for building libsparse.a
