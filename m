From: paolo <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC RESEND 01/14] block: kconfig update and build bits for BFQ
Date: Tue, 27 May 2014 14:42:25 +0200
Message-ID: <1401194558-5283-2-git-send-email-paolo.valente@unimore.it>
References: <1401194558-5283-1-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1401194558-5283-1-git-send-email-paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Update Kconfig.iosched and make the related Makefile changes to include
kernel-configuration options for BFQ.

Signed-off-by: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/Kconfig.iosched | 19 +++++++++++++++++++
 block/Makefile        |  1 +
 2 files changed, 20 insertions(+)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 421bef9..8f98cc7 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -39,6 +39,15 @@ config CFQ_GROUP_IOSCHED
 	---help---
 	  Enable group IO scheduling in CFQ.
 
+config IOSCHED_BFQ
+	tristate "BFQ I/O scheduler"
+	default n
+	---help---
+	  The BFQ I/O scheduler tries to distribute bandwidth among all
+	  processes according to their weights.
+	  It aims at distributing the bandwidth as desired, regardless
+	  of the disk parameters and with any workload.
+
 choice
 	prompt "Default I/O scheduler"
 	default DEFAULT_CFQ
@@ -52,6 +61,15 @@ choice
 	config DEFAULT_CFQ
 		bool "CFQ" if IOSCHED_CFQ=y
 
+	config DEFAULT_BFQ
+		bool "BFQ" if IOSCHED_BFQ=y
+		help
+		  Selects BFQ as the default I/O scheduler which will be
+		  used by default for all block devices.
+		  The BFQ I/O scheduler aims at distributing the bandwidth
+		  as desired, regardless of the disk parameters and with
+		  any workload.
+
 	config DEFAULT_NOOP
 		bool "No-op"
 
@@ -61,6 +79,7 @@ config DEFAULT_IOSCHED
 	string
 	default "deadline" if DEFAULT_DEADLINE
 	default "cfq" if DEFAULT_CFQ
+	default "bfq" if DEFAULT_BFQ
 	default "noop" if DEFAULT_NOOP
 
 endmenu
diff --git a/block/Makefile b/block/Makefile
index 20645e8..cbd83fb 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -16,6 +16,7 @@ obj-$(CONFIG_BLK_DEV_THROTTLING)	+= blk-throttle.o
 obj-$(CONFIG_IOSCHED_NOOP)	+= noop-iosched.o
 obj-$(CONFIG_IOSCHED_DEADLINE)	+= deadline-iosched.o
 obj-$(CONFIG_IOSCHED_CFQ)	+= cfq-iosched.o
+obj-$(CONFIG_IOSCHED_BFQ)	+= bfq-iosched.o
 
 obj-$(CONFIG_BLOCK_COMPAT)	+= compat_ioctl.o
 obj-$(CONFIG_BLK_DEV_INTEGRITY)	+= blk-integrity.o
-- 
1.9.2
