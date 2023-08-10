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

get_tar = \
	curl -L \
	-o $(SOURCES)/sparse-latest.tar.xz \
	https://mirrors.edge.kernel.org/pub/software/devel/sparse/dist/sparse-latest.tar.xz

get_version = \
	nv=$(tar tzf $(SOURCES)/sparse-latest.tar.xz | head -n 1 | awk -F/ '{print $1}'); \


# These are the cross-compile targets
# The final one will also build the src.rpm
#
# Currently, sparse only supports x86_64, ppc64, and aarch64.
#
all:
	$(call get_tar)
	@tar -xf $(SOURCES)/sparse-latest.tar.xz -C $(SOURCES)
	nv=$$(tar -tf $(SOURCES)/sparse-latest.tar.xz | head -n 1 | cut -d'/' -f1 | cut -d'-' -f2 ); \
	echo "nv: $$nv"; \
	$(RPMFLAGS) --define "version $$nv" -ba $(SPECS)/libsparse.spec

clean:
	rm -rf $(SOURCES)/sparse-*
	rm -rf $(BUILD)
	# find $(RPMS)/ -name "*.rpm" -exec rm -vf '{}' \;
