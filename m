From: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 04/12] container quota: introduce container disk quota data
	header file.
Date: Wed, 30 May 2012 22:58:58 +0800
Message-ID: <1338389946-13711-5-git-send-email-jeff.liu@oracle.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338389946-13711-1-git-send-email-jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: tytso-3s7WtUTddSA@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

Header file for container disk quota.

Signed-off-by: Jie Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 fs/ns_quota.h |   84 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 84 insertions(+), 0 deletions(-)
 create mode 100644 fs/ns_quota.h

diff --git a/fs/ns_quota.h b/fs/ns_quota.h
new file mode 100644
index 0000000..cf90fff
--- /dev/null
+++ b/fs/ns_quota.h
@@ -0,0 +1,84 @@
+#ifndef _LINUX_NS_QUOTA_
+#define _LINUX_NS_QUOTA_
+
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/rwsem.h>
+#include <linux/spinlock.h>
+#include <linux/atomic.h>
+#include <linux/quota.h>
+#include <linux/user_namespace.h>
+
+#define NS_MAX_IQ_TIME	604800		/* (7*24*60*60) 1 week */
+#define NS_MAX_DQ_TIME	604800		/* (7*24*60*60) 1 week */
+
+/*
+ * Below most stuff were copied from kernel/user.c, using them
+ * to calculate and define quota hash table and hash routine.
+ */
+#define NS_DQHASH_BITS	(CONFIG_BASE_SMALL ? 3 : 7)
+#define NS_DQHASH_SZ	(1 << NS_DQHASH_BITS)
+
+struct ns_mem_dqinfo {
+	unsigned long dqi_flags;
+	unsigned int dqi_bgrace;
+	unsigned int dqi_igrace;
+	qsize_t dqi_maxblimit;
+	qsize_t dqi_maxilimit;
+};
+
+/* Mount namespace disk quota definitation */
+struct ns_quota_info {
+	/* Flags for disk quotas on this mount namespace */
+	unsigned int dq_flags;
+	/* Serialize mount namespace quotaon & quotaoff */
+	struct mutex dqonoff_mutex;
+	/* Serialize user/group quota list operations */
+	spinlock_t dq_list_lock;
+	/* Serialize quota value incr/decr operations */
+	spinlock_t dq_data_lock;
+	struct kmem_cache *dquot_cachep;
+	/* Hash list of all user disk quotas */
+	struct hlist_head u_dquots[NS_DQHASH_SZ];
+	/* Hash list of all group disk quotas */
+	struct hlist_head g_dquots[NS_DQHASH_SZ];
+	/* Information for each quota type */
+	struct ns_mem_dqinfo dqinfo[MAXQUOTAS];
+};
+
+/* Mount namespace disk quota object */
+struct ns_dquot {
+	struct hlist_node dq_hash_node;	/* Hash list in memory */
+	struct mnt_namespace *dq_ns;	/* Mount namespace this applies to */
+	unsigned int dq_id;		/* ID this applies to (uid, gid) */
+	unsigned long dq_flags;		/* See DQ_* */
+	short dq_type;			/* Type of quota */
+	struct mem_dqblk dq_dqb;	/* Diskquota usage */
+};
+
+/* Operations for quota object allocation/destroy */
+struct ns_dquot_ops {
+	/* Allocate memory for new dqout object */
+	struct ns_dquot *(*alloc_dquot)(struct mnt_namespace *);
+	/* Free memory for dquot */
+	void (*destroy_dquot)(struct ns_dquot *);
+};
+
+/* Operations for quota control */
+struct ns_quotactl_ops {
+	int (*quota_on)(struct mnt_namespace *, int);
+	int (*quota_off)(struct mnt_namespace *, int);
+	int (*get_info)(struct mnt_namespace *, int, struct if_dqinfo *);
+	int (*set_info)(struct mnt_namespace *, int, struct if_dqinfo *);
+	int (*get_dqblk)(struct mnt_namespace *, int, qid_t,
+			 struct fs_disk_quota *);
+	int (*set_dqblk)(struct mnt_namespace *, int, qid_t,
+			 struct fs_disk_quota *);
+};
+
+int ns_dqinfo_init(struct mnt_namespace *ns);
+void ns_dqinfo_destroy(struct mnt_namespace *ns);
+extern unsigned int ns_dquot_getfmt(struct mnt_namespace *ns, int type);
+
+#endif /* _LINUX_NS_QUOTA_ */
-- 
1.7.9
