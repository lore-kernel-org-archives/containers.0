From: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 5/6 mm] memcgroup: fix zone isolation OOM
Date: Fri, 9 Nov 2007 07:13:22 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0711090712180.21663@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0711090700530.21638-VFT1Jj/mpSzq8/QPP7pA5326JSxr+BKB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

mem_cgroup_charge_common shows a tendency to OOM without good reason,
when a memhog goes well beyond its rss limit but with plenty of swap
available.  Seen on x86 but not on PowerPC; seen when the next patch
omits swapcache from memcgroup, but we presume it can happen without.

mem_cgroup_isolate_pages is not quite satisfying reclaim's criteria
for OOM avoidance.  Already it has to scan beyond the nr_to_scan limit
when it finds a !LRU page or an active page when handling inactive or
an inactive page when handling active.  It needs to do exactly the same
when it finds a page from the wrong zone (the x86 tests had two zones,
the PowerPC tests had only one).

Don't increment scan and then decrement it in these cases, just move
the incrementation down.  Fix recent off-by-one when checking against
nr_to_scan.  Cut out "Check if the meta page went away from under us",
presumably left over from early debugging: no amount of such checks
could save us if this list really were being updated without locking.

This change does make the unlimited scan while holding two spinlocks
even worse - bad for latency and bad for containment; but that's a
separate issue which is better left to be fixed a little later.

Signed-off-by: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
---
Insert just after bugfix-for-memory-cgroup-controller-avoid-pagelru-page-in-mem_cgroup_isolate_pages-fix.patch
or just before memory-cgroup-enhancements

 mm/memcontrol.c |   17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

--- patch4/mm/memcontrol.c	2007-11-08 16:03:33.000000000 +0000
+++ patch5/mm/memcontrol.c	2007-11-08 16:51:39.000000000 +0000
@@ -260,24 +260,20 @@ unsigned long mem_cgroup_isolate_pages(u
 	spin_lock(&mem_cont->lru_lock);
 	scan = 0;
 	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
-		if (scan++ > nr_to_scan)
+		if (scan >= nr_to_scan)
 			break;
 		page = pc->page;
 		VM_BUG_ON(!pc);
 
-		if (unlikely(!PageLRU(page))) {
-			scan--;
+		if (unlikely(!PageLRU(page)))
 			continue;
-		}
 
 		if (PageActive(page) && !active) {
 			__mem_cgroup_move_lists(pc, true);
-			scan--;
 			continue;
 		}
 		if (!PageActive(page) && active) {
 			__mem_cgroup_move_lists(pc, false);
-			scan--;
 			continue;
 		}
 
@@ -288,13 +284,8 @@ unsigned long mem_cgroup_isolate_pages(u
 		if (page_zone(page) != z)
 			continue;
 
-		/*
-		 * Check if the meta page went away from under us
-		 */
-		if (!list_empty(&pc->lru))
-			list_move(&pc->lru, &pc_list);
-		else
-			continue;
+		scan++;
+		list_move(&pc->lru, &pc_list);
 
 		if (__isolate_lru_page(page, mode) == 0) {
 			list_move(&page->lru, dst);
