From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 05/23] cgroup: add subsystem pointer to cgroup_subsys_state
Date: Thu,  1 Aug 2013 17:49:43 -0400
Message-ID: <1375393801-4817-6-git-send-email-tj@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Currently, given a cgroup_subsys_state, there's no way to find out
which subsystem the css is for, which we'll need to convert the cgroup
controller API to primarily use @css instead of @cgroup.  This patch
adds cgroup_subsys_state->ss which points to the subsystem the @css
belongs to.

While at it, remove the comment about accessing @css->cgroup to
determine the hierarchy.  cgroup core will provide API to traverse
hierarchy of css'es and we don't want subsystems to directly walk
cgroup hierarchies anymore.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 9 ++++-----
 kernel/cgroup.c        | 1 +
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1938292..9c2f9d7 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -66,13 +66,12 @@ enum cgroup_subsys_id {
 
 /* Per-subsystem/per-cgroup state maintained by the system. */
 struct cgroup_subsys_state {
-	/*
-	 * The cgroup that this subsystem is attached to. Useful
-	 * for subsystems that want to know about the cgroup
-	 * hierarchy structure
-	 */
+	/* the cgroup that this css is attached to */
 	struct cgroup *cgroup;
 
+	/* the cgroup subsystem that this css is attached to */
+	struct cgroup_subsys *ss;
+
 	/* reference count - access via css_[try]get() and css_put() */
 	struct percpu_ref refcnt;
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 9d5af91..fad5498 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4179,6 +4179,7 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 			       struct cgroup *cgrp)
 {
 	css->cgroup = cgrp;
+	css->ss = ss;
 	css->flags = 0;
 	css->id = NULL;
 	if (cgrp == cgroup_dummy_top)
-- 
1.8.3.1
