gentoo-gpu
=============

This repository contains mostly live ebuilds for
bleeding-edge support of GPU APIs: OpenCL, GLVND,
Vulkan.

It also contains additional associated software,
including nvidia-drivers with support for system-
wide GLNVD.

The media-libs/mesa ebuild incorporates Beignet for
Intel HD Graphics OpenCL support, along with optional
builds for the OpenGL Vendor Neutral Dispatch library
(GLVND) and Vulkan for Intel HD Graphics!

GCC Offload Acceleration support integrated with
live GCC7 ebuilds.  (Currently only NVPTX.  MIC
support will follow, but I'm unable to test it.)

