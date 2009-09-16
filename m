From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/4] makefile hack for powerpc
Date: Wed, 16 Sep 2009 04:27:51 -0500
Message-ID: <1253093271-16357-5-git-send-email-ntl@pobox.com>
References: <1253093271-16357-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253093271-16357-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Add an explict restart target which links clone_ppc32.o into the
restart executable.

Ideas on how to handle this in a mergeable form are welcome.
---
 Makefile |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/Makefile b/Makefile
index 8cd0c2d..10c068c 100644
--- a/Makefile
+++ b/Makefile
@@ -45,6 +45,9 @@ all: $(PROGS)
 ckptinfo: ckptinfo_types.o
 
 restart: CFLAGS += -D__REENTRANT -pthread
+# powerpc hack
+restart: restart.c clone_ppc32.o
+	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -o $@
 
 ckptinfo_types.o: ckptinfo_types.c
 	@echo $(CC) -c $(CFLAGS) $<
-- 
1.6.0.6
