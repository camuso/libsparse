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
ARCH		:= $(shell uname -i)

RPM		:= $(PWD)/rpm
SOURCES 	:= $(RPM)/SOURCES
BUILD		:= $(RPM)/BUILD
RPMS		:= $(RPM)/RPMS
SRPMS		:= $(RPM)/SRPMS
SPECS		:= $(RPM)/SPECS
SPARSESRC	:= $(wildcard $(SOURCES)/sparse-?????)

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

get_tar = \
	curl -L \
	-o $(SOURCES)/sparse-latest.tar.xz \
	https://mirrors.edge.kernel.org/pub/software/devel/sparse/dist/sparse-latest.tar.xz

# These are the cross-compile targets
# The final one will also build the src.rpm
#
all:
	$(shell [[ $(ARCH) == "x86_64" ]] || $(call wrong_arch))
	$(call get_tar)
	tar -xf $(SOURCES)/sparse-latest.tar.xz -C $(SOURCES)
	find . | grep spec
	echo "$(RPM)"
	echo "$(SOURCES)"
#	$(RPMFLAGS) --target i686    --with cross -bb $(SPECS)/libsparse.spec
#	$(RPMFLAGS) --target s390x   --with cross -bb $(SPECS)/libsparse.spec
	$(RPMFLAGS) --target ppc64   --with cross -bb $(SPECS)/libsparse.spec
#	$(RPMFLAGS) --target ppc64le --with cross -bb $(SPECS)/libsparse.spec
	$(RPMFLAGS) --target aarch64 --with cross -bb $(SPECS)/libsparse.spec
	$(RPMFLAGS) -ba $(SPECS)/libsparse.spec

clean:
	rm -rf $(SOURCES)/sparse-*
	rm -rf $(BUILD)
	# find $(RPMS)/ -name "*.rpm" -exec rm -vf '{}' \;
