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

CROSS_RPMFLAGS = $(RPMFLAGS) --with cross

CROSS_ARCHES := aarch64 ppc64le s390x

aarch64_cflags	:= -mtune=generic
pp64le_cflags	:= -mtune=generic -mlittle-endian
s390x_cflags	:= -mtune=generic -mzarch -march=z196

cc_aarch64	:= aarch64-gnu-gcc
cc_pp64le	:= powerpc64-gnu-gcc
cc_s390x	:= gcc-s390x-gnu

cxx_aarch64	:= aarch64-linux-gnu-cpp
cxx_pp64le	:= powerpc64-linux-gnu-cpp
cxx_s390x	:= s390x-linux-gnu-cpp


CROSS_PACKAGE_LIST = \
   cross-binutils-common cross-gcc-common diffstat \
   glibc-static ncurses-devel numactl-devel rng-tools

CROSS_PACKAGE_LIST += binutils-aarch64-linux-gnu gcc-aarch64-linux-gnu
CROSS_PACKAGE_LIST += binutils-ppc64le-linux-gnu gcc-powerpc64-linux-gnu
CROSS_PACKAGE_LIST += binutils-s390x-linux-gnu gcc-s390x-linux-gnu

wrong_arch = \
	echo -e "\nThis arch is $(uname -m), but this make must be executed on x86_64."

get_tar = \
	curl -L \
	-o $(SOURCES)/sparse-latest.tar.xz \
	https://mirrors.edge.kernel.org/pub/software/devel/sparse/dist/sparse-latest.tar.xz

# These are the cross-compile targets
# The final one will also build the src.rpm
#
# Currently, sparse only supports x86_64, ppc64, and aarch64.
#
all: cross_check
	@if [ "$(ARCH)" != "x86_64" ]; then $(call wrong_arch); fi
	$(call get_tar)
	@tar -xf $(SOURCES)/sparse-latest.tar.xz -C $(SOURCES)

	@for arch in $(CROSS_ARCHES); do \
		[ -d $(PWD)/lib-$$arch ] || mkdir -p $(PWD)/lib-$$arch; \
	done
	$(CROSS_RPMFLAGS) --define 'arch_cflags $(aarch64_cflags)' --target aarch64 -bb $(SPECS)/libsparse.spec
	$(CROSS_RPMFLAGS) --define 'arch_cflags $(pp64le_cflags)' --target pp64le -bb $(SPECS)/libsparse.spec
	$(CROSS_RPMFLAGS) --define 'arch_cflags $(s390x_cflags)' --target s390x -bb $(SPECS)/libsparse.spec

	$(RPMFLAGS) -ba $(SPECS)/libsparse.spec

clean:
	rm -rf $(SOURCES)/sparse-*
	rm -rf $(BUILD)
	# find $(RPMS)/ -name "*.rpm" -exec rm -vf '{}' \;

cross_check:
	@status=0; \
	for pkg in $(CROSS_PACKAGE_LIST); do \
		if ! rpm -q $$pkg > /dev/null 2>&1; then \
			status=1; \
			echo "Missing package: $$pkg"; \
		fi; \
	done; \
	if [ $$status -ne 0 ]; then \
		echo -e "\nThe abovelisted packages must be installed first.\n"; \
		exit 1; \
	fi
