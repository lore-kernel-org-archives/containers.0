From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/6] proc: implement support for automounts in task
	directories
Date: Tue, 6 Jan 2009 02:32:41 +0300
Message-ID: <20090105233241.GA3924@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752164AbZAEX14@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: ebiederm@xmission.com, viro@zeniv.linux.org.uk
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, sds@tycho.nsa.gov, jmorris@namei.org
List-Id: containers.vger.kernel.org

This is current version of /proc/net as separate file system patchset,
rebased, etc. I'll put it into -next again when merge window closes.

Please, review.
----------------------------------------------------------------------
From a934c391e19837e760592536c4cdd1b4f2432caa Mon Sep 17 00:00:00 2001
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Wed, 19 Nov 2008 03:57:02 +0300
Subject: [PATCH 1/6] proc: implement support for automounts in task directories

This is a general mechanism that is capable of removing any unused mounts on
/proc in any directory.  As we flush the mounts when a processes dies this
mechanism is tailored for flushing mounts in the per task and per task group
directories.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 fs/proc/Makefile        |    1 +
 fs/proc/automount.c     |   28 ++++++++++++++++++++++++++++
 fs/proc/internal.h      |    2 ++
 include/linux/proc_fs.h |    5 +++++
 kernel/exit.c           |    2 +-
 5 files changed, 37 insertions(+), 1 deletions(-)
 create mode 100644 fs/proc/automount.c

diff --git a/fs/proc/Makefile b/fs/proc/Makefile
index 63d9651..757f7c1 100644
--- a/fs/proc/Makefile
+++ b/fs/proc/Makefile
@@ -9,6 +9,7 @@ proc-$(CONFIG_MMU)	:= mmu.o task_mmu.o
 
 proc-y       += inode.o root.o base.o generic.o array.o \
 		proc_tty.o
+proc-y	+= automount.o
 proc-y	+= cmdline.o
 proc-y	+= cpuinfo.o
 proc-y	+= devices.o
diff --git a/fs/proc/automount.c b/fs/proc/automount.c
new file mode 100644
index 0000000..5d22b5a
--- /dev/null
+++ b/fs/proc/automount.c
@@ -0,0 +1,28 @@
+#include <linux/list.h>
+#include <linux/mount.h>
+#include <linux/workqueue.h>
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
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 3e8aeb8..314c0d3 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -93,3 +93,5 @@ struct pde_opener {
 	int (*release)(struct inode *, struct file *);
 	struct list_head lh;
 };
+
+extern struct list_head proc_automounts;
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index b8bdb96..768e627 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -101,6 +101,7 @@ extern spinlock_t proc_subdir_lock;
 
 extern void proc_root_init(void);
 
+void proc_shrink_automounts(void);
 void proc_flush_task(struct task_struct *task);
 struct dentry *proc_pid_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *);
 int proc_pid_readdir(struct file * filp, void * dirent, filldir_t filldir);
@@ -207,6 +208,10 @@ static inline void proc_flush_task(struct task_struct *task)
 {
 }
 
+static inline void proc_shrink_automounts(void)
+{
+}
+
 static inline struct proc_dir_entry *create_proc_entry(const char *name,
 	mode_t mode, struct proc_dir_entry *parent) { return NULL; }
 static inline struct proc_dir_entry *proc_create(const char *name,
diff --git a/kernel/exit.c b/kernel/exit.c
index c9e5a1c..640b3bb 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -173,7 +173,7 @@ repeat:
 	/* don't need to get the RCU readlock here - the process is dead and
 	 * can't be modifying its own credentials */
 	atomic_dec(&__task_cred(p)->user->processes);
-
+	proc_shrink_automounts();
 	proc_flush_task(p);
 	write_lock_irq(&tasklist_lock);
 	tracehook_finish_release_task(p);
-- 
1.5.6.5
