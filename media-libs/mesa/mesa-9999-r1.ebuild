# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="${EGIT_REPO_URI:-https://anongit.freedesktop.org/git/mesa/mesa.git}"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
	EXPERIMENTAL="true"
	B_PV="${PV}"
	V_PV="${PV}"
else
	B_PV="0.9"
fi

inherit base autotools multilib multilib-minimal flag-o-matic \
	python-utils-r1 toolchain-funcs pax-utils ${GIT_ECLASS}

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
		${SRC_PATCHES}"
fi

LICENSE="MIT"
SLOT="0"

INTEL_CARDS="i915 i965 intel"
RADEON_CARDS="r100 r200 r300 r600 radeon radeonsi"
VIDEO_CARDS="${INTEL_CARDS} ${RADEON_CARDS} freedreno nouveau vmware vc4 virgl"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	+classic d3d9 debug +dri3 +egl +gallium +gbm gles1 gles2 +llvm
	+nptl opencl osmesa pax_kernel ocl-icd openmax pic selinux vaapi valgrind
	vdpau wayland xvmc xa kernel_FreeBSD glvnd vulkan gcrypt eselect-gl-bobwya"

#  Not available at present unfortunately
#	openvg? ( egl gallium )

REQUIRED_USE="
	llvm?   ( gallium )
	d3d9?   ( dri3 gallium )
	opencl? (
		video_cards_r600? ( gallium )
		video_cards_radeon? ( gallium )
		video_cards_radeonsi? ( gallium )
	)
	ocl-icd? ( opencl )
	openmax? ( gallium )
	gles1?  ( egl )
	gles2?  ( egl )
	vaapi? ( gallium )
	vdpau? ( gallium )
	vulkan? ( || ( video_cards_radeon? ( llvm ) video_cards_intel? ( classic ) ) )
	wayland? ( egl gbm )
	xa?  ( gallium )
	video_cards_freedreno?  ( gallium )
	video_cards_intel?  ( || ( classic ) )
	video_cards_i915?   ( || ( classic gallium ) )
	video_cards_i965?   ( classic )
	video_cards_nouveau? ( || ( classic gallium ) )
	video_cards_radeon? ( || ( classic gallium ) )
	video_cards_r100?   ( classic )
	video_cards_r200?   ( classic )
	video_cards_r300?   ( gallium )
	video_cards_r600?   ( gallium )
	video_cards_radeonsi?   ( gallium llvm )
	video_cards_vmware? ( gallium )
	video_cards_virgl? ( gallium )
"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.75"
# keep correct libdrm and dri2proto dep
# keep blocks in rdepend for binpkg
RDEPEND="
	!<x11-base/xorg-server-1.7
	!<=x11-proto/xf86driproto-2.0.3
	abi_x86_32? ( !app-emulation/emul-linux-x86-opengl[-abi_x86_32(-)] )
	classic? ( app-eselect/eselect-mesa )
	gallium? ( app-eselect/eselect-mesa )
	>=app-eselect/eselect-opengl-1.3.0
	eselect-gl-bobwya? ( >=app-eselect/eselect-opengl-1.3.3-r1 )
	kernel_linux? ( >=virtual/libudev-215:=[${MULTILIB_USEDEP}] )
	>=dev-libs/expat-2.1.0-r3:=[${MULTILIB_USEDEP}]
	gbm? ( >=virtual/libudev-215:=[${MULTILIB_USEDEP}] )
	dri3? ( >=virtual/libudev-215:=[${MULTILIB_USEDEP}] )
	>=x11-libs/libX11-1.6.2:=[${MULTILIB_USEDEP}]
	>=x11-libs/libXrandr-1.5.1:=[${MULTILIB_USEDEP}]
	>=x11-libs/libxshmfence-1.1:=[${MULTILIB_USEDEP}]
	>=x11-libs/libXdamage-1.1.4-r1:=[${MULTILIB_USEDEP}]
	>=x11-libs/libXext-1.3.2:=[${MULTILIB_USEDEP}]
	>=x11-libs/libXxf86vm-1.1.3:=[${MULTILIB_USEDEP}]
	>=x11-libs/libxcb-1.9.3:=[${MULTILIB_USEDEP}]
	x11-libs/libXfixes:=[${MULTILIB_USEDEP}]
	llvm? ( !kernel_FreeBSD? (
		video_cards_nouveau? ( || (
			>=dev-libs/elfutils-0.155-r1:=[${MULTILIB_USEDEP}]
			>=dev-libs/libelf-0.8.13-r2:=[${MULTILIB_USEDEP}]
			) )
		video_cards_radeonsi? ( || (
			>=dev-libs/elfutils-0.155-r1:=[${MULTILIB_USEDEP}]
			>=dev-libs/libelf-0.8.13-r2:=[${MULTILIB_USEDEP}]
			) )
		!video_cards_r600? (
			video_cards_radeon? ( || (
				>=dev-libs/elfutils-0.155-r1:=[${MULTILIB_USEDEP}]
				>=dev-libs/libelf-0.8.13-r2:=[${MULTILIB_USEDEP}]
				) )
		) )
		>=sys-devel/llvm-3.7.0:=[${MULTILIB_USEDEP}]
	)
	opencl? (
				app-eselect/eselect-opencl
				ocl-icd? ( dev-libs/ocl-icd )
				gallium? (
					dev-libs/libclc
					( || (
						>=dev-libs/elfutils-0.155-r1:=[${MULTILIB_USEDEP}]
						>=dev-libs/libelf-0.8.13-r2:=[${MULTILIB_USEDEP}]
					) )
				)
	)
	openmax? ( >=media-libs/libomxil-bellagio-0.9.3:=[${MULTILIB_USEDEP}] )
	vaapi? (
		>=x11-libs/libva-1.6.0:=[${MULTILIB_USEDEP}]
		video_cards_nouveau? ( !<=x11-libs/libva-vdpau-driver-0.7.4-r3 )
	)
	vdpau? ( >=x11-libs/libvdpau-1.1:=[${MULTILIB_USEDEP}] )
	wayland? ( >=dev-libs/wayland-1.2.0:=[${MULTILIB_USEDEP}] )
	xvmc? ( >=x11-libs/libXvMC-1.0.8:=[${MULTILIB_USEDEP}] )
	glvnd? ( media-libs/libglvnd[${MULTILIB_USEDEP}] )
	gcrypt? ( dev-libs/libgcrypt )
