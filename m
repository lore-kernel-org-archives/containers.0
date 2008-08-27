From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC][PATCH -mm 5/5] export per-task i/o throttling statistics to
	userspace
Date: Wed, 27 Aug 2008 18:07:37 +0200
Message-ID: <1219853257-11052-6-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <>
References: <>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Export the throttling statistics collected for each task through
/proc/PID/io-throttle-stat:
 - total number of delayed I/O request
 - total amount of time in jiffies spent to wait for the delayed requests

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/proc/base.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 01ed610..9983730 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -54,6 +54,7 @@
 #include <linux/proc_fs.h>
 #include <linux/stat.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/init.h>
 #include <linux/capability.h>
 #include <linux/file.h>
@@ -2440,6 +2441,14 @@ static int proc_tgid_io_accounting(struct task_struct *task, char *buffer)
 }
 #endif /* CONFIG_TASK_IO_ACCOUNTING */
 
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+static int proc_iothrottle_stat(struct task_struct *task, char *buffer)
+{
+	return sprintf(buffer, "%llu %llu\n",
+		get_io_throttle_cnt(task), get_io_throttle_sleep(task));
+}
+#endif /* CONFIG_CGROUP_IO_THROTTLE */
+
 /*
  * Thread groups
  */
@@ -2515,6 +2524,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_TASK_IO_ACCOUNTING
 	INF("io",	S_IRUGO, tgid_io_accounting),
 #endif
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	INF("io-throttle-stat",	S_IRUGO, iothrottle_stat),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file * filp,
@@ -2846,6 +2858,9 @@ static const struct pid_entry tid_base_stuff[] = {
 #ifdef CONFIG_TASK_IO_ACCOUNTING
 	INF("io",	S_IRUGO, tid_io_accounting),
 #endif
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	INF("io-throttle-stat",	S_IRUGO, iothrottle_stat),
+#endif
 };
 
 static int proc_tid_base_readdir(struct file * filp,
-- 
1.5.4.3
