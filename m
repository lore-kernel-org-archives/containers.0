From: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Subject: include/linux/cgroup.h:553 suspicious rcu_dereference_check() usage!
Date: Fri, 14 Sep 2012 11:23:22 +0200
Message-ID: <5052F78A.7010007__15371.0312596106$1347614619$gmane$org@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux kernel mailing list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

with current -next trees and LDEP enabled, I'm getting:
===============================
[ INFO: suspicious RCU usage. ]
3.6.0-rc5-next-20120913+ #42 Not tainted
-------------------------------
/home/latest/linux/include/linux/cgroup.h:553 suspicious
rcu_dereference_check() usage!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 0
2 locks held by kdevtmpfs/23:
 #0:  (sb_writers){.+.+.+}, at: [<ffffffff8116873f>]
mnt_want_write+0x1f/0x50
 #1:  (&sb->s_type->i_mutex_key#3/1){+.+.+.}, at: [<ffffffff811558af>]
kern_path_create+0x7f/0x170

stack backtrace:
Pid: 23, comm: kdevtmpfs Not tainted 3.6.0-rc5-next-20120913+ #42
Call Trace:
 [<ffffffff810c638d>] lockdep_rcu_suspicious+0xfd/0x130
 [<ffffffff8121541d>] devcgroup_inode_mknod+0x19d/0x240
 [<ffffffff8107bf54>] ? ns_capable+0x44/0x80
 [<ffffffff81156b21>] vfs_mknod+0x71/0xf0
 [<ffffffff813a8332>] handle_create.isra.2+0x72/0x200
 [<ffffffff813a85d4>] devtmpfsd+0x114/0x140
 [<ffffffff813a84c0>] ? handle_create.isra.2+0x200/0x200
 [<ffffffff81093ad6>] kthread+0xd6/0xe0
 [<ffffffff81654f24>] kernel_thread_helper+0x4/0x10
 [<ffffffff8165369d>] ? retint_restore_args+0xe/0xe
 [<ffffffff81093a00>] ? kthread_create_on_node+0x140/0x140
 [<ffffffff81654f20>] ? gs_change+0xb/0xb


It's due to the commit "device_cgroup: convert device_cgroup internally
to policy + exceptions". It removed rcu locks which are needed in
task_devcgroup called in this chain: devcgroup_inode_mknod OR
__devcgroup_inode_permission -> __devcgroup_inode_permission ->
task_devcgroup -> task_subsys_state -> task_subsys_state_check.

regards,
-- 
js
suse labs
