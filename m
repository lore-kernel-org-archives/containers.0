From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][user-cr][v2] Create libeclone.a
Date: Mon, 8 Feb 2010 09:58:08 -0800
Message-ID: <20100208175808.GA29695@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Here is an updated patch which includes genstack.o in libeclone and
adds Serge's ack.

---
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Sat, 6 Feb 2010 10:45:10 -0800
Subject: [PATCH 1/1] Create libeclone.a

The user-api to the eclone() system call is architecture dependent.

Besides checkpoint/restart code, this api could be used by eclone() test
cases (see cr-tests.git tree) and possibly other users of eclone().

To avoid duplication of the arch dependent code, move the api into
libeclone.a (as suggested by Serge Hallyn).

Changelog[v2]:
	- Include genstack.o in libeclone.a

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/Makefile b/Makefile
index 35188f9..b7af994 100644
--- a/Makefile
+++ b/Makefile
@@ -5,7 +5,7 @@ CKPT_HEADERS = include/linux/checkpoint.h \
 		include/linux/checkpoint_hdr.h \
 		include/asm/checkpoint_hdr.h
 
-# detect architecture (for clone_with_pids)
+# detect architecture (for eclone)
 SUBARCH = $(patsubst i%86,x86_32,$(shell uname -m))
 
 # compile with debug ?
@@ -19,8 +19,11 @@ CFLAGS += -g $(WARNS) $(CKPT_INCLUDE) $(DEBUG)
 
 # install dir
 INSTALL_DIR = /bin
+LIB_INSTALL_DIR = /lib
 
-PROGS =	checkpoint restart ckptinfo nsexeccwp
+ECLONE_PROGS = restart nsexeccwp
+PROGS = checkpoint ckptinfo $(ECLONE_PROGS) 
+LIB_ECLONE = libeclone.a
 
 # other cleanup
 OTHER = ckptinfo_types.c
@@ -32,21 +35,22 @@ LDLIBS = -lm
 all: $(PROGS)
 	@make -C test
 
+$(LIB_ECLONE):
+	ar ruv $(LIB_ECLONE) $^
+
 # restart needs to be thread-safe
 restart: CFLAGS += -D__REENTRANT -pthread
 
 # eclone() is architecture specific
 ifneq ($(SUBARCH),)
-restart: clone_$(SUBARCH).o genstack.o
-restart: CFLAGS += -DARCH_HAS_ECLONE
-nsexeccwp: clone_$(SUBARCH).o genstack.o
-nsexeccwp: CFLAGS += -DARCH_HAS_ECLONE
+$(ECLONE_PROGS): $(LIB_ECLONE) 
+$(ECLONE_PROGS): CFLAGS += -DARCH_HAS_ECLONE
+$(LIB_ECLONE): clone_$(SUBARCH).o genstack.o
 endif
 
 # on powerpc, need also assembly file
 ifeq ($(SUBARCH),ppc)
-restart: clone_$(SUBARCH)_.o
-nsexeccwp: clone_$(SUBARCH)_.o
+$(LIB_ECLONE): clone_$(SUBARCH)_.o
 endif
 
 # ckptinfo dependencies
@@ -56,6 +60,8 @@ ckptinfo_types.c: $(CKPT_HEADERS) ckptinfo.py
 	cat $(CKPT_HEADERS) | ./ckptinfo.py > ckptinfo_types.c
 
 install:
+	@echo /usr/bin/install -m 755 $(LIB_ECLONE) $(LIB_INSTALL_DIR)
+	@/usr/bin/install -m 755 $(LIB_ECLONE) $(LIB_INSTALL_DIR)
 	@echo /usr/bin/install -m 755 checkpoint restart ckptinfo $(INSTALL_DIR)
 	@/usr/bin/install -m 755 checkpoint restart ckptinfo $(INSTALL_DIR)
 
@@ -68,5 +74,5 @@ distclean: clean
 	@rm -f $(CKPT_HEADERS)
 
 clean:
-	@rm -f $(PROGS) $(OTHER) *~ *.o headers.h
+	@rm -f $(PROGS) $(OTHER) $(LIB_ECLONE) *~ *.o headers.h
 	@make -C test clean
-- 
1.6.0.4
