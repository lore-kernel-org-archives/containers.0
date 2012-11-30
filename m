From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] cgroup: use cgroup_addrm_files() in cgroup_clear_directory()
Date: Fri, 30 Nov 2012 11:47:20 -0800
Message-ID: <20121130194720.GG3873__12182.7236413539$1354304883$gmane$org@htj.dyndns.org>
References: <1354292489-18434-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1354292489-18434-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From 879a3d9dbbde823ac77d39131e7a287f31b8296f Mon Sep 17 00:00:00 2001
From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date: Sat, 1 Dec 2012 00:21:28 +0800

cgroup_clear_directory() incorrectly invokes cgroup_rm_file() on each
cftset of the target subsystems, which only removes the first file of
each set.  This leaves dangling files after subsystems are removed
from a cgroup root via remount.

Use cgroup_addrm_files() to remove all files of target subsystems.

tj: Move cgroup_addrm_files() prototype decl upwards next to other
    global declarations.  Commit message updated.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
Applied to cgroup/for-3.8 with minor updates.  Thanks!

 kernel/cgroup.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b186a7e..e1293a9 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -246,6 +246,8 @@ static DEFINE_SPINLOCK(hierarchy_id_lock);
 static int need_forkexit_callback __read_mostly;
 
 static int cgroup_destroy_locked(struct cgroup *cgrp);
+static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
+			      struct cftype cfts[], bool is_add);
 
 #ifdef CONFIG_PROVE_LOCKING
 int cgroup_lock_is_held(void)
@@ -964,7 +966,7 @@ static void cgroup_clear_directory(struct dentry *dir, bool base_files,
 		if (!test_bit(ss->subsys_id, &subsys_mask))
 			continue;
 		list_for_each_entry(set, &ss->cftsets, node)
-			cgroup_rm_file(cgrp, set->cfts);
+			cgroup_addrm_files(cgrp, NULL, set->cfts, false);
 	}
 	if (base_files) {
 		while (!list_empty(&cgrp->files))
-- 
1.7.11.7
