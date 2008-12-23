From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: avoid accessing uninitialized data in failure path
Date: Tue, 23 Dec 2008 11:22:04 +0800
Message-ID: <4950595C.9070907__36430.7215008468$1230002713$gmane$org@cn.fujitsu.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

If cgroup_get_rootdir() failed, free_cg_links() will be called
in the failure path, but tmp_cg_links hasn't been initialized
at that time.

I should be blamed to introduce this bug in 2.6.26 merge window.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 8185a0f..330b7ae 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1024,7 +1024,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 		if (ret == -EBUSY) {
 			mutex_unlock(&cgroup_mutex);
 			mutex_unlock(&inode->i_mutex);
-			goto drop_new_super;
+			goto free_cg_links;
 		}
 
 		/* EBUSY should be the only error here */
@@ -1073,10 +1073,11 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 
 	return simple_set_mnt(mnt, sb);
 
+ free_cg_links:
+	free_cg_links(&tmp_cg_links);
  drop_new_super:
 	up_write(&sb->s_umount);
 	deactivate_super(sb);
-	free_cg_links(&tmp_cg_links);
 	return ret;
 }
 
-- 
1.5.4.rc3
