From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Fri, 18 Jun 2010 23:23:55 +0200
Message-ID: <20100618212355.GA29478@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100618175541.GA13680@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Louis Rilling <louis.rillin>
List-Id: containers.vger.kernel.org

On 06/18, Oleg Nesterov wrote:
>
> work->func(ns) is
> called when ns is already fixed.
                            ^^^^^
(I meant freed)

We can move kmem_cache_free(ns) into work->func(), or we can optimize
the usage of schedule_work(), something like the patch below.

Once again, it is completely untested, I do not pretend I understand
this code today, and I am sure the patch is wrong. I only try to discuss
the idea to break the circular reference. In any case, I am not proud
of this patch ;)

Or we should do the more sophisticated change suggested by Pavel. But
I'd like to avoid the changes in do_wait/release_task, this doesn't
look right to me.

Oleg.

 include/linux/pid_namespace.h |    1 +
 kernel/pid_namespace.c        |   35 ++++++++++++++++++++++++++++++++++-
 fs/proc/base.c                |    4 ----
 fs/proc/root.c                |   10 ++++++----
 4 files changed, 41 insertions(+), 9 deletions(-)

--- 34-rc1/include/linux/pid_namespace.h~PID_NS	2010-06-18 17:48:56.000000000 +0200
+++ 34-rc1/include/linux/pid_namespace.h	2010-06-18 22:37:45.000000000 +0200
@@ -26,6 +26,7 @@ struct pid_namespace {
 	struct pid_namespace *parent;
 #ifdef CONFIG_PROC_FS
 	struct vfsmount *proc_mnt;
+	struct list_head dead_node;
 #endif
 #ifdef CONFIG_BSD_PROCESS_ACCT
 	struct bsd_acct_struct *bacct;
--- 34-rc1/kernel/pid_namespace.c~PID_NS	2010-06-18 17:48:56.000000000 +0200
+++ 34-rc1/kernel/pid_namespace.c	2010-06-18 22:52:41.000000000 +0200
@@ -10,6 +10,7 @@
 
 #include <linux/pid.h>
 #include <linux/pid_namespace.h>
+#include <linux/proc_fs.h>
 #include <linux/syscalls.h>
 #include <linux/err.h>
 #include <linux/acct.h>
@@ -105,15 +106,47 @@ out:
 	return ERR_PTR(-ENOMEM);
 }
 
-static void destroy_pid_namespace(struct pid_namespace *ns)
+static LIST_HEAD(dead_list);
+static DEFINE_SPINLOCK(dead_lock);
+
+static void do_destroy_pid_namespace(struct pid_namespace *ns)
 {
 	int i;
 
+	pid_ns_release_proc(ns);
+
 	for (i = 0; i < PIDMAP_ENTRIES; i++)
 		kfree(ns->pidmap[i].page);
 	kmem_cache_free(pid_ns_cachep, ns);
 }
 
+static void dead_work_func(struct work_struct *unused)
+{
+	LIST_HEAD(list);
+	unsigned long flags;
+	struct pid_namespace *ns, *tmp;
+
+	spin_lock_irqsave(&dead_lock, flags);
+	list_splice_init(&dead_list, &list);
+	spin_unlock_irqrestore(&dead_lock, flags);
+
+	list_for_each_entry_safe(ns, tmp, &list, dead_node)
+		do_destroy_pid_namespace(ns);
+}
+
+static DECLARE_WORK(dead_work, dead_work_func);
+
+static void destroy_pid_namespace(struct pid_namespace *ns)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&dead_lock, flags);
+	list_add(&ns->dead_node, &dead_list);
+	spin_unlock_irqrestore(&dead_lock, flags);
+
+	schedule_work(&dead_work);
+}
+
 struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *old_ns)
 {
 	if (!(flags & CLONE_NEWPID))
--- 34-rc1/fs/proc/base.c~PID_NS	2010-06-18 17:48:56.000000000 +0200
+++ 34-rc1/fs/proc/base.c	2010-06-18 17:49:45.000000000 +0200
@@ -2720,10 +2720,6 @@ void proc_flush_task(struct task_struct 
 		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
 					tgid->numbers[i].nr);
 	}
-
-	upid = &pid->numbers[pid->level];
-	if (upid->nr == 1)
-		pid_ns_release_proc(upid->ns);
 }
 
 static struct dentry *proc_pid_instantiate(struct inode *dir,
--- 34-rc1/fs/proc/root.c~PID_NS	2010-06-18 17:48:56.000000000 +0200
+++ 34-rc1/fs/proc/root.c	2010-06-18 22:54:03.000000000 +0200
@@ -31,7 +31,7 @@ static int proc_set_super(struct super_b
 	struct pid_namespace *ns;
 
 	ns = (struct pid_namespace *)data;
-	sb->s_fs_info = get_pid_ns(ns);
+	sb->s_fs_info = ns;
 	return set_anon_super(sb, NULL);
 }
 
@@ -74,7 +74,7 @@ static int proc_get_sb(struct file_syste
 		ei = PROC_I(sb->s_root->d_inode);
 		if (!ei->pid) {
 			rcu_read_lock();
-			ei->pid = get_pid(find_pid_ns(1, ns));
+			ei->pid = find_pid_ns(1, ns);
 			rcu_read_unlock();
 		}
 
@@ -92,7 +92,6 @@ static void proc_kill_sb(struct super_bl
 
 	ns = (struct pid_namespace *)sb->s_fs_info;
 	kill_anon_super(sb);
-	put_pid_ns(ns);
 }
 
 static struct file_system_type proc_fs_type = {
@@ -218,5 +217,8 @@ int pid_ns_prepare_proc(struct pid_names
 
 void pid_ns_release_proc(struct pid_namespace *ns)
 {
-	mntput(ns->proc_mnt);
+	if (ns->proc_mnt) {
+		PROC_I(ns->proc_mnt->mnt_sb->s_root->d_inode)->pid = NULL;
+		mntput(ns->proc_mnt);
+	}
 }
