From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: liblxc: Add pkg-config file
Date: Thu, 29 Jan 2009 02:27:58 -0800
Message-ID: <1233224878.28626.132.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Add a pkg-config file which makes developing with liblxc easier. For
example, if an unusual --prefix is used to install liblxc no special
changes to Makefile rules are needed if pkg-config is used:

        gcc $(shell pkg-config --cflags) $(shell pkg-config --libs) -o my_lxc_prog my_lxc_prog.c

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile.am  |    5 ++++-
 configure.in |    2 ++
 lxc.pc.in    |   15 +++++++++++++++
 3 files changed, 21 insertions(+), 1 deletion(-)

Index: lxc-0.5.2-mh/configure.in
===================================================================
--- lxc-0.5.2-mh.orig/configure.in
+++ lxc-0.5.2-mh/configure.in
@@ -14,6 +14,7 @@ AC_GNU_SOURCE
 AC_PROG_LIBTOOL
 AC_CHECK_PROG(SETCAP, setcap, yes, no)
 AC_CHECK_PROG(DOCBOOK, docbook2man, yes, no)
+PKG_PROG_PKG_CONFIG
 AM_CONDITIONAL(ENABLE_DOCBOOK, test x$DOCBOOK = xyes)
 AS_AC_EXPAND(BINDIR, $bindir)
 AS_AC_EXPAND(SYSCONFDIR, $sysconfdir)
@@ -52,6 +53,7 @@ AC_SUBST(LXC_MICRO_VERSION)
 AC_CONFIG_FILES([
         Makefile
 	lxc.spec
+ 	lxc.pc
         config/Makefile
 
         doc/Makefile
Index: lxc-0.5.2-mh/lxc.pc.in
===================================================================
--- /dev/null
+++ lxc-0.5.2-mh/lxc.pc.in
@@ -0,0 +1,15 @@
+prefix=@prefix@
+exec_prefix=@exec_prefix@
+libdir=@libdir@
+libexecdir=@libexecdir@
+includedir=@includedir@
+datadir=@datadir@
+
+localstatedir=@localstatedir@
+
+Name: lxc
+Description: Linux containers tools
+Version: @VERSION@
+Requires:
+Libs:
+Cflags:
Index: lxc-0.5.2-mh/Makefile.am
===================================================================
--- lxc-0.5.2-mh.orig/Makefile.am
+++ lxc-0.5.2-mh/Makefile.am
@@ -2,7 +2,10 @@
 
 SUBDIRS = doc src test etc scripts 
 DIST_SUBDIRS = config doc src test etc scripts
-EXTRA_DIST = lxc.spec CONTRIBUTING MAINTAINERS ChangeLog
+EXTRA_DIST = lxc.spec lxc.pc.in CONTRIBUTING MAINTAINERS ChangeLog
+
+pkgconfigdir = $(libdir)/pkgconfig
+pkgconfig_DATA = lxc.pc
 
 ChangeLog::
 	@touch ChangeLog
