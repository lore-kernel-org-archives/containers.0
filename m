From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/4] user-cr: Fix install rule dependencies
Date: Fri, 26 Feb 2010 10:56:41 -0800
Message-ID: <ebfc75a7048c07d030934bdcf98ae2bac12e685a.1267210517.git.matthltc@us.ibm.com>
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

Since we're installing these programs we need them to be built first.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index e776857..f8b113a 100644
--- a/Makefile
+++ b/Makefile
@@ -67,7 +67,7 @@ ckptinfo: ckptinfo_types.o
 ckptinfo_types.c: $(CKPT_HEADERS) ckptinfo.py
 	cat $(CKPT_HEADERS) | ./ckptinfo.py > ckptinfo_types.c
 
-install:
+install: $(PROGS)
 	/usr/bin/install -d -D $(BIN_INSTALL_DIR) $(LIB_INSTALL_DIR)
 	@echo /usr/bin/install -m 755 checkpoint restart nsexec ckptinfo $(BIN_INSTALL_DIR)
 	@/usr/bin/install -m 755 checkpoint restart ckptinfo nsexec $(BIN_INSTALL_DIR)
-- 
1.6.3.3
