From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroup: fix invalid cgrp->dentry before cgroup has been
	completely removed
Date: Thu, 30 Oct 2008 15:23:27 +0800
Message-ID: <490960EF.7020500__4925.31346758387$1225351932$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

This fixes oops when reading /proc/sched_debug.

A cgroup won't be removed completely until finishing cgroup_diput(), so we
shouldn't invalidate cgrp->dentry in cgroup_rmdir(). Otherwise, when a
group is being removed while cgroup_path() gets called, we may trigger NULL
dereference BUG.

The bug can be reproduced:

 # cat test.sh
 #!/bin/sh
 mount -t cgroup -o cpu xxx /mnt
 for (( ; ; ))
 {
	mkdir /mnt/sub
	rmdir /mnt/sub
 }
 # ./test.sh &
 # cat /proc/sched_debug

BUG: unable to handle kernel NULL pointer dereference at 00000038
IP: [<c045a47f>] cgroup_path+0x39/0x90
...
Call Trace:
 [<c0420344>] ? print_cfs_rq+0x6e/0x75d
 [<c0421160>] ? sched_debug_show+0x72d/0xc1e
...

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 35eebd5..358e775 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2497,7 +2497,6 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	list_del(&cgrp->sibling);
 	spin_lock(&cgrp->dentry->d_lock);
 	d = dget(cgrp->dentry);
-	cgrp->dentry = NULL;
 	spin_unlock(&d->d_lock);
 
 	cgroup_d_remove_dir(d);
-- 
1.5.4.rc3
