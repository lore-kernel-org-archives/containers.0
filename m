From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Thu, 17 Jun 2010 23:20:03 +0200
Message-ID: <20100617212003.GA4182@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Louis Rilling <louis.rilling@kerlabs.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 06/16, Louis Rilling wrote:
>
> Detached tasks are not seen by zap_pid_ns_processes()->sys_wait4(), so
> that release_task()->proc_flush_task() of container init can be called
> before it is for some detached tasks in the namespace.
>
> Pin proc_mnt's in copy_process(), so that proc_flush_task() becomes safe
> whatever the ordering of tasks.

I must have missed something, but can't we just move mntput() ?

Oleg.

--- x/kernel/pid_namespace.c
+++ x/kernel/pid_namespace.c
@@ -110,6 +110,9 @@ static void destroy_pid_namespace(struct
 {
 	int i;
 
+	if (ns->proc_mount)
+		mntput(ns->proc_mount);
+
 	for (i = 0; i < PIDMAP_ENTRIES; i++)
 		kfree(ns->pidmap[i].page);
 	kmem_cache_free(pid_ns_cachep, ns);
--- x/fs/proc/base.c
+++ x/fs/proc/base.c
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
