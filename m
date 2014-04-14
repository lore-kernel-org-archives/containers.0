From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/3] cgroup: implement cgroup.subtree_populated for the
	default hierarchy
Date: Mon, 14 Apr 2014 17:44:06 -0400
Message-ID: <1397511846-2904-4-git-send-email-tj@kernel.org>
References: <1397511846-2904-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1397511846-2904-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: rlove-L7G0xEPcOZbYtjvyW6yDsg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup users often need a way to determine when a cgroup's
subhierarchy becomes empty so that it can be cleaned up.  cgroup
currently provides release_agent for it; unfortunately, this mechanism
is riddled with issues.

* It delivers events by forking and execing a userland binary
  specified as the release_agent.  This is a long deprecated method of
  notification delivery.  It's extremely heavy, slow and cumbersome to
  integrate with larger infrastructure.

* There is single monitoring point at the root.  There's no way to
  delegate management of subtree.

* The event isn't recursive.  It triggers when a cgroup doesn't have
  any tasks or child cgroups.  Events for internal nodes trigger only
  after all children are removed.  This again makes it impossible to
  delegate management of subtree.

* Events are filtered from the kernel side.  "notify_on_release" file
  is used to subscribe to or suppress release event.  This is
  unnecessarily complicated and probably done this way because event
  delivery itself was expensive.

This patch implements interface file "cgroup.subtree_populated" which
can be used to monitor whether the cgroup's subhierarchy has tasks in
it or not.  Its value is 0 if there is no task in the cgroup and its
descendants; otherwise, 1, and kernfs_notify() notificaiton is
triggers when the value changes, which can be monitored through poll
and [di]notify.

This is a lot ligther and simpler and trivially allows delegating
management of subhierarchy - subhierarchy monitoring can block further
propgation simply by putting itself or another process in the root of
the subhierarchy and monitor events that it's interested in from there
without interfering with monitoring higher in the tree.

