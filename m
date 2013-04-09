From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/3] perf: make perf_event cgroup hierarchical
Date: Mon,  8 Apr 2013 19:23:33 -0700
Message-ID: <1365474213-13354-4-git-send-email-tj@kernel.org>
References: <1365474213-13354-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365474213-13354-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: namhyung.kim-Hm3cg6mZ9cc@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

perf_event is one of a couple remaining cgroup controllers with broken
hierarchy support.  Converting it to support hierarchy is almost
trivial.  The only thing necessary is to consider a task belonging to
a descendant cgroup as a match.  IOW, if the cgroup of the currently
executing task (@cpuctx->cgrp) equals or is a descendant of the
event's cgroup (@event->cgrp), then the event should be enabled.

Implement hierarchy support and remove .broken_hierarchy tag along
with the incorrect comment on what needs to be done for hierarchy
support.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
Cc: Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Namhyung Kim <namhyung.kim-Hm3cg6mZ9cc@public.gmane.org>
---
 kernel/events/core.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index b0cd865..310ec19 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -251,7 +251,22 @@ perf_cgroup_match(struct perf_event *event)
 	struct perf_event_context *ctx = event->ctx;
 	struct perf_cpu_context *cpuctx = __get_cpu_context(ctx);
 
-	return !event->cgrp || event->cgrp == cpuctx->cgrp;
+	/* @event doesn't care about cgroup */
+	if (!event->cgrp)
+		return true;
+
+	/* wants specific cgroup scope but @cpuctx isn't associated with any */
+	if (!cpuctx->cgrp)
+		return false;
+
+	/*
+	 * Cgroup scoping is recursive.  An event enabled for a cgroup is
+	 * also enabled for all its descendant cgroups.  If @cpuctx's
+	 * cgroup is a descendant of @event's (the test covers identity
+	 * case), it's a match.
+	 */
+	return cgroup_is_descendant(cpuctx->cgrp->css.cgroup,
+				    event->cgrp->css.cgroup);
 }
 
 static inline bool perf_tryget_cgroup(struct perf_event *event)
@@ -7509,12 +7524,5 @@ struct cgroup_subsys perf_subsys = {
 	.css_free	= perf_cgroup_css_free,
 	.exit		= perf_cgroup_exit,
 	.attach		= perf_cgroup_attach,
-
-	/*
-	 * perf_event cgroup doesn't handle nesting correctly.
-	 * ctx->nr_cgroups adjustments should be propagated through the
-	 * cgroup hierarchy.  Fix it and remove the following.
-	 */
-	.broken_hierarchy = true,
 };
 #endif /* CONFIG_CGROUP_PERF */
-- 
1.8.1.4
