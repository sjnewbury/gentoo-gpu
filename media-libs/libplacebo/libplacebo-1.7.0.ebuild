# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ "${PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://code.videolan.org/videolan/libplacebo.git"
	inherit git-r3
else
	KEYWORDS="~amd64"
	SRC_URI="https://code.videolan.org/videolan/libplacebo/-/archive/v${PV}/libplacebo-v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-v${PV}"
fi

inherit meson ninja-utils multilib-minimal

DESCRIPTION="Reusable library for GPU-accelerated image processing primitives"
HOMEPAGE="https://github.com/haasn/libplacebo"

LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="glslang lcms +shaderc +vulkan"
REQUIRED_USE="vulkan? ( || ( glslang shaderc ) )"

RDEPEND="glslang? ( <dev-util/glslang-7.10[${MULTILIB_USEDEP}] )
	shaderc? ( >=media-libs/shaderc-2017.2[${MULTILIB_USEDEP}] )
	vulkan? ( media-libs/vulkan-loader[${MULTILIB_USEDEP}] )
	lcms? ( media-libs/lcms:2[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}"

multilib_src_configure() {
	local emesonargs=(
		-D glslang=$(usex glslang enabled disabled)
		-D shaderc=$(usex shaderc enabled disabled)
		-D vulkan=$(usex vulkan enabled disabled)
		-D lcms=$(usex lcms enabled disabled)
	)
	meson_src_configure
}

multilib_src_compile() {
	eninja
}

multilib_src_install() {
	DESTDIR="${D}" eninja install
}
