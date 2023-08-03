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

RPMBUILD	:= $(shell which rpmbuild)
ARCH		:= $(shell uname -m)

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

ARCHES := aarch64 ppc64 x86_64

CROSS_PACKAGE_LIST := binutils-powerpc64-linux-gnu \
		      binutils-s390x-linux-gnu \
		      cross-binutils-common \
		      cross-gcc-common \
		      gcc-powerpc64-linux-gnu \
		      gcc-s390x-linux-gnu \
		      glibc-static \
		      ncurses-devel \
		      numactl-devel \
		      diffstat

wrong_arch = \
	echo -e "\nThis arch is $(uname -m), but this make must be executed on x86_64.";

get_tar = \
	curl -L \
	-o $(SOURCES)/sparse-latest.tar.xz \
	https://mirrors.edge.kernel.org/pub/software/devel/sparse/dist/sparse-latest.tar.xz

# These are the cross-compile targets
# The final one will also build the src.rpm
#
# Currently, sparse only supports x86_64, ppc64, and aarch64.
#
all:
	$(shell [[ $(ARCH) == "x86_64" ]] || $(call wrong_arch))
	./download_cross $(CROSS_PACKAGE_LIST)
	$(call get_tar)
	@tar -xf $(SOURCES)/sparse-latest.tar.xz -C $(SOURCES)

	@for arch in $(ARCHES); do \
		echo; echo "*****"; echo "arch = $$arch"; echo "*****"; \
		[ -d $(PWD)/lib-$$arch ] || mkdir -p $(PWD)/lib-$$arch; \
		$(RPMFLAGS) --target $$arch --with cross -bb $(SPECS)/libsparse.spec; \
	done

clean:
	rm -rf $(SOURCES)/sparse-*
	rm -rf $(BUILD)
	# find $(RPMS)/ -name "*.rpm" -exec rm -vf '{}' \;
