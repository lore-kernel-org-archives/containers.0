From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH UPDATED 4/4] cgroup: implement
	task_cgroup_path_from_hierarchy()
Date: Sun, 14 Apr 2013 20:50:08 -0700
Message-ID: <20130415035008.GM3050__14075.5561915741$1365997826$gmane$org@htj.dyndns.org>
References: <1365964619-14762-1-git-send-email-tj@kernel.org>
	<1365964619-14762-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1365964619-14762-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

kdbus folks want a sane way to determine the cgroup path that a given
task belongs to on a given hierarchy, which is a reasonble thing to
expect from cgroup core.

Implement task_cgroup_path_from_hierarchy().

v2: Dropped unnecessary NULL check on the return value of
    task_cgroup_from_root() as suggested by Li Zefan.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Greg Kroah-Hartman <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>
Cc: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>
Cc: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |    2 ++
 kernel/cgroup.c        |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -443,6 +443,8 @@ int cgroup_is_removed(const struct cgrou
 bool cgroup_is_descendant(struct cgroup *cgrp, struct cgroup *ancestor);
 
 int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen);
+int task_cgroup_path_from_hierarchy(struct task_struct *task, int hierarchy_id,
+				    char *buf, size_t buflen);
 
 int cgroup_task_count(const struct cgroup *cgrp);
 
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1842,6 +1842,38 @@ out:
 }
 EXPORT_SYMBOL_GPL(cgroup_path);
 
+/**
+ * task_cgroup_path_from_hierarchy - cgroup path of a task on a hierarchy
+ * @task: target task
+ * @hierarchy_id: the hierarchy to look up @task's cgroup from
+ * @buf: the buffer to write the path into
+ * @buflen: the length of the buffer
+ *
+ * Determine @task's cgroup on the hierarchy specified by @hierarchy_id and
+ * copy its path into @buf.  This function grabs cgroup_mutex and shouldn't
+ * be used inside locks used by cgroup controller callbacks.
+ */
+int task_cgroup_path_from_hierarchy(struct task_struct *task, int hierarchy_id,
+				    char *buf, size_t buflen)
+{
+	struct cgroupfs_root *root;
+	struct cgroup *cgrp = NULL;
+	int ret = -ENOENT;
+
+	mutex_lock(&cgroup_mutex);
+
+	root = idr_find(&cgroup_hierarchy_idr, hierarchy_id);
+	if (root) {
+		cgrp = task_cgroup_from_root(task, root);
+		ret = cgroup_path(cgrp, buf, buflen);
+	}
+
+	mutex_unlock(&cgroup_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(task_cgroup_path_from_hierarchy);
+
 /*
  * Control Group taskset
  */
