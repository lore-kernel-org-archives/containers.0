From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/24] cfq-iosched: Print sync-noidle information in blktrace
	messages
Date: Fri, 28 Dec 2012 12:35:28 -0800
Message-ID: <1356726946-26037-7-git-send-email-tj@kernel.org>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1356726946-26037-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Currently we attach a character "S" or "A" to the cfqq<pid>, to represent
whether queues is sync or async. Add one more character "N" to represent
whether it is sync-noidle queue or sync queue. So now three different
type of queues will look as follows.

cfq1234S   --> sync queus
cfq1234SN  --> sync noidle queue
cfq1234A   --> Async queue

Previously S/A classification was being printed only if group scheduling
was enabled. This patch also makes sure that this classification is
displayed even if group idling is disabled.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/cfq-iosched.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 5ad4cae..bc076f4 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -586,8 +586,9 @@ static inline void cfqg_put(struct cfq_group *cfqg)
 	char __pbuf[128];						\
 									\
 	blkg_path(cfqg_to_blkg((cfqq)->cfqg), __pbuf, sizeof(__pbuf));	\
-	blk_add_trace_msg((cfqd)->queue, "cfq%d%c %s " fmt, (cfqq)->pid, \
-			  cfq_cfqq_sync((cfqq)) ? 'S' : 'A',		\
+	blk_add_trace_msg((cfqd)->queue, "cfq%d%c%c %s " fmt, (cfqq)->pid, \
+			cfq_cfqq_sync((cfqq)) ? 'S' : 'A',		\
+			cfqq_type((cfqq)) == SYNC_NOIDLE_WORKLOAD ? 'N' : ' ',\
 			  __pbuf, ##args);				\
 } while (0)
 
@@ -675,7 +676,10 @@ static inline void cfqg_get(struct cfq_group *cfqg) { }
 static inline void cfqg_put(struct cfq_group *cfqg) { }
 
 #define cfq_log_cfqq(cfqd, cfqq, fmt, args...)	\
-	blk_add_trace_msg((cfqd)->queue, "cfq%d " fmt, (cfqq)->pid, ##args)
+	blk_add_trace_msg((cfqd)->queue, "cfq%d%c%c " fmt, (cfqq)->pid,	\
+			cfq_cfqq_sync((cfqq)) ? 'S' : 'A',		\
+			cfqq_type((cfqq)) == SYNC_NOIDLE_WORKLOAD ? 'N' : ' ',\
+				##args)
 #define cfq_log_cfqg(cfqd, cfqg, fmt, args...)		do {} while (0)
 
 static inline void cfqg_stats_update_io_add(struct cfq_group *cfqg,
-- 
1.8.0.2
