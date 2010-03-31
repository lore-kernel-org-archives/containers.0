From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/6][lxc][v3] Add --with-libcr configure option
Date: Wed, 31 Mar 2010 00:06:33 -0700
Message-ID: <20100331070633.GA23567@us.ibm.com>
References: <20100331070440.GA21570@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100331070440.GA21570-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Wed, 24 Mar 2010 17:26:44 -0700
Subject: [PATCH 1/6][lxc][v3] Add --with-libcr configure option

Add a configure option, --with-libcr=dir which would allow linking
with external (i.e USERCR) implementation  of checkpoint/restart.

For now, USERCR "publishes" a app-checkpoint.h, checkpoint.o and
restart.o files which implement the functions app_checkpoint() and
app_restart().

Usage:
	$ ./autogen.sh

	$ ./configure --help |grep libcr
	--with-libcr=dir     use the Checkpoint/Restart implementation in 'dir'

	$ ls /home/guest/user-cr/
	app-checkpoint.h    checkpoint.o    restart.o

	$ ./configure --with-libcr=/home/guest/user-cr

TODO:
	If names of interfaces in USERCR change, we may want to rename
	the config option too ?

	LIBCR_CFLAGS are only needed for src/lxc/{checkpoint.c,restart.c}
	but not sure if there is an easy way to define autoconf CFLAGS
	just for those two files.

Changelog[v2]:
	- Rename --with-usercr to --with-libcr
	- Add libeclone.a to the LIBCR_OBJS variable since functions in
	  libeclone.a will be used by checkpoint() and restart() functions.
	- Add -I${with_libcr}/include to LIBCR_CFLAGS to pick up
	  checkpoint_hdr.h, checkpoint.h etc.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 configure.ac        |   19 +++++++++++++++++++
 src/lxc/Makefile.am |   10 +++++++++-
 2 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/configure.ac b/configure.ac
index f82e7df..fe6584c 100644
--- a/configure.ac
+++ b/configure.ac
@@ -12,6 +12,25 @@ AM_PROG_CC_C_O
 AC_GNU_SOURCE
 AC_CHECK_PROG(SETCAP, setcap, yes, no, $PATH$PATH_SEPARATOR/sbin)
 
+AC_ARG_WITH(libcr, [AS_HELP_STRING([--with-libcr=dir], \
+           [use the Checkpoint/Restart implementation in 'dir'])], [], \
+	   [with_libcr=no])
+
+if test "x$with_libcr" != "xno"; then
+       AS_AC_EXPAND(LIBCR_OBJS, "${with_libcr}/checkpoint.o ${with_libcr}/restart.o ${with_libcr}/libeclone.a")
+       AS_AC_EXPAND(LIBCR_CFLAGS, "-DLIBCR -I${with_libcr} -I$(with_libcr}/include")
+
+       AC_CHECK_FILE([$with_libcr/app-checkpoint.h], [], \
+               AC_MSG_ERROR([--with-libcr specified directory $with_libcr but $with_libcr/app-checkpoint.h was not found]))
+
+       AC_CHECK_FILE([${with_libcr}/checkpoint.o], [], \
+               AC_MSG_ERROR([--with-libcr specified directory $with_libcr but ${with_libcr}/checkpoint.o was not found]))
+
+       AC_CHECK_FILE([${with_libcr}/restart.o], [], \
+               AC_MSG_ERROR([--with-libcr specified directory $with_libcr but ${with_libcr}/restart.o was not found]))
+fi
+
+
 AC_ARG_ENABLE([doc],
 	[AC_HELP_STRING([--enable-doc], [make mans (require docbook2man installed) [default=auto]])],
 	[], [enable_doc=auto])
diff --git a/src/lxc/Makefile.am b/src/lxc/Makefile.am
index 890f706..699c355 100644
--- a/src/lxc/Makefile.am
+++ b/src/lxc/Makefile.am
@@ -46,12 +46,20 @@ liblxc_so_SOURCES = \
 	mainloop.c mainloop.h \
 	af_unix.c af_unix.h
 
-AM_CFLAGS=-I$(top_srcdir)/src
+# We only need $(LIBCR_CFLAGS) for lxc_checkpoint and lxc_restart files
+# but for now, just set it for all.
+AM_CFLAGS=-I$(top_srcdir)/src $(LIBCR_CFLAGS)
 
 liblxc_so_CFLAGS = -fPIC -DPIC $(AM_CFLAGS)
 
+# TODO: Adding $(LIBCR_OBJS) here ensures we don't have undefined references
+# 	when building liblxc.so, but this has the side-effect of putting the
+# 	app_checkpoint/restart functions in liblxc.so. Or alternatively,
+# 	we could remove src/lxc/{checkpoint.o,restart.o} from liblxc.so
+# 	and link lxc-checkpoint/lxc-restart with them directly.
 liblxc_so_LDFLAGS = \
 	-shared \
+	$(LIBCR_OBJS) \
 	-Wl,-soname,liblxc.so.$(firstword $(subst ., ,$(VERSION)))
 
 liblxc_so_LDADD = -lutil
-- 
1.6.6.1
