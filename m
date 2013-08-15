From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH cgroup/for-3.12 2/2] cgroup: fix cgroup_write_event_control()
Date: Thu, 15 Aug 2013 11:43:15 -0400
Message-ID: <20130815154315.GH14606__8158.83756517923$1376581410$gmane$org@htj.dyndns.org>
References: <20130815154236.GG14606@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130815154236.GG14606-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From ced043264c9c3f03ab3c992af17461db50421dd8 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Thu, 15 Aug 2013 11:37:54 -0400

81eeaf0411 ("cgroup: make cftype->[un]register_event() deal with
cgroup_subsys_state inst ead of cgroup") updated the cftype event
methods to take @css (cgroup_subsys_state) instead of @cgroup;
however, it incorrectly used @css passed to
cgroup_write_event_control(), which the dummy_css for the cgroup as
the file is a cgroup core file.  This leads to oops on event
registration.

Fix it by using the css matching the event target file.  Note that
cgroup_write_event_control() now disallows cgroup core files from
being event sources.  This is for simplicity and doesn't matter as
cgroup_event will be moved and made specific to memcg.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ab2a23f..6499004 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4040,10 +4040,10 @@ static void cgroup_event_ptable_queue_proc(struct file *file,
  * Input must be in format '<event_fd> <control_fd> <args>'.
  * Interpretation of args is defined by control file implementation.
  */
-static int cgroup_write_event_control(struct cgroup_subsys_state *css,
+static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 				      struct cftype *cft, const char *buffer)
 {
-	struct cgroup *cgrp = css->cgroup;
+	struct cgroup *cgrp = dummy_css->cgroup;
 	struct cgroup_event *event;
 	struct cgroup *cgrp_cfile;
 	unsigned int efd, cfd;
@@ -4065,7 +4065,7 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 	event = kzalloc(sizeof(*event), GFP_KERNEL);
 	if (!event)
 		return -ENOMEM;
-	event->css = css;
+
 	INIT_LIST_HEAD(&event->list);
 	init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
 	init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
@@ -4101,6 +4101,23 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 		goto out_put_cfile;
 	}
 
+	if (!event->cft->ss) {
+		ret = -EBADF;
+		goto out_put_cfile;
+	}
+
+	/* determine the css of @cfile and associate @event with it */
+	rcu_read_lock();
+
+	ret = -EINVAL;
+	event->css = cgroup_css(cgrp, event->cft->ss->subsys_id);
+	if (event->css)
+		ret = 0;
+
+	rcu_read_unlock();
+	if (ret)
+		goto out_put_cfile;
+
 	/*
 	 * The file to be monitored must be in the same cgroup as
 	 * cgroup.event_control is.
@@ -4116,7 +4133,7 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 		goto out_put_cfile;
 	}
 
-	ret = event->cft->register_event(css, event->cft,
+	ret = event->cft->register_event(event->css, event->cft,
 			event->eventfd, buffer);
 	if (ret)
 		goto out_put_cfile;
-- 
1.8.3.1
