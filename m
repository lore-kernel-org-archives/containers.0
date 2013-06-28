From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 7/9] cgroup: cosmetic follow-up cleanups
Date: Fri, 28 Jun 2013 16:45:43 -0700
Message-ID: <1372463145-4245-8-git-send-email-tj__14424.937676131$1372463205$gmane$org@kernel.org>
References: <1372463145-4245-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1372463145-4245-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

* Busy subsystem check in rebind_subsystems() is unnecessarily
  verbose.  Restructure it for brevity.

* The init_cred dancing in cgroup_mount() has a very high WTF factor.
  Add a comment explaining what's going on and point to the original
  commit.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f0f8bb9..51632b4 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1009,17 +1009,9 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	BUG_ON(!mutex_is_locked(&cgroup_root_mutex));
 
 	/* Check that any added subsystems are currently free */
-	for_each_subsys(ss, i) {
-		unsigned long bit = 1UL << i;
-
-		if (!(bit & added_mask))
-			continue;
-
-		if (ss->root != &cgroup_dummy_root) {
-			/* Subsystem isn't free */
+	for_each_subsys(ss, i)
+		if (test_bit(i, &added_mask) && ss->root != &cgroup_dummy_root)
 			return -EBUSY;
-		}
-	}
 
 	/* Currently we don't handle adding/removing subsystems when
 	 * any child cgroups exist. This is theoretically supportable
@@ -1650,6 +1642,13 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		sb->s_root->d_fsdata = root_cgrp;
 		root_cgrp->dentry = sb->s_root;
 
+		/*
+		 * We're inside get_sb() and will call lookup_one_len() to
+		 * create the root files, which doesn't work if SELinux is
+		 * in use.  The following cred dancing somehow works around
+		 * it.  See 2ce9738ba ("cgroupfs: use init_cred when
+		 * populating new cgroupfs mount") for more details.
+		 */
 		cred = override_creds(&init_cred);
 
 		ret = cgroup_addrm_files(root_cgrp, NULL, cgroup_base_files, true);
-- 
1.8.3.1
