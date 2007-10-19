From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: [RFC][PATCH] memory cgroup enhancements updated [7/10] RSS/CACHE
 failcnt
Date: Fri, 19 Oct 2007 18:34:52 +0900
Message-ID: <20071019183452.3b7057ca.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071019182436.485e20cd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071019182436.485e20cd.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

cgroup's resource has "failure" counter. But I think memory cgroup
has 2 types of failure
	- failure of cache
	- failure of RSS

This patch adds above 2 information to stat file.
Above information is shown in "byte". But I wonder showing just counter
is better o not...rather than PAGE_SIZE.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>


 mm/memcontrol.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

Index: devel-2.6.23-mm1/mm/memcontrol.c
===================================================================
--- devel-2.6.23-mm1.orig/mm/memcontrol.c
+++ devel-2.6.23-mm1/mm/memcontrol.c
@@ -50,6 +50,11 @@ enum mem_cgroup_stat_index {
 	 */
 	MEM_CGROUP_STAT_ACTIVE,	   /* # of pages in active list */
 	MEM_CGROUP_STAT_INACTIVE,  /* # of pages on inactive list */
+	/*
+	 * precise failcnt
+	 */
+	MEM_CGROUP_STAT_FAIL_RSS,  /* # of failure in RSS charging */
+	MEM_CGROUP_STAT_FAIL_CACHE,/* # of failure in CACHE charging */
 
 	MEM_CGROUP_STAT_NSTATS,
 };
@@ -486,6 +491,12 @@ retry:
 	 */
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		bool is_atomic = gfp_mask & GFP_ATOMIC;
+		if (is_cache)
+			mem_cgroup_stat_inc(&mem->stat,
+				MEM_CGROUP_STAT_FAIL_CACHE);
+		else
+			mem_cgroup_stat_inc(&mem->stat,
+				MEM_CGROUP_STAT_FAIL_RSS);
 		/*
 		 * We cannot reclaim under GFP_ATOMIC, fail the charge
 		 */
@@ -850,6 +861,8 @@ static const struct mem_cgroup_stat_desc
 	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
 	[MEM_CGROUP_STAT_ACTIVE] = { "active", PAGE_SIZE, },
 	[MEM_CGROUP_STAT_INACTIVE] = { "inactive", PAGE_SIZE, },
+	[MEM_CGROUP_STAT_FAIL_RSS] = { "rss_failure", PAGE_SIZE, },
+	[MEM_CGROUP_STAT_FAIL_CACHE] = { "cache_failure", PAGE_SIZE, },
 };
 
 static int mem_control_stat_show(struct seq_file *m, void *arg)
