# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
CMAKE_BUILD_TYPE="Release"
LLVM_VER=10

inherit python-any-r1 cmake-multilib flag-o-matic toolchain-funcs

DESCRIPTION="OpenCL implementation for Intel GPUs"
HOMEPAGE="https://01.org/beignet"

IUSE="beignet-generic debug ocl20 ocl-icd"
# beignet-egl build requires mesa sources

LICENSE="LGPL-2.1+"
SLOT="0"

if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="git://anongit.freedesktop.org/beignet"
#	EGIT_BRANCH=newRT
	KEYWORDS=""
else
	KEYWORDS="~amd64"
	SRC_URI="https://01.org/sites/default/files/${P}-source.tar.gz"
	S=${WORKDIR}/Beignet-${PV}-Source
fi

COMMON="${PYTHON_DEPS}
	media-libs/mesa
	sys-devel/clang:${LLVM_VER}
	sys-devel/llvm:${LLVM_VER}
	x11-libs/libdrm[video_cards_intel]
	x11-libs/libXext
	x11-libs/libXfixes
	!beignet-generic? ( sys-apps/pciutils )
"
#RDEPEND="${COMMON}
#	app-eselect/eselect-opencl"
DEPEND="${COMMON}
	${PYTHON_DEPS}
	ocl-icd? ( dev-libs/ocl-icd )
	virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/debian/Debian-compliant-compiler-flags-handling.patch
	"${FILESDIR}"/debian/support-kfreebsd.patch
	"${FILESDIR}"/debian/reduce-notfound-output.patch
	"${FILESDIR}"/debian/update-docs.patch
	"${FILESDIR}"/debian/ship-test-tool.patch
	"${FILESDIR}"/debian/find-python35.patch
	"${FILESDIR}"/debian/docs-broken-links.patch
	"${FILESDIR}"/debian/cl_accelerator_intel.patch
	"${FILESDIR}"/debian/add-appstream-metadata.patch
#	"${FILESDIR}"/debian/static-llvm.patch
	"${FILESDIR}"/debian/grammar.patch
	"${FILESDIR}"/debian/clearer-type-errors.patch
	"${FILESDIR}"/debian/885423.patch
	"${FILESDIR}"/debian/disable-wayland-warning.patch
	"${FILESDIR}"/debian/eventchain-memory-leak.patch
	"${FILESDIR}"/debian/llvm6-support.patch
	"${FILESDIR}"/debian/llvm7-support.patch
	"${FILESDIR}"/debian/accept-old-create-queue.patch
	"${FILESDIR}"/debian/reduce-notfound-output2.patch
	"${FILESDIR}"/debian/coffeelake.patch
	"${FILESDIR}"/debian/in-order-queue.patch
	"${FILESDIR}"/debian/reproducibility.patch
	"${FILESDIR}"/debian/accept-ignore--g.patch
	"${FILESDIR}"/debian/llvm8-support.patch
	"${FILESDIR}"/debian/llvm9-support.patch
	"${FILESDIR}"/no-debian-multiarch-r3.patch
	"${FILESDIR}"/${PN}-1.2.0_no-hardcoded-cflags.patch
	"${FILESDIR}"/llvm-terminfo.patch
	"${FILESDIR}"/${PN}-9999-libOpenCL.patch
	"${FILESDIR}"/${PN}-9999-llvm-libs-tr.patch
	#"${FILESDIR}"/${PN}-9999-silence-dri2-failure-r2.patch
	"${FILESDIR}"/${PN}-9999-no-self-test.patch
	"${FILESDIR}"/GBE-let-GenRegister-reg-never-return-uninitialized-m.patch
	"${FILESDIR}"/${P}-c++14.patch
	"${FILESDIR}"/${P}-llvm10-r1.patch
)

DOCS=(
	docs/.
)

pkg_pretend() {
	if [[ ${MERGE_TYPE} != "binary" ]]; then
		if tc-is-gcc; then
			if [[ $(gcc-major-version) -eq 4 ]] && [[ $(gcc-minor-version) -lt 6 ]]; then
				eerror "Compilation with gcc older than 4.6 is not supported"
				die "Too old gcc found."
			fi
		fi
	fi
}

pkg_setup() {
	python_setup
}

src_prepare() {
	# See Bug #593968
	append-flags -fPIC -fno-strict-aliasing

	cmake-utils_src_prepare
	# We cannot run tests because they require permissions to access
	# the hardware, and building them is very time-consuming.
	cmake_comment_add_subdirectory utests
}

multilib_src_configure() {
	local mycmakeargs=()
	VENDOR_DIR="/usr/$(get_libdir)/OpenCL/vendors/${PN}"

	if [[ ${CC} == clang* ]]; then
		filter-flags -f*graphite -f*loop-*
		filter-flags -mfpmath* -frceorder-blocks-and-partition
		filter-flags -flto* -fuse-linker-plugin
		filter-flags -ftracer -fvect-cost-model -ftree*
		mycmakeargs+=(
			-DCOMPILER=CLANG
		)
	else
		mycmakeargs+=(
			-DCOMPILER=GCC
		)
	fi

	# Pre-compiled headers otherwise result in redefined symbols (gcc only)
	if [[ ${CC} == gcc* ]]; then
		append-flags -fpch-deps
	fi

	local mycmakeargs=(
		-DBEIGNET_INSTALL_DIR="${VENDOR_DIR}"
	)

	if ! use ocl-icd; then
		mycmakeargs+=(
			-DOCLICD_COMPAT=0
		)
	fi

	if ! use ocl20; then
		mycmakeargs+=(
			-DENABLE_OPENCL_20=0
		)
	fi

	if ! use beignet-generic; then
		mycmakeargs+=(
			-DGEN_PCI_ID=$(. "${S}"/GetGenID.sh)
		)
	fi

	mycmakeargs+=(
		-DLLVM_INSTALL_DIR="/usr/lib/llvm/${LLVM_VER}/bin"
		-DLLVM_CONFIG_EXECUTABLE="/usr/lib/llvm/${LLVM_VER}/bin/$(get_abi_CHOST ${ABI})-llvm-config"
	)

	if use debug; then
		export CMAKE_BUILD_TYPE=Debug
	fi

	cmake-utils_src_configure
}

multilib_src_install() {
	VENDOR_DIR="/usr/$(get_libdir)/OpenCL/vendors/${PN}"

	cmake-utils_src_install

	# Remove upstream icd
	rm -f "${ED}"/etc/OpenCL/vendors/intel-beignet.icd

	# Headers should only be in VENDOR_DIR
	rm -rf "${ED}"/usr/include

	insinto /etc/OpenCL/vendors/
	echo "${VENDOR_DIR}/libOpenCL.so" > "${PN}-${ABI}.icd" || die "Failed to generate ICD file"
	doins "${PN}-${ABI}.icd"
}
