From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/12] cgroup: make css_next_child() skip missing csses
Date: Mon, 14 Apr 2014 17:37:02 -0400
Message-ID: <1397511430-2673-5-git-send-email-tj@kernel.org>
References: <1397511430-2673-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1397511430-2673-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

css_next_child() walks the children of the specified css.  It does
this by finding the next cgroup and then returning the requested css.
On the default unified hierarchy, a cgroup may not have a css
associated with it even if the hierarchy has the subsystem enabled.
This patch updates css_next_child() so that it skips children without
the requested css associated.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 29e8698..f525578 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2712,10 +2712,19 @@ css_next_child(struct cgroup_subsys_state *pos_css,
 				break;
 	}
 
-	if (&next->sibling == &cgrp->children)
-		return NULL;
+	/*
+	 * @next, if not pointing to the head, can be dereferenced and is
+	 * the next sibling; however, it might have @ss disabled.  If so,
+	 * fast-forward to the next enabled one.
+	 */
+	while (&next->sibling != &cgrp->children) {
+		struct cgroup_subsys_state *next_css = cgroup_css(next, parent_css->ss);
 
-	return cgroup_css(next, parent_css->ss);
+		if (next_css)
+			return next_css;
+		next = list_entry_rcu(next->sibling.next, struct cgroup, sibling);
+	}
+	return NULL;
 }
 
 /**
-- 
1.9.0
