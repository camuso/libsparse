Name:		libsparse
Version:	0.5.0
Release:	1%{?dist}
Summary:	Library of Sparse Routines
BuildRoot:	%{_topdir}/BUILDROOT/

License:        GPLv2
URL:		http://git.kernel.org/cgit/devel/sparse/sparse.git/
#Source0:	%{_topdir}/%{name}-%{version}.tar.gz

BuildRequires:	gcc >= 4.8
Requires:	gcc >= 4.8

%description
Installs libsparse.a, the static library of the sparse project.

%prep
#%setup -q
echo %{_topdir}
mkdir -p %{_builddir}/%{name}-%{version}
cd %{_builddir}/%{name}-%{version}
rsync -Pvat --cvs-exclude --exclude=*.swp %{_sourcedir}/ .

%build
cd %{_builddir}/%{name}-%{version}
make %{?_smp_mflags} libsparse.a

%install
mkdir -p $RPM_BUILD_ROOT%{_libdir}
cp %{_topdir}/BUILD/%{name}-%{version}/libsparse.a $RPM_BUILD_ROOT%{_libdir}

%files
%defattr(-,root,root)
%{_libdir}/libsparse.a

%changelog
* Wed Nov 16 2016 Tony Camuso <tcamuso@redhat.com> - 0.5.0-1
- Initial spec for building libsparse.a
