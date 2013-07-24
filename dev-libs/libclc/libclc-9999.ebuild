# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )

EGIT_REPO_URI="git://people.freedesktop.org/~tstellar/${PN}"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-2"
	EXPERIMENTAL="true"
fi

inherit base $GIT_ECLASS python-single-r1 multilib flag-o-matic

DESCRIPTION="OpenCL C library"
HOMEPAGE="http://libclc.llvm.org/"

if [[ $PV = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI=""
fi

LICENSE="MIT BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=sys-devel/clang-3.3
	>=sys-devel/llvm-3.3
	${PYTHON_DEPS}"
DEPEND="${RDEPEND}"

PATCHES=(
		"${FILESDIR}/0001-Rename-target-to-r600-amd-none.patch"
)
#		"${FILESDIR}/fix-install-target.patch"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	base_src_prepare

	strip-flags

	# Use our CFLAGS
	sed -i 	-e "s/\(^llvm_cxxflags.*\)/\1 + \' ${CFLAGS}\'/" \
		-e "s/\(clang++\) -o/\1 $(get_abi_CFLAGS) -o/" \
		configure.py || die
#		-e "/^llvm_cxxflags.*/allvm_ldflags = \' $(get_abi_LDFLAGS)\ -v'" \
}

src_configure() {
	${EPYTHON} ./configure.py \
		--with-llvm-config="${EPREFIX}/usr/bin/llvm-config" \
		--prefix="${EPREFIX}/usr" \
		--libexecdir="/usr/$(get_libdir)/clc" \
		--pkgconfigdir="/usr/$(get_libdir)/pkgconfig"		
}
