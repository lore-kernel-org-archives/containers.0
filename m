From: Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] memcg: move page-freeing code out of lock
Date: Wed, 23 Mar 2011 20:59:18 +0900
Message-ID: <1300881558-13523-1-git-send-email-namhyung__43624.3503507741$1300881713$gmane$org@gmail.com>
References: <20110323133614.95553de8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110323133614.95553de8.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Move page-freeing code out of swap_cgroup_mutex in the hope that it
could reduce few of theoretical contentions between swapons and/or
swapoffs.

This is just a cleanup, no functional changes.

Signed-off-by: Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 mm/page_cgroup.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 29951abc852e..17eb5eb95bab 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -463,8 +463,8 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
 		/* memory shortage */
 		ctrl->map = NULL;
 		ctrl->length = 0;
-		vfree(array);
 		mutex_unlock(&swap_cgroup_mutex);
+		vfree(array);
 		goto nomem;
 	}
 	mutex_unlock(&swap_cgroup_mutex);
@@ -479,7 +479,8 @@ nomem:
 
 void swap_cgroup_swapoff(int type)
 {
-	int i;
+	struct page **map;
+	unsigned long i, length;
 	struct swap_cgroup_ctrl *ctrl;
 
 	if (!do_swap_account)
@@ -487,17 +488,20 @@ void swap_cgroup_swapoff(int type)
 
 	mutex_lock(&swap_cgroup_mutex);
 	ctrl = &swap_cgroup_ctrl[type];
-	if (ctrl->map) {
-		for (i = 0; i < ctrl->length; i++) {
-			struct page *page = ctrl->map[i];
+	map = ctrl->map;
+	length = ctrl->length;
+	ctrl->map = NULL;
+	ctrl->length = 0;
+	mutex_unlock(&swap_cgroup_mutex);
+
+	if (map) {
+		for (i = 0; i < length; i++) {
+			struct page *page = map[i];
 			if (page)
 				__free_page(page);
 		}
-		vfree(ctrl->map);
-		ctrl->map = NULL;
-		ctrl->length = 0;
+		vfree(map);
 	}
-	mutex_unlock(&swap_cgroup_mutex);
 }
 
 #endif
-- 
1.7.4
