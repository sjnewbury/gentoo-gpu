# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

DESCRIPTION="Alternative to vendor specific OpenCL ICD loaders"
HOMEPAGE="http://forge.imag.fr/projects/ocl-icd/"
SRC_URI="https://forge.imag.fr/frs/download.php/698/${P}.tar.gz"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND="dev-lang/ruby"
RDEPEND="app-eselect/eselect-opencl"

src_prepare() {
	echo "/usr/$(get_libdir)/OpenCL/vendors/ocl-icd/libOpenCL.so" > ocl-icd.icd
}

src_install() {
	insinto /etc/OpenCL/vendors/
	doins ocl-icd.icd

	emake DESTDIR="${D}" install

	OCL_DIR=/usr/"$(get_libdir)"/OpenCL/vendors/ocl-icd/
	dodir ${OCL_DIR}

	mv ${D}/usr/"$(get_libdir)"/libOpenCL* ${D}"${OCL_DIR}"

	# Install OpenCL2.0 headers from Khronos
	dodir ${OCL_DIR}/include
	insinto "${OCL_DIR}"/include/CL
	doins "${FILESDIR}"/2.0/*
}
