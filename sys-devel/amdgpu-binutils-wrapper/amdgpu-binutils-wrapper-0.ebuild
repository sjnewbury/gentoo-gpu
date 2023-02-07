# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Wrappers for llvm amdgcn toolchain to make gcc-offload happy"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"
SRC_URI=""
S=${WORKDIR}

LICENSE="public-domain"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="sys-devel/llvm:=[llvm_targets_AMDGPU]"

src_install() {
	local target_tools=(
		as ar nm ranlib ld objcopy objdump strip
	)

	dobin ${FILESDIR}/amdgcn-amdhsa-wrapper

	for tool in ${target_tools[@]}; do
		dosym amdgcn-amdhsa-wrapper /usr/bin/amdgcn-amdhsa-${tool}
	done	
}
