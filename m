From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 2/2] pid_ns: refactor the buggy pid_ns_release_proc() logic
Date: Sun, 20 Jun 2010 20:06:37 +0200
Message-ID: <20100620180637.GD17120@redhat.com>
References: <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com> <m1pqzmqema.fsf_-_@fess.ebiederm.org> <20100620180335.GA17120@redhat.com> <20100620180530.GB17120@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100620180530.GB17120@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org

pid_namespace holds ns->proc_mnt, while this vfsmount has a referene to
the namespace via PROC_I(sb->s_root->d_inode)->pid. To break this circle
/sbin/init does mntput() in pid_ns_release_proc(). See 6f4e6433.

But we have the following problems:

	- Nobody does mntput() if copy_process() fails after
	  pid_ns_prepare_proc().

	- proc_flush_task() checks upid->nr == 1 to verify we are init,
	  this is wrong if a multi-threaded init does exec.

	- As Louis pointed out, this namespace can have the detached
	  EXIT_DEAD tasks which can use ns->proc_mnt after this mntput().

With this patch only pid_namespace has a reference to ns->proc_mnt, and
mntput(ns->proc_mnt) is called by destroy_pid_namespace() paths when we
know that this ns must not have any references (in particular, there are
no pids in this namespace).

Changes:

	- kill proc_flush_task()->pid_ns_release_proc()

	- change fs/proc/root.c so that we don't create the "artificial"
	  references to the namespace or its pid==1.

	- change destroy_pid_namespace() to call pid_ns_release_proc().

	- change pid_ns_release_proc() to clear s_root->d_inode->pid.
	  The caller is destroy_pid_namespace(), this pid was already
	  freed.

Reported-by:  Louis Rilling <louis.rilling@kerlabs.com>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 kernel/pid_namespace.c |    2 ++
 fs/proc/base.c         |    4 ----
 fs/proc/root.c         |   10 ++++++----
 3 files changed, 8 insertions(+), 8 deletions(-)

--- 35-rc3/kernel/pid_namespace.c~PNS_6_BREAK_CIRCLE	2010-06-20 18:36:00.000000000 +0200
+++ 35-rc3/kernel/pid_namespace.c	2010-06-20 18:50:30.000000000 +0200
@@ -128,6 +128,8 @@ static void destroy_pid_namespace(struct
 {
 	int i;
 
+	pid_ns_release_proc(ns);
+
 	for (i = 0; i < PIDMAP_ENTRIES; i++)
 		kfree(ns->pidmap[i].page);
 	kmem_cache_free(pid_ns_cachep, ns);
--- 35-rc3/fs/proc/base.c~PNS_6_BREAK_CIRCLE	2010-05-28 13:41:41.000000000 +0200
+++ 35-rc3/fs/proc/base.c	2010-06-20 18:51:14.000000000 +0200
@@ -2745,10 +2745,6 @@ void proc_flush_task(struct task_struct 
 		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
 					tgid->numbers[i].nr);
 	}
-
-	upid = &pid->numbers[pid->level];
-	if (upid->nr == 1)
-		pid_ns_release_proc(upid->ns);
 }
 
 static struct dentry *proc_pid_instantiate(struct inode *dir,
--- 35-rc3/fs/proc/root.c~PNS_6_BREAK_CIRCLE	2010-06-19 20:11:03.000000000 +0200
+++ 35-rc3/fs/proc/root.c	2010-06-20 18:58:12.000000000 +0200
@@ -31,7 +31,7 @@ static int proc_set_super(struct super_b
 	struct pid_namespace *ns;
 
 	ns = (struct pid_namespace *)data;
-	sb->s_fs_info = get_pid_ns(ns);
+	sb->s_fs_info = ns;
 	return set_anon_super(sb, NULL);
 }
 
@@ -68,7 +68,7 @@ static int proc_get_sb(struct file_syste
 		struct proc_inode *ei = PROC_I(sb->s_root->d_inode);
 		if (!ei->pid) {
 			rcu_read_lock();
-			ei->pid = get_pid(find_pid_ns(1, ns));
+			ei->pid = find_pid_ns(1, ns);
 			rcu_read_unlock();
 		}
 	}
@@ -83,7 +83,6 @@ static void proc_kill_sb(struct super_bl
 
 	ns = (struct pid_namespace *)sb->s_fs_info;
 	kill_anon_super(sb);
-	put_pid_ns(ns);
 }
 
 static struct file_system_type proc_fs_type = {
@@ -209,5 +208,8 @@ int pid_ns_prepare_proc(struct pid_names
 
 void pid_ns_release_proc(struct pid_namespace *ns)
 {
-	mntput(ns->proc_mnt);
+	if (ns->proc_mnt) {
+		PROC_I(ns->proc_mnt->mnt_sb->s_root->d_inode)->pid = NULL;
+		mntput(ns->proc_mnt);
+	}
 }
