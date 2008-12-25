From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: fix a race between cgroup_clone and umount
Date: Thu, 25 Dec 2008 11:47:09 +0800
Message-ID: <4953023D.4010401__11615.8872646794$1230177030$gmane$org@cn.fujitsu.com>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

The race is calling cgroup_clone() while umounting the ns cgroup subsys,
and thus cgroup_clone() might access invalid cgroup_fs, or kill_sb() is
called after cgroup_clone() created a new dir in it.

The BUG I triggered is BUG_ON(root->number_of_cgroups != 1);

------------[ cut here ]------------
kernel BUG at kernel/cgroup.c:1093!
invalid opcode: 0000 [#1] SMP
...
Process umount (pid: 5177, ti=e411e000 task=e40c4670 task.ti=e411e000)
...
Call Trace:
 [<c0493df7>] ? deactivate_super+0x3f/0x51
 [<c04a3600>] ? mntput_no_expire+0xb3/0xdd
 [<c04a3ab2>] ? sys_umount+0x265/0x2ac
 [<c04a3b06>] ? sys_oldumount+0xd/0xf
 [<c0403911>] ? sysenter_do_call+0x12/0x31
...
EIP: [<c0456e76>] cgroup_kill_sb+0x23/0xe0 SS:ESP 0068:e411ef2c
---[ end trace c766c1be3bf944ac ]---

CC: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---

affected kernel: 2.6.24 to 2.6.28

---
 kernel/cgroup.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2606d0f..c882385 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2942,7 +2942,11 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
 	parent = task_cgroup(tsk, subsys->subsys_id);
 
 	/* Pin the hierarchy */
-	atomic_inc(&parent->root->sb->s_active);
+	if (!atomic_inc_not_zero(&parent->root->sb->s_active)) {
+		/* We race with the final deactivate_super() */
+		mutex_unlock(&cgroup_mutex);
+		return 0;
+	}
 
 	/* Keep the cgroup alive */
 	get_css_set(cg);
-- 
1.5.4.rc3
