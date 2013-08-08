From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/14] cgroup: rename cgroup_subsys_state->dput_work and its
	callback function
Date: Thu,  8 Aug 2013 16:13:39 -0400
Message-ID: <1375992831-4650-3-git-send-email-tj@kernel.org>
References: <1375992831-4650-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375992831-4650-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

css (cgroup_subsys_state) will become RCU protected and there will be
two stages which require punting to work item during release.  To
prepare for using the work item for multiple times, rename
css->dput_work to css->destroy_work and css_dput_fn() to
css_free_work_fn() and move work item initialization from css init to
right before the actual usage.

This reorganization doesn't introduce any behavior change.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  2 +-
 kernel/cgroup.c        | 21 ++++++++++-----------
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8ec5b0f..12d66fe 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -80,7 +80,7 @@ struct cgroup_subsys_state {
 	struct css_id __rcu *id;
 
 	/* Used to put @cgroup->dentry on the last css_put() */
-	struct work_struct dput_work;
+	struct work_struct destroy_work;
 };
 
 /* bits in struct cgroup_subsys_state flags field */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 49ad96e..0b28097 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4259,10 +4259,10 @@ err:
 	return ret;
 }
 
-static void css_dput_fn(struct work_struct *work)
+static void css_free_work_fn(struct work_struct *work)
 {
 	struct cgroup_subsys_state *css =
-		container_of(work, struct cgroup_subsys_state, dput_work);
+		container_of(work, struct cgroup_subsys_state, destroy_work);
 
 	cgroup_dput(css->cgroup);
 }
@@ -4272,7 +4272,14 @@ static void css_release(struct percpu_ref *ref)
 	struct cgroup_subsys_state *css =
 		container_of(ref, struct cgroup_subsys_state, refcnt);
 
-	schedule_work(&css->dput_work);
+	/*
+	 * css holds an extra ref to @cgrp->dentry which is put on the last
+	 * css_put().  dput() requires process context, which css_put() may
+	 * be called without.  @css->destroy_work will be used to invoke
+	 * dput() asynchronously from css_put().
+	 */
+	INIT_WORK(&css->destroy_work, css_free_work_fn);
+	schedule_work(&css->destroy_work);
 }
 
 static void init_cgroup_css(struct cgroup_subsys_state *css,
@@ -4287,14 +4294,6 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 		css->flags |= CSS_ROOT;
 	BUG_ON(cgroup_css(cgrp, ss->subsys_id));
 	cgrp->subsys[ss->subsys_id] = css;
-
-	/*
-	 * css holds an extra ref to @cgrp->dentry which is put on the last
-	 * css_put().  dput() requires process context, which css_put() may
-	 * be called without.  @css->dput_work will be used to invoke
-	 * dput() asynchronously from css_put().
-	 */
-	INIT_WORK(&css->dput_work, css_dput_fn);
 }
 
 /* invoke ->css_online() on a new CSS and mark it online if successful */
-- 
1.8.3.1
