From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/11] cgroup: remove now unused css_depth()
Date: Wed, 12 Jun 2013 14:03:06 -0700
Message-ID: <1371070996-20613-2-git-send-email-tj@kernel.org>
References: <1371070996-20613-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371070996-20613-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  1 -
 kernel/cgroup.c        | 12 ------------
 2 files changed, 13 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index d0ad379..5830592 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -848,7 +848,6 @@ bool css_is_ancestor(struct cgroup_subsys_state *cg,
 
 /* Get id and depth of css */
 unsigned short css_id(struct cgroup_subsys_state *css);
-unsigned short css_depth(struct cgroup_subsys_state *css);
 struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id);
 
 #else /* !CONFIG_CGROUPS */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3ad2a9c..dc8997a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5230,18 +5230,6 @@ unsigned short css_id(struct cgroup_subsys_state *css)
 }
 EXPORT_SYMBOL_GPL(css_id);
 
-unsigned short css_depth(struct cgroup_subsys_state *css)
-{
-	struct css_id *cssid;
-
-	cssid = rcu_dereference_check(css->id, css_refcnt(css));
-
-	if (cssid)
-		return cssid->depth;
-	return 0;
-}
-EXPORT_SYMBOL_GPL(css_depth);
-
 /**
  *  css_is_ancestor - test "root" css is an ancestor of "child"
  * @child: the css to be tested.
-- 
1.8.2.1
