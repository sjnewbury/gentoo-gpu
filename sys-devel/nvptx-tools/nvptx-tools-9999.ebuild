# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4
AUTOTOOLS_AUTO_DEPEND="yes"

inherit autotools multilib-minimal

DESCRIPTION="a collection of tools for use with nvptx-none GCC toolchains."
HOMEPAGE="http://www.zlib.net/"

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI=git://github.com/MentorEmbedded/nvptx-tools.git
	SRC_URI=
else
	die "No releases yet!"
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"

DEPEND="
	x11-drivers/nvidia-drivers
	dev-util/nvidia-cuda-toolkit
"

src_prepare() {
	default
	epatch "${FILESDIR}"/"${PN}"-no-error-as-needed.patch
	multilib_copy_sources
}

multilib_src_configure() {
	econf \
		--target=nvptx-none \
		--with-cuda-driver=/opt/cuda
}
