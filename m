From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/6] pidns: Call pid_ns_prepare_proc from create_pid_namespace
Date: Sun, 20 Jun 2010 01:45:00 -0700
Message-ID: <m1hbkyqeib.fsf_-_@fess.ebiederm.org>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
	<20100617212003.GA4182@redhat.com>
	<20100618082033.GD16877@hawkmoon.kerlabs.com>
	<20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com>
	<20100618173320.GG16877@hawkmoon.kerlabs.com>
	<20100618175541.GA13680@redhat.com>
	<20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com>
	<m1pqzmqema.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqzmqema.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 20 Jun 2010 01\:42\:37 -0700")
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org


Reorganize proc_get_sb so it can be called before the struct pid
of the first process is allocated.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/root.c         |   26 ++++++++------------------
 kernel/fork.c          |    6 ------
 kernel/pid_namespace.c |    4 ++++
 3 files changed, 12 insertions(+), 24 deletions(-)

diff --git a/fs/proc/root.c b/fs/proc/root.c
index 4258384..5f15353 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -43,17 +43,6 @@ static int proc_get_sb(struct file_system_type *fs_type,
 	struct pid_namespace *ns;
 	struct proc_inode *ei;
 
-	if (proc_mnt) {
-		/* Seed the root directory with a pid so it doesn't need
-		 * to be special in base.c.  I would do this earlier but
-		 * the only task alive when /proc is mounted the first time
-		 * is the init_task and it doesn't have any pids.
-		 */
-		ei = PROC_I(proc_mnt->mnt_sb->s_root->d_inode);
-		if (!ei->pid)
-			ei->pid = find_get_pid(1);
-	}
-
 	if (flags & MS_KERNMOUNT)
 		ns = (struct pid_namespace *)data;
 	else
@@ -71,17 +60,18 @@ static int proc_get_sb(struct file_system_type *fs_type,
 			return err;
 		}
 
-		ei = PROC_I(sb->s_root->d_inode);
-		if (!ei->pid) {
-			rcu_read_lock();
-			ei->pid = get_pid(find_pid_ns(1, ns));
-			rcu_read_unlock();
-		}
-
 		sb->s_flags |= MS_ACTIVE;
 		ns->proc_mnt = mnt;
 	}
 
+	/* Ensure the root directory has it's associated pid. */
+	ei = PROC_I(sb->s_root->d_inode);
+	if (!ei->pid) {
+		rcu_read_lock();
+		ei->pid = get_pid(find_pid_ns(1, ns));
+		rcu_read_unlock();
+	}
+
 	simple_set_mnt(mnt, sb);
 	return 0;
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index 8b85b17..3c2501d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1154,12 +1154,6 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		pid = alloc_pid(p->nsproxy->pid_ns);
 		if (!pid)
 			goto bad_fork_cleanup_io;
-
-		if (clone_flags & CLONE_NEWPID) {
-			retval = pid_ns_prepare_proc(p->nsproxy->pid_ns);
-			if (retval < 0)
-				goto bad_fork_free_pid;
-		}
 	}
 
 	p->pid = pid_nr(pid);
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index a5aff94..b90e4ab 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -14,6 +14,7 @@
 #include <linux/err.h>
 #include <linux/acct.h>
 #include <linux/slab.h>
+#include <linux/proc_fs.h>
 
 #define BITS_PER_PAGE		(PAGE_SIZE*8)
 
@@ -96,6 +97,9 @@ static struct pid_namespace *create_pid_namespace(struct pid_namespace *parent_p
 	for (i = 1; i < PIDMAP_ENTRIES; i++)
 		atomic_set(&ns->pidmap[i].nr_free, BITS_PER_PAGE);
 
+	if (pid_ns_prepare_proc(ns))
+		goto out_free_map;
+
 	return ns;
 
 out_free_map:
-- 
1.6.5.2.143.g8cc62
