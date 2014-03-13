From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/11] cgroup: implement CFTYPE_ONLY_ON_DFL
Date: Thu, 13 Mar 2014 15:50:13 -0400
Message-ID: <1394740213-17626-12-git-send-email-tj__45088.1124510945$1394740347$gmane$org@kernel.org>
References: <1394740213-17626-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1394740213-17626-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

This cftype flag makes the file only appear on the default hierarchy.
This will later be used for cgroup.controllers file.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 1 +
 kernel/cgroup.c        | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 7e9fa50..43d1ed3 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -384,6 +384,7 @@ enum {
 	CFTYPE_NOT_ON_ROOT	= (1 << 1),	/* don't create on root cgrp */
 	CFTYPE_INSANE		= (1 << 2),	/* don't create if sane_behavior */
 	CFTYPE_NO_PREFIX	= (1 << 3),	/* (DON'T USE FOR NEW FILES) no subsys prefix */
+	CFTYPE_ONLY_ON_DFL	= (1 << 4),	/* only on default hierarchy */
 };
 
 #define MAX_CFTYPE_NAME		64
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c42230c..79e3573 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2356,6 +2356,8 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 
 	for (cft = cfts; cft->name[0] != '\0'; cft++) {
 		/* does cft->flags tell us to skip this file on @cgrp? */
+		if ((cft->flags & CFTYPE_ONLY_ON_DFL) && !cgroup_on_dfl(cgrp))
+			continue;
 		if ((cft->flags & CFTYPE_INSANE) && cgroup_sane_behavior(cgrp))
 			continue;
 		if ((cft->flags & CFTYPE_NOT_ON_ROOT) && !cgrp->parent)
-- 
1.8.5.3
