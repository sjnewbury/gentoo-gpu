# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

USE_RUBY="ruby25 ruby24 ruby23 ruby22"

inherit ruby-single multilib-minimal

DESCRIPTION="Alternative to vendor specific OpenCL ICD loaders"
HOMEPAGE="http://forge.imag.fr/projects/ocl-icd/"
SRC_URI="https://forge.imag.fr/frs/download.php/814/${P}.tar.gz"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

PATCHES=("${FILESDIR}/${P}-static-inline.patch")

DEPEND="${RUBY_DEPS}"

RDEPEND="app-eselect/eselect-opencl"

ECONF_SOURCE="${S}"

append_abi_icd()
{
	echo "/usr/$(get_libdir)/OpenCL/vendors/ocl-icd/libOpenCL.so" >> ocl-icd.icd
}

src_prepare() {
	default
	multilib_foreach_abi append_abi_icd
}

multilib_src_install() {
	emake DESTDIR="${D}" install

	OCL_DIR=/usr/"$(get_libdir)"/OpenCL/vendors/ocl-icd/
	dodir "${OCL_DIR}"

	mv ${D}/usr/"$(get_libdir)"/libOpenCL* ${D}"${OCL_DIR}"

	# Install OpenCL2.0 headers from Khronos
	dodir ${OCL_DIR}/include
	insinto "${OCL_DIR}"/include/CL
	doins "${FILESDIR}"/2.0/*
}

multilib_src_install_all() {
	default
	insinto /etc/OpenCL/vendors/
	doins ocl-icd.icd
}
