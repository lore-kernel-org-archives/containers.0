From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/4] user-cr: Remove pointless echo lines and @-prefixed lines
Date: Fri, 26 Feb 2010 10:56:42 -0800
Message-ID: <ac29ecfa1c93bb7fd7ae65794d65c4526e435e76.1267210517.git.matthltc@us.ibm.com>
References: <1267210602-11444-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1267210602-11444-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <eef3af1ee39b3146facf08eac6230be041e6263d.1267210517.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <eef3af1ee39b3146facf08eac6230be041e6263d.1267210517.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

In Make, actions prefixed with @ do not produce output showing what
Make is executing. It seems rather silly to manually echo the precise
output Make would produce automatically without the @ prefix.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/Makefile b/Makefile
index f8b113a..a4a1a8a 100644
--- a/Makefile
+++ b/Makefile
@@ -69,10 +69,8 @@ ckptinfo_types.c: $(CKPT_HEADERS) ckptinfo.py
 
 install: $(PROGS)
 	/usr/bin/install -d -D $(BIN_INSTALL_DIR) $(LIB_INSTALL_DIR)
-	@echo /usr/bin/install -m 755 checkpoint restart nsexec ckptinfo $(BIN_INSTALL_DIR)
-	@/usr/bin/install -m 755 checkpoint restart ckptinfo nsexec $(BIN_INSTALL_DIR)
-	@echo /usr/bin/install -m 755 $(LIB_ECLONE) $(LIB_INSTALL_DIR)
-	@/usr/bin/install -m 755 $(LIB_ECLONE) $(LIB_INSTALL_DIR)
+	/usr/bin/install -m 755 checkpoint restart ckptinfo nsexec $(BIN_INSTALL_DIR)
+	/usr/bin/install -m 755 $(LIB_ECLONE) $(LIB_INSTALL_DIR)
 
 $(CKPT_HEADERS): %:
 	./scripts/extract-headers.sh -s $(KERNELSRC) -o ./include
-- 
1.6.3.3
