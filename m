From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Fri, 18 Jun 2010 18:08:49 +0200
Message-ID: <20100618160849.GA7404@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100618111554.GA3252@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Louis Rilling <Louis.Rillin>
List-Id: containers.vger.kernel.org

On 06/18, Oleg Nesterov wrote:
>
> On 06/18, Louis Rilling wrote:
> >
> > On 17/06/10 23:20 +0200, Oleg Nesterov wrote:
> > > On 06/16, Louis Rilling wrote:
> > > >
> > > > Detached tasks are not seen by zap_pid_ns_processes()->sys_wait4(), so
> > > > that release_task()->proc_flush_task() of container init can be called
> > > > before it is for some detached tasks in the namespace.
> > > >
> > > > Pin proc_mnt's in copy_process(), so that proc_flush_task() becomes safe
> > > > whatever the ordering of tasks.
> > >
> > > I must have missed something, but can't we just move mntput() ?
> >
> > See the log of the commit introducing pid_ns_release_proc() (6f4e6433):
> >
> >     Sice the namespace holds the vfsmnt, vfsmnt holds the superblock and the
> >     superblock holds the namespace we must explicitly break this circle to destroy
> >     all the stuff.  This is done after the init of the namespace dies.
>
> I see thanks.

Not sure I ever understood this code. Certainly I can't say I understand
it now. Still, do we really need this circle? I am almost sure the patch
below is not right (and it wasn't tested at all), but could you take a
look?

Note: afaics we have another problem. What if copy_process(CLONE_NEWPID)
fails after pid_ns_prepare_proc() ? Who will do mntput() ? This patch
should fix this too (again, ___if___ it correct).

Oleg.

 include/linux/pid_namespace.h |    1 +
 kernel/pid_namespace.c        |    3 +++
 fs/proc/base.c                |    4 ----
 fs/proc/root.c                |   18 ++++++++++++++----
 4 files changed, 18 insertions(+), 8 deletions(-)

--- 34-rc1/include/linux/pid_namespace.h~PID_NS	2010-06-18 17:48:56.000000000 +0200
+++ 34-rc1/include/linux/pid_namespace.h	2010-06-18 17:53:11.000000000 +0200
@@ -26,6 +26,7 @@ struct pid_namespace {
 	struct pid_namespace *parent;
 #ifdef CONFIG_PROC_FS
 	struct vfsmount *proc_mnt;
+	struct work_struct proc_put;
 #endif
 #ifdef CONFIG_BSD_PROCESS_ACCT
 	struct bsd_acct_struct *bacct;
--- 34-rc1/kernel/pid_namespace.c~PID_NS	2010-06-18 17:48:56.000000000 +0200
+++ 34-rc1/kernel/pid_namespace.c	2010-06-18 17:53:44.000000000 +0200
@@ -10,6 +10,7 @@
 
 #include <linux/pid.h>
 #include <linux/pid_namespace.h>
+#include <linux/proc_fs.h>
 #include <linux/syscalls.h>
 #include <linux/err.h>
 #include <linux/acct.h>
@@ -109,6 +110,8 @@ static void destroy_pid_namespace(struct
 {
 	int i;
 
+	pid_ns_release_proc(ns);
+
 	for (i = 0; i < PIDMAP_ENTRIES; i++)
 		kfree(ns->pidmap[i].page);
 	kmem_cache_free(pid_ns_cachep, ns);
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
+++ 34-rc1/fs/proc/root.c	2010-06-18 17:56:57.000000000 +0200
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
@@ -216,7 +215,18 @@ int pid_ns_prepare_proc(struct pid_names
 	return 0;
 }
 
-void pid_ns_release_proc(struct pid_namespace *ns)
+static void proc_mntput(struct work_struct *work)
 {
+	struct pid_namespace *ns = container_of(work, struct pid_namespace, proc_put);
+
+	PROC_I(ns->proc_mnt->mnt_sb->s_root->d_inode)->pid = NULL;
 	mntput(ns->proc_mnt);
 }
+
+void pid_ns_release_proc(struct pid_namespace *ns)
+{
+	if (ns->proc_mnt) {
+		INIT_WORK(&ns->proc_put, proc_mntput);
+		schedule_work(&ns->proc_put);
+	}
+}