v2: Patch description updated as per Serge.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>
---
 include/linux/cgroup.h | 15 ++++++++++++
 kernel/cgroup.c        | 65 ++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 76 insertions(+), 4 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index ada2392..4b38e2d 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -154,6 +154,14 @@ struct cgroup {
 	/* the number of attached css's */
 	int nr_css;
 
+	/*
+	 * If this cgroup contains any tasks, it contributes one to
+	 * populated_cnt.  All children with non-zero popuplated_cnt of
+	 * their own contribute one.  The count is zero iff there's no task
+	 * in this cgroup or its subtree.
+	 */
+	int populated_cnt;
+
 	atomic_t refcnt;
 
 	/*
@@ -166,6 +174,7 @@ struct cgroup {
 	struct cgroup *parent;		/* my parent */
 	struct kernfs_node *kn;		/* cgroup kernfs entry */
 	struct kernfs_node *control_kn;	/* kn for "cgroup.subtree_control" */
+	struct kernfs_node *populated_kn; /* kn for "cgroup.subtree_populated" */
 
 	/*
 	 * Monotonically increasing unique serial number which defines a
@@ -264,6 +273,12 @@ enum {
 	 *
 	 * - "cgroup.clone_children" is removed.
 	 *
+	 * - "cgroup.subtree_populated" is available.  Its value is 0 if
+	 *   the cgroup and its descendants contain no task; otherwise, 1.
+	 *   The file also generates kernfs notification which can be
+	 *   monitored through poll and [di]notify when the value of the
+	 *   file changes.
+	 *
 	 * - If mount is requested with sane_behavior but without any
 	 *   subsystem, the default unified hierarchy is mounted.
 	 *
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 08c4439..e379e83 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -411,6 +411,43 @@ static struct css_set init_css_set = {
 
 static int css_set_count	= 1;	/* 1 for init_css_set */
 
+/**
+ * cgroup_update_populated - updated populated count of a cgroup
+ * @cgrp: the target cgroup
+ * @populated: inc or dec populated count
+ *
+ * @cgrp is either getting the first task (css_set) or losing the last.
+ * Update @cgrp->populated_cnt accordingly.  The count is propagated
+ * towards root so that a given cgroup's populated_cnt is zero iff the
+ * cgroup and all its descendants are empty.
+ *
+ * @cgrp's interface file "cgroup.subtree_populated" is zero if
+ * @cgrp->populated_cnt is zero and 1 otherwise.  When @cgrp->populated_cnt
+ * changes from or to zero, userland is notified that the content of the
+ * interface file has changed.  This can be used to detect when @cgrp and
+ * its descendants become populated or empty.
+ */
+static void cgroup_update_populated(struct cgroup *cgrp, bool populated)
+{
+	lockdep_assert_held(&css_set_rwsem);
+
+	do {
+		bool trigger;
+
+		if (populated)
+			trigger = !cgrp->populated_cnt++;
+		else
+			trigger = !--cgrp->populated_cnt;
+
+		if (!trigger)
+			break;
+
+		if (cgrp->populated_kn)
+			kernfs_notify(cgrp->populated_kn);
+		cgrp = cgrp->parent;
+	} while (cgrp);
+}
+
 /*
  * hash table for cgroup groups. This improves the performance to find
  * an existing css_set. This hash doesn't (currently) take into
@@ -456,10 +493,13 @@ static void put_css_set_locked(struct css_set *cset, bool taskexit)
 		list_del(&link->cgrp_link);
 
 		/* @cgrp can't go away while we're holding css_set_rwsem */
-		if (list_empty(&cgrp->cset_links) && notify_on_release(cgrp)) {
-			if (taskexit)
-				set_bit(CGRP_RELEASABLE, &cgrp->flags);
-			check_for_release(cgrp);
+		if (list_empty(&cgrp->cset_links)) {
+			cgroup_update_populated(cgrp, false);
+			if (notify_on_release(cgrp)) {
+				if (taskexit)
+					set_bit(CGRP_RELEASABLE, &cgrp->flags);
+				check_for_release(cgrp);
+			}
 		}
 
 		kfree(link);
@@ -668,7 +708,11 @@ static void link_css_set(struct list_head *tmp_links, struct css_set *cset,
 	link = list_first_entry(tmp_links, struct cgrp_cset_link, cset_link);
 	link->cset = cset;
 	link->cgrp = cgrp;
+
+	if (list_empty(&cgrp->cset_links))
+		cgroup_update_populated(cgrp, true);
 	list_move(&link->cset_link, &cgrp->cset_links);
+
 	/*
 	 * Always add links to the tail of the list so that the list
 	 * is sorted by order of hierarchy creation
@@ -2643,6 +2687,12 @@ err_undo_css:
 	goto out_unlock;
 }
 
+static int cgroup_subtree_populated_show(struct seq_file *seq, void *v)
+{
+	seq_printf(seq, "%d\n", (bool)seq_css(seq)->cgroup->populated_cnt);
+	return 0;
+}
+
 static ssize_t cgroup_file_write(struct kernfs_open_file *of, char *buf,
 				 size_t nbytes, loff_t off)
 {
@@ -2809,6 +2859,8 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cftype *cft)
 
 	if (cft->seq_show == cgroup_subtree_control_show)
 		cgrp->control_kn = kn;
+	else if (cft->seq_show == cgroup_subtree_populated_show)
+		cgrp->populated_kn = kn;
 	return 0;
 }
 
@@ -3922,6 +3974,11 @@ static struct cftype cgroup_base_files[] = {
 		.seq_show = cgroup_subtree_control_show,
 		.write_string = cgroup_subtree_control_write,
 	},
+	{
+		.name = "cgroup.subtree_populated",
+		.flags = CFTYPE_ONLY_ON_DFL | CFTYPE_NOT_ON_ROOT,
+		.seq_show = cgroup_subtree_populated_show,
+	},
 
 	/*
 	 * Historical crazy stuff.  These don't have "cgroup."  prefix and
-- 
1.9.0
