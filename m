From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/3] cgroup: implement cgroup_is_descendant()
Date: Mon,  8 Apr 2013 19:23:32 -0700
Message-ID: <1365474213-13354-3-git-send-email-tj@kernel.org>
References: <1365474213-13354-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365474213-13354-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: namhyung.kim-Hm3cg6mZ9cc@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

A couple controllers want to determine whether two cgroups are in
ancestor/descendant relationship.  As it's more likely that the
descendant is the primary subject of interest and there are other
operations focusing on the descendants, let's ask is_descendent rather
than is_ancestor.

Implementation is trivial as the previous patch guarantees that all
ancestors of a cgroup stay accessible as long as the cgroup is
accessible.

tj: Removed depth optimization, renamed from cgroup_is_ancestor(),
    rewrote descriptions.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  1 +
 kernel/cgroup.c        | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 515927e..45aee0f 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -439,6 +439,7 @@ int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts);
 int cgroup_rm_cftypes(struct cgroup_subsys *ss, struct cftype *cfts);
 
 int cgroup_is_removed(const struct cgroup *cgrp);
+bool cgroup_is_descendant(struct cgroup *cgrp, struct cgroup *ancestor);
 
 int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d7dfa64..678a22c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -276,6 +276,26 @@ inline int cgroup_is_removed(const struct cgroup *cgrp)
 	return test_bit(CGRP_REMOVED, &cgrp->flags);
 }
 
+/**
+ * cgroup_is_descendant - test ancestry
+ * @cgrp: the cgroup to be tested
+ * @ancestor: possible ancestor of @cgrp
+ *
+ * Test whether @cgrp is a descendant of @ancestor.  It also returns %true
+ * if @cgrp == @ancestor.  This function is safe to call as long as @cgrp
+ * and @ancestor are accessible.
+ */
+bool cgroup_is_descendant(struct cgroup *cgrp, struct cgroup *ancestor)
+{
+	while (cgrp) {
+		if (cgrp == ancestor)
+			return true;
+		cgrp = cgrp->parent;
+	}
+	return false;
+}
+EXPORT_SYMBOL_GPL(cgroup_is_descendant);
+
 /* bits in struct cgroupfs_root flags field */
 enum {
 	ROOT_NOPREFIX,	/* mounted subsystems have no named prefix */
-- 
1.8.1.4
