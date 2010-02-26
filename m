From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] [RFC] user-cr: Eliminate SUBARCH from Makefile
Date: Fri, 26 Feb 2010 12:37:49 -0800
Message-ID: <0c6c11c99f939c74b86893d5eac268ce5c612fe7.1267216666.git.matthltc@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux-Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

[ Depends on recent series of non-RFC Makefile patches ]

SUBARCH is gross. We shouldn't need to detect the arch to compile to
using uname. It's bad practice because we could be using a cross compiler,
or someone may (gag) autoconfiscate this tree. If we must select a true
subarch, we should just let builders set -mXX in CFLAGS.

This patch tries to build all of the clone_*.[cSs] files. Any builds
that fail are quietly ignored and don't get used. One that succeeds
gets hardlinked to clone.a and subsequently linked into libeclone.a

This makes SUBARCH unnecessary.

Only tested on x86-32 so far. This also doesn't properly add clone.a
to libclone.a for some reason.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile |   55 ++++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/Makefile b/Makefile
index 60ddccd..03acea7 100644
--- a/Makefile
+++ b/Makefile
@@ -5,9 +5,6 @@ CKPT_HEADERS = include/linux/checkpoint.h \
 		include/linux/checkpoint_hdr.h \
 		include/asm/checkpoint_hdr.h
 
-# detect architecture (for eclone)
-SUBARCH = $(patsubst i%86,x86_32,$(shell uname -m))
-
 # compile with debug ?
 DEBUG = -DCHECKPOINT_DEBUG
 
@@ -42,24 +39,44 @@ $(LIB_ECLONE):
 # restart needs to be thread-safe
 restart: CFLAGS += -D__REENTRANT -pthread
 
+# Set CFLAGS to -m32 or -m64 to select a non-default subarch.
+# Hence we don't need the commented out CFLAGS-setting rules
+# immediately below.
+
+# clone_ppc.o: CFLAGS += -m32
+clone_ppc_.o: ASFLAGS += -m32
+# clone_ppc64.o: CFLAGS += -m64
+clone_ppc64_.o: ASFLAGS += -m64
+
+# powerpc clone.a requires two object files
+clone_ppc.a: clone_ppc_.o clone_ppc.o
+	$(AR) ruv $@ $^
+
+clone_ppc64.a: clone_ppc64_.o clone_ppc64.o
+	$(AR) ruv $@ $^
+
+# The remaining arch's clone.a all share the following rule
+%.a: %.o
+	$(AR) ruv $@ $^
+
+# Unlike normal rule dependencies, we want to link libeclone with the
+# object files that build successfully and ignore the rest. Normally
+# we do this by testing which will build and then setting a variable
+# for the dependency to use. Here we just depend on all the real source
+# files and hardlink the result of a successful build.
+clone.a: $(shell echo clone_*.[cSs])
+	@$(MAKE) -s clone_x86_32.a && ln clone_x86_32.a clone.a || /bin/true
+	@$(MAKE) -s clone_x86_64.a && ln clone_x86_64.a clone.a || /bin/true
+	@$(MAKE) -s clone_ppc.a && ln clone_ppc.a clone.a || /bin/true
+	@$(MAKE) -s clone_ppc64.a && ln clone_ppc64.o clone.a || /bin/true
+	@$(MAKE) -s clone_s390x.a && ln clone_s390x.o clone.a || /bin/true
+
 # eclone() is architecture specific
-ifneq ($(SUBARCH),)
-$(ECLONE_PROGS): $(LIB_ECLONE) 
+# TODO why doesn't clone.a link properly into libeclone.a??
+$(ECLONE_PROGS): $(LIB_ECLONE) clone.a
 $(ECLONE_PROGS): CFLAGS += -DARCH_HAS_ECLONE
-$(LIB_ECLONE): clone_$(SUBARCH).o genstack.o
-endif
-
-# on powerpc, need also assembly file
-ifeq ($(SUBARCH),ppc)
-CFLAGS += -m32
-ASFLAGS += -m32
-$(LIB_ECLONE): clone_$(SUBARCH)_.o
-endif
-ifeq ($(SUBARCH),ppc64)
-CFLAGS += -m64
-ASFLAGS += -m64
-$(LIB_ECLONE): clone_$(SUBARCH)_.o
-endif
+$(LIB_ECLONE): clone.a genstack.o
+
 
 # ckptinfo dependencies
 ckptinfo: ckptinfo_types.o
-- 
1.6.3.3
