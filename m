From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/23] hugetlb_cgroup: pass around @hugetlb_cgroup instead of
	@cgroup
Date: Thu,  1 Aug 2013 17:49:42 -0400
Message-ID: <1375393801-4817-5-git-send-email-tj@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup controller API will be converted to primarily use struct
cgroup_subsys_state instead of struct cgroup.  In preparation, make
hugetlb_cgroup functions pass around struct hugetlb_cgroup instead of
struct cgroup.

This patch shouldn't cause any behavior differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
---
 mm/hugetlb_cgroup.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 50f213f..d2f9fc0 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -56,17 +56,19 @@ static inline bool hugetlb_cgroup_is_root(struct hugetlb_cgroup *h_cg)
 	return (h_cg == root_h_cgroup);
 }
 
-static inline struct hugetlb_cgroup *parent_hugetlb_cgroup(struct cgroup *cg)
+static inline struct hugetlb_cgroup *
+parent_hugetlb_cgroup(struct hugetlb_cgroup *h_cg)
 {
-	if (!cg->parent)
+	struct cgroup *parent = h_cg->css.cgroup->parent;
+
+	if (!parent)
 		return NULL;
-	return hugetlb_cgroup_from_cgroup(cg->parent);
+	return hugetlb_cgroup_from_cgroup(parent);
 }
 
-static inline bool hugetlb_cgroup_have_usage(struct cgroup *cg)
+static inline bool hugetlb_cgroup_have_usage(struct hugetlb_cgroup *h_cg)
 {
 	int idx;
-	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cg);
 
 	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
 		if ((res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE)) > 0)
@@ -115,15 +117,14 @@ static void hugetlb_cgroup_css_free(struct cgroup *cgroup)
  * page reference and test for page active here. This function
  * cannot fail.
  */
-static void hugetlb_cgroup_move_parent(int idx, struct cgroup *cgroup,
+static void hugetlb_cgroup_move_parent(int idx, struct hugetlb_cgroup *h_cg,
 				       struct page *page)
 {
 	int csize;
 	struct res_counter *counter;
 	struct res_counter *fail_res;
 	struct hugetlb_cgroup *page_hcg;
-	struct hugetlb_cgroup *h_cg   = hugetlb_cgroup_from_cgroup(cgroup);
-	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(cgroup);
+	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(h_cg);
 
 	page_hcg = hugetlb_cgroup_from_page(page);
 	/*
@@ -155,6 +156,7 @@ out:
  */
 static void hugetlb_cgroup_css_offline(struct cgroup *cgroup)
 {
+	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
 	struct hstate *h;
 	struct page *page;
 	int idx = 0;
@@ -163,13 +165,13 @@ static void hugetlb_cgroup_css_offline(struct cgroup *cgroup)
 		for_each_hstate(h) {
 			spin_lock(&hugetlb_lock);
 			list_for_each_entry(page, &h->hugepage_activelist, lru)
-				hugetlb_cgroup_move_parent(idx, cgroup, page);
+				hugetlb_cgroup_move_parent(idx, h_cg, page);
 
 			spin_unlock(&hugetlb_lock);
 			idx++;
 		}
 		cond_resched();
-	} while (hugetlb_cgroup_have_usage(cgroup));
+	} while (hugetlb_cgroup_have_usage(h_cg));
 }
 
 int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
-- 
1.8.3.1
