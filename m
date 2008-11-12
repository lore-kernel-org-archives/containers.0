From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH][cfq-cgroups][03/12] Add cgroup file and modify configure
	files.
Date: Wed, 12 Nov 2008 17:25:35 +0900
Message-ID: <001001c944a0$3c1ed700$b45c8500$__21743.0255179808$1226479660$gmane$org@jp.nec.com>
References: <000c01c9449e$c5bcdc20$51369460$@jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <000c01c9449e$c5bcdc20$51369460$@jp.nec.com>
Content-Language: ja
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, 'Ryo Tsuruta' <ryov@valin>
Cc: 'Andrew Morton' <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, 'SUGAWARA Tomoyoshi' <tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


  This patch adds the cfq-cgroup file and modifies configure files.
  The cfq-cgroup file store some functions which use to expand CFQ
  scheduler for handling cgroups.
  Expanded CFQ scheduler is registered for "cfq-cgroups".


    Signed-off-by: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/Kconfig.iosched |   16 ++++++++++++++++
 block/Makefile        |    1 +
 block/cfq-cgroup.c    |   32 ++++++++++++++++++++++++++++++++
 3 files changed, 49 insertions(+), 0 deletions(-)
 create mode 100644 block/cfq-cgroup.c

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 7e803fc..dc61120 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -40,6 +40,18 @@ config IOSCHED_CFQ
 	  working environment, suitable for desktop systems.
 	  This is the default I/O scheduler.
 
+config IOSCHED_CFQ_CGROUP
+	tristate "expanded CFQ I/O Scheduler for cgroups"
+	default n
+	depends on IOSCHED_CFQ && CGROUPS
+	---help---
+	  The expanded CFQ I/O scheduelr for cgroups tries to distribute
+	  bandwidth equally among all groups and among all processes within
+	  groups in the system. It should provide a fair working environment,
+	  suitable for consolidated environment which have some destop systems.
+	  This scheduler expands the CFQ I/O scheduler into two layer control
+	  -- per group layer and per task layer --.
+
 choice
 	prompt "Default I/O scheduler"
 	default DEFAULT_CFQ
@@ -56,6 +68,9 @@ choice
 	config DEFAULT_CFQ
 		bool "CFQ" if IOSCHED_CFQ=y
 
+	config DEFAULT_CFQ_CGROUP
+		bool "CFQ-Cgroups" if IOSCHED_CFQ_CGROUP=y
+
 	config DEFAULT_NOOP
 		bool "No-op"
 
@@ -66,6 +81,7 @@ config DEFAULT_IOSCHED
 	default "anticipatory" if DEFAULT_AS
 	default "deadline" if DEFAULT_DEADLINE
 	default "cfq" if DEFAULT_CFQ
+	default "cfq-cgroups" if DEFAULT_CFQ_CGROUP
 	default "noop" if DEFAULT_NOOP
 
 endmenu
diff --git a/block/Makefile b/block/Makefile
index bfe7304..3c0f59d 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -12,6 +12,7 @@ obj-$(CONFIG_IOSCHED_NOOP)	+= noop-iosched.o
 obj-$(CONFIG_IOSCHED_AS)	+= as-iosched.o
 obj-$(CONFIG_IOSCHED_DEADLINE)	+= deadline-iosched.o
 obj-$(CONFIG_IOSCHED_CFQ)	+= cfq-iosched.o
+obj-$(CONFIG_IOSCHED_CFQ_CGROUP)	+= cfq-cgroup.o
 
 obj-$(CONFIG_BLK_DEV_IO_TRACE)	+= blktrace.o
 obj-$(CONFIG_BLOCK_COMPAT)	+= compat_ioctl.o
diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
new file mode 100644
index 0000000..3deef41
--- /dev/null
+++ b/block/cfq-cgroup.c
@@ -0,0 +1,32 @@
+/*
+ *  CFQ CGROUP disk scheduler.
+ *
+ *     This program is a wrapper program that is
+ *     extend CFQ disk scheduler for handling
+ *     cgroup subsystem.
+ *
+ *     This program is based on original CFQ code.
+ *
+ *  Copyright (C) 2008 Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
+ *   and NEC Corp.
+ */
+
+#include <linux/blkdev.h>
+#include <linux/cgroup.h>
+#include <linux/cfq-iosched.h>
+
+static int __init cfq_cgroup_init(void)
+{
+	return 0;
+}
+
+static void __exit cfq_cgroup_exit(void)
+{
+}
+
+module_init(cfq_cgroup_init);
+module_exit(cfq_cgroup_exit);
+
+MODULE_AUTHOR("Satoshi UCHIDA");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Expanded CFQ IO scheduler for CGROUPS");
-- 
1.5.6.5
