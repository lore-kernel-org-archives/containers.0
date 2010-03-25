From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH][lxc]: Add --with-usercr configure option
Date: Wed, 24 Mar 2010 18:05:24 -0700
Message-ID: <20100325010524.GA7385@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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


Pls let me know if this will work. Will address your other comments
and repost entire patchset.

---
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Wed, 24 Mar 2010 17:26:44 -0700
Subject: [PATCH 1/1] Add --with-usercr configure option

Add a configure option, --with-usercr=dir which would allow linking
with external (i.e USERCR) implementation  of checkpoint/restart.

For now, USERCR "publishes" a app-checkpoint.h, checkpoint.o and
restart.o files which implement the functions app_checkpoint() and
app_restart().

Usage:
	$ ./autogen.sh

	$ ./configure --help |grep usercr
	--with-usercr=dir     use the Checkpoint/Restart implementation in 'dir'

	$ ls /home/guest/user-cr/
	app-checkpoint.h    checkpoint.o    restart.o

	$ ./configure --with-usercr=/home/guest/user-cr

TODO:
	If names of interfaces in USERCR change, we may want to rename
	the config option too ?

	Can we remove the src/lxc/{checkpoint.o,restart.o} files from
	liblxc.so and lxc-checkpoint/lxc-restart directly with them ?
	That way, the USERCR interfaces/object files don't end up in
	liblxc.so.

	USERCR_CFLAGS are only needed for src/lxc/{checkpoint.c,restart.c}
	but not sure if there is an easy way to define autoconf CFLAGS
	just for those two files.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 configure.ac        |   19 +++++++++++++++++++
 src/lxc/Makefile.am |   10 +++++++++-
 2 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/configure.ac b/configure.ac
index f82e7df..dd46e4d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -12,6 +12,25 @@ AM_PROG_CC_C_O
 AC_GNU_SOURCE
 AC_CHECK_PROG(SETCAP, setcap, yes, no, $PATH$PATH_SEPARATOR/sbin)
 
+AC_ARG_WITH(usercr, [AS_HELP_STRING([--with-usercr=dir], \
+           [use the Checkpoint/Restart implementation in 'dir'])], [], \
+	   [with_usercr=no])
+
+if test "x$with_usercr" != "xno"; then
+       AS_AC_EXPAND(USERCR_OBJS, "${with_usercr}/checkpoint.o ${with_usercr}/restart.o")
+       AS_AC_EXPAND(USERCR_CFLAGS, "-DUSERCR -I${with_usercr}")
+
+       AC_CHECK_FILE([$with_usercr/app-checkpoint.h], [], \
+               AC_MSG_ERROR([--with-usercr specified directory $with_usercr but $with_usercr/app-checkpoint.h was not found]))
+
+       AC_CHECK_FILE([${with_usercr}/checkpoint.o], [], \
+               AC_MSG_ERROR([--with-usercr specified directory $with_usercr but ${with_usercr}/checkpoint.o was not found]))
+
+       AC_CHECK_FILE([${with_usercr}/restart.o], [], \
+               AC_MSG_ERROR([--with-usercr specified directory $with_usercr but ${with_usercr}/restart.o was not found]))
+fi
+
+
 AC_ARG_ENABLE([doc],
 	[AC_HELP_STRING([--enable-doc], [make mans (require docbook2man installed) [default=auto]])],
 	[], [enable_doc=auto])
diff --git a/src/lxc/Makefile.am b/src/lxc/Makefile.am
index be64b2a..e8748b5 100644
--- a/src/lxc/Makefile.am
+++ b/src/lxc/Makefile.am
@@ -45,12 +45,20 @@ liblxc_so_SOURCES = \
 	mainloop.c mainloop.h \
 	af_unix.c af_unix.h
 
-AM_CFLAGS=-I$(top_srcdir)/src
+# We only need $(USERCR_CFLAGS) for lxc_checkpoint and lxc_restart files
+# but for now, just set it for all.
+AM_CFLAGS=-I$(top_srcdir)/src $(USERCR_CFLAGS)
 
 liblxc_so_CFLAGS = -fPIC -DPIC $(AM_CFLAGS)
 
+# TODO: Adding $(USERCR_OBJS) here ensures we don't have undefined references
+# 	when building liblxc.so, but this has the side-effect of putting the
+# 	app_checkpoint/restart functions in liblxc.so. Or alternatively,
+# 	we could remove src/lxc/{checkpoint.o,restart.o} from liblxc.so
+# 	and link lxc-checkpoint/lxc-restart with them directly.
 liblxc_so_LDFLAGS = \
 	-shared \
+	$(USERCR_OBJS) \
 	-Wl,-soname,liblxc.so.$(firstword $(subst ., ,$(VERSION)))
 
 liblxc_so_LDADD = -lutil
-- 
1.6.6.1
