From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/12] cgroup: add css_set->dfl_cgrp
Date: Thu, 27 Mar 2014 22:40:58 -0400
Message-ID: <1395974461-12735-10-git-send-email-tj@kernel.org>
References: <1395974461-12735-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1395974461-12735-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

To implement the unified hierarchy behavior, we'll need to be able to
determine the associated cgroup on the default hierarchy from css_set.
Let's add css_set->dfl_cgrp so that it can be accessed conveniently
and efficiently.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 3 +++
 kernel/cgroup.c        | 4 ++++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index cbfd8be..b6f5e40 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -354,6 +354,9 @@ struct css_set {
 	 */
 	struct list_head cgrp_links;
 
+	/* the default cgroup associated with this css_set */
+	struct cgroup *dfl_cgrp;
+
 	/*
 	 * Set of subsystem states, one for each subsystem. This array is
 	 * immutable after creation apart from the init_css_set during
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 30f48b0..e714ccf 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -651,6 +651,10 @@ static void link_css_set(struct list_head *tmp_links, struct css_set *cset,
 	struct cgrp_cset_link *link;
 
 	BUG_ON(list_empty(tmp_links));
+
+	if (cgroup_on_dfl(cgrp))
+		cset->dfl_cgrp = cgrp;
+
 	link = list_first_entry(tmp_links, struct cgrp_cset_link, cset_link);
 	link->cset = cset;
 	link->cgrp = cgrp;
-- 
1.8.5.3
