From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/2] cgroup: remove gratuituous BUG_ON()s from
	rebind_subsystems()
Date: Fri, 28 Jun 2013 21:13:05 -0700
Message-ID: <20130629041305.GB31353__20715.9211430282$1372479197$gmane$org@htj.dyndns.org>
References: <20130629041231.GA31353@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130629041231.GA31353-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From 9d47f1dd70a19b78a9da53e71fc1bf41e0300026 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Fri, 28 Jun 2013 21:08:27 -0700

rebind_subsystems() performs santiy checks even on subsystems which
aren't specified to be added or removed and the checks aren't all that
useful given that these are in a very cold path while the violations
they check would trip up in much hotter paths.

Let's remove these from rebind_subsystems().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a65aff1..864a4b2 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1071,15 +1071,6 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			/* subsystem is now free - drop reference on module */
 			module_put(ss->module);
 			root->subsys_mask &= ~bit;
-		} else if (bit & root->subsys_mask) {
-			/* Subsystem state should already exist */
-			BUG_ON(!cgrp->subsys[i]);
-#ifdef CONFIG_MODULE_UNLOAD
-			BUG_ON(ss->module && !module_refcount(ss->module));
-#endif
-		} else {
-			/* Subsystem state shouldn't exist */
-			BUG_ON(cgrp->subsys[i]);
 		}
 	}
 
-- 
1.8.3.1
