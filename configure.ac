dnl -*- Autoconf -*-
dnl
dnl   configuration script for GNU G-Golf
dnl   Process this file with autoconf to produce configure.
dnl

define(G_GOLF_CONFIGURE_COPYRIGHT,[[

Copyright (C) 2016
Free Software Foundation, Inc.

This file is part of GNU G-Golf

GNU G-Golf is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 3 of the
License, or (at your option) any later version.

GNU G-Golf is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with GNU G-Golf.  If not, see
<https://www.gnu.org/licenses/lgpl.html>.

]])

AC_PREREQ(2.69)

AC_INIT(
  [g-golf],
  [0.1.0-mockup-1],
  [david at altosw dot be])

AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
dnl Use `serial-tests' so the output `check-guile' is not hidden
dnl (`parallel-tests' is the default in Automake 1.13.)
dnl `serial-tests' was introduced in Automake 1.12.
AM_INIT_AUTOMAKE([1.14 gnu -Wall -Werror -Wno-portability -Wno-syntax \
  color-tests serial-tests foreign])
AM_MAINTAINER_MODE([enable])
AM_SILENT_RULES([yes])

dnl AC_PROG_CC
dnl AC_STDC_HEADERS
dnl LT_INIT([disable-static])

AC_COPYRIGHT(G_GOLF_CONFIGURE_COPYRIGHT)
AC_CONFIG_SRCDIR([g-golf])

AC_CHECK_PROG(have_makeinfo, makeinfo, yes, no)
AM_CONDITIONAL(HAVE_MAKEINFO, test "$have_makeinfo" = yes)

GUILE_PKG([2.2 2.0])
GUILE_PROGS([2.0.12])
GUILE_SITE_DIR
GUILE_GLOBAL_SITE_DIR
GUILE_SITE_CCACHE_DIR

PKG_CHECK_MODULES(GI, gobject-introspection-1.0 >= 1.48.0)
PKG_CHECK_MODULES(GLIB, glib-2.0 >= 2.48.0)
PKG_CHECK_MODULES(GOBJECT, gobject-2.0 >= 2.48.0)

PKG_CHECK_MODULES(GUILE_LIB, guile-lib-1.0 >= 0.2.3)

AC_CONFIG_FILES(
  [pre-inst-env],
  [chmod +x pre-inst-env])
AC_CONFIG_FILES([
  meta/g-golf-1.0.pc
  Makefile
  doc/Makefile
  test-suite/Makefile
])
AC_OUTPUT