"

for card in ${RADEON_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? (
								${LIBDRM_DEPSTRING}[video_cards_radeon]
								opencl? (
											|| (	>=sys-devel/llvm-3.3-r1[video_cards_radeon,${MULTILIB_USEDEP}]
												>=sys-devel/llvm-3.9[llvm_targets_AMDGPU,${MULTILIB_USEDEP}]
											)
											dev-libs/libclc
								)
								vulkan? (	|| (	>=sys-devel/llvm-3.9[video_cards_radeon,${MULTILIB_USEDEP}]
											>=sys-devel/llvm-3.9[llvm_targets_AMDGPU,${MULTILIB_USEDEP}]
										)
								)
		)
	"
done

DEPEND="${RDEPEND}
	llvm? (
		video_cards_radeonsi? ( || (
			sys-devel/llvm[llvm_targets_AMDGPU]
			sys-devel/llvm[video_cards_radeon]
		) )
	)
	opencl? (
				>=sys-devel/llvm-3.7:=[${MULTILIB_USEDEP}]
				>=sys-devel/clang-3.7:=[${MULTILIB_USEDEP}]
				>=sys-devel/gcc-4.6
	)
	sys-devel/gettext
	virtual/pkgconfig
	valgrind? ( dev-util/valgrind )
	x11-base/xorg-proto
	dev-lang/python:2.7
	vulkan? ( =dev-lang/python-3* )
	wayland? ( >=dev-libs/wayland-protocols-1.16 )
	>=dev-python/mako-0.7.3[python_targets_python2_7]
"
[[ ${PV} == 9999 ]] && DEPEND+="
	sys-devel/bison
	sys-devel/flex
"

RDEPEND="${RDEPEND}
	${LIBDRM_DEPSTRING}[video_cards_freedreno?,video_cards_nouveau?,video_cards_vc4?,video_cards_vmware?,video_cards_virgl?,${MULTILIB_USEDEP}]
"

for card in ${INTEL_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_intel] )
	"
done

RDEPEND="${RDEPEND}
	video_cards_radeonsi? ( ${LIBDRM_DEPSTRING}[video_cards_amdgpu] )
"

S="${WORKDIR}/${MY_P}"

QA_WX_LOAD="
x86? (
	!pic? (
		usr/lib*/libglapi.so.0.0.0
		usr/lib*/libGLESv1_CM.so.1.1.0
		usr/lib*/libGLESv2.so.2.0.0
		usr/lib*/libGL.so.1.2.0
		usr/lib*/libOSMesa.so.8.0.0
	)
)"

pkg_setup() {
	# warning message for bug 459306
	if use llvm && has_version sys-devel/llvm[!debug=]; then
		ewarn "Mismatch between debug USE flags in media-libs/mesa and sys-devel/llvm"
		ewarn "detected! This can cause problems. For details, see bug 459306."
	fi
	use vulkan && [[ ${PV} != 9999 ]] && die "Vulkan is currently git only"
}

