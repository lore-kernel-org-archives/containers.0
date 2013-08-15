From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/12] cgroup: rename cgroup_css_from_dir() to css_from_dir()
	and update its syntax
Date: Thu, 15 Aug 2013 12:02:19 -0400
Message-ID: <1376582550-12548-2-git-send-email-tj__3166.25887430764$1376582570$gmane$org@kernel.org>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1376582550-12548-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_css_from_dir() will grow another user.  In preparation, make
the following changes.

* All css functions are prefixed with just "css_", rename it to
  css_from_dir().

* Take dentry * instead of file * as dentry is what ultimately
  identifies a cgroup and file may not always be available.  Note that
  the function now checkes whether @dentry->d_inode is NULL as the
  caller now may specify a negative dentry.

* Make it take cgroup_subsys * instead of integer subsys_id.  This
  simplifies the function and allows specifying no subsystem for
  cgroup->dummy_css.

* Make return section a bit less verbose.

This patch doesn't introduce any behavior changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/cgroup.h |  3 ++-
 kernel/cgroup.c        | 26 ++++++++++----------------
 kernel/events/core.c   |  2 +-
 3 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c24bd0b..5029176 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -919,7 +919,8 @@ bool css_is_ancestor(struct cgroup_subsys_state *cg,
 
 /* Get id and depth of css */
 unsigned short css_id(struct cgroup_subsys_state *css);
-struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id);
+struct cgroup_subsys_state *css_from_dir(struct dentry *dentry,
+					 struct cgroup_subsys *ss);
 
 #else /* !CONFIG_CGROUPS */
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 6499004..007053d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5700,34 +5700,28 @@ struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)
 EXPORT_SYMBOL_GPL(css_lookup);
 
 /**
- * cgroup_css_from_dir - get corresponding css from file open on cgroup dir
- * @f: directory file of interest
- * @id: subsystem id of interest
+ * css_from_dir - get corresponding css from the dentry of a cgroup dir
+ * @dentry: directory dentry of interest
+ * @ss: subsystem of interest
  *
  * Must be called under RCU read lock.  The caller is responsible for
  * pinning the returned css if it needs to be accessed outside the RCU
  * critical section.
  */
-struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
+struct cgroup_subsys_state *css_from_dir(struct dentry *dentry,
+					 struct cgroup_subsys *ss)
 {
 	struct cgroup *cgrp;
-	struct inode *inode;
-	struct cgroup_subsys_state *css;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
-	inode = file_inode(f);
-	/* check in cgroup filesystem dir */
-	if (inode->i_op != &cgroup_dir_inode_operations)
+	/* is @dentry a cgroup dir? */
+	if (!dentry->d_inode ||
+	    dentry->d_inode->i_op != &cgroup_dir_inode_operations)
 		return ERR_PTR(-EBADF);
 
-	if (id < 0 || id >= CGROUP_SUBSYS_COUNT)
-		return ERR_PTR(-EINVAL);
-
-	/* get cgroup */
-	cgrp = __d_cgrp(f->f_dentry);
-	css = cgroup_css(cgrp, id);
-	return css ? css : ERR_PTR(-ENOENT);
+	cgrp = __d_cgrp(dentry);
+	return cgroup_css(cgrp, ss->subsys_id) ?: ERR_PTR(-ENOENT);
 }
 
 #ifdef CONFIG_CGROUP_DEBUG
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 23261f9..b59ab66 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -593,7 +593,7 @@ static inline int perf_cgroup_connect(int fd, struct perf_event *event,
 
 	rcu_read_lock();
 
-	css = cgroup_css_from_dir(f.file, perf_subsys_id);
+	css = css_from_dir(f.file->f_dentry, &perf_subsys);
 	if (IS_ERR(css)) {
 		ret = PTR_ERR(css);
 		goto out;
-- 
1.8.3.1
