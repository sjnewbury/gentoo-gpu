# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-multilib eutils

DESCRIPTION="Vulkan ICD loader and validation layers"
HOMEPAGE="https://www.khronos.org/opengles/sdk/tools/Reference-Compiler/"
SRC_URI="https://github.com/KhronosGroup/Vulkan-LoaderAndValidationLayers/archive/sdk-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE="+layers xcb Xlib vulkaninfo"

# Other demos use XLib
REQUIRED_USE="vulkaninfo? ( Xlib xcb )"


DEPEND=">=dev-lang/python-3
        dev-util/cmake
		dev-util/glslang
		dev-util/SPIRV-Tools[${MULTILIB_USEDEP}]
		${RDEPEND}"
RDEPEND="xcb? ( x11-libs/libxcb )
	     Xlib? ( x11-libs/libX11 )"

S="${WORKDIR}/Vulkan-LoaderAndValidationLayers-sdk-${PV}"

src_unpack() {
	unpack $A
}

src_prepare() {
	# Change the search path to match dev-util/glslang
	epatch "${FILESDIR}"/glslang-spirv-hpp.patch
	sed -i -e 's@\("library_path": "\).@\1/usr/lib@' layers/linux/*.json
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_build xcb WSI_XCB_SUPPORT)
		$(cmake-utils_use_build Xlib WSI_XLIB_SUPPORT)
		$(cmake-utils_use_build layers LAYERS)
		# Build all demos to get vulkaninfo
		$(cmake-utils_use_build vulkaninfo DEMOS)
		"-DBUILD_TESTS=OFF"
	)

	cmake-multilib_src_configure
}

multilib_src_install() {
	cd ${CMAKE_BUILD_DIR}
	dolib.so loader/libvulkan.so*
	dolib.so layers/*.so

	if multilib_is_native_abi; then
		use vulkaninfo && dobin demos/vulkaninfo
	fi
}

multilib_src_install_all() {
	cd ${S}
	insinto /usr/include/vulkan
	doins include/vulkan/*

	insinto /usr/share/vulkan/explicit_layer.d
	doins layers/linux/*.json
}
