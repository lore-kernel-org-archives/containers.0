From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/24] cfq-iosched: Rename few functions related to selecting
	workload
Date: Fri, 28 Dec 2012 12:35:26 -0800
Message-ID: <1356726946-26037-5-git-send-email-tj@kernel.org>
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

choose_service_tree() selects/sets both wl_class and wl_type.  Rename it to
choose_wl_class_and_type() to make it very clear.

cfq_choose_wl() only selects and sets wl_type. It is easy to confuse
it with choose_st(). So rename it to cfq_choose_wl_type() to make
it clear what does it do.

Just renaming. No functionality change.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/cfq-iosched.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index db4a1a5..e34e142 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -2490,7 +2490,7 @@ static void cfq_setup_merge(struct cfq_queue *cfqq, struct cfq_queue *new_cfqq)
 	}
 }
 
-static enum wl_type_t cfq_choose_wl(struct cfq_data *cfqd,
+static enum wl_type_t cfq_choose_wl_type(struct cfq_data *cfqd,
 			struct cfq_group *cfqg, enum wl_class_t wl_class)
 {
 	struct cfq_queue *queue;
@@ -2513,7 +2513,8 @@ static enum wl_type_t cfq_choose_wl(struct cfq_data *cfqd,
 	return cur_best;
 }
 
-static void choose_service_tree(struct cfq_data *cfqd, struct cfq_group *cfqg)
+static void
+choose_wl_class_and_type(struct cfq_data *cfqd, struct cfq_group *cfqg)
 {
 	unsigned slice;
 	unsigned count;
@@ -2551,7 +2552,7 @@ static void choose_service_tree(struct cfq_data *cfqd, struct cfq_group *cfqg)
 
 new_workload:
 	/* otherwise select new workload type */
-	cfqd->serving_wl_type = cfq_choose_wl(cfqd, cfqg,
+	cfqd->serving_wl_type = cfq_choose_wl_type(cfqd, cfqg,
 					cfqd->serving_wl_class);
 	st = st_for(cfqg, cfqd->serving_wl_class, cfqd->serving_wl_type);
 	count = st->count;
@@ -2621,7 +2622,7 @@ static void cfq_choose_cfqg(struct cfq_data *cfqd)
 	} else
 		cfqd->workload_expires = jiffies - 1;
 
-	choose_service_tree(cfqd, cfqg);
+	choose_wl_class_and_type(cfqd, cfqg);
 }
 
 /*
-- 
1.8.0.2
