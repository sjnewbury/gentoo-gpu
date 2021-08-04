# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} == 9999* ]]; then
	vcs_eclass=git-r3
	EGIT_REPO_URI="https://gitlab.gnome.org/jadahl/libdecor.git"
else
	SRC_URI="https://gitlab.gnome.org/jadahl/libdecor/-/archive/${PV}/${P}.tar.gz"
	KEYWORDS="~amd64"
fi

inherit meson ${vcs_eclass} multilib-minimal

DESCRIPTION="A client-side decorations library for Wayland client"
HOMEPAGE="https://gitlab.gnome.org/jadahl/libdecor"
LICENSE="MIT"
SLOT="0"

DEPEND="
	dev-libs/wayland[${MULTILIB_USEDEP}]
	dev-libs/wayland-protocols
	>=sys-apps/dbus-1.0[${MULTILIB_USEDEP}]
	x11-libs/cairo[${MULTILIB_USEDEP}]
	x11-libs/pango[${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}"
BDEPEND=""

multilib_src_prepare() {
	default
	meson_src_prepare
}

multilib_src_configure() {
	default
	meson_src_configure
}

multilib_src_compile() {
	default
	meson_src_compile
}

multilib_src_install() {
	default
	meson_src_install
}

