

RPMBUILD	:= /usr/bin/rpmbuild
SPARSEDIR	:= /work/sparse
SPARSESRC	:= $(SPARSEDIR)/src
SOURCES 	:= $(SPARSESRC)
REDHAT		:= $(SPARSEDIR)/redhat
RPM		:= $(REDHAT)/rpm
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
	--define "_specdir	$(SPECS)" \

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

rh-cross-all-builds:
	$(shell [[ $(ARCH) == "x86_64" ]] || $(call wrong_arch))
	$(RPMFLAGS) --target ppc64 --with cross -ba $(SPECS)/libsparse.spec
	# make -C $(SPARSESRC) libsparse.a

clean:
	make -C $(SPARSESRC) clean
	rm -rf $(BUILD)
