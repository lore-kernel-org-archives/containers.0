From: paolo <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC RESEND 03/14] block: add hierarchical-support option to
	kconfig
Date: Tue, 27 May 2014 14:42:27 +0200
Message-ID: <1401194558-5283-4-git-send-email-paolo.valente@unimore.it>
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

Add the CGROUP_BFQIO option to Kconfig.iosched. This option allows
full hierarchical support to be enabled in BFQ, and the bfqio
controller to be added to the cgroups interface.

Signed-off-by: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/Kconfig.iosched | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 8f98cc7..a3675cb 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -46,7 +46,18 @@ config IOSCHED_BFQ
 	  The BFQ I/O scheduler tries to distribute bandwidth among all
 	  processes according to their weights.
 	  It aims at distributing the bandwidth as desired, regardless
-	  of the disk parameters and with any workload.
+	  of the disk parameters and with any workload. If compiled
+	  built-in (saying Y here), BFQ can be configured to support
+	  hierarchical scheduling.
+
+config CGROUP_BFQIO
+	bool "BFQ hierarchical scheduling support"
+	depends on CGROUPS && IOSCHED_BFQ=y
+	default n
+	---help---
+	  Enable hierarchical scheduling in BFQ, using the cgroups
+	  filesystem interface.  The name of the subsystem will be
+	  bfqio.
 
 choice
 	prompt "Default I/O scheduler"
-- 
1.9.2
