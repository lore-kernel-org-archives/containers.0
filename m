From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/14] cgroup: cgroup_css_from_dir() now should be called with
	RCU read locked
Date: Thu,  8 Aug 2013 16:13:41 -0400
Message-ID: <1375992831-4650-5-git-send-email-tj@kernel.org>
References: <1375992831-4650-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375992831-4650-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup->subsys[] will become RCU protected and thus all cgroup_css()
usages should either be under RCU read lock or cgroup_mutex.  This
patch updates cgroup_css_from_dir() which returns the matching
cgroup_subsys_state given a directory file and subsys_id so that it
requires RCU read lock and updates its sole user
perf_cgroup_connect().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c      | 12 ++++++++++--
 kernel/events/core.c |  3 +++
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5c6dd7e..cbb6314 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5616,8 +5616,14 @@ struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)
 }
 EXPORT_SYMBOL_GPL(css_lookup);
 
-/*
- * get corresponding css from file open on cgroupfs directory
+/**
+ * cgroup_css_from_dir - get corresponding css from file open on cgroup dir
+ * @f: directory file of interest
+ * @id: subsystem id of interest
+ *
+ * Must be called under RCU read lock.  The caller is responsible for
+ * pinning the returned css if it needs to be accessed outside the RCU
+ * critical section.
  */
 struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
 {
@@ -5625,6 +5631,8 @@ struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
 	struct inode *inode;
 	struct cgroup_subsys_state *css;
 
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
 	inode = file_inode(f);
 	/* check in cgroup filesystem dir */
 	if (inode->i_op != &cgroup_dir_inode_operations)
diff --git a/kernel/events/core.c b/kernel/events/core.c
index c199c4f..23261f9 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -591,6 +591,8 @@ static inline int perf_cgroup_connect(int fd, struct perf_event *event,
 	if (!f.file)
 		return -EBADF;
 
+	rcu_read_lock();
+
 	css = cgroup_css_from_dir(f.file, perf_subsys_id);
 	if (IS_ERR(css)) {
 		ret = PTR_ERR(css);
@@ -617,6 +619,7 @@ static inline int perf_cgroup_connect(int fd, struct perf_event *event,
 		ret = -EINVAL;
 	}
 out:
+	rcu_read_unlock();
 	fdput(f);
 	return ret;
 }
-- 
1.8.3.1
