From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH for-3.5] cgroup: remove cgroup_subsys->populate()
Date: Tue, 10 Apr 2012 10:16:36 -0700
Message-ID: <20120410171636.GB21311__34608.8062193759$1334078214$gmane$org@dhcp-172-17-108-109.mtv.corp.google.com>
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
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

With memcg converted, cgroup_subsys->populate() doesn't have any user
left.  Remove it.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
Li, can you please ack this?  Thanks.

 include/linux/cgroup.h |    1 -
 kernel/cgroup.c        |    3 ---
 2 files changed, 4 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 565c803..d3f5fba 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -472,7 +472,6 @@ struct cgroup_subsys {
 	void (*fork)(struct task_struct *task);
 	void (*exit)(struct cgroup *cgrp, struct cgroup *old_cgrp,
 		     struct task_struct *task);
-	int (*populate)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*post_clone)(struct cgroup *cgrp);
 	void (*bind)(struct cgroup *root);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2905977..b2f203f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3842,9 +3842,6 @@ static int cgroup_populate_dir(struct cgroup *cgrp)
 	for_each_subsys(cgrp->root, ss) {
 		struct cftype_set *set;
 
-		if (ss->populate && (err = ss->populate(ss, cgrp)) < 0)
-			return err;
-
 		list_for_each_entry(set, &ss->cftsets, node)
 			cgroup_addrm_files(cgrp, ss, set->cfts, true);
 	}