src_unpack() {
	default
	if [[ $PV = 9999* ]] ; then
		EGIT_MIN_CLONE_TYPE=shallow
		git-r3_fetch "" "" "${CATEGORY}/${PN}/${SLOT%/*}-MesaGL"
		git-r3_checkout "" "${S}" "${CATEGORY}/${PN}/${SLOT%/*}-MesaGL"

		# We want to make sure the mesa repo HEAD gets stored
		# so set the EGIT_VERSION ourselves. 
		cd "${S}"
		local new_commit_id=$(
			git rev-parse --verify HEAD
		)
		export EGIT_VERSION=${new_commit_id}
	fi
}

apply_mesa_patches() {
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

	epatch "${FILESDIR}/${P}-fix-missing-openmp-include.patch"
	#upstreamed
	#epatch "${FILESDIR}"/glthread/*
	#epatch "${FILESDIR}"/0001-Revert-autoconf-stop-exporting-internal-wayland-deta.patch
#	epatch "${FILESDIR}"/${P}-with-sha1.patch
}

src_prepare() {
	apply_mesa_patches

	# libglvnd patches (landed upstream)

	base_src_prepare

	eautoreconf

	multilib_copy_sources

}

glvnd_src_configure() {
	mkdir -p "${BUILD_DIR}"/glvnd_build
	pushd "${BUILD_DIR}"/glvnd_build
	ECONF_SOURCE="${S}" \
	econf \
		--enable-autotools \
		${myconf} \
		${eglconf} \
		--enable-libglvnd \
		--enable-dri \
		--enable-glx \
		--enable-shared-glapi \
		$(use_enable gles1) \
		$(use_enable gles2) \
		$(use_enable gbm) \
		$(use_enable nptl glx-tls) \
		$(use_enable debug) \
		$(use_enable dri3) \
		--enable-llvm-shared-libs \
		--with-dri-drivers=${DRI_DRIVERS} \
		--with-gallium-drivers=${GALLIUM_DRIVERS} \
		--disable-nine \
		--disable-opencl \
		PYTHON2="${PYTHON}"
	popd


}

multilib_src_configure() {
	# Most Mesa Python build scripts are Python2
	python_export python2.7 PYTHON

	local myconf eglconf

	if use vulkan; then
		if use video_cards_i965 || \
			use video_cards_intel; then
			vulkan_enable intel
		fi
		if use video_cards_radeon || \
			use video_cards_radeonsi; then
			vulkan_enable radeon
		fi
	fi

	if use classic; then
		# Configurable DRI drivers
		driver_enable swrast

		# Intel code
		driver_enable video_cards_i915 i915
		driver_enable video_cards_i965 i965
		if ! use video_cards_i915 && \
			! use video_cards_i965; then
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
		eglconf+="--with-egl-platforms=x11$(use wayland && echo ",wayland")$(use gbm && echo ",drm") "
	fi

# FIXME
#			$(use_enable openvg)
#			$(use_enable openvg gallium-egl)

	if use gallium; then
		# gallium-nine only makes sense on x86 and and amd64
		# (maybe ARM?)
		if ( [[ ${ABI} == x86* ]] || [[ ${ABI} == amd64* ]] ); then
			myconf+=" $(use_enable d3d9 nine)"
		else
			myconf+=" --disable-nine"
		fi

		myconf+="
			$(use_enable llvm)
			$(use_enable openmax omx-bellagio)
			$(use_enable vaapi va)
			$(use_enable vdpau)
			$(use_enable xa)
			$(use_enable xvmc)
		"

		use vaapi && myconf+=" --with-va-libdir=/usr/$(get_libdir)/va/drivers"

		gallium_enable swrast
		gallium_enable video_cards_vc4 vc4
		gallium_enable video_cards_vmware svga
		gallium_enable video_cards_virgl virgl
		gallium_enable video_cards_nouveau nouveau
		gallium_enable video_cards_i915 i915
		if ! use video_cards_i915; then
			gallium_enable video_cards_intel i915
		fi

		gallium_enable video_cards_r300 r300
		gallium_enable video_cards_r600 r600
		gallium_enable video_cards_radeonsi radeonsi
		if ! use video_cards_r300 && \
				! use video_cards_r600; then
			gallium_enable video_cards_radeon r300 r600
		fi

		gallium_enable video_cards_freedreno freedreno
		# opencl stuff
		if use opencl; then
			myconf+="
				$(use_enable opencl)
				--with-clang-libdir="${EPREFIX}/usr/${LIBDIR_default}"
				"
		fi
	fi

	# x86 hardened pax_kernel needs glx-rts, bug 240956
	if [[ ${ABI} == x86 ]]; then
		myconf+=" $(use_enable pax_kernel glx-read-only-text)"
	fi

	# on abi_x86_32 hardened we need to have asm disable
	if ( [[ ${ABI} == x86* ]] && use pic ) || [[ ${ABI} == x32* ]]; then
		myconf+=" --disable-asm"
	fi

	if use gallium; then
		myconf+=" $(use_enable osmesa gallium-osmesa)"
	else
		myconf+=" $(use_enable osmesa)"
	fi

	# build fails with BSD indent, bug #428112
	use userland_GNU || export INDENT=cat

	if ! multilib_is_native_abi; then
			LLVM_CONFIG="${EPREFIX}/usr/bin/llvm-config.${ABI}"
	fi

#	ECONF_SOURCE="${S}" \
	econf \
		--enable-autotools \
		--enable-dri \
		--enable-glx \
		--enable-shared-glapi \
		$(use_enable debug) \
		$(use_enable dri3) \
		$(use_enable egl) \
		$(use_enable gbm) \
		$(use_enable gles1) \
		$(use_enable gles2) \
		$(use_enable nptl glx-tls) \
		$(use_enable ocl-icd opencl-icd) \
		--enable-valgrind=$(usex valgrind auto no) \
		--enable-llvm-shared-libs \
		--with-dri-drivers=${DRI_DRIVERS} \
		--with-gallium-drivers=${GALLIUM_DRIVERS} \
		--with-vulkan-drivers=${VULKAN_DRIVERS} \
		PYTHON2="${PYTHON}" \
		${eglconf} \
		${myconf}

	use glvnd && glvnd_src_configure
}

