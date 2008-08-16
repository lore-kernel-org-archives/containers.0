From: "IKEDA, Munehiro" <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH] cgroup: memory.force_empty can make system slowdown
Date: Fri, 15 Aug 2008 22:26:25 -0400
Message-ID: <48A63AD1.3010907__15601.2101019316$1218854073$gmane$org@ds.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Cgroup's memory controller has a control file "memory.force_empty"
to reset usage account charged to a cgroup.  The account shouldn't
be reset if one or more processes are attached to the cgroup (at
least for memory controller, IMHO).  So mem_cgroup_force_empty()
is implemented to return -EBUSY and do nothing if so.
However, cgroup on hierarchy root faultily might be a exception.
Even if processes are attached to root cgroup (which is a "default"
cgroup for processes), forcing-empty can run by writing something to
memory.force_empty and it'll never end.

Following patch prevents this issue.

This patch is for cgroup infrastructure code.  The issue can be
measured by modifying memory controller code also, namely to change
mem_cgroup_force_empty() to see CSS_ROOT bit of css->flags.
I believe cgroup->count approach like the patch below is rather
generic and reasonable, how does that sound?

Paul, Balbir?



Signed-off-by: Munehiro "Muuhh" Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>

diff -uNrp linux-2.6.27-rc3.orig/kernel/cgroup.c linux-2.6.27-rc3/kernel/cgroup.c
--- linux-2.6.27-rc3.orig/kernel/cgroup.c	2008-08-12 21:55:39.000000000 -0400
+++ linux-2.6.27-rc3/kernel/cgroup.c	2008-08-15 20:52:52.000000000 -0400
@@ -2264,8 +2264,10 @@ static void init_cgroup_css(struct cgrou
 	css->cgroup = cgrp;
 	atomic_set(&css->refcnt, 0);
 	css->flags = 0;
-	if (cgrp == dummytop)
+	if (cgrp == dummytop) {
 		set_bit(CSS_ROOT, &css->flags);
+		atomic_set(&css->cgroup->count, 1);
+	}
 	BUG_ON(cgrp->subsys[ss->subsys_id]);
 	cgrp->subsys[ss->subsys_id] = css;
 }



-- 
IKEDA, Munehiro
  NEC Corporation of America
    m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
