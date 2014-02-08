From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/13] cgroup: improve css_from_dir() into
	css_tryget_from_dir()
Date: Sat,  8 Feb 2014 11:15:15 -0500
Message-ID: <1391876127-7134-2-git-send-email-tj@kernel.org>
References: <1391876127-7134-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391876127-7134-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

css_from_dir() returns the matching css (cgroup_subsys_state) given a
dentry and subsystem.  The function doesn't pin the css before
returning and requires the caller to be holding RCU read lock or
cgroup_mutex and handling pinning on the caller side.

Given that users of the function are likely to want to pin the
returned css (both existing users do) and that getting and putting
css's are very cheap, there's no reason for the interface to be tricky
like this.

Rename css_from_dir() to css_tryget_from_dir() and make it try to pin
the found css and return it only if pinning succeeded.  The callers
are updated so that they no longer do RCU locking and pinning around
the function and just use the returned css.

This will also ease converting cgroup to kernfs.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h |  4 ++--
 kernel/cgroup.c        | 25 ++++++++++++++++---------
 kernel/events/core.c   | 17 +----------------
 mm/memcontrol.c        | 16 +++++++---------
 4 files changed, 26 insertions(+), 36 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 198c7fc..2255639 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -823,8 +823,8 @@ int css_scan_tasks(struct cgroup_subsys_state *css,
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
 
-struct cgroup_subsys_state *css_from_dir(struct dentry *dentry,
-					 struct cgroup_subsys *ss);
+struct cgroup_subsys_state *css_tryget_from_dir(struct dentry *dentry,
+						struct cgroup_subsys *ss);
 
 #else /* !CONFIG_CGROUPS */
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f5bbe58..57eb942 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4976,28 +4976,35 @@ static int __init cgroup_disable(char *str)
 __setup("cgroup_disable=", cgroup_disable);
 
 /**
- * css_from_dir - get corresponding css from the dentry of a cgroup dir
+ * css_tryget_from_dir - get corresponding css from the dentry of a cgroup dir
  * @dentry: directory dentry of interest
  * @ss: subsystem of interest
  *
- * Must be called under cgroup_mutex or RCU read lock.  The caller is
- * responsible for pinning the returned css if it needs to be accessed
- * outside the critical section.
+ * If @dentry is a directory for a cgroup which has @ss enabled on it, try
+ * to get the corresponding css and return it.  If such css doesn't exist
+ * or can't be pinned, an ERR_PTR value is returned.
  */
-struct cgroup_subsys_state *css_from_dir(struct dentry *dentry,
-					 struct cgroup_subsys *ss)
+struct cgroup_subsys_state *css_tryget_from_dir(struct dentry *dentry,
+						struct cgroup_subsys *ss)
 {
 	struct cgroup *cgrp;
-
-	cgroup_assert_mutex_or_rcu_locked();
+	struct cgroup_subsys_state *css;
 
 	/* is @dentry a cgroup dir? */
 	if (!dentry->d_inode ||
 	    dentry->d_inode->i_op != &cgroup_dir_inode_operations)
 		return ERR_PTR(-EBADF);
 
+	rcu_read_lock();
+
 	cgrp = __d_cgrp(dentry);
-	return cgroup_css(cgrp, ss) ?: ERR_PTR(-ENOENT);
+	css = cgroup_css(cgrp, ss);
+
+	if (!css || !css_tryget(css))
+		css = ERR_PTR(-ENOENT);
+
+	rcu_read_unlock();
+	return css;
 }
 
 /**
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 6490373..a3c3ab5 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -370,11 +370,6 @@ perf_cgroup_match(struct perf_event *event)
 				    event->cgrp->css.cgroup);
 }
 
-static inline bool perf_tryget_cgroup(struct perf_event *event)
-{
-	return css_tryget(&event->cgrp->css);
-}
-
 static inline void perf_put_cgroup(struct perf_event *event)
 {
 	css_put(&event->cgrp->css);
@@ -593,9 +588,7 @@ static inline int perf_cgroup_connect(int fd, struct perf_event *event,
 	if (!f.file)
 		return -EBADF;
 
-	rcu_read_lock();
-
-	css = css_from_dir(f.file->f_dentry, &perf_event_cgrp_subsys);
+	css = css_tryget_from_dir(f.file->f_dentry, &perf_event_cgrp_subsys);
 	if (IS_ERR(css)) {
 		ret = PTR_ERR(css);
 		goto out;
@@ -604,13 +597,6 @@ static inline int perf_cgroup_connect(int fd, struct perf_event *event,
 	cgrp = container_of(css, struct perf_cgroup, css);
 	event->cgrp = cgrp;
 
-	/* must be done before we fput() the file */
-	if (!perf_tryget_cgroup(event)) {
-		event->cgrp = NULL;
-		ret = -ENOENT;
-		goto out;
-	}
-
 	/*
 	 * all events in a group must monitor
 	 * the same cgroup because a task belongs
@@ -621,7 +607,6 @@ static inline int perf_cgroup_connect(int fd, struct perf_event *event,
 		ret = -EINVAL;
 	}
 out:
-	rcu_read_unlock();
 	fdput(f);
 	return ret;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 04a97bc..102ab48 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6183,17 +6183,15 @@ static int memcg_write_event_control(struct cgroup_subsys_state *css,
 	 * automatically removed on cgroup destruction but the removal is
 	 * asynchronous, so take an extra ref on @css.
 	 */
-	rcu_read_lock();
-
+	cfile_css = css_tryget_from_dir(cfile.file->f_dentry->d_parent,
+					&memory_cgrp_subsys);
 	ret = -EINVAL;
-	cfile_css = css_from_dir(cfile.file->f_dentry->d_parent,
-				 &memory_cgrp_subsys);
-	if (cfile_css == css && css_tryget(css))
-		ret = 0;
-
-	rcu_read_unlock();
-	if (ret)
+	if (IS_ERR(cfile_css))
 		goto out_put_cfile;
+	if (cfile_css != css) {
+		css_put(cfile_css);
+		goto out_put_cfile;
+	}
 
 	ret = event->register_event(memcg, event->eventfd, buffer);
 	if (ret)
-- 
1.8.5.3
