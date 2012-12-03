From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RESEND] cgroup: remove subsystem files when remounting cgroup
Date: Mon, 3 Dec 2012 09:28:18 +0800
Message-ID: <1354498098-17312-1-git-send-email-gaofeng@cn.fujitsu.com>
References: <1354292489-18434-2-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1354292489-18434-2-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_clear_directroy is called by cgroup_d_remove_dir
and cgroup_remount.

when we call cgroup_remount to remount the cgroup,the subsystem
may be unlinked from cgroupfs_root->subsys_list in rebind_subsystem,this
subsystem's files will not be removed in cgroup_clear_directroy.
And the system will panic when we try to access these files.

this patch removes subsystems's files before rebind_subsystems,
if rebind_subsystems failed, repopulate these removed files.

With help from Tejun.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e1293a9..afabd2a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1349,14 +1349,21 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 		goto out_unlock;
 	}
 
+	/*
+	 * Clear out the files of subsystems that should be removed,do
+	 * this job before rebind_subsystems,since rebind_subsystems may
+	 * change this hierarchy's subsys_list.
+	 */
+	cgroup_clear_directory(cgrp->dentry, false, removed_mask);
+
 	ret = rebind_subsystems(root, opts.subsys_mask);
 	if (ret) {
+		/* rebind_subsystems failed,re-populate the removed files */
+		cgroup_populate_dir(cgrp, false, removed_mask);
 		drop_parsed_module_refcounts(opts.subsys_mask);
 		goto out_unlock;
 	}
 
-	/* clear out any existing files and repopulate subsystem files */
-	cgroup_clear_directory(cgrp->dentry, false, removed_mask);
 	/* re-populate subsystem files */
 	cgroup_populate_dir(cgrp, false, added_mask);
 
-- 
1.7.7.6
