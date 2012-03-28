From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/21] blkcg: implement blkio_policy_type->cftypes
Date: Wed, 28 Mar 2012 15:51:20 -0700
Message-ID: <1332975091-10950-11-git-send-email-tj@kernel.org>
References: <1332975091-10950-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1332975091-10950-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Add blkiop->cftypes which is added and removed together with the
policy.  This will be used to move conf/stat handling to the policies.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c |    6 ++++++
 block/blk-cgroup.h |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index df1e197..2f05056 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1538,6 +1538,9 @@ void blkio_policy_register(struct blkio_policy_type *blkiop)
 	list_for_each_entry(q, &all_q_list, all_q_node)
 		update_root_blkg_pd(q, blkiop->plid);
 	blkcg_bypass_end();
+
+	if (blkiop->cftypes)
+		WARN_ON(cgroup_add_cftypes(&blkio_subsys, blkiop->cftypes));
 }
 EXPORT_SYMBOL_GPL(blkio_policy_register);
 
@@ -1545,6 +1548,9 @@ void blkio_policy_unregister(struct blkio_policy_type *blkiop)
 {
 	struct request_queue *q;
 
+	if (blkiop->cftypes)
+		cgroup_rm_cftypes(&blkio_subsys, blkiop->cftypes);
+
 	blkcg_bypass_start();
 	spin_lock(&blkio_list_lock);
 
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 361ecfa..fa744d5 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -181,6 +181,7 @@ struct blkio_policy_type {
 	struct blkio_policy_ops ops;
 	enum blkio_policy_id plid;
 	size_t pdata_size;		/* policy specific private data size */
+	struct cftype *cftypes;		/* cgroup files for the policy */
 };
 
 extern int blkcg_init_queue(struct request_queue *q);
-- 
1.7.7.3
