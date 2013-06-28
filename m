From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH cgroup/for-3.11 2/2] cgroup: CGRP_ROOT_SUBSYS_BOUND should be
	ignored when comparing mount options
Date: Thu, 27 Jun 2013 19:40:03 -0700
Message-ID: <20130628024003.GB2500__24811.0547232956$1372387216$gmane$org@htj.dyndns.org>
References: <20130628023930.GA2500@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130628023930.GA2500-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

From 0ce6cba35777cf96a54ce0d5856dc962566b8717 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Thu, 27 Jun 2013 19:37:26 -0700

1672d04070 ("cgroup: fix cgroupfs_root early destruction path")
introduced CGRP_ROOT_SUBSYS_BOUND which is used to mark completion of
subsys binding on a new root; however, this broke remounts.
cgroup_remount() doesn't allow changing root options via remount and
CGRP_ROOT_SUBSYS_BOUND, which is set on all fully initialized roots,
makes the function reject all remounts.

Fix it by putting the options part in the lower 16 bits of root->flags
and masking the comparions.  While at it, make cgroup_remount() emit
an error message explaining why it's rejecting a remount request, so
that it's less of a mystery.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 6 +++++-
 kernel/cgroup.c        | 5 ++++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index ad3555b..8db5397 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -276,7 +276,11 @@ enum {
 
 	CGRP_ROOT_NOPREFIX	= (1 << 1), /* mounted subsystems have no named prefix */
 	CGRP_ROOT_XATTR		= (1 << 2), /* supports extended attributes */
-	CGRP_ROOT_SUBSYS_BOUND	= (1 << 3), /* subsystems finished binding */
+
+	/* mount options live below bit 16 */
+	CGRP_ROOT_OPTION_MASK	= (1 << 16) - 1,
+
+	CGRP_ROOT_SUBSYS_BOUND	= (1 << 16), /* subsystems finished binding */
 };
 
 /*
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1b7b567..5a2fcf5 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1362,8 +1362,11 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	removed_mask = root->subsys_mask & ~opts.subsys_mask;
 
 	/* Don't allow flags or name to change at remount */
-	if (opts.flags != root->flags ||
+	if (((opts.flags ^ root->flags) & CGRP_ROOT_OPTION_MASK) ||
 	    (opts.name && strcmp(opts.name, root->name))) {
+		pr_err("cgroup: option or name mismatch, new: 0x%lx \"%s\", old: 0x%lx \"%s\"\n",
+		       opts.flags & CGRP_ROOT_OPTION_MASK, opts.name ?: "",
+		       root->flags & CGRP_ROOT_OPTION_MASK, root->name);
 		ret = -EINVAL;
 		goto out_unlock;
 	}
-- 
1.8.3.1