#		$(use_enable !pic asm) \
# FIXME
#		$(use_with gcrypt sha1=libgcrypt) \

multilib_src_compile() {
	default
	
	if use glvnd ; then
		pushd "${BUILD_DIR}"/glvnd_build
			emake
		popd
	fi
}

multilib_src_install() {
	if use glvnd ; then
		pushd "${BUILD_DIR}"/glvnd_build
			emake install DESTDIR="${D}"
			ebegin "Moving glvnd-mesa libs to glvnd directory"
			local x
			local gl_dir="/usr/$(get_libdir)/opengl/glvnd/"
			dodir ${gl_dir}/lib
			for x in "${ED}"/usr/$(get_libdir)/lib*mesa.{la,a,so*}; do
				if [ -f ${x} -o -L ${x} ]; then
					mv -f "${x}" "${ED}${gl_dir}"/lib \
						|| die "Failed to move ${x}"
				fi
			done

			# Create libGLX_driver symlinks for each driver
			local ALL_DRIVERS
			local y
			local z
			ALL_DRIVERS="${DRI_DRIVERS//,/ } ${GALLIUM_DRIVERS//,/ }"
			for x in ${ALL_DRIVERS//i965/intel} indirect; do
				for y in "${ED}${gl_dir}"/lib/lib*mesa.{la,a,so*}; do
					if [ -f ${y} -o -L ${y} ]; then
						z=${y##*/}
						dosym ${z} ${gl_dir}/lib/${z/mesa/${x}}
					fi
				done
			done
		eend $?
		popd
	fi

	# Install standard Mesa build
	emake install DESTDIR="${D}"

	if use classic || use gallium; then

		# Move libGL and others from /usr/lib to /usr/lib/opengl/blah/lib
		# because user can eselect desired GL provider.  "bobwya" has
		# forked and improved the symlink management in a new
		# version of eselect-opengl.  This was removed in portage with
		# the behaviour of always using the mesa provider for the system
		# libGL since that provides better build compatibility, but this
		# can break other things like Bumblebee.  The main benefit was
		# using predictable headers to this end Mesa GL headers are
		# always used as system headers even in this case and not
		# provided by other implementations.

		if use eselect-gl-bobwya; then
			ebegin "Moving libGL and friends for dynamic switching"
				dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/{lib,extensions,include}
				local x
				for x in "${ED}"/usr/$(get_libdir)/lib*GL*.{la,a,so*}; do
					if [ -f ${x} -o -L ${x} ]; then
						mv -f "${x}" "${ED}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/lib \
							|| die "Failed to move ${x}"
					fi
				done
			eend $?
		fi

		ebegin "Moving DRI/Gallium drivers for dynamic switching"
			local gallium_drivers=( i915_dri.so i965_dri.so r300_dri.so r600_dri.so swrast_dri.so )
			keepdir /usr/$(get_libdir)/dri
			dodir /usr/$(get_libdir)/mesa
			for x in ${gallium_drivers[@]}; do
				if [ -f "$(get_libdir)/gallium/${x}" ]; then
					mv -f "${ED}/usr/$(get_libdir)/dri/${x}" "${ED}/usr/$(get_libdir)/dri/${x/_dri.so/g_dri.so}" \
						|| die "Failed to move ${x}"
				fi
			done
			if use classic; then
				emake -C "${BUILD_DIR}/src/mesa/drivers/dri" DESTDIR="${D}" install
			fi
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
		if use ocl-icd; then
			einfo "Gallium/Clover OpenCL driver installed, creating ICD config"
			rm -f "${ED}"/etc/OpenCL/vendors/mesa.icd
			local ocl_lib=libMesaOpenCL.so
			dodir /etc/OpenCL/vendors/
			echo "/usr/$(get_libdir)/${ocl_lib}" > "${ED}"/etc/OpenCL/vendors/mesa-${ABI}.icd
		else
			ebegin "Moving Gallium/Clover OpenCL implementation for dynamic switching"
			local cl_dir="/usr/$(get_libdir)/OpenCL/vendors/mesa"
			local ocl_lib=libOpenCL.so
			dodir ${cl_dir}/{lib,include}
			if [ -f "${ED}/usr/include/CL/opencl.h" ]; then
				mv -f "${ED}"/usr/include/CL \
					"${ED}"${cl_dir}/include
			fi
			if [ -f "${ED}/usr/$(get_libdir)/${ocl_lib}" ]; then
				mv -f "${ED}"/usr/$(get_libdir)/${ocl_lib}* \
					"${ED}"${cl_dir}
			fi
		fi
		eend $?
	fi

	if use openmax; then
		echo "XDG_DATA_DIRS=\"${EPREFIX}/usr/share/mesa/xdg\"" > "${T}/99mesaxdgomx"
		doenvd "${T}"/99mesaxdgomx
		keepdir /usr/share/mesa/xdg
	fi

	# wayland-egl library is now provided by dev-libs/wayland
	ebegin "Removing wayland-egl libraries"
	find "${ED}" -name '*wayland-egl*' -exec rm -f {} \;
	eend $?
}

multilib_src_install_all() {
	prune_libtool_files --all
	einstalldocs

	# Only install the platform vulkan headers
	if [ -d "${ED}"/usr/include/vulkan ]; then
		ebegin "Remove generic Vulkan headers"
		rm -rf "${ED}"/usr/include/vulkan || die Remove generic Vulkan headers failed!?!
		eend $?
	fi

	# Install config file for eselect mesa
	insinto /usr/share/mesa
	newins "${FILESDIR}/eselect-mesa.conf.10.1" eselect-mesa.conf
}

multilib_src_test() {
	if use llvm; then
		local llvm_tests='lp_test_arit lp_test_arit lp_test_blend lp_test_blend lp_test_conv lp_test_conv lp_test_format lp_test_format lp_test_printf lp_test_printf'
		pushd src/gallium/drivers/llvmpipe >/dev/null || die
		emake ${llvm_tests}
		pax-mark m ${llvm_tests}
		popd >/dev/null || die
	fi
	emake check
}

pkg_postinst() {
	# Switch to the xorg implementation.
	echo
	eselect opengl set --use-old ${OPENGL_DIR}

	# Select classic/gallium drivers
	if use classic || use gallium; then
		eselect mesa set --auto
	fi

	# Switch to mesa opencl
	if use opencl && ! use ocl-icd; then
		eselect opencl set --use-old ${PN}
	fi

	# run omxregister-bellagio to make the OpenMAX drivers known system-wide
	if use openmax; then
		ebegin "Registering OpenMAX drivers"
		BELLAGIO_SEARCH_PATH="${EPREFIX}/usr/$(get_libdir)/libomxil-bellagio0" \
			OMX_BELLAGIO_REGISTRY=${EPREFIX}/usr/share/mesa/xdg/.omxregister \
			omxregister-bellagio
		eend $?
	fi

	if ! has_version media-libs/libtxc_dxtn; then
		elog "Note that in order to have full S3TC support, it is necessary to install"
		elog "media-libs/libtxc_dxtn as well. This may be necessary to get nice"
		elog "textures in some apps, and some others even require this to run."
	fi
}

pkg_prerm() {
	if use openmax; then
		rm "${EPREFIX}"/usr/share/mesa/xdg/.omxregister
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

vulkan_enable() {
	case $# in
		# for enabling unconditionally
		1)
			VULKAN_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					VULKAN_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}
