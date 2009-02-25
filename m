From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 1/2] cgroup allow subsys to set default mode of its own file
Date: Wed, 25 Feb 2009 16:35:55 +0900
Message-ID: <20090225163555.d2a0b24c.kamezawa.hiroyu__26786.3706489608$1235547627$gmane$org@jp.fujitsu.com>
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
To: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

cgroup's subsys has "readonly" files, but default permission is always
rw-r--r--. This allows to create r--r--r-- file to subsys.
(The user can do chmod on this read-only file. But this behavior is not
 different from current pseudo file systems as /proc.)

Reason:
 When I wrote tools for maintain cgroup, I can't find which file is
 writable intarfece or not via cgroup file systems. (finally, I did
 dirty approach.)
 IMHO, showing "this file is read-only" in explicit way is useful
 for user-land (tools). In other story, a file whose name sounds read-only
 may have "trigger" operation and support reseting. In this case,
 "writable" is informative.
 

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h |    2 ++
 kernel/cgroup.c        |    5 ++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

Index: mmotm-2.6.29-Feb24/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.29-Feb24.orig/include/linux/cgroup.h
+++ mmotm-2.6.29-Feb24/include/linux/cgroup.h
@@ -258,6 +258,8 @@ struct cftype {
 	 */
 	char name[MAX_CFTYPE_NAME];
 	int private;
+	/* if not 0, mode is set to mode, otherwise 0644 */
+	int mode;
 
 	/*
 	 * If non-zero, defines the maximum length of string that can
Index: mmotm-2.6.29-Feb24/kernel/cgroup.c
===================================================================
--- mmotm-2.6.29-Feb24.orig/kernel/cgroup.c
+++ mmotm-2.6.29-Feb24/kernel/cgroup.c
@@ -1767,7 +1767,10 @@ int cgroup_add_file(struct cgroup *cgrp,
 	BUG_ON(!mutex_is_locked(&dir->d_inode->i_mutex));
 	dentry = lookup_one_len(name, dir, strlen(name));
 	if (!IS_ERR(dentry)) {
-		error = cgroup_create_file(dentry, 0644 | S_IFREG,
+		int mode = 0644;
+		if (cft->mode)
+			mode = cft->mode;
+		error = cgroup_create_file(dentry, mode | S_IFREG,
 						cgrp->root->sb);
 		if (!error)
 			dentry->d_fsdata = (void *)cft;
