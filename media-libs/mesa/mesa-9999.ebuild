# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"
BEIGNET_BRANCH=master


if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
	EXPERIMENTAL="true"
	B_PV="${PV}"
else
	B_PV="0.3"
fi

PYTHON_COMPAT=( python{2_6,2_7} )

inherit cmake-utils base autotools multilib multilib-minimal flag-o-matic \
	python-any-r1 toolchain-funcs ${GIT_ECLASS}

OPENGL_DIR="xorg-x11"

MY_PN="${PN/m/M}"
MY_P="${MY_PN}-${PV/_/-}"
MY_SRC_P="${MY_PN}Lib-${PV/_/-}"

FOLDER="${PV/_rc*/}"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="http://mesa3d.sourceforge.net/"

#SRC_PATCHES="mirror://gentoo/${P}-gentoo-patches-01.tar.bz2"
if [[ $PV = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="ftp://ftp.freedesktop.org/pub/mesa/${FOLDER}/${MY_SRC_P}.tar.bz2
		${SRC_PATCHES}
		http://cgit.freedesktop.org/beignet/snapshot/Release_v${B_PV}.tar.gz"
fi

# The code is MIT/X11.
# GLES[2]/gl[2]{,ext,platform}.h are SGI-B-2.0
LICENSE="MIT SGI-B-2.0"
SLOT="0"
KEYWORDS=""

INTEL_CARDS="i915 i965 ilo intel"
RADEON_CARDS="r100 r200 r300 r600 radeon radeonsi"
VIDEO_CARDS="${INTEL_CARDS} ${RADEON_CARDS} freedreno nouveau vmware"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	bindist +classic debug +egl +gallium gbm gles1 gles2 +llvm +nptl opencl
	openvg osmesa pax_kernel pic r600-llvm-compiler selinux vdpau
	wayland xvmc xa xorg kernel_FreeBSD beignet"

REQUIRED_USE="
	llvm?   ( gallium )
	openvg? ( egl gallium )
	opencl? (
		video_cards_r600? ( gallium r600-llvm-compiler )
		video_cards_radeon? ( gallium r600-llvm-compiler )
		video_cards_radeonsi? ( gallium r600-llvm-compiler )
		video_cards_i965? ( beignet )
		video_cards_ilo? ( beignet )
		video_cards_intel? ( beignet )
	)
	gles1?  ( egl )
	gles2?  ( egl )
	r600-llvm-compiler? ( gallium llvm || ( video_cards_r600 video_cards_radeonsi video_cards_radeon ) )
	wayland? ( egl )
	xa?  ( gallium )
	xorg?  ( gallium )
	video_cards_freedreno?  ( gallium )
	video_cards_intel?  ( || ( classic gallium ) )
	video_cards_i915?   ( || ( classic gallium ) )
	video_cards_i965?   ( classic )
	video_cards_ilo?    ( gallium )
	video_cards_nouveau? ( || ( classic gallium ) )
	video_cards_radeon? ( || ( classic gallium ) )
	video_cards_r100?   ( classic )
	video_cards_r200?   ( classic )
	video_cards_r300?   ( gallium )
	video_cards_r600?   ( gallium )
	video_cards_radeonsi?   ( gallium llvm )
	video_cards_vmware? ( gallium )
"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.46"
# keep correct libdrm and dri2proto dep
# keep blocks in rdepend for binpkg
RDEPEND="
	!<x11-base/xorg-server-1.7
	!<=x11-proto/xf86driproto-2.0.3
	abi_x86_32? ( !app-emulation/emul-linux-x86-opengl[-abi_x86_32(-)] )
	classic? ( app-admin/eselect-mesa )
	gallium? ( app-admin/eselect-mesa )
	>=app-admin/eselect-opengl-1.2.7
	dev-libs/expat[${MULTILIB_USEDEP}]
	gbm? ( virtual/udev[${MULTILIB_USEDEP}] )
	>=x11-libs/libX11-1.3.99.901[${MULTILIB_USEDEP}]
	x11-libs/libXdamage[${MULTILIB_USEDEP}]
	x11-libs/libXext[${MULTILIB_USEDEP}]
	x11-libs/libXxf86vm[${MULTILIB_USEDEP}]
	>=x11-libs/libxcb-1.9.3[${MULTILIB_USEDEP}]
	>=x11-libs/libxshmfence-1.0.0[${MULTILIB_USEDEP}]
	opencl? (
				app-admin/eselect-opencl
				beignet? ( !dev-libs/beignet )
			)
	vdpau? ( >=x11-libs/libvdpau-0.4.1[${MULTILIB_USEDEP}] )
	wayland? ( >=dev-libs/wayland-1.0.3[${MULTILIB_USEDEP}] )
	xorg? (
		x11-base/xorg-server:=
		x11-libs/libdrm[libkms]
	)
	xvmc? ( >=x11-libs/libXvMC-1.0.6[${MULTILIB_USEDEP}] )
	${LIBDRM_DEPSTRING}[video_cards_freedreno?,video_cards_nouveau?,video_cards_vmware?,${MULTILIB_USEDEP}]
"
for card in ${INTEL_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? (
								${LIBDRM_DEPSTRING}[video_cards_intel]
								opencl? ( beignet? ( || (
									>=sys-devel/llvm-3.3[${MULTILIB_USEDEP}]
									>=sys-devel/llvm-3.4[-ncurses,${MULTILIB_USEDEP}]
										) )
								)
		)
	"
done

for card in ${RADEON_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? (
								${LIBDRM_DEPSTRING}[video_cards_radeon]
								opencl? (
											>=sys-devel/llvm-3.3-r1[video_cards_radeon,${MULTILIB_USEDEP}]
											dev-libs/libclc[${MULTILIB_USEDEP}]
								)
		)
	"
done

DEPEND="${RDEPEND}
	llvm? (
		>=sys-devel/llvm-3.3[${MULTILIB_USEDEP}]
		r600-llvm-compiler? ( sys-devel/llvm[video_cards_radeon] )
		video_cards_radeonsi? ( sys-devel/llvm[video_cards_radeon] )
	)
	opencl? (
				>=sys-devel/clang-3.3[${MULTILIB_USEDEP}]
				>=sys-devel/gcc-4.6
	)
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	>=x11-proto/dri2proto-2.6[${MULTILIB_USEDEP}]
	>=x11-proto/dri3proto-1.0[${MULTILIB_USEDEP}]
	>=x11-proto/presentproto-1.0[${MULTILIB_USEDEP}]
	>=x11-proto/glproto-1.4.15-r1[${MULTILIB_USEDEP}]
	>=x11-proto/xextproto-7.0.99.1[${MULTILIB_USEDEP}]
	x11-proto/xf86driproto[${MULTILIB_USEDEP}]
	x11-proto/xf86vidmodeproto[${MULTILIB_USEDEP}]
	$(python_gen_any_dep 'dev-libs/libxml2[python,${PYTHON_USEDEP}]')
"

python_check_deps() {
	has_version "dev-libs/libxml2[python,${PYTHON_USEDEP}]"
}

S="${WORKDIR}/${MY_P}"
CMAKE_USE_DIR="${S}"/beignet-${B_PV}

# It is slow without texrels, if someone wants slow
# mesa without texrels +pic use is worth the shot
QA_EXECSTACK="usr/lib*/opengl/xorg-x11/lib/libGL.so*"
QA_WX_LOAD="usr/lib*/opengl/xorg-x11/lib/libGL.so*"

# Think about: ggi, fbcon, no-X configs

pkg_setup() {
	# workaround toc-issue wrt #386545
	use ppc64 && append-flags -mminimal-toc

	python-any-r1_pkg_setup
}

beignet_src_unpack() {
		git-r3_fetch "git://anongit.freedesktop.org/beignet" \
			"refs/heads/${BEIGNET_BRANCH}"
		git-r3_checkout "git://anongit.freedesktop.org/beignet" \
			"${S}"/beignet-${B_PV}
}

src_unpack() {
	default
	if [[ $PV = 9999* ]] ; then
		git-r3_fetch
		EGIT_CHECKOUT_DIR="${S}" git-r3_checkout
		use opencl && use beignet && beignet_src_unpack
	else
		# keep beignet sources in mesa source tree so they 
		# get copied with for multilib build
  		use beignet && mv "${WORKDIR}"/beignet-${B_PV} "${S}"
	fi
}

beignet_src_prepare() {
	cd "${S}"/beignet-${B_PV}
	cmake-utils_src_prepare

	# Fix linking
	epatch "${FILESDIR}"/beignet-"${B_PV}"-respect-flags.patch
	epatch "${FILESDIR}"/beignet-"${B_PV}"-libOpenCL.patch
	epatch "${FILESDIR}"/beignet-"${B_PV}"-llvm-libs-tr.patch
#	epatch "${FILESDIR}"/beignet-"${B_PV}"-llvm35.patch
	epatch "${FILESDIR}"/beignet-"${B_PV}"-mesa-includes.patch

	# Make beignet master compatible with upstream mesa master changes
	epatch "${FILESDIR}"/beignet-"${B_PV}"-mesa-master.patch
}

src_prepare() {
	# apply patches
	if [[ ${PV} != 9999* && -n ${SRC_PATCHES} ]]; then
		EPATCH_FORCE="yes" \
		EPATCH_SOURCE="${WORKDIR}/patches" \
		EPATCH_SUFFIX="patch" \
		epatch
	fi

	# relax the requirement that r300 must have llvm, bug 380303
	#epatch "${FILESDIR}"/${P}-dont-require-llvm-for-r300.patch

	# fix for hardened pax_kernel, bug 240956
	[[ ${PV} != 9999* ]] && epatch "${FILESDIR}"/glx_ro_text_segm.patch

	# Solaris needs some recent POSIX stuff in our case
	if [[ ${CHOST} == *-solaris* ]] ; then
		sed -i -e "s/-DSVR4/-D_POSIX_C_SOURCE=200112L/" configure.ac || die
	fi

	base_src_prepare

	eautoreconf

	# prepare beignet (intel opencl support) using cmake
	use opencl && use beignet && beignet_src_prepare

	multilib_copy_sources

}

beignet_src_configure() {
	pushd "${BUILD_DIR}"/beignet-${B_PV}
	local OLD_CFLAGS=${CFLAGS}
	local OLD_CXXFLAGS=${CFLAGS}
	local mycmakeargs=(
		-DMESA_SOURCE_PREFIX="${BUILD_DIR}"
		-DLIB_INSTALL_DIR="$(get_libdir)/OpenCL/vendors/beignet"
	)
	multilib_is_native_abi || mycmakeargs+=(
		-DLLVM_CONFIG_EXECUTABLE="${EPREFIX}/usr/bin/llvm-config.${ABI}"
	)
	# LTO currently doesn't work with beignet
	filter-flags -flto*
	BUILD_DIR=${BUILD_DIR}/beignet-${B_PV} cmake-utils_src_configure
	CFLAGS=${OLD_CFLAGS}
	CXXFLAGS=${OLD_CXXFLAGS}
	popd
}

multilib_src_configure() {

	local myconf

	if use classic; then
	# Configurable DRI drivers
		driver_enable swrast

	# Intel code
		driver_enable video_cards_i915 i915
		driver_enable video_cards_i965 i965
		if ! use video_cards_i915 && \
			! use video_cards_i965 && \
				! use video_cards_ilo; then
			driver_enable video_cards_intel i915 i965
		fi

		# Nouveau code
		driver_enable video_cards_nouveau nouveau

		# ATI code
		driver_enable video_cards_r100 radeon
		driver_enable video_cards_r200 r200
		if ! use video_cards_r100 && \
				! use video_cards_r200; then
			driver_enable video_cards_radeon radeon r200
		fi
	fi

	if use egl; then
		myconf+="
			--with-egl-platforms=x11$(use wayland && echo ",wayland")$(use gbm && echo ",drm")
			$(use_enable gallium gallium-egl)
		"
	fi

	if use gallium; then
		myconf+="
			$(use_enable llvm gallium-llvm)
			$(use_with llvm llvm-shared-libs)
			$(use_enable openvg)
			$(use_enable r600-llvm-compiler)
			$(use_enable vdpau)
			$(use_enable xvmc)
		"
		gallium_enable swrast
		gallium_enable video_cards_vmware svga
		gallium_enable video_cards_nouveau nouveau
		gallium_enable video_cards_i915 i915
		gallium_enable video_cards_ilo ilo
		if ! use video_cards_i915 && \
			! use video_cards_ilo; then
			gallium_enable video_cards_intel i915 ilo
		fi

		gallium_enable video_cards_r300 r300
		gallium_enable video_cards_r600 r600
		gallium_enable video_cards_radeonsi radeonsi
		if ! use video_cards_r300 && \
				! use video_cards_r600; then
			gallium_enable video_cards_radeon r300 r600
		fi

		gallium_enable video_cards_freedreno freedreno
		# opencl stuff (currently only supported for radeon r600 and newer)
		if use opencl; then
			if use video_cards_r600 || use video_cards_radeonsi ; then
				myconf+="
					$(use_enable opencl)
					--with-opencl-libdir="${EPREFIX}/usr/$(get_libdir)/OpenCL/vendors/mesa"
					--with-clang-libdir="${EPREFIX}/usr/${LIBDIR_default}"
					"
			fi
		fi
	fi

	# x86 hardened pax_kernel needs glx-rts, bug 240956
	if use pax_kernel; then
		myconf+="
			$(use_enable x86 glx-rts)
		"
	fi

	# build fails with BSD indent, bug #428112
	use userland_GNU || export INDENT=cat

	if ! multilib_is_native_abi; then
		myconf+="--disable-xorg
			LLVM_CONFIG=${EPREFIX}/usr/bin/llvm-config.${ABI}"
	fi

	econf \
		--enable-dri \
		--enable-glx \
		--enable-shared-glapi \
		$(use_enable !bindist texture-float) \
		$(use_enable debug) \
		$(use_enable egl) \
		$(use_enable gbm) \
		$(use_enable gles1) \
		$(use_enable gles2) \
		$(use_enable nptl glx-tls) \
		$(use_enable osmesa) \
		$(use_enable xa) \
		$(use_enable xorg) \
		--with-dri-drivers=${DRI_DRIVERS} \
		--with-gallium-drivers=${GALLIUM_DRIVERS} \
		PYTHON2="${PYTHON}" \
		${myconf}

	# intel opencl stuff
	use opencl && use beignet && beignet_src_configure
}

#		$(use_enable !pic asm) \

multilib_src_compile() {

	default
	if use opencl && use beignet ; then
		cd "${BUILD_DIR}"/beignet-${B_PV}
		emake		
	fi
}

multilib_src_install() {
	emake install DESTDIR="${D}"

	# Move libGL and others from /usr/lib to /usr/lib/opengl/blah/lib
	# because user can eselect desired GL provider.
	ebegin "Moving libGL and friends for dynamic switching"
		local x
		local gl_dir="/usr/$(get_libdir)/opengl/${OPENGL_DIR}/"
		dodir ${gl_dir}/{lib,extensions,include/GL}
		for x in "${ED}"/usr/$(get_libdir)/lib{EGL,GL*,OpenVG}.{la,a,so*}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${ED}${gl_dir}"/lib \
					|| die "Failed to move ${x}"
			fi
		done
		for x in "${ED}"/usr/include/GL/{gl.h,glx.h,glext.h,glxext.h}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${ED}${gl_dir}"/include/GL \
					|| die "Failed to move ${x}"
			fi
		done
		for x in "${ED}"/usr/include/{EGL,GLES*,VG,KHR}; do
			if [ -d ${x} ]; then
				mv -f "${x}" "${ED}${gl_dir}"/include \
					|| die "Failed to move ${x}"
			fi
		done
	eend $?
	if use classic || use gallium; then
			ebegin "Moving DRI/Gallium drivers for dynamic switching"
			local gallium_drivers=( i915_dri.so ilo_dri.so i965_dri.so r300_dri.so r600_dri.so swrast_dri.so )
			keepdir /usr/$(get_libdir)/dri
			dodir /usr/$(get_libdir)/mesa
			for x in ${gallium_drivers[@]}; do
				if [ -f "$(get_libdir)/gallium/${x}" ]; then
					insinto "/usr/$(get_libdir)/dri/"
					doins "$(get_libdir)/gallium/${x}"
					if [ -f "$(get_libdir)/${x}" ]; then
						mv -f "${ED}/usr/$(get_libdir)/dri/${x}" "${ED}/usr/$(get_libdir)/dri/${x/_dri.so/g_dri.so}" \
							|| die "Failed to move ${x}"
						insopts -m0755
						doins "$(get_libdir)/${x}"
					fi
				fi
			done
			for x in "${ED}"/usr/$(get_libdir)/dri/*.so; do
				if [ -f ${x} -o -L ${x} ]; then
					mv -f "${x}" "${x/dri/mesa}" \
						|| die "Failed to move ${x}"
				fi
			done
			pushd "${ED}"/usr/$(get_libdir)/dri || die "pushd failed"
			ln -s ../mesa/*.so . || die "Creating symlink failed"
			# remove symlinks to drivers known to eselect
			for x in ${gallium_drivers[@]}; do
				if [ -f ${x} -o -L ${x} ]; then
					rm "${x}" || die "Failed to remove ${x}"
				fi
			done
			popd
		eend $?
	fi
	if use opencl; then
		if use gallium ; then
			ebegin "Moving Gallium/Clover OpenCL implementation for dynamic switching"
			local cl_dir="/usr/$(get_libdir)/OpenCL/vendors/mesa"
			dodir ${cl_dir}/{lib,include}
			if [ -f "${ED}/usr/$(get_libdir)/libOpenCL.so" ]; then
				mv -f "${ED}"/usr/$(get_libdir)/libOpenCL.so* \
				"${ED}"${cl_dir}
			fi
			if [ -f "${ED}/usr/include/CL/opencl.h" ]; then
				mv -f "${ED}"/usr/include/CL \
				"${ED}"${cl_dir}/include
			fi
			eend $?
		fi
		if use beignet ; then
			ebegin "Installing Beignet Intel HD Graphics OpenCL implementation"
			cd "${BUILD_DIR}/beignet-${B_PV}"
			DESTDIR="${D}" ${CMAKE_MAKEFILE_GENERATOR} install "$@" || \
											die "Failed to install Beignet"
			insinto /usr/$(get_libdir)/OpenCL/vendors/beignet/include/CL
			doins include/CL/*
			eend $?
		fi
	fi
}

multilib_src_install_all() {
	prune_libtool_files --all
	einstalldocs

	if use !bindist; then
		dodoc docs/patents.txt
	fi

	# Install config file for eselect mesa
	insinto /usr/share/mesa
	newins "${FILESDIR}/eselect-mesa.conf.10.1" eselect-mesa.conf
}

pkg_postinst() {
	# Switch to the xorg implementation.
	echo
	eselect opengl set --use-old ${OPENGL_DIR}

	# switch to xorg-x11 and back if necessary, bug #374647 comment 11
	OLD_IMPLEM="$(eselect opengl show)"
	if [[ ${OPENGL_DIR}x != ${OLD_IMPLEM}x ]]; then
		eselect opengl set ${OPENGL_DIR}
		eselect opengl set ${OLD_IMPLEM}
	fi

	# Select classic/gallium drivers
	if use classic || use gallium; then
		eselect mesa set --auto
	fi

	# Switch to mesa opencl
	if use opencl; then
		eselect opencl set --use-old ${PN}
	fi

	# warn about patent encumbered texture-float
	if use !bindist; then
		elog "USE=\"bindist\" was not set. Potentially patent encumbered code was"
		elog "enabled. Please see patents.txt for an explanation."
	fi

	local using_radeon r_flag
	for r_flag in ${RADEON_CARDS}; do
		if use video_cards_${r_flag}; then
			using_radeon=1
			break
		fi
	done

	if [[ ${using_radeon} = 1 ]] && ! has_version media-libs/libtxc_dxtn; then
		elog "Note that in order to have full S3TC support, it is necessary to install"
		elog "media-libs/libtxc_dxtn as well. This may be necessary to get nice"
		elog "textures in some apps, and some others even require this to run."
	fi
}

# $1 - VIDEO_CARDS flag
# other args - names of DRI drivers to enable
# TODO: avoid code duplication for a more elegant implementation
driver_enable() {
	case $# in
		# for enabling unconditionally
		1)
			DRI_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					DRI_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}

gallium_enable() {
	case $# in
		# for enabling unconditionally
		1)
			GALLIUM_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					GALLIUM_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}
