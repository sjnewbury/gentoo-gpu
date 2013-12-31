# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )

EGIT_REPO_URI="git://people.freedesktop.org/~tstellar/${PN}"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-2"
	EXPERIMENTAL="true"
fi

inherit base $GIT_ECLASS python-single-r1 multilib flag-o-matic multilib-minimal

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
	>=sys-devel/clang-3.2[${MULTILIB_USEDEP}]
	>=sys-devel/llvm-3.2[${MULTILIB_USEDEP}]
	${PYTHON_DEPS}"
DEPEND="${RDEPEND}"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	base_src_prepare

	strip-flags

    multilib_copy_sources

	# Use our CFLAGS
	local abi
	for abi in $(multilib_get_enabled_abis); do
    	sed -i 	-e "/^llvm_cxxflags/s/$/ + \' "$(get_abi_var CFLAGS ${abi})" ${CXXFLAGS}\'/" \
    		-e "s/\(clang++\) -o/\1 "$(get_abi_var CFLAGS ${abi})" -o/" \
    		"${S}"-"${abi}"/configure.py || die
	done
#		-e "/^llvm_cxxflags.*/allvm_ldflags = \' $(get_abi_LDFLAGS)\ -v'" \
    
}

multilib_src_configure() {
	local myconf
	myconf="
		--prefix=${EPREFIX}/usr
		--libexecdir=/usr/$(get_libdir)/clc
		--pkgconfigdir=/usr/$(get_libdir)/pkgconfig
		"
	if [[ ${ABI} != ${DEFAULT_ABI} ]] ; then
            myconf+="--with-llvm-config=${EPREFIX}/usr/bin/llvm-config.${ABI}"
	else
            myconf+="--with-llvm-config=${EPREFIX}/usr/bin/llvm-config"
	fi

	export VERBOSE=1

	${EPYTHON} ./configure.py ${myconf} || die
}

multilib_src_compile() {
    emake
}

multilibsrc_install_all() {
    emake DESTDIR="${D}" install
}
