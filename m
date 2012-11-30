From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 1/2] cgroup: use cgroup_addrm_files in cgroup_clear_directory
Date: Sat, 1 Dec 2012 00:21:28 +0800
Message-ID: <1354292489-18434-1-git-send-email-gaofeng__44138.7067585767$1354297838$gmane$org@cn.fujitsu.com>
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
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_rm_file only remove the first file. after remount,
the cgroup subsystem will be unloaded with it's files left.

use cgroup_addrm_files to remove all files of subsystem.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f24f724..e5233b7 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -970,6 +970,8 @@ static int cgroup_rm_file(struct cgroup *cgrp, const struct cftype *cft)
 	return -ENOENT;
 }
 
+static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
+			      struct cftype cfts[], bool is_add);
 /**
  * cgroup_clear_directory - selective removal of base and subsystem files
  * @dir: directory containing the files
@@ -987,7 +989,7 @@ static void cgroup_clear_directory(struct dentry *dir, bool base_files,
 		if (!test_bit(ss->subsys_id, &subsys_mask))
 			continue;
 		list_for_each_entry(set, &ss->cftsets, node)
-			cgroup_rm_file(cgrp, set->cfts);
+			cgroup_addrm_files(cgrp, NULL, set->cfts, false);
 	}
 	if (base_files) {
 		while (!list_empty(&cgrp->files))
-- 
1.7.7.6
