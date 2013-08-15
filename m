From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/12] memcg: cgroup_write_event_control() now knows @css is
	for memcg
Date: Thu, 15 Aug 2013 12:02:25 -0400
Message-ID: <1376582550-12548-8-git-send-email-tj__28248.1469250799$1376582615$gmane$org@kernel.org>
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

@css for cgroup_write_event_control() is now always for memcg and the
target file should be a memcg file too.  Drop code which assumes @css
is dummy_css and the target file may belong to different subsystems.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 mm/memcontrol.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9e54932..ef75925 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6027,10 +6027,10 @@ static void cgroup_event_ptable_queue_proc(struct file *file,
  * Input must be in format '<event_fd> <control_fd> <args>'.
  * Interpretation of args is defined by control file implementation.
  */
-static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
+static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 				      struct cftype *cft, const char *buffer)
 {
-	struct cgroup *cgrp = dummy_css->cgroup;
+	struct cgroup *cgrp = css->cgroup;
 	struct cgroup_event *event;
 	struct cgroup_subsys_state *cfile_css;
 	unsigned int efd, cfd;
@@ -6053,6 +6053,7 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 	if (!event)
 		return -ENOMEM;
 
+	event->css = css;
 	INIT_LIST_HEAD(&event->list);
 	init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
 	init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
@@ -6088,23 +6089,16 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 		goto out_put_cfile;
 	}
 
-	if (!event->cft->ss) {
-		ret = -EBADF;
-		goto out_put_cfile;
-	}
-
 	/*
-	 * Determine the css of @cfile, verify it belongs to the same
-	 * cgroup as cgroup.event_control, and associate @event with it.
-	 * Remaining events are automatically removed on cgroup destruction
-	 * but the removal is asynchronous, so take an extra ref.
+	 * Verify @cfile should belong to @css.  Also, remaining events are
+	 * automatically removed on cgroup destruction but the removal is
+	 * asynchronous, so take an extra ref on @css.
 	 */
 	rcu_read_lock();
 
 	ret = -EINVAL;
-	event->css = cgroup_css(cgrp, event->cft->ss);
-	cfile_css = css_from_dir(cfile->f_dentry->d_parent, event->cft->ss);
-	if (event->css && event->css == cfile_css && css_tryget(event->css))
+	cfile_css = css_from_dir(cfile->f_dentry->d_parent, &mem_cgroup_subsys);
+	if (cfile_css == css && css_tryget(css))
 		ret = 0;
 
 	rcu_read_unlock();
@@ -6116,7 +6110,7 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 		goto out_put_css;
 	}
 
-	ret = event->cft->register_event(event->css, event->cft,
+	ret = event->cft->register_event(css, event->cft,
 			event->eventfd, buffer);
 	if (ret)
 		goto out_put_css;
@@ -6133,7 +6127,7 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 	return 0;
 
 out_put_css:
-	css_put(event->css);
+	css_put(css);
 out_put_cfile:
 	fput(cfile);
 out_put_eventfd:
-- 
1.8.3.1
