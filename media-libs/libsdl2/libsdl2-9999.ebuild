# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# TODO: convert FusionSound #484250

EAPI=7

CMAKE_ECLASS=cmake

inherit flag-o-matic toolchain-funcs eutils cmake-multilib

MY_P=SDL2-${PV}
DESCRIPTION="Simple Direct Media Layer"
HOMEPAGE="http://www.libsdl.org"

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI=https://github.com/libsdl-org/SDL.git
else
	SRC_URI="http://www.libsdl.org/release/${MY_P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86"
fi

LICENSE="ZLIB"
SLOT="0"

IUSE="cpu_flags_x86_3dnow alsa altivec custom-cflags fusionsound gles2 haptic +joystick cpu_flags_x86_mmx nas opengl oss pulseaudio +sound cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_sse3 static-libs +threads tslib +video wayland X xinerama xscreensaver libsamplerate vulkan xrandr"
REQUIRED_USE="
	alsa? ( sound )
	fusionsound? ( sound )
	gles2? ( video )
	nas? ( sound )
	opengl? ( video )
	pulseaudio? ( sound )
	wayland? ( gles2 )
	xinerama? ( X )
	xscreensaver? ( X )"

RDEPEND="
	alsa? ( >=media-libs/alsa-lib-1.0.27.2[${MULTILIB_USEDEP}] )
	>=sys-apps/dbus-1.6.18-r1[${MULTILIB_USEDEP}]
	fusionsound? ( || ( >=media-libs/FusionSound-1.1.1 >=dev-libs/DirectFB-1.7.1[fusionsound] ) )
	gles2? ( >=media-libs/mesa-9.1.6[${MULTILIB_USEDEP},gles2] )
	nas? ( >=media-libs/nas-1.9.4[${MULTILIB_USEDEP}] )
	opengl? (
		>=virtual/opengl-7.0-r1[${MULTILIB_USEDEP}]
		>=virtual/glu-9.0-r1[${MULTILIB_USEDEP}]
	)
	pulseaudio? ( >=media-sound/pulseaudio-2.1-r1[${MULTILIB_USEDEP}] )
	tslib? ( >=x11-libs/tslib-1.0-r3[${MULTILIB_USEDEP}] )
	>=virtual/libudev-208:=[${MULTILIB_USEDEP}]
	wayland? (
		>=dev-libs/wayland-1.0.6[${MULTILIB_USEDEP}]
		>=media-libs/mesa-9.1.6[${MULTILIB_USEDEP},egl,gles2,wayland]
		>=x11-libs/libxkbcommon-0.2.0[${MULTILIB_USEDEP}]
	)
	X? (
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXcursor-1.1.14[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXi-1.7.2[${MULTILIB_USEDEP}]
		xrandr? ( >=x11-libs/libXrandr-1.4.2[${MULTILIB_USEDEP}] )
		>=x11-libs/libXt-1.1.4[${MULTILIB_USEDEP}]
		>=x11-libs/libXxf86vm-1.1.3[${MULTILIB_USEDEP}]
		xinerama? ( >=x11-libs/libXinerama-1.1.3[${MULTILIB_USEDEP}] )
		xscreensaver? ( >=x11-libs/libXScrnSaver-1.2.2-r1[${MULTILIB_USEDEP}] )
		libsamplerate? ( media-libs/libsamplerate )
	)
	vulkan? ( >=media-libs/vulkan-loader-1.0.61 )"
DEPEND="${RDEPEND}
	X? (
		>=x11-base/xorg-proto-2018.4
	)
	virtual/pkgconfig"

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/SDL2/SDL_config.h
)

PATCHES=(
	# https://bugzilla.libsdl.org/show_bug.cgi?id=1431
	#"${FILESDIR}"/${P}-static-libs.patch
	"${FILESDIR}"/${P}-wayland-before-x11.patch
	"${FILESDIR}"/${P}-fix-gl-multilib.patch
	#"${FILESDIR}"/${PN}-2.0.12-vulkan-headers.patch
	"${FILESDIR}"/${P}-fix-cmake-linkage.patch
)

