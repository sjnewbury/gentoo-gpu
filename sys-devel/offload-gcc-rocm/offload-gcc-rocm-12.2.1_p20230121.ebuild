# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TOOLCHAIN_PATCH_DEV="sam"
PATCH_VER="1"
PATCH_GCC_VER="12.2.0"
MUSL_VER="1"
MUSL_GCC_VER="12.2.0"

NEWLIBV="4.3.0.20230120"
ROCM_VERSION="6.0.2"
CTARGET=amdgcn-amdhsa
TOOLCHAIN_ALLOWED_LANGS="c c++ jit fortran"

if [[ $(ver_cut 3) == 9999 ]] ; then
	MY_PV_2=$(ver_cut 2)
	if [[ ${MY_PV_2} == 0 ]] ; then
		MY_PV_2=0
	else
		MY_PV_2=$(($(ver_cut 2) - 1))
	fi

	# e.g. 12.2.9999 -> 12.1.1
	TOOLCHAIN_GCC_PV=$(ver_cut 1).${MY_PV_2}.$(($(ver_cut 3) - 9998))
elif [[ -n ${TOOLCHAIN_GCC_RC} ]] ; then
	# Cheesy hack for RCs
	MY_PV=$(ver_cut 1).$((($(ver_cut 2) + 1))).$((($(ver_cut 3) - 1)))-RC-$(ver_cut 5)
	MY_P=${PN}-${MY_PV}
	GCC_TARBALL_SRC_URI="https://gcc.gnu.org/pub/gcc/snapshots/${MY_PV}/${MY_P}.tar.xz"
	TOOLCHAIN_SET_S=no
	S="${WORKDIR}"/${MY_P}
fi

inherit toolchain

# Needs to be after inherit (for now?), bug #830908
EGIT_BRANCH=releases/gcc-$(ver_cut 1)

# Don't keyword live ebuilds
if ! tc_is_live && [[ -z ${TOOLCHAIN_USE_GIT_PATCHES} ]] ; then
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
fi

src_prepare() {
	toolchain_src_prepare
	pushd "${WORKDIR}"/newlib-${NEWLIBV}
	eapply "${FILESDIR}/newlib-amdgcm-exit.patch"
	popd
	eapply_user
}
