From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/12] cgroup: make cgroup_event hold onto cgroup_subsys_state
	instead of cgroup
Date: Thu, 15 Aug 2013 12:02:22 -0400
Message-ID: <1376582550-12548-5-git-send-email-tj__48624.9859598049$1376582637$gmane$org@kernel.org>
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

Currently, each registered cgroup_event holds an extra reference to
the cgroup.  This is a bit weird as events are subsystem specific and
will also be incorrect in the planned unified hierarchy as css
(cgroup_subsys_state) may come and go dynamically across the lifetime
of a cgroup.  Holding onto cgroup won't prevent the target css from
going away.

Update cgroup_event to hold onto the css the traget file belongs to
instead of cgroup.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 73d1c70..3e34c1e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3969,7 +3969,6 @@ static void cgroup_event_remove(struct work_struct *work)
 	struct cgroup_event *event = container_of(work, struct cgroup_event,
 			remove);
 	struct cgroup_subsys_state *css = event->css;
-	struct cgroup *cgrp = css->cgroup;
 
 	remove_wait_queue(event->wqh, &event->wait);
 
@@ -3980,7 +3979,7 @@ static void cgroup_event_remove(struct work_struct *work)
 
 	eventfd_ctx_put(event->eventfd);
 	kfree(event);
-	cgroup_dput(cgrp);
+	css_put(css);
 }
 
 /*
@@ -4103,12 +4102,16 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 		goto out_put_cfile;
 	}
 
-	/* determine the css of @cfile and associate @event with it */
+	/*
+	 * Determine the css of @cfile and associate @event with it.
+	 * Remaining events are automatically removed on cgroup destruction
+	 * but the removal is asynchronous, so take an extra ref.
+	 */
 	rcu_read_lock();
 
 	ret = -EINVAL;
 	event->css = cgroup_css(cgrp, event->cft->ss);
-	if (event->css)
+	if (event->css && css_tryget(event->css))
 		ret = 0;
 
 	rcu_read_unlock();
@@ -4122,28 +4125,21 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 	cgrp_cfile = __d_cgrp(cfile->f_dentry->d_parent);
 	if (cgrp_cfile != cgrp) {
 		ret = -EINVAL;
-		goto out_put_cfile;
+		goto out_put_css;
 	}
 
 	if (!event->cft->register_event || !event->cft->unregister_event) {
 		ret = -EINVAL;
-		goto out_put_cfile;
+		goto out_put_css;
 	}
 
 	ret = event->cft->register_event(event->css, event->cft,
 			event->eventfd, buffer);
 	if (ret)
-		goto out_put_cfile;
+		goto out_put_css;
 
 	efile->f_op->poll(efile, &event->pt);
 
-	/*
-	 * Events should be removed after rmdir of cgroup directory, but before
-	 * destroying subsystem state objects. Let's take reference to cgroup
-	 * directory dentry to do that.
-	 */
-	dget(cgrp->dentry);
-
 	spin_lock(&cgrp->event_list_lock);
 	list_add(&event->list, &cgrp->event_list);
 	spin_unlock(&cgrp->event_list_lock);
@@ -4153,6 +4149,8 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 
 	return 0;
 
+out_put_css:
+	css_put(event->css);
 out_put_cfile:
 	fput(cfile);
 out_put_eventfd:
-- 
1.8.3.1
