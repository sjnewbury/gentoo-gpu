# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-multilib eutils

DESCRIPTION="Vulkan ICD loader and validation layers"
HOMEPAGE="https://www.khronos.org/opengles/sdk/tools/Reference-Compiler/"

if [[ "${PV}" == 9999* ]]; then
	SRC_URI=
	EGIT_REPO_URI=https://github.com/KhronosGroup/Vulkan-LoaderAndValidationLayers.git
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="https://github.com/KhronosGroup/Vulkan-LoaderAndValidationLayers/archive/sdk-${PV}.tar.gz"
	KEYWORDS="amd64"
fi

LICENSE="BSD"
SLOT="0"
IUSE="+layers xcb Xlib wayland vulkaninfo"

# Other demos use XLib
REQUIRED_USE="vulkaninfo? ( Xlib xcb wayland )"


DEPEND=">=dev-lang/python-3
        dev-util/cmake:*
	dev-util/glslang:=
	dev-util/SPIRV-Tools:=[${MULTILIB_USEDEP}]
	${RDEPEND}"
RDEPEND="xcb? ( x11-libs/libxcb:= )
	Xlib? ( x11-libs/libX11:= )
	wayland? ( dev-libs/wayland:* )"

if [[ "${PV}" != 9999* ]]; then
	S="${WORKDIR}/Vulkan-LoaderAndValidationLayers-sdk-${PV}"
fi

src_prepare() {
	sed -i -e 's@\("library_path": "\).@\1/usr/lib@' layers/linux/*.json
	default
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_WSI_WAYLAND_SUPPORT=$(usex wayland ON OFF)
		-DBUILD_WSI_XCB_SUPPORT=$(usex xcb ON OFF)
		-DBUILD_WSI_XLIB_SUPPORT=$(usex Xlib ON OFF)
		-DBUILD_WSI_MIR_SUPPORT=OFF
		-DBUILD_LAYERS=$(usex layers ON OFF)
		# Build all demos to get vulkaninfo
		-DBUILD_DEMOS=$(usex vulkaninfo ON OFF)
		-DBUILD_TESTS=OFF
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
