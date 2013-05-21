From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/5] cgroup: make cgroup_is_removed() static
Date: Tue, 21 May 2013 10:50:22 +0900
Message-ID: <1369101025-28335-3-git-send-email-tj__13262.1860517704$1369101061$gmane$org@kernel.org>
References: <1369101025-28335-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1369101025-28335-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_is_removed() no longer has external users and it shouldn't grow
any - controllers should deal with cgroup_subsys_state on/offline
state instead of cgroup removal state.  Make it static.

While at it, make it return bool.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 1 -
 kernel/cgroup.c        | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1df5f69..8d9f3c9 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -538,7 +538,6 @@ static inline const char *cgroup_name(const struct cgroup *cgrp)
 int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts);
 int cgroup_rm_cftypes(struct cgroup_subsys *ss, struct cftype *cfts);
 
-int cgroup_is_removed(const struct cgroup *cgrp);
 bool cgroup_is_descendant(struct cgroup *cgrp, struct cgroup *ancestor);
 
 int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f20f80c..3222f93 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -226,7 +226,7 @@ static int css_refcnt(struct cgroup_subsys_state *css)
 }
 
 /* convenient tests for these bits */
-inline int cgroup_is_removed(const struct cgroup *cgrp)
+static inline bool cgroup_is_removed(const struct cgroup *cgrp)
 {
 	return test_bit(CGRP_REMOVED, &cgrp->flags);
 }
-- 
1.8.1.4
