From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/3] cpuset: implement cgroup_rightmost_descendant()
Date: Wed, 28 Nov 2012 14:26:59 -0800
Message-ID: <1354141621-11906-2-git-send-email-tj@kernel.org>
References: <1354141621-11906-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1354141621-11906-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Implement cgroup_rightmost_descendant() which returns the right most
descendant of the specified cgroup.  This can be used to skip the
cgroup's subtree while iterating with
cgroup_for_each_descendant_pre().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
---
 include/linux/cgroup.h |  1 +
 kernel/cgroup.c        | 26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 7d73905..860ca0f 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -558,6 +558,7 @@ static inline struct cgroup* task_cgroup(struct task_struct *task,
 
 struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
 					  struct cgroup *cgroup);
+struct cgroup *cgroup_rightmost_descendant(struct cgroup *pos);
 
 /**
  * cgroup_for_each_descendant_pre - pre-order walk of a cgroup's descendants
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c02b055..bbf7460 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3009,6 +3009,32 @@ struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
 }
 EXPORT_SYMBOL_GPL(cgroup_next_descendant_pre);
 
+/**
+ * cgroup_rightmost_descendant - return the rightmost descendant of a cgroup
+ * @cgrp: cgroup of interest
+ *
+ * Return the rightmost descendant of @cgrp.  If there's no descendant,
+ * @cgrp is returned.  This can be used during pre-order traversal to skip
+ * subtree of @cgrp.
+ */
+struct cgroup *cgroup_rightmost_descendant(struct cgroup *pos)
+{
+	struct cgroup *last, *tmp;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	do {
+		last = pos;
+		/* ->prev isn't RCU safe, walk ->next till the end */
+		pos = NULL;
+		list_for_each_entry_rcu(tmp, &last->children, sibling)
+			pos = tmp;
+	} while (pos);
+
+	return last;
+}
+EXPORT_SYMBOL_GPL(cgroup_rightmost_descendant);
+
 static struct cgroup *cgroup_leftmost_descendant(struct cgroup *pos)
 {
 	struct cgroup *last;
-- 
1.7.11.7
