# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

USE_RUBY="ruby23 ruby24 ruby25 ruby26"

inherit autotools multilib-minimal ruby-single

DESCRIPTION="Alternative to vendor specific OpenCL ICD loaders"
HOMEPAGE="https://github.com/OCL-dev/ocl-icd"
SRC_URI="https://github.com/OCL-dev/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE="+khronos-headers"

PATCHES=("${FILESDIR}/${PN}-2.2.11-static-inline.patch")

DEPEND="${RUBY_DEPS}"

RDEPEND="app-eselect/eselect-opencl"

ECONF_SOURCE="${S}"

append_abi_icd()
{
	echo "/usr/$(get_libdir)/OpenCL/vendors/ocl-icd/libOpenCL.so" >> ocl-icd.icd
}

src_prepare() {
	default
	eautoreconf
	multilib_foreach_abi append_abi_icd
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf --enable-pthread-once
}

multilib_src_install() {
	default

	# Drop .la files
	find "${D}" -name '*.la' -delete || die

	OCL_DIR="/usr/$(get_libdir)/OpenCL/vendors/ocl-icd"
	dodir ${OCL_DIR}/{,include}

	# Install vendor library
	mv -f "${D}/usr/$(get_libdir)"/libOpenCL* "${ED}${OCL_DIR}" || die "Can't install vendor library"

	# Install vendor headers
	if use khronos-headers; then
		cp -r "${S}/khronos-headers/CL" "${ED}${OCL_DIR}/include" || die "Can't install vendor headers"
	fi
}

multilib_src_install_all() {
	insinto /etc/OpenCL/vendors/
	doins ocl-icd.icd
}

pkg_postinst() {
	eselect opencl set --use-old ${PN}
}