[[ ${PV} == 9999* ]] || S=${WORKDIR}/${MY_P}

src_prepare() {
	sed -i -e 's/\"\.\/khronos\/\(.*\)\"/<\1>/' src/video/SDL_vulkan_internal.h || die
	cmake_src_prepare
}

multilib_src_configure() {
	local mycmakeargs=()
	use custom-cflags || strip-flags
	append-cppflags -DHAVE_VULKAN_H

	# We always build shared libs, but static libs are only built when
	# no preference is made or shared libs are disabled
	if ! use static-libs; then
		mycmakeargs+=(
			-DBUILD_SHARED_LIBS=YES
		)
	fi

	mycmakeargs+=(
		-DGCC_ATOMICS=YES
		-DSDL_AUDIO=$(usex sound)
		-DSDL_VIDEO=$(usex video)
		-DSDL_RENDER=YES
		-DSDL_EVENTS=YES
		-DSDL_JOYSTICK=$(usex joystick)
		-DSDL_HAPTIC=$(usex haptic)
		-DSDL_POWER=YES
		-DSDL_FILESYSTEM=YES
		-DSDL_THREADS=$(usex threads)
		-DSDL_TIMERS=YES
		-DSDL_FILE=YES
		-DSDL_LOADSO=YES
		-DSDL_CPUINFO=YES
		-DASSEMBLY=YES
		-DSSEMATH=$(usex cpu_flags_x86_sse)
		-DMMX=$(usex cpu_flags_x86_mmx)
		-D3DNOW=$(usex cpu_flags_x86_3dnow)
		-DSSE=$(usex cpu_flags_x86_sse)
		-DSSE2=$(usex cpu_flags_x86_sse2)
		-DSSE3=$(usex cpu_flags_x86_sse3)
		-DALTIVEC=$(usex altivec)
		-DOSS=$(usex oss)
		-DALSA=$(usex alsa)
		-DALSA_SHARED=NO
		-DESD=NO
		-DPULSEAUDIO=$(usex pulseaudio)
		-DPULSEAUDIO_SHARED=NO
		-DLIBSAMPLERATE=$(usex libsamplerate)
		-DLIBSAMPLERATE_SHARED=NO
		-DARTS=NO
		-DNAS=$(usex nas)
		-DNAS_SHARED=NO
		-DSNDIO=NO
		-DSNDIO_SHARED=NO
		-DDISKAUDIO=$(usex sound)
		-DDUMMYAUDIO=$(usex sound)
		-DVIDEO_WAYLAND=$(usex wayland)
		-DWAYLAND_SHARED=NO
		-DVIDEO_X11=$(usex X)
		-DX11_SHARED=NO
		-DVIDEO_X11_XCURSOR=$(usex X)
		-DVIDEO_X11_XINERAMA=$(usex xinerama)
		-DVIDEO_X11_XINPUT=$(usex X)
		-DVIDEO_X11_XRANDR=$(usex xrandr)
		-DVIDEO_X11_XSCRNSAVER=$(usex xscreensaver)
		-DVIDEO_X11_XSHAPE=$(usex X)
		-DVIDEO_X11_XVM=$(usex X)
		-DVIDEO_COCOA=NO
		-DVIDEO_DIRECTFB=NO
		-DVIDEO_VULKAN=$(usex vulkan)
		-DFUSIONSOUND=$(multilib_native_usex fusionsound)
		-DFUSIONSOUND_SHARED=NO
		-DVIDEO_DUMMY=$(usex video)
		-DVIDEO_OPENGL=$(usex opengl)
		-DVIDEO_OPENGLES=$(usex gles2)
		-DVIDEO_RPI=NO
		-DSDL_USE_IME=NO
		-DINPUT_TSLIB=$(usex tslib)
		-DDIRECTX=NO
		-DRPATH=NO
		-DRENDER_D3D=NO
	)
	cmake_src_configure
}

multilib_src_install() {
	cmake_src_install

	multilib_is_native_abi && \
		dodoc "${S}"/{BUGS,CREDITS,README-SDL,TODO,WhatsNew}.txt "${S}"/docs/README*.md
}
