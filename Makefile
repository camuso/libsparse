###########################################################################
#
# Makefile for libsparse.a
#
# This make invokes cross compilers to create libsparse.a for the following
# architectures
#
#	i386
#	s390x
#	ppc64
#	ppc64le
#	x86_64
#
###########################################################################

RPMBUILD	:= /usr/bin/rpmbuild
SPARSEDIR	:= /work/sparse
SPARSESRC	:= $(SPARSEDIR)/src
REDHAT		:= $(SPARSEDIR)/redhat
RPM		:= $(REDHAT)/rpm
SOURCES 	:= $(RPM)/SOURCES
BUILD		:= $(RPM)/BUILD
RPMS		:= $(RPM)/RPMS
SRPMS		:= $(RPM)/SRPMS
SPECS		:= $(RPM)/SPECS
ARCH		:= $(shell uname -i)

RPMFLAGS = $(RPMBUILD) \
	--define "_topdir	$(RPM)" \
	--define "_sourcedir	$(SOURCES)" \
	--define "_builddir	$(BUILD)" \
	--define "_srcrpmdir	$(SRPMS)" \
	--define "_rpmdir	$(RPMS)" \
	--define "_specdir	$(SPECS)"

CROSS_PACKAGE_LIST = binutils-powerpc64-linux-gnu \
		     binutils-s390x-linux-gnu \
		     cross-binutils-common \
		     cross-gcc-common \
		     gcc-powerpc64-linux-gnu \
		     gcc-s390x-linux-gnu \
		     glibc-static \
		     ncurses-devel \
		     numactl-devel \
		     diffstat

wrong_arch = 	\
	echo -e "\nThis arch is $(uname -i), but this make must be executed on x86_64.";

make_tar = \
	tar --exclude-vcs -czf $(SOURCES)/libsparse.tar.gz -C $(SPARSESRC) .

# These are the cross-compile targets
# The final one will also build the src.rpm
#
all:
	$(shell [[ $(ARCH) == "x86_64" ]] || $(call wrong_arch))
	$(call make_tar)
	$(RPMFLAGS) --target i686 --with cross -bb $(SPECS)/libsparse.spec
	$(RPMFLAGS) --target s390x --with cross -bb $(SPECS)/libsparse.spec
	$(RPMFLAGS) --target ppc64 --with cross -bb $(SPECS)/libsparse.spec
	$(RPMFLAGS) --target ppc64le --with cross -bb $(SPECS)/libsparse.spec
	$(RPMFLAGS) --target aarch64 --with cross -bb $(SPECS)/libsparse.spec
	$(RPMFLAGS) -ba $(SPECS)/libsparse.spec

clean:
	make -C $(SPARSESRC) clean
	rm -rf $(BUILD)
	find $(RPMS)/ -name "*.rpm" -exec rm -vf '{}' \;
