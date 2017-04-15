# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )
CMAKE_BUILD_TYPE="Release"

inherit python-any-r1 cmake-multilib flag-o-matic toolchain-funcs

DESCRIPTION="OpenCL implementation for Intel GPUs"
HOMEPAGE="https://01.org/beignet"

IUSE="beignet-generic"
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
	sys-devel/clang
	>=sys-devel/llvm-3.5
	x11-libs/libdrm[video_cards_intel]
	x11-libs/libXext
	x11-libs/libXfixes
	!beignet-generic? ( sys-apps/pciutils )
"
RDEPEND="${COMMON}
	app-eselect/eselect-opencl"
DEPEND="${COMMON}
	${PYTHON_DEPS}
	virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/no-debian-multiarch-r2.patch
	"${FILESDIR}"/${PN}-1.2.0_no-hardcoded-cflags.patch
	"${FILESDIR}"/llvm-terminfo.patch
	"${FILESDIR}"/beignet-9999-libOpenCL.patch
	"${FILESDIR}"/beignet-9999-llvm-libs-tr.patch
	"${FILESDIR}"/beignet-9999-silence-dri2-failure-r2.patch
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
	VENDOR_DIR="/usr/$(get_libdir)/OpenCL/vendors/${PN}"

	if [[ ${CC} == clang ]]; then
		filter-flags -f*graphite -f*loop-*
		filter-flags -mfpmath* -freorder-blocks-and-partition
		filter-flags -flto* -fuse-linker-plugin
		filter-flags -ftracer -fvect-cost-model -ftree*
	fi

	# Pre-compiled headers otherwise result in redefined symbols (gcc only)
	if [[ ${CC} == gcc* ]]; then
		append-flags -fpch-deps
	fi

	local mycmakeargs=(
		-DBEIGNET_INSTALL_DIR="${VENDOR_DIR}"
	)

	if ! use beignet-generic; then
		mycmakeargs+=(
			-DGEN_PCI_ID=$(. "${S}"/GetGenID.sh)
		)
	fi

	multilib_is_native_abi || mycmakeargs+=(
		-DLLVM_CONFIG_EXECUTABLE="${EPREFIX}/usr/bin/$(get_abi_CHOST ${ABI})-llvm-config"
	)

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
