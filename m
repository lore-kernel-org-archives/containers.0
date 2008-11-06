From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/7] proc: Implement support for automounts in task directories
Date: Thu, 06 Nov 2008 02:48:35 -0800
Message-ID: <m1abcd2kqk.fsf@frodo.ebiederm.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754674AbYKFKz3@vger.kernel.org>
In-Reply-To: <m1ej1p2l6u.fsf@frodo.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 06 Nov 2008 02:38:49 -0800")
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org


This is a genearl mechanism that is capable of removing
any unused mounts on /proc in any directory.  As we flush
the mounts when a processes dies this mechanism is tailored
for flushing mounts in the per task and per task group
directories.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/Makefile        |    1 +
 fs/proc/automount.c     |   29 +++++++++++++++++++++++++++++
 fs/proc/internal.h      |    3 +++
 include/linux/proc_fs.h |    1 +
 kernel/exit.c           |    1 +
 5 files changed, 35 insertions(+), 0 deletions(-)
 create mode 100644 fs/proc/automount.c

diff --git a/fs/proc/Makefile b/fs/proc/Makefile
index 63d9651..862a8fe 100644
--- a/fs/proc/Makefile
+++ b/fs/proc/Makefile
@@ -18,6 +18,7 @@ proc-y	+= meminfo.o
 proc-y	+= stat.o
 proc-y	+= uptime.o
 proc-y	+= version.o
+proc-y	+= automount.o
 proc-$(CONFIG_PROC_SYSCTL)	+= proc_sysctl.o
 proc-$(CONFIG_NET)		+= proc_net.o
 proc-$(CONFIG_PROC_KCORE)	+= kcore.o
diff --git a/fs/proc/automount.c b/fs/proc/automount.c
new file mode 100644
index 0000000..a1fabf2
--- /dev/null
+++ b/fs/proc/automount.c
@@ -0,0 +1,29 @@
+#include <linux/workqueue.h>
+#include <linux/mount.h>
+#include <linux/vfs.h>
+#include "internal.h"
+
+LIST_HEAD(proc_automounts);
+
+static void proc_expire_automounts(struct work_struct *work);
+
+static DECLARE_DELAYED_WORK(proc_automount_task, proc_expire_automounts);
+static int proc_automount_timeout = 500 * HZ;
+
+void proc_shrink_automounts(void)
+{
+	struct list_head *list = &proc_automounts;
+
+	mark_mounts_for_expiry(list);
+	mark_mounts_for_expiry(list);
+	if (list_empty(list))
+		return;
+
+	schedule_delayed_work(&proc_automount_task, proc_automount_timeout);
+}
+
+static void proc_expire_automounts(struct work_struct *work)
+{
+	proc_shrink_automounts();
+}
+
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 3e8aeb8..2a8eabb 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -93,3 +93,6 @@ struct pde_opener {
 	int (*release)(struct inode *, struct file *);
 	struct list_head lh;
 };
+
+extern struct list_head proc_automounts;
+
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index b8bdb96..3505a72 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -101,6 +101,7 @@ extern spinlock_t proc_subdir_lock;
 
 extern void proc_root_init(void);
 
+void proc_shrink_automounts(void);
 void proc_flush_task(struct task_struct *task);
 struct dentry *proc_pid_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *);
 int proc_pid_readdir(struct file * filp, void * dirent, filldir_t filldir);
diff --git a/kernel/exit.c b/kernel/exit.c
index 80137a5..8a8badb 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -161,6 +161,7 @@ void release_task(struct task_struct * p)
 repeat:
 	tracehook_prepare_release_task(p);
 	atomic_dec(&p->user->processes);
+	proc_shrink_automounts();
 	proc_flush_task(p);
 	write_lock_irq(&tasklist_lock);
 	tracehook_finish_release_task(p);
-- 
1.5.3.rc6.17.g1911
