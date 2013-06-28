From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH cgroup/for-3.11 1/2] cgroup: fix deadlock on cgroup_mutex via
	drop_parsed_module_refcounts()
Date: Thu, 27 Jun 2013 19:39:30 -0700
Message-ID: <20130628023930.GA2500@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From e2bd416f6246d11be29999c177d2534943a5c2df Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Thu, 27 Jun 2013 19:37:23 -0700

eb178d06332 ("cgroup: grab cgroup_mutex in
drop_parsed_module_refcounts()") made drop_parsed_module_refcounts()
grab cgroup_mutex to make lockdep assertion in for_each_subsys()
happy.  Unfortunately, cgroup_remount() calls the function while
holding cgroup_mutex in its failure path leading to the following
deadlock.

# mount -t cgroup -o remount,memory,blkio cgroup blkio

 cgroup: option changes via remount are deprecated (pid=525 comm=mount)

 =============================================
 [ INFO: possible recursive locking detected ]
 3.10.0-rc4-work+ #1 Not tainted
 ---------------------------------------------
 mount/525 is trying to acquire lock:
  (cgroup_mutex){+.+.+.}, at: [<ffffffff8110a3e1>] drop_parsed_module_refcounts+0x21/0xb0

 but task is already holding lock:
  (cgroup_mutex){+.+.+.}, at: [<ffffffff8110e4e1>] cgroup_remount+0x51/0x200

 other info that might help us debug this:
  Possible unsafe locking scenario:

	CPU0
	----
   lock(cgroup_mutex);
   lock(cgroup_mutex);

  *** DEADLOCK ***

  May be due to missing lock nesting notation

 4 locks held by mount/525:
  #0:  (&type->s_umount_key#30){+.+...}, at: [<ffffffff811e9a0d>] do_mount+0x2bd/0xa30
  #1:  (&sb->s_type->i_mutex_key#9){+.+.+.}, at: [<ffffffff8110e4d3>] cgroup_remount+0x43/0x200
  #2:  (cgroup_mutex){+.+.+.}, at: [<ffffffff8110e4e1>] cgroup_remount+0x51/0x200
  #3:  (cgroup_root_mutex){+.+.+.}, at: [<ffffffff8110e4ef>] cgroup_remount+0x5f/0x200

 stack backtrace:
 CPU: 2 PID: 525 Comm: mount Not tainted 3.10.0-rc4-work+ #1
 Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
  ffffffff829651f0 ffff88000ec2fc28 ffffffff81c24bb1 ffff88000ec2fce8
  ffffffff810f420d 0000000000000006 0000000000000001 0000000000000056
  ffff8800153b4640 ffff880000000000 ffffffff81c2e468 ffff8800153b4640
 Call Trace:
  [<ffffffff81c24bb1>] dump_stack+0x19/0x1b
  [<ffffffff810f420d>] __lock_acquire+0x15dd/0x1e60
  [<ffffffff810f531c>] lock_acquire+0x9c/0x1f0
  [<ffffffff81c2a805>] mutex_lock_nested+0x65/0x410
  [<ffffffff8110a3e1>] drop_parsed_module_refcounts+0x21/0xb0
  [<ffffffff8110e63e>] cgroup_remount+0x1ae/0x200
  [<ffffffff811c9bb2>] do_remount_sb+0x82/0x190
  [<ffffffff811e9d41>] do_mount+0x5f1/0xa30
  [<ffffffff811ea203>] SyS_mount+0x83/0xc0
  [<ffffffff81c2fb82>] system_call_fastpath+0x16/0x1b

Fix it by moving the drop_parsed_module_refcounts() invocation outside
cgroup_mutex.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
Two patches to fix regressions that I introduced lately.  Given that
-rc1 is imminent, I applied them to for-3.11 directly so that they can
get exposure in -next ASAP.

Thanks!

 kernel/cgroup.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4ed8677..1b7b567 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1365,7 +1365,6 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	if (opts.flags != root->flags ||
 	    (opts.name && strcmp(opts.name, root->name))) {
 		ret = -EINVAL;
-		drop_parsed_module_refcounts(opts.subsys_mask);
 		goto out_unlock;
 	}
 
@@ -1380,7 +1379,6 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	if (ret) {
 		/* rebind_subsystems failed, re-populate the removed files */
 		cgroup_populate_dir(cgrp, false, removed_mask);
-		drop_parsed_module_refcounts(opts.subsys_mask);
 		goto out_unlock;
 	}
 
@@ -1395,6 +1393,8 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
+	if (ret)
+		drop_parsed_module_refcounts(opts.subsys_mask);
 	return ret;
 }
 
-- 
1.8.3.1
