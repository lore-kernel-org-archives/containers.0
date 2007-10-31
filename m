From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] memory cgroup enhancements take 4 [4/8] remember
 "a page is on active list of cgroup or not"
Date: Wed, 31 Oct 2007 19:29:26 +0900
Message-ID: <20071031192926.4532ffcd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071031192213.4f736fac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071031192213.4f736fac.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Remember page_cgroup is on active_list or not in page_cgroup->flags.

Against 2.6.23-mm1.

Changelog v2->v3
  - renamed #define PCGF_ACTIVE to PAGE_CGROUP_FLAG_ACTIVE.
Changelog v1->v2
  - moved #define to out-side of struct definition

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Signed-off-by: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

 mm/memcontrol.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Index: devel-2.6.23-mm1/mm/memcontrol.c
===================================================================
--- devel-2.6.23-mm1.orig/mm/memcontrol.c
+++ devel-2.6.23-mm1/mm/memcontrol.c
@@ -86,6 +86,7 @@ struct page_cgroup {
 	int	 flags;
 };
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
+#define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
 
 enum {
 	MEM_CGROUP_TYPE_UNSPEC = 0,
@@ -213,10 +214,13 @@ clear_page_cgroup(struct page *page, str
 
 static void __mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
 {
-	if (active)
+	if (active) {
+		pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
 		list_move(&pc->lru, &pc->mem_cgroup->active_list);
-	else
+	} else {
+		pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
 		list_move(&pc->lru, &pc->mem_cgroup->inactive_list);
+	}
 }
 
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
@@ -425,7 +429,7 @@ noreclaim:
 	atomic_set(&pc->ref_cnt, 1);
 	pc->mem_cgroup = mem;
 	pc->page = page;
-	pc->flags = 0;
+	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
 		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
 	if (page_cgroup_assign_new_page_cgroup(page, pc)) {
