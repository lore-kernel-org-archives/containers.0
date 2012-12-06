From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2] cgroup_rm_file: don't delete the uncreated files
Date: Thu, 6 Dec 2012 14:38:57 +0800
Message-ID: <1354775937-2625-1-git-send-email-gaofeng__39126.2703262784$1354775973$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

in cgroup_add_file,when creating files for cgroup,
some of creation may be skipped. So we need to avoid
deleting these uncreated files in cgroup_rm_file,
otherwise the warning msg will be triggered.

"cgroup_addrm_files: failed to remove memory_pressure_enabled, err=-2"

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5cc3724..f34c41b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2724,12 +2724,6 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 
 	simple_xattrs_init(&cft->xattrs);
 
-	/* does @cft->flags tell us to skip creation on @cgrp? */
-	if ((cft->flags & CFTYPE_NOT_ON_ROOT) && !cgrp->parent)
-		return 0;
-	if ((cft->flags & CFTYPE_ONLY_ON_ROOT) && cgrp->parent)
-		return 0;
-
 	if (subsys && !test_bit(ROOT_NOPREFIX, &cgrp->root->flags)) {
 		strcpy(name, subsys->name);
 		strcat(name, ".");
@@ -2770,6 +2764,12 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 	int err, ret = 0;
 
 	for (cft = cfts; cft->name[0] != '\0'; cft++) {
+		/* does cft->flags tell us to skip this file on @cgrp? */
+		if ((cft->flags & CFTYPE_NOT_ON_ROOT) && !cgrp->parent)
+			continue;
+		if ((cft->flags & CFTYPE_ONLY_ON_ROOT) && cgrp->parent)
+			continue;
+
 		if (is_add)
 			err = cgroup_add_file(cgrp, subsys, cft);
 		else
-- 
1.7.7.6
