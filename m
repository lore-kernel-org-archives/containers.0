From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/5] blk-cgroup: introduce task_to_blkio_cgroup()
Date: Tue, 22 Feb 2011 18:12:53 +0100
Message-ID: <1298394776-9957-3-git-send-email-arighi__18786.5398046144$1298394976$gmane$org@develer.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1298394776-9957-1-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Introduce a helper function to retrieve a blkio cgroup from a task.

Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
---
 block/blk-cgroup.c         |    7 +++++++
 include/linux/blk-cgroup.h |    4 ++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index bf9d354..f283ae1 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -107,6 +107,13 @@ blkio_policy_search_node(const struct blkio_cgroup *blkcg, dev_t dev,
 	return NULL;
 }
 
+struct blkio_cgroup *task_to_blkio_cgroup(struct task_struct *task)
+{
+	return container_of(task_subsys_state(task, blkio_subsys_id),
+				struct blkio_cgroup, css);
+}
+EXPORT_SYMBOL_GPL(task_to_blkio_cgroup);
+
 struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup)
 {
 	return container_of(cgroup_subsys_state(cgroup, blkio_subsys_id),
diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index 5e48204..41b59db 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -287,6 +287,7 @@ static inline void blkiocg_set_start_empty_time(struct blkio_group *blkg) {}
 extern struct blkio_cgroup blkio_root_cgroup;
 extern bool blkio_cgroup_disabled(void);
 extern struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup);
+extern struct blkio_cgroup *task_to_blkio_cgroup(struct task_struct *task);
 extern void blkiocg_add_blkio_group(struct blkio_cgroup *blkcg,
 	struct blkio_group *blkg, void *key, dev_t dev,
 	enum blkio_policy_id plid);
@@ -311,6 +312,9 @@ static inline bool blkio_cgroup_disabled(void) { return true; }
 static inline struct blkio_cgroup *
 cgroup_to_blkio_cgroup(struct cgroup *cgroup) { return NULL; }
 
+static inline struct blkio_cgroup *
+task_to_blkio_cgroup(struct task_struct *task) { return NULL; }
+
 static inline void blkiocg_add_blkio_group(struct blkio_cgroup *blkcg,
 		struct blkio_group *blkg, void *key, dev_t dev,
 		enum blkio_policy_id plid) {}
-- 
1.7.1
