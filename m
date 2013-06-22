From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/6] cgroup: clean up find_css_set() and friends
Date: Fri, 21 Jun 2013 18:34:12 -0700
Message-ID: <1371864854-28364-5-git-send-email-tj__509.189422200684$1371864899$gmane$org@kernel.org>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371864854-28364-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

find_css_set() passes uninitialized on-stack template[] array to
find_existing_css_set() which sets the entries for all subsystems.
Passing around an uninitialized array is a bit icky and we want to
introduce an iterator which only iterates loaded subsystems.  Let's
initialize it on definition.

While at it, also make the following cosmetic cleanups.

* Convert to proper /** comments.

* Reorder variable declarations.

* Replace comment on synchronization with lockdep_assert_held().

This patch doesn't make any functional differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 38 +++++++++++++++++---------------------
 1 file changed, 17 insertions(+), 21 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c3222a7..5f85f3a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -434,7 +434,7 @@ static inline void put_css_set_taskexit(struct css_set *cset)
 	__put_css_set(cset, 1);
 }
 
-/*
+/**
  * compare_css_sets - helper function for find_existing_css_set().
  * @cset: candidate css_set being tested
  * @old_cset: existing css_set for a task
@@ -506,27 +506,20 @@ static bool compare_css_sets(struct css_set *cset,
 	return true;
 }
 
-/*
- * find_existing_css_set() is a helper for
- * find_css_set(), and checks to see whether an existing
- * css_set is suitable.
- *
- * oldcg: the cgroup group that we're using before the cgroup
- * transition
- *
- * cgrp: the cgroup that we're moving into
- *
- * template: location in which to build the desired set of subsystem
- * state objects for the new cgroup group
+/**
+ * find_existing_css_set - init css array and find the matching css_set
+ * @old_cset: the css_set that we're using before the cgroup transition
+ * @cgrp: the cgroup that we're moving into
+ * @template: out param for the new set of csses, should be clear on entry
  */
 static struct css_set *find_existing_css_set(struct css_set *old_cset,
 					struct cgroup *cgrp,
 					struct cgroup_subsys_state *template[])
 {
-	int i;
 	struct cgroupfs_root *root = cgrp->root;
 	struct css_set *cset;
 	unsigned long key;
+	int i;
 
 	/*
 	 * Build the set of subsystem state objects that we want to see in the
@@ -618,22 +611,25 @@ static void link_css_set(struct list_head *tmp_links, struct css_set *cset,
 	list_add_tail(&link->cgrp_link, &cset->cgrp_links);
 }
 
-/*
- * find_css_set() takes an existing cgroup group and a
- * cgroup object, and returns a css_set object that's
- * equivalent to the old group, but with the given cgroup
- * substituted into the appropriate hierarchy. Must be called with
- * cgroup_mutex held
+/**
+ * find_css_set - return a new css_set with one cgroup updated
+ * @old_cset: the baseline css_set
+ * @cgrp: the cgroup to be updated
+ *
+ * Return a new css_set that's equivalent to @old_cset, but with @cgrp
+ * substituted into the appropriate hierarchy.
  */
 static struct css_set *find_css_set(struct css_set *old_cset,
 				    struct cgroup *cgrp)
 {
+	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT] = { };
 	struct css_set *cset;
-	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
 	struct list_head tmp_links;
 	struct cgrp_cset_link *link;
 	unsigned long key;
 
+	lockdep_assert_held(&cgroup_mutex);
+
 	/* First see if we already have a cgroup group that matches
 	 * the desired set */
 	read_lock(&css_set_lock);
-- 
1.8.2.1
