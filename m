From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/12] cgroup: relocate __d_cgrp() and __d_cft()
Date: Wed, 21 Mar 2012 15:17:43 -0700
Message-ID: <1332368265-21586-11-git-send-email-tj@kernel.org>
References: <1332368265-21586-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1332368265-21586-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Move the two macros upwards as they'll be used earlier in the file.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 02e131e..d64f16d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -282,6 +282,16 @@ list_for_each_entry(_ss, &_root->subsys_list, sibling)
 #define for_each_active_root(_root) \
 list_for_each_entry(_root, &roots, root_list)
 
+static inline struct cgroup *__d_cgrp(struct dentry *dentry)
+{
+	return dentry->d_fsdata;
+}
+
+static inline struct cftype *__d_cft(struct dentry *dentry)
+{
+	return dentry->d_fsdata;
+}
+
 /* the list of cgroups eligible for automatic release. Protected by
  * release_list_lock */
 static LIST_HEAD(release_list);
@@ -1708,16 +1718,6 @@ static struct file_system_type cgroup_fs_type = {
 
 static struct kobject *cgroup_kobj;
 
-static inline struct cgroup *__d_cgrp(struct dentry *dentry)
-{
-	return dentry->d_fsdata;
-}
-
-static inline struct cftype *__d_cft(struct dentry *dentry)
-{
-	return dentry->d_fsdata;
-}
-
 /**
  * cgroup_path - generate the path of a cgroup
  * @cgrp: the cgroup in question
-- 
1.7.7.3
