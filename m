From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 05/12] cgroup: make cgroup_write_event_control() use
	css_from_dir() instead of __d_cgrp()
Date: Thu, 15 Aug 2013 12:02:23 -0400
Message-ID: <1376582550-12548-6-git-send-email-tj__8509.73959682069$1376582605$gmane$org@kernel.org>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1376582550-12548-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_event will be moved to its only user - memcg.  Replace
__d_cgrp() usage with css_from_dir(), which is already exported.  This
also simplifies the code a bit.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3e34c1e..6deed8b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4041,7 +4041,7 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 {
 	struct cgroup *cgrp = dummy_css->cgroup;
 	struct cgroup_event *event;
-	struct cgroup *cgrp_cfile;
+	struct cgroup_subsys_state *cfile_css;
 	unsigned int efd, cfd;
 	struct file *efile;
 	struct file *cfile;
@@ -4103,7 +4103,8 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 	}
 
 	/*
-	 * Determine the css of @cfile and associate @event with it.
+	 * Determine the css of @cfile, verify it belongs to the same
+	 * cgroup as cgroup.event_control, and associate @event with it.
 	 * Remaining events are automatically removed on cgroup destruction
 	 * but the removal is asynchronous, so take an extra ref.
 	 */
@@ -4111,23 +4112,14 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 
 	ret = -EINVAL;
 	event->css = cgroup_css(cgrp, event->cft->ss);
-	if (event->css && css_tryget(event->css))
+	cfile_css = css_from_dir(cfile->f_dentry->d_parent, event->cft->ss);
+	if (event->css && event->css == cfile_css && css_tryget(event->css))
 		ret = 0;
 
 	rcu_read_unlock();
 	if (ret)
 		goto out_put_cfile;
 
-	/*
-	 * The file to be monitored must be in the same cgroup as
-	 * cgroup.event_control is.
-	 */
-	cgrp_cfile = __d_cgrp(cfile->f_dentry->d_parent);
-	if (cgrp_cfile != cgrp) {
-		ret = -EINVAL;
-		goto out_put_css;
-	}
-
 	if (!event->cft->register_event || !event->cft->unregister_event) {
 		ret = -EINVAL;
 		goto out_put_css;
-- 
1.8.3.1
