From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 3/4] procfs: move pid_ns_prepare_proc() from copy_process()
	to create_pid_namespace()
Date: Sat, 19 Jun 2010 21:10:56 +0200
Message-ID: <20100619191056.GD3424@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100619190840.GA3424@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Imho, pid_ns_prepare_proc() in copy_process() looks very ugly.

Now that pid_ns_prepare_proc()->proc_get_sb() does not depend on the
first alloc_pid(), we can move this code into create_pid_namespace().

This looks much more clean to me, and in theory more correct in case
we ever implement sys_unshare(CLONE_NEWPID).

Note: with or without this patch we have a bug. If CLONE_NEWPID fails
after pid_ns_prepare_proc(), nobody frees ns->proc_mnt. This will be
fixed by the next patches.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 kernel/fork.c          |    7 -------
 kernel/pid_namespace.c |   10 +++++++++-
 2 files changed, 9 insertions(+), 8 deletions(-)

--- 35-rc3/kernel/fork.c~PNS_3_KILL_FORK_MOUNT	2010-06-19 19:20:22.000000000 +0200
+++ 35-rc3/kernel/fork.c	2010-06-19 20:17:35.000000000 +0200
@@ -58,7 +58,6 @@
 #include <linux/taskstats_kern.h>
 #include <linux/random.h>
 #include <linux/tty.h>
-#include <linux/proc_fs.h>
 #include <linux/blkdev.h>
 #include <linux/fs_struct.h>
 #include <linux/magic.h>
@@ -1154,12 +1153,6 @@ static struct task_struct *copy_process(
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
--- 35-rc3/kernel/pid_namespace.c~PNS_3_KILL_FORK_MOUNT	2010-06-19 19:20:22.000000000 +0200
+++ 35-rc3/kernel/pid_namespace.c	2010-06-19 19:21:42.000000000 +0200
@@ -10,6 +10,7 @@
 
 #include <linux/pid.h>
 #include <linux/pid_namespace.h>
+#include <linux/proc_fs.h>
 #include <linux/syscalls.h>
 #include <linux/err.h>
 #include <linux/acct.h>
@@ -72,6 +73,7 @@ static struct pid_namespace *create_pid_
 {
 	struct pid_namespace *ns;
 	unsigned int level = parent_pid_ns->level + 1;
+	int err = -ENOMEM;
 	int i;
 
 	ns = kmem_cache_zalloc(pid_ns_cachep, GFP_KERNEL);
@@ -96,14 +98,20 @@ static struct pid_namespace *create_pid_
 	for (i = 1; i < PIDMAP_ENTRIES; i++)
 		atomic_set(&ns->pidmap[i].nr_free, BITS_PER_PAGE);
 
+	err = pid_ns_prepare_proc(ns);
+	if (err)
+		goto out_put_parent;
+
 	return ns;
 
+out_put_parent:
+	put_pid_ns(parent_pid_ns);
 out_free_map:
 	kfree(ns->pidmap[0].page);
 out_free:
 	kmem_cache_free(pid_ns_cachep, ns);
 out:
-	return ERR_PTR(-ENOMEM);
+	return ERR_PTR(err);
 }
 
 static void destroy_pid_namespace(struct pid_namespace *ns)
