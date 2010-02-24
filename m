From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 4/4][user-cr] Rename libeclone.a to libcheckpoint.a
Date: Wed, 24 Feb 2010 00:37:26 -0800
Message-ID: <20100224083726.GF18758@us.ibm.com>
References: <20100224083452.GB18758@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100224083452.GB18758-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From c4063a8976fd8eca9b8d62a12b95c3125c8471c7 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 23 Feb 2010 16:25:36 -0800
Subject: [PATCH 4/4][user-cr] Rename libeclone.a to libcheckpoint.a

Export app_restart() and usercr.h to user in a new library libcheckpoint.a.
Until eclone() makes it into glibc, include eclone() also in this new library
and remove the libeclone.a.

TODO:
	- cr-tests should be modified to look for libcheckpoint.a instead
	  of libeclone.a

	- libcheckpoint.a should eventually include the app_checkpoint()
	  interface.  I am guessing extracting the app_checkpoint() from
	  checkpoint.c would be similar to (or somewhat easier than) the
	  way we extracted app_restart() from restart.c

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 Makefile  |   33 ++++++++++++++++++++-------------
 restart.c |    6 ++++++
 2 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/Makefile b/Makefile
index 4449081..090914a 100644
--- a/Makefile
+++ b/Makefile
@@ -18,14 +18,14 @@ WARNS := -Wall -Wstrict-prototypes -Wno-trigraphs
 CFLAGS += -g $(WARNS) $(CKPT_INCLUDE) $(DEBUG)
 
 # install dir
+INC_INSTALL_DIR = /usr/include
 BIN_INSTALL_DIR = /bin
 LIB_INSTALL_DIR = /lib
 
-restart: restart.o restart-main.o
-
 ECLONE_PROGS = restart nsexec
 PROGS =	checkpoint ckptinfo $(ECLONE_PROGS)
-LIB_ECLONE = libeclone.a
+LIB_CHECKPOINT = libcheckpoint.a
+INC_CHECKPOINT = usercr.h
 
 # other cleanup
 OTHER = ckptinfo_types.c
@@ -34,32 +34,37 @@ LDLIBS = -lm
 
 .PHONY: all distclean clean headers install
 
-all: $(PROGS)
+all: $(PROGS) $(LIB_CHECKPOINT)
 	@make -C test
 
-$(LIB_ECLONE):
-	ar ruv $(LIB_ECLONE) $^
+restart: restart-main.o
+
+$(PROGS): $(LIB_CHECKPOINT) 
+
+$(LIB_CHECKPOINT):
+	ar ruv $(LIB_CHECKPOINT) $^
 
 # restart needs to be thread-safe
 restart: CFLAGS += -D__REENTRANT -pthread
 
+$(LIB_CHECKPOINT): restart.o
+
 # eclone() is architecture specific
 ifneq ($(SUBARCH),)
-$(ECLONE_PROGS): $(LIB_ECLONE) 
 $(ECLONE_PROGS): CFLAGS += -DARCH_HAS_ECLONE
-$(LIB_ECLONE): clone_$(SUBARCH).o genstack.o
+$(LIB_CHECKPOINT): clone_$(SUBARCH).o genstack.o
 endif
 
 # on powerpc, need also assembly file
 ifeq ($(SUBARCH),ppc)
 CFLAGS += -m32
 ASFLAGS += -m32
-$(LIB_ECLONE): clone_$(SUBARCH)_.o
+$(LIB_CHECKPOINT): clone_$(SUBARCH)_.o
 endif
 ifeq ($(SUBARCH),ppc64)
 CFLAGS += -m64
 ASFLAGS += -m64
-$(LIB_ECLONE): clone_$(SUBARCH)_.o
+$(LIB_CHECKPOINT): clone_$(SUBARCH)_.o
 endif
 
 # ckptinfo dependencies
@@ -71,8 +76,10 @@ ckptinfo_types.c: $(CKPT_HEADERS) ckptinfo.py
 install:
 	@echo /usr/bin/install -m 755 checkpoint restart nsexec ckptinfo $(BIN_INSTALL_DIR)
 	@/usr/bin/install -m 755 checkpoint restart ckptinfo nsexec $(BIN_INSTALL_DIR)
-	@echo /usr/bin/install -m 755 $(LIB_ECLONE) $(LIB_INSTALL_DIR)
-	@/usr/bin/install -m 755 $(LIB_ECLONE) $(LIB_INSTALL_DIR)
+	@echo /usr/bin/install -m 755 $(INC_CHECKPOINT) $(INC_INSTALL_DIR)
+	@/usr/bin/install -m 755 $(INC_CHECKPOINT) $(INC_INSTALL_DIR)
+	@echo /usr/bin/install -m 755 $(LIB_CHECKPOINT) $(LIB_INSTALL_DIR)
+	@/usr/bin/install -m 755 $(LIB_CHECKPOINT) $(LIB_INSTALL_DIR)
 
 $(CKPT_HEADERS): %:
 	./scripts/extract-headers.sh -s $(KERNELSRC) -o ./include
@@ -83,5 +90,5 @@ distclean: clean
 	@rm -f $(CKPT_HEADERS)
 
 clean:
-	@rm -f $(PROGS) $(LIB_ECLONE) $(OTHER) *~ *.o headers.h
+	@rm -f $(PROGS) $(LIB_CHECKPOINT) $(OTHER) *~ *.o headers.h
 	@make -C test clean
diff --git a/restart.c b/restart.c
index b1518f2..a163862 100644
--- a/restart.c
+++ b/restart.c
@@ -530,6 +530,12 @@ int app_restart(struct restart_args *args)
 		ret = ckpt_coordinator(&ctx);
 	}
 
+	/*
+	 * Hack for LXC - which currently only uses pidns == 1, pid0 == 1;
+	 */
+	if (ret >= 0)
+		ret = global_child_pid;
+
 	return ret;
 }
 
-- 
1.6.6.1
