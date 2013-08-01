From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/23] cgroup: add cgroup->dummy_css
Date: Thu,  1 Aug 2013 17:49:49 -0400
Message-ID: <1375393801-4817-12-git-send-email-tj@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup subsystem API is being converted to use css
(cgroup_subsys_state) as the main handle, which makes things a bit
awkward for subsystem agnostic core features - the "cgroup.*"
interface files and various iterations - a bit awkward as they don't
have a css to use.

This patch adds cgroup->dummy_css which has NULL ->ss and whose only
role is pointing back to the cgroup.  This will be used to support
subsystem agnostic features on the coming css based API.

css_parent() is updated to handle dummy_css's.  Note that css will
soon grow its own ->parent field and css_parent() will be made
trivial.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 11 ++++++++++-
 kernel/cgroup.c        |  9 +++++----
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 2e0e9e2..085ca93 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -225,6 +225,9 @@ struct cgroup {
 	struct list_head pidlists;
 	struct mutex pidlist_mutex;
 
+	/* dummy css with NULL ->ss, points back to this cgroup */
+	struct cgroup_subsys_state dummy_css;
+
 	/* For css percpu_ref killing and RCU-protected deletion */
 	struct rcu_head rcu_head;
 	struct work_struct destroy_work;
@@ -669,7 +672,13 @@ struct cgroup_subsys_state *css_parent(struct cgroup_subsys_state *css)
 {
 	struct cgroup *parent_cgrp = css->cgroup->parent;
 
-	return parent_cgrp ? parent_cgrp->subsys[css->ss->subsys_id] : NULL;
+	if (!parent_cgrp)
+		return NULL;
+
+	if (css->ss)
+		return parent_cgrp->subsys[css->ss->subsys_id];
+	else
+		return &parent_cgrp->dummy_css;
 }
 
 /**
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b413e22..bb87c9f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1365,6 +1365,7 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->release_list);
 	INIT_LIST_HEAD(&cgrp->pidlists);
 	mutex_init(&cgrp->pidlist_mutex);
+	cgrp->dummy_css.cgroup = cgrp;
 	INIT_LIST_HEAD(&cgrp->event_list);
 	spin_lock_init(&cgrp->event_list_lock);
 	simple_xattrs_init(&cgrp->xattrs);
@@ -2278,7 +2279,7 @@ static struct cgroup_subsys_state *cgroup_file_css(struct cfent *cfe)
 
 	if (cft->ss)
 		return cgrp->subsys[cft->ss->subsys_id];
-	return NULL;
+	return &cgrp->dummy_css;
 }
 
 /* A buffer size big enough for numbers or short strings */
@@ -2460,7 +2461,7 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 	 * unpinned either on open failure or release.  This ensures that
 	 * @css stays alive for all file operations.
 	 */
-	if (css && !css_tryget(css))
+	if (css->ss && !css_tryget(css))
 		return -ENODEV;
 
 	if (cft->read_map || cft->read_seq_string) {
@@ -2470,7 +2471,7 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 		err = cft->open(inode, file);
 	}
 
-	if (css && err)
+	if (css->ss && err)
 		css_put(css);
 	return err;
 }
@@ -2484,7 +2485,7 @@ static int cgroup_file_release(struct inode *inode, struct file *file)
 
 	if (cft->release)
 		ret = cft->release(inode, file);
-	if (css)
+	if (css->ss)
 		css_put(css);
 	return ret;
 }
-- 
1.8.3.1
