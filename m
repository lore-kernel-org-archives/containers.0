From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup changes for 3.11-rc2
Date: Tue, 23 Jul 2013 13:47:11 -0400
Message-ID: <20130723174711.GE21100__36381.5970755697$1374601650$gmane$org@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Linus.

This pull request contains two patches, both of which aren't fixes
per-se but I think it'd be better to fast-track them.

One removes bcache_subsys_id which was added without proper review
through the block tree.  Fortunately, bcache cgroup code is
unconditionally disabled, so this was never exposed to userland.  The
cgroup subsys_id is removed.  Kent will remove the affected (disabled)
code through bcache branch.

The other simplifies task_group_path_from_hierarchy().  The function
doesn't currently have in-kernel users but there are external code and
development going on dependent on the function and making the function
available for 3.11 would make things go smoother.

The two patches are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.11-fixes

for you to fetch changes up to 913ffdb54366f94eec65c656cae8c6e00e1ab1b0:

  cgroup: replace task_cgroup_path_from_hierarchy() with task_cgroup_path() (2013-07-12 12:49:05 -0700)

Thanks.

----------------------------------------------------------------
Tejun Heo (2):
      cgroup: remove bcache_subsys_id which got added stealthily
      cgroup: replace task_cgroup_path_from_hierarchy() with task_cgroup_path()

 include/linux/cgroup.h        |  3 +--
 include/linux/cgroup_subsys.h | 45 +++++++------------------------------------
 kernel/cgroup.c               | 31 +++++++++++++++++------------
 3 files changed, 27 insertions(+), 52 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index fd097ec..21cfaff 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -540,8 +540,7 @@ int cgroup_rm_cftypes(struct cgroup_subsys *ss, struct cftype *cfts);
 bool cgroup_is_descendant(struct cgroup *cgrp, struct cgroup *ancestor);
 
 int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen);
-int task_cgroup_path_from_hierarchy(struct task_struct *task, int hierarchy_id,
-				    char *buf, size_t buflen);
+int task_cgroup_path(struct task_struct *task, char *buf, size_t buflen);
 
 int cgroup_task_count(const struct cgroup *cgrp);
 
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 6e7ec64..b613ffd 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -1,86 +1,55 @@
-/* Add subsystem definitions of the form SUBSYS(<name>) in this
- * file. Surround each one by a line of comment markers so that
- * patches don't collide
+/*
+ * List of cgroup subsystems.
+ *
+ * DO NOT ADD ANY SUBSYSTEM WITHOUT EXPLICIT ACKS FROM CGROUP MAINTAINERS.
  */
-
-/* */
-
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_CPUSETS)
 SUBSYS(cpuset)
 #endif
 
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_CGROUP_DEBUG)
 SUBSYS(debug)
 #endif
 
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_CGROUP_SCHED)
 SUBSYS(cpu_cgroup)
 #endif
 
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_CGROUP_CPUACCT)
 SUBSYS(cpuacct)
 #endif
 
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_MEMCG)
 SUBSYS(mem_cgroup)
 #endif
 
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_CGROUP_DEVICE)
 SUBSYS(devices)
 #endif
 
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_CGROUP_FREEZER)
 SUBSYS(freezer)
 #endif
 
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_NET_CLS_CGROUP)
 SUBSYS(net_cls)
 #endif
 
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_BLK_CGROUP)
 SUBSYS(blkio)
 #endif
 
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_CGROUP_PERF)
 SUBSYS(perf)
 #endif
 
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_NETPRIO_CGROUP)
 SUBSYS(net_prio)
 #endif
 
-/* */
-
 #if IS_SUBSYS_ENABLED(CONFIG_CGROUP_HUGETLB)
 SUBSYS(hugetlb)
 #endif
-
-/* */
-
-#ifdef CONFIG_CGROUP_BCACHE
-SUBSYS(bcache)
-#endif
-
-/* */
+/*
+ * DO NOT ADD ANY SUBSYSTEM WITHOUT EXPLICIT ACKS FROM CGROUP MAINTAINERS.
+ */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e5583d1..afb8d53 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1846,36 +1846,43 @@ out:
 EXPORT_SYMBOL_GPL(cgroup_path);
 
 /**
- * task_cgroup_path_from_hierarchy - cgroup path of a task on a hierarchy
+ * task_cgroup_path - cgroup path of a task in the first cgroup hierarchy
  * @task: target task
- * @hierarchy_id: the hierarchy to look up @task's cgroup from
  * @buf: the buffer to write the path into
  * @buflen: the length of the buffer
  *
- * Determine @task's cgroup on the hierarchy specified by @hierarchy_id and
- * copy its path into @buf.  This function grabs cgroup_mutex and shouldn't
- * be used inside locks used by cgroup controller callbacks.
+ * Determine @task's cgroup on the first (the one with the lowest non-zero
+ * hierarchy_id) cgroup hierarchy and copy its path into @buf.  This
+ * function grabs cgroup_mutex and shouldn't be used inside locks used by
+ * cgroup controller callbacks.
+ *
+ * Returns 0 on success, fails with -%ENAMETOOLONG if @buflen is too short.
  */
-int task_cgroup_path_from_hierarchy(struct task_struct *task, int hierarchy_id,
-				    char *buf, size_t buflen)
+int task_cgroup_path(struct task_struct *task, char *buf, size_t buflen)
 {
 	struct cgroupfs_root *root;
-	struct cgroup *cgrp = NULL;
-	int ret = -ENOENT;
+	struct cgroup *cgrp;
+	int hierarchy_id = 1, ret = 0;
+
+	if (buflen < 2)
+		return -ENAMETOOLONG;
 
 	mutex_lock(&cgroup_mutex);
 
-	root = idr_find(&cgroup_hierarchy_idr, hierarchy_id);
+	root = idr_get_next(&cgroup_hierarchy_idr, &hierarchy_id);
+
 	if (root) {
 		cgrp = task_cgroup_from_root(task, root);
 		ret = cgroup_path(cgrp, buf, buflen);
+	} else {
+		/* if no hierarchy exists, everyone is in "/" */
+		memcpy(buf, "/", 2);
 	}
 
 	mutex_unlock(&cgroup_mutex);
-
 	return ret;
 }
-EXPORT_SYMBOL_GPL(task_cgroup_path_from_hierarchy);
+EXPORT_SYMBOL_GPL(task_cgroup_path);
 
 /*
  * Control Group taskset
