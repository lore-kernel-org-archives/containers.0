From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: fix broken compilation for architectures that don't
	support c/r
Date: Tue,  9 Feb 2010 18:54:03 -0500
Message-ID: <1265759643-23495-1-git-send-email-orenl@cs.columbia.edu>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

The include file <linux/checkpoint_hdr.h> itself includes the header
<asm/checkpoint_hdr.h>, which exists only for supported architectures.

Therefore, non c/r specific code must not include it unconditionally,
but only when CONFIG_CHECKPOINT is defined.

Instead, either use include <linux/checkpoint.h>, which take the
necessary precautions (preferred), or explicit test CONFIG_CHECKPOINT.

This patch fixes this in eventfd.c and eventpoll.c, to allow a kernel
with the c/r patches to compile on other architectures.

(Reported by: Christoffer Dall)

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 fs/eventfd.c   |    1 -
 fs/eventpoll.c |    5 -----
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/fs/eventfd.c b/fs/eventfd.c
index 5259d6e..3277534 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -19,7 +19,6 @@
 #include <linux/kref.h>
 #include <linux/eventfd.h>
 #include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
 
 struct eventfd_ctx {
 	struct kref kref;
diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index cb286c7..aedaf87 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -38,12 +38,7 @@
 #include <asm/io.h>
 #include <asm/mman.h>
 #include <asm/atomic.h>
-
-#ifdef CONFIG_CHECKPOINT
 #include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
-#include <linux/deferqueue.h>
-#endif
 
 /*
  * LOCKING:
-- 
1.6.3.3
