From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [patch] cgroup: move assignement out of condition in
	cgroup_attach_proc()
Date: Wed, 4 Jan 2012 10:24:29 +0300
Message-ID: <20120104072429.GF30978__1025.30074441365$1325661892$gmane$org@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Gcc complains about this: "kernel/cgroup.c:2179:4: warning: suggest
parentheses around assignment used as truth value [-Wparentheses]"

Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
I feel like the original developer may have left the parens out on
deliberately to stop checkpatch.pl complaining about long lines.  I so
much hate the long line warning...

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index cb3c131..6a057fe 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2175,9 +2175,12 @@ static int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 		oldcg = tc->task->cgroups;
 
 		/* if we don't already have it in the list get a new one */
-		if (!css_set_check_fetched(cgrp, tc->task, oldcg, &newcg_list))
-			if (retval = css_set_prefetch(cgrp, oldcg, &newcg_list))
+		if (!css_set_check_fetched(cgrp, tc->task, oldcg,
+					&newcg_list)) {
+			retval = css_set_prefetch(cgrp, oldcg, &newcg_list);
+			if (retval)
 				goto out_list_teardown;
+		}
 	}
 
 	/*
