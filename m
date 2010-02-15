From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] rename and install nsexec
Date: Mon, 15 Feb 2010 16:58:14 -0600
Message-ID: <1266274696-23018-2-git-send-email-serue@us.ibm.com>
References: <1266274696-23018-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1266274696-23018-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Rename nsexeccwp to nsexec, and have it installed into /bin.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile                |    6 +++---
 nsexeccwp.c => nsexec.c |    0
 2 files changed, 3 insertions(+), 3 deletions(-)
 rename nsexeccwp.c => nsexec.c (100%)

diff --git a/Makefile b/Makefile
index 3281f47..b312358 100644
--- a/Makefile
+++ b/Makefile
@@ -21,7 +21,7 @@ CFLAGS += -g $(WARNS) $(CKPT_INCLUDE) $(DEBUG)
 BIN_INSTALL_DIR = /bin
 LIB_INSTALL_DIR = /lib
 
-ECLONE_PROGS = restart nsexeccwp
+ECLONE_PROGS = restart nsexec
 PROGS =	checkpoint ckptinfo $(ECLONE_PROGS)
 LIB_ECLONE = libeclone.a
 
@@ -67,8 +67,8 @@ ckptinfo_types.c: $(CKPT_HEADERS) ckptinfo.py
 	cat $(CKPT_HEADERS) | ./ckptinfo.py > ckptinfo_types.c
 
 install:
-	@echo /usr/bin/install -m 755 checkpoint restart ckptinfo $(BIN_INSTALL_DIR)
-	@/usr/bin/install -m 755 checkpoint restart ckptinfo $(BIN_INSTALL_DIR)
+	@echo /usr/bin/install -m 755 checkpoint restart nsexec ckptinfo $(BIN_INSTALL_DIR)
+	@/usr/bin/install -m 755 checkpoint restart ckptinfo nsexec $(BIN_INSTALL_DIR)
 	@echo /usr/bin/install -m 755 $(LIB_ECLONE) $(LIB_INSTALL_DIR)
 	@/usr/bin/install -m 755 $(LIB_ECLONE) $(LIB_INSTALL_DIR)
 
diff --git a/nsexeccwp.c b/nsexec.c
similarity index 100%
rename from nsexeccwp.c
rename to nsexec.c
-- 
1.6.0.6
