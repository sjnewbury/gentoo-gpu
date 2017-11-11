# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{4,5,6} )

if [[ "${PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/KhronosGroup/Vulkan-LoaderAndValidationLayers.git"
	inherit git-r3
else
	KEYWORDS="~amd64"
	SRC_URI="https://github.com/KhronosGroup/Vulkan-LoaderAndValidationLayers/archive/sdk-${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/Vulkan-LoaderAndValidationLayers-sdk-${PV}"
fi

inherit python-any-r1 cmake-multilib

DESCRIPTION="Vulkan Installable Client Driver (ICD) Loader"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-LoaderAndValidationLayers"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="+layers wayland X vulkaninfo"

RDEPEND=""
DEPEND="${PYTHON_DEPS}
	dev-util/glslang:=
	dev-util/SPIRV-Tools:=[${MULTILIB_USEDEP}]
	wayland? ( dev-libs/wayland:=[${MULTILIB_USEDEP}] )
	X? ( x11-libs/libX11:=[${MULTILIB_USEDEP}] )"

src_prepare() {
	cmake-utils_src_prepare
	# Change the search path to match dev-util/glslang
	sed -i -e 's@\("library_path": "\).@\1/usr/lib@' layers/linux/*.json
	default
}

multilib_src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=True
		-DBUILD_TESTS=False
		-DBUILD_LAYERS=False
		-DBUILD_VKJSON=False
		-DBUILD_LOADER=True
		-DBUILD_WSI_MIR_SUPPORT=False
		-DBUILD_WSI_WAYLAND_SUPPORT=$(usex wayland)
		-DBUILD_WSI_XCB_SUPPORT=$(usex X)
		-DBUILD_WSI_XLIB_SUPPORT=$(usex X)
		-DBUILD_LAYERS=$(usex layers)
		# Build all demos to get vulkaninfo
		-DBUILD_DEMOS=$(usex vulkaninfo)
		-DCMAKE_C_FLAGS="${CFLAGS}"
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}"
		-DCMAKE_LD_FLAGS="${LDFLAGS}"
	)
	#This should be handled by portage
	case ${ABI} in
		x86) mycmakeargs+=( -DCMAKE_ASM-ATT_FLAGS=--32)
		;;
		amd64) mycmakeargs+=( -DCMAKE_ASM-ATT_FLAGS=--64)
		;;
		x32) mycmakeargs+=( -DCMAKE_ASM-ATT_FLAGS=--x32)
		;;
	esac

	cmake-utils_src_configure
}

multilib_src_install() {
#	cd ${CMAKE_BUILD_DIR}
	dolib.so loader/libvulkan.so*
	dolib.so layers/*.so

	if multilib_is_native_abi; then
		use vulkaninfo && dobin demos/vulkaninfo

		insinto /usr/lib/pkgconfig/
		doins loader/vulkan.pc
	fi
}

multilib_src_install_all() {
	keepdir /etc/vulkan/icd.d

	cd "${S}"
	insinto /usr/include/vulkan
	doins include/vulkan/*.h

	insinto /usr/share/vulkan/explicit_layer.d
	doins layers/linux/*.json

	einstalldocs
}
