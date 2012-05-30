From: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 06/12] container quota: implementations and header for
	block/inode bill up.
Date: Wed, 30 May 2012 22:59:00 +0800
Message-ID: <1338389946-13711-7-git-send-email-jeff.liu@oracle.com>
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

Add container disk quota operation header file as well as the implementations.

Signed-off-by: Jie Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 fs/ns_dquot.c    | 1246 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/ns_quotaops.h |   72 ++++
 2 files changed, 1318 insertions(+), 0 deletions(-)
 create mode 100644 fs/ns_dquot.c
 create mode 100644 fs/ns_quotaops.h

diff --git a/fs/ns_dquot.c b/fs/ns_dquot.c
new file mode 100644
index 0000000..27c36c6
--- /dev/null
+++ b/fs/ns_dquot.c
@@ -0,0 +1,1246 @@
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/fs.h>
+#include <linux/mount.h>
+#include <linux/mm.h>
+#include <linux/time.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/fcntl.h>
+#include <linux/stat.h>
+#include <linux/tty.h>
+#include <linux/file.h>
+#include <linux/slab.h>
+#include <linux/sysctl.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/proc_fs.h>
+#include <linux/security.h>
+#include <linux/sched.h>
+#include <linux/kmod.h>
+#include <linux/namei.h>
+#include <linux/capability.h>
+#include <linux/quota.h>
+#include <linux/quotaops.h>
+#include <linux/nsproxy.h>
+#include <linux/user_namespace.h>
+#include <linux/mnt_namespace.h>
+
+#include "mount.h"
+#include "internal.h" /* ugh */
+
+#include <linux/uaccess.h>
+
+static __cacheline_aligned_in_smp DEFINE_SPINLOCK(ns_dq_state_lock);
+
+#define VFS_FS_DQ_MASK \
+	(FS_DQ_BCOUNT | FS_DQ_BSOFT | FS_DQ_BHARD | \
+	 FS_DQ_ICOUNT | FS_DQ_ISOFT | FS_DQ_IHARD | \
+	 FS_DQ_BTIMER | FS_DQ_ITIMER)
+
+#define NS_DQHASH_MASK	(NS_DQHASH_BITS - 1)
+#define __hashfn(id)	(((id >> NS_DQHASH_BITS) + id) & NS_DQHASH_MASK)
+#define hashentry(dq_hash_table, id)	(dq_hash_table + __hashfn((id)))
+
+static inline void remove_ns_dquot_hash(struct ns_dquot *dquot)
+{
+	hlist_del_init(&dquot->dq_hash_node);
+}
+
+static struct ns_dquot *ns_dqhash_find(unsigned int id,
+				       struct hlist_head *hashent)
+{
+	struct ns_dquot *dquot;
+	struct hlist_node *h;
+
+	hlist_for_each_entry(dquot, h, hashent, dq_hash_node) {
+		/* FIXME: maybe need to add ns check up as well */
+		if (dquot->dq_id == id)
+			return dquot;
+	}
+
+	return NULL;
+}
+
+/*
+ * Find out a desired dquot.  Currently, it only supports user quota
+ * type, maybe we also need to add directory quota support here.
+ */
+static struct ns_dquot *find_ns_dquot(struct mnt_namespace *ns,
+				      unsigned int id, int type)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+	struct ns_dquot *dquot;
+
+	switch (type) {
+	case USRQUOTA:
+		dquot = ns_dqhash_find(id, hashentry(dqinfo->u_dquots, id));
+		break;
+	case GRPQUOTA:
+		dquot = ns_dqhash_find(id, hashentry(dqinfo->g_dquots, id));
+		break;
+	}
+
+	return dquot;
+}
+
+static void insert_ns_dquot_hash(struct ns_dquot *dquot)
+{
+	struct ns_quota_info *dqinfo = dquot->dq_ns->ns_dqinfo;
+	struct hlist_head *hashent;
+
+	switch (dquot->dq_type) {
+	case USRQUOTA:
+		hashent = hashentry(dqinfo->u_dquots, dquot->dq_id);
+		break;
+	case GRPQUOTA:
+		hashent = hashentry(dqinfo->g_dquots, dquot->dq_id);
+		break;
+	}
+
+	hlist_add_head(&dquot->dq_hash_node, hashent);
+}
+
+/* Allocate and return a new dquot */
+static inline struct ns_dquot *ns_dquot_alloc(struct mnt_namespace *ns)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+
+	return kmem_cache_zalloc(dqinfo->dquot_cachep, GFP_NOFS);
+}
+
+/* Remove a dquot from cache */
+static void ns_dquot_destroy(struct ns_dquot *dquot)
+{
+	struct ns_quota_info *dqinfo = dquot->dq_ns->ns_dqinfo;
+
+	if (dqinfo->dquot_cachep)
+		kmem_cache_free(dqinfo->dquot_cachep, dquot);
+}
+
+static void __remove_dq_hash_list_items(struct hlist_head *hashent)
+{
+	struct ns_dquot *dquot;
+	struct hlist_node *h, *tmp;
+
+	hlist_for_each_entry_safe(dquot, h, tmp, hashent, dq_hash_node)
+		remove_ns_dquot_hash(dquot);
+}
+
+static void __remove_dq_hash_list(struct hlist_head *hashent)
+{
+	if (!hlist_empty(hashent))
+		__remove_dq_hash_list_items(hashent);
+}
+
+static inline bool ns_has_quota_usage_enabled(struct mnt_namespace *ns,
+					      int type)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+
+	return dqinfo->dq_flags &
+	       dquot_state_flag(DQUOT_USAGE_ENABLED, type);
+}
+
+static inline bool ns_has_quota_limit_enabled(struct mnt_namespace *ns,
+					      int type)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+
+	return dqinfo->dq_flags &
+	       dquot_state_flag(DQUOT_LIMITS_ENABLED, type);
+}
+
+/*
+ * Does kernel know about any quota information for the given
+ * mount namespace + type?
+ */
+static inline bool ns_has_quota_loaded(struct mnt_namespace *ns, int type)
+{
+	/* currently if anything is on, then quota usage is on as well */
+	return ns_has_quota_usage_enabled(ns, type);
+}
+
+static inline unsigned ns_any_quota_loaded(struct mnt_namespace *ns)
+{
+	unsigned type, tmsk = 0;
+	for (type = 0; type < MAXQUOTAS; type++)
+		tmsk |= ns_has_quota_loaded(ns, type) << type;
+
+	return tmsk;
+}
+
+static inline bool ns_has_quota_active(struct mnt_namespace *ns, int type)
+{
+	return ns_has_quota_limit_enabled(ns, type);
+}
+
+/*
+ * FIXME: Currently, below warning stuff for mount namespace quota are not well
+ * configured and tested, the only purpose here is to demo the how we can using
+ * them in the furture.
+ */
+struct ns_dquot_warn {
+	struct mnt_namespace *w_ns;
+	qid_t w_dq_id;
+	short w_dq_type;
+	short w_type;
+};
+
+static int warning_issued(struct ns_dquot *dquot, const int warntype)
+{
+	int flag = (warntype == QUOTA_NL_BHARDWARN ||
+		    warntype == QUOTA_NL_BSOFTLONGWARN) ? DQ_BLKS_B :
+		    ((warntype == QUOTA_NL_IHARDWARN ||
+		      warntype == QUOTA_NL_ISOFTLONGWARN) ? DQ_INODES_B : 0);
+
+	if (!flag)
+		return 0;
+
+	return test_and_set_bit(flag, &dquot->dq_flags);
+}
+
+/* FIXME: below parameter is not presented on Kconfig yet. */
+#ifdef CONFIG_PRINT_NS_QUOTA_WARNING
+static int flag_print_warnings = 1;
+
+static int need_print_warning(struct dquot_warn *warn)
+{
+	if (!flag_print_warnings)
+		return 0;
+
+	switch (warn->w_dq_type) {
+	case USRQUOTA:
+		return current_fsuid() == warn->w_dq_id;
+	case GRPQUOTA:
+		return in_group_p(warn->w_dq_id);
+	}
+
+	return 0;
+}
+
+/*
+ * Print warning to user which exceeded quota.
+ * FIXME:
+ * As "Pint quota warning to console" has been marked to OBSOLETE on
+ * Kconfig menu, maybe we can just ignore that in mount namespace quota?
+ */
+static void print_warning(struct dquot_warn *warn)
+{
+	char *msg = NULL;
+	struct tty_struct *tty;
+	int warntype = warn->w_type;
+
+	if (warntype == QUOTA_NL_IHARDBELOW ||
+	    warntype == QUOTA_NL_ISOFTBELOW ||
+	    warntype == QUOTA_NL_BHARDBELOW ||
+	    warntype == QUOTA_NL_BSOFTBELOW ||
+	    !need_print_warning(warn))
+		return;
+
+	tty = get_current_tty();
+	if (!tty)
+		return;
+
+	tty_write_message(tty, warn->w_sb->s_id);
+	if (warntype == QUOTA_NL_ISOFTWARN || warntype == QUOTA_NL_BSOFTWARN)
+		tty_write_message(tty, ": warning, ");
+	else
+		tty_write_message(tty, ": write failed, ");
+
+	tty_write_message(tty, quotatypes[warn->w_dq_type]);
+	switch (warntype) {
+	case QUOTA_NL_IHARDWARN:
+		msg = " file limit reached.\r\n";
+		break;
+	case QUOTA_NL_ISOFTLONGWARN:
+		msg = " file quota exceeded too long.\r\n";
+		break;
+	case QUOTA_NL_ISOFTWARN:
+		msg = " file quota exceeded.\r\n";
+		break;
+	case QUOTA_NL_BHARDWARN:
+		msg = " block limit reached.\r\n";
+		break;
+	case QUOTA_NL_BSOFTLONGWARN:
+		msg = " block quota exceeded too long.\r\n";
+		break;
+	case QUOTA_NL_BSOFTWARN:
+		msg = " block quota exceeded.\r\n";
+		break;
+	}
+	tty_write_message(tty, msg);
+	tty_kref_put(tty);
+}
+#endif
+
+static void prepare_warning(struct ns_dquot_warn *warn, struct ns_dquot *dquot,
+			    int warntype)
+{
+	if (warning_issued(dquot, warntype))
+		return;
+
+	warn->w_type = warntype;
+	warn->w_ns = dquot->dq_ns;
+	warn->w_dq_id = dquot->dq_id;
+	warn->w_dq_type = dquot->dq_type;
+}
+
+/*
+ * Write warnings to the console and send warning messages over netlink.
+ * Note that this function can call into tty and networking code.
+ */
+static void flush_warnings(struct ns_dquot_warn *warn)
+{
+	int i;
+
+	for (i = 0; i < MAXQUOTAS; i++) {
+		if (warn[i].w_type == QUOTA_NL_NOWARN)
+			continue;
+#ifdef CONFIG_PRINT_QUOTA_WARNING
+#if 0
+		print_warning(&warn[i]);
+		quota_send_warning(warn[i].w_dq_type, warn[i].w_dq_id,
+				   warn[i].w_ns->s_dev, warn[i].w_type);
+#endif
+#endif
+	}
+}
+
+static struct ns_dquot *get_empty_ns_dquot(struct mnt_namespace *ns)
+{
+	return ns->ns_dqop->alloc_dquot(ns);
+}
+
+/* Find out or allocate a new dquot */
+static struct ns_dquot *ns_dqget(struct mnt_namespace *ns, unsigned int id,
+				 int type)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+	struct ns_dquot *dquot;
+
+	if (!dqinfo)
+		return NULL;
+
+	spin_lock(&dqinfo->dq_list_lock);
+	dquot = find_ns_dquot(ns, id, type);
+	if (!dquot) {
+		dquot = get_empty_ns_dquot(ns);
+		if (!dquot)
+			goto out_unlock;
+		INIT_HLIST_NODE(&dquot->dq_hash_node);
+		dquot->dq_ns = ns;
+		dquot->dq_id = id;
+		dquot->dq_type = type;
+		insert_ns_dquot_hash(dquot);
+	}
+
+out_unlock:
+	spin_unlock(&dqinfo->dq_list_lock);
+	return dquot;
+}
+
+/*
+ * FIXME:
+ * Below stuff regarding space calculations are all copied from general disk
+ * quota, need to refector them to reduce duplications maybe.
+ */
+static inline void ns_dquot_incr_inodes(struct ns_dquot *dquot, qsize_t number)
+{
+	dquot->dq_dqb.dqb_curinodes += number;
+}
+
+static inline void ns_dquot_resv_space(struct ns_dquot *dquot, qsize_t number)
+{
+	dquot->dq_dqb.dqb_rsvspace += number;
+}
+
+static inline void ns_dquot_incr_space(struct ns_dquot *dquot, qsize_t number)
+{
+	dquot->dq_dqb.dqb_curspace += number;
+}
+
+/* claim reserved quota space */
+static void ns_dquot_claim_reserved_space(struct ns_dquot *dquot,
+					  qsize_t number)
+{
+	if (dquot->dq_dqb.dqb_rsvspace < number) {
+		WARN_ON_ONCE(1);
+		number = dquot->dq_dqb.dqb_rsvspace;
+	}
+
+	dquot->dq_dqb.dqb_curspace += number;
+	dquot->dq_dqb.dqb_rsvspace -= number;
+}
+
+static inline void dquot_free_reserved_space(struct ns_dquot *dquot,
+					     qsize_t number)
+{
+	if (dquot->dq_dqb.dqb_rsvspace >= number)
+		dquot->dq_dqb.dqb_rsvspace -= number;
+	else {
+		WARN_ON_ONCE(1);
+		dquot->dq_dqb.dqb_rsvspace = 0;
+	}
+}
+
+static void ns_dquot_decr_inodes(struct ns_dquot *dquot, qsize_t number)
+{
+	struct ns_quota_info *dqinfo = dquot->dq_ns->ns_dqinfo;
+
+	if (dqinfo->dq_flags & DQUOT_NEGATIVE_USAGE ||
+	    dquot->dq_dqb.dqb_curinodes >= number)
+		dquot->dq_dqb.dqb_curinodes -= number;
+	else
+		dquot->dq_dqb.dqb_curinodes = 0;
+
+	if (dquot->dq_dqb.dqb_curinodes <= dquot->dq_dqb.dqb_isoftlimit)
+		dquot->dq_dqb.dqb_itime = (time_t)0;
+}
+
+static void ns_dquot_decr_space(struct ns_dquot *dquot, qsize_t number)
+{
+	struct ns_quota_info *dqinfo = dquot->dq_ns->ns_dqinfo;
+
+	if (dqinfo->dq_flags & DQUOT_NEGATIVE_USAGE ||
+	    dquot->dq_dqb.dqb_curspace >= number)
+		dquot->dq_dqb.dqb_curspace -= number;
+	else
+		dquot->dq_dqb.dqb_curspace = 0;
+	if (dquot->dq_dqb.dqb_curspace <= dquot->dq_dqb.dqb_bsoftlimit)
+		dquot->dq_dqb.dqb_btime = (time_t)0;
+}
+
+static int ns_check_idq(struct ns_dquot *dquot, qsize_t inodes,
+			struct ns_dquot_warn *warn)
+{
+	qsize_t newinodes = dquot->dq_dqb.dqb_curinodes + inodes;
+	struct mnt_namespace *ns = dquot->dq_ns;
+
+	if (!ns_has_quota_limit_enabled(ns, dquot->dq_type))
+		return 0;
+
+	if (dquot->dq_dqb.dqb_ihardlimit &&
+	    newinodes > dquot->dq_dqb.dqb_ihardlimit) {
+		prepare_warning(warn, dquot, QUOTA_NL_IHARDWARN);
+		return -EDQUOT;
+	}
+
+	if (dquot->dq_dqb.dqb_isoftlimit &&
+	    newinodes > dquot->dq_dqb.dqb_isoftlimit &&
+	    dquot->dq_dqb.dqb_itime &&
+	    get_seconds() >= dquot->dq_dqb.dqb_itime) {
+		prepare_warning(warn, dquot, QUOTA_NL_ISOFTLONGWARN);
+		return -EDQUOT;
+	}
+
+	if (dquot->dq_dqb.dqb_isoftlimit &&
+	    newinodes > dquot->dq_dqb.dqb_isoftlimit &&
+	    dquot->dq_dqb.dqb_itime == 0) {
+		prepare_warning(warn, dquot, QUOTA_NL_ISOFTWARN);
+		dquot->dq_dqb.dqb_itime = get_seconds() +
+			ns->ns_dqinfo->dqinfo[dquot->dq_type].dqi_igrace;
+	}
+
+	return 0;
+}
+
+static int ns_check_bdq(struct ns_dquot *dquot, qsize_t space,
+			struct ns_dquot_warn *warn)
+{
+	struct mnt_namespace *ns = dquot->dq_ns;
+	qsize_t tspace;
+
+	if (!ns_has_quota_limit_enabled(ns, dquot->dq_type))
+		return 0;
+
+	tspace = dquot->dq_dqb.dqb_curspace + dquot->dq_dqb.dqb_rsvspace
+		 + space;
+
+	if (dquot->dq_dqb.dqb_bhardlimit &&
+	    tspace > dquot->dq_dqb.dqb_bhardlimit) {
+		prepare_warning(warn, dquot, QUOTA_NL_BHARDWARN);
+		return -EDQUOT;
+	}
+
+	if (dquot->dq_dqb.dqb_bsoftlimit &&
+	    tspace > dquot->dq_dqb.dqb_bsoftlimit &&
+	    dquot->dq_dqb.dqb_btime &&
+	    get_seconds() >= dquot->dq_dqb.dqb_btime) {
+		prepare_warning(warn, dquot, QUOTA_NL_BHARDWARN);
+		return -EDQUOT;
+	}
+
+	if (dquot->dq_dqb.dqb_bsoftlimit &&
+	    tspace > dquot->dq_dqb.dqb_bsoftlimit &&
+	    dquot->dq_dqb.dqb_btime == 0) {
+		prepare_warning(warn, dquot, QUOTA_NL_BSOFTWARN);
+		dquot->dq_dqb.dqb_btime = get_seconds() +
+		ns->ns_dqinfo->dqinfo[dquot->dq_type].dqi_bgrace;
+		return -EDQUOT;
+	}
+
+	return 0;
+}
+
+static int __ns_dquot_alloc_space(const struct inode *inode, qsize_t number,
+				  int flags)
+{
+	int cnt, ret = 0;
+	struct ns_dquot_warn warn[MAXQUOTAS];
+	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+	int reserve = flags & DQUOT_SPACE_RESERVE;
+
+	if (!dqinfo)
+		return 0;
+
+	if (!ns_any_quota_loaded(ns))
+		return 0;
+
+	spin_lock(&dqinfo->dq_list_lock);
+	for (cnt = 0; cnt < MAXQUOTAS; cnt++) {
+		unsigned int id;
+		struct ns_dquot *dquot;
+		warn[cnt].w_type = QUOTA_NL_NOWARN;
+
+		switch (cnt) {
+		case USRQUOTA:
+			id = inode->i_uid;
+			break;
+		case GRPQUOTA:
+			id = inode->i_gid;
+			break;
+		}
+		dquot = find_ns_dquot(ns, id, cnt);
+		if (!dquot)
+			continue;
+
+		ret = ns_check_bdq(dquot, number, &warn[cnt]);
+		if (ret && !(flags & DQUOT_SPACE_NOFAIL))
+			goto out_flush_warn;
+
+		spin_lock(&dqinfo->dq_data_lock);
+		if (reserve)
+			ns_dquot_resv_space(dquot, number);
+		else
+			ns_dquot_incr_space(dquot, number);
+		spin_unlock(&dqinfo->dq_data_lock);
+	}
+
+out_flush_warn:
+	spin_unlock(&dqinfo->dq_list_lock);
+	flush_warnings(warn);
+	return ret;
+}
+
+/* Exported routine for file system disk space quota checking */
+int ns_dquot_alloc_block(struct inode *inode, qsize_t nr)
+{
+	return __ns_dquot_alloc_space(inode, nr << inode->i_blkbits,
+				      DQUOT_SPACE_WARN);
+}
+EXPORT_SYMBOL(ns_dquot_alloc_block);
+
+static void ns_dquot_alloc_space_nofail(struct inode *inode, qsize_t nr)
+{
+	__ns_dquot_alloc_space(inode, nr, DQUOT_SPACE_WARN|DQUOT_SPACE_NOFAIL);
+}
+
+void ns_dquot_alloc_block_nofail(struct inode *inode, qsize_t nr)
+{
+	ns_dquot_alloc_space_nofail(inode, nr << inode->i_blkbits);
+}
+EXPORT_SYMBOL(ns_dquot_alloc_block_nofail);
+
+int ns_dquot_reserve_block(struct inode *inode, qsize_t nr)
+{
+	return __ns_dquot_alloc_space(inode, nr << inode->i_blkbits,
+				DQUOT_SPACE_WARN|DQUOT_SPACE_RESERVE);
+}
+EXPORT_SYMBOL(ns_dquot_reserve_block);
+
+void ns_dquot_claim_block(struct inode *inode, qsize_t nr)
+{
+	int cnt;
+	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+
+	if (!dqinfo)
+		return;
+
+	if (!ns_any_quota_loaded(ns))
+		return;
+
+	spin_lock(&dqinfo->dq_list_lock);
+	for (cnt = 0; cnt < MAXQUOTAS; cnt++) {
+		unsigned int id;
+		struct ns_dquot *dquot;
+
+		switch (cnt) {
+		case USRQUOTA:
+			id = inode->i_uid;
+			break;
+		case GRPQUOTA:
+			id = inode->i_gid;
+			break;
+		}
+		dquot = find_ns_dquot(ns, id, cnt);
+		if (!dquot)
+			continue;
+
+		spin_lock(&dqinfo->dq_data_lock);
+		ns_dquot_claim_reserved_space(dquot, nr << inode->i_blkbits);
+		spin_unlock(&dqinfo->dq_data_lock);
+	}
+
+	spin_unlock(&dqinfo->dq_list_lock);
+}
+EXPORT_SYMBOL(ns_dquot_claim_block);
+
+/* This operation can block, but only after everything is updated */
+int ns_dquot_alloc_inode(const struct inode *inode)
+{
+	int cnt, ret = 0;
+	struct ns_dquot_warn warn[MAXQUOTAS];
+	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+
+	if (!dqinfo)
+		return 0;
+
+	if (!ns_any_quota_loaded(ns))
+		return 0;
+
+	spin_lock(&dqinfo->dq_list_lock);
+	for (cnt = 0; cnt < MAXQUOTAS; cnt++) {
+		struct ns_dquot *dquot;
+		unsigned int id;
+		warn[cnt].w_type = QUOTA_NL_NOWARN;
+
+		switch (cnt) {
+		case USRQUOTA:
+			id = inode->i_uid;
+			break;
+		case GRPQUOTA:
+			id = inode->i_gid;
+			break;
+		}
+
+		dquot = find_ns_dquot(ns, id, cnt);
+		if (!dquot)
+			continue;
+
+		ret = ns_check_idq(dquot, 1, &warn[cnt]);
+		if (ret)
+			goto over_quota;
+
+		spin_lock(&dqinfo->dq_data_lock);
+		ns_dquot_incr_inodes(dquot, 1);
+		spin_unlock(&dqinfo->dq_data_lock);
+	}
+
+over_quota:
+	spin_unlock(&dqinfo->dq_list_lock);
+	flush_warnings(warn);
+	return ret;
+}
+EXPORT_SYMBOL(ns_dquot_alloc_inode);
+
+static int ns_info_bdq_free(struct ns_dquot *dquot, qsize_t space)
+{
+	struct mem_dqblk *dq_dqb = &dquot->dq_dqb;
+
+	if (dq_dqb->dqb_curspace <= dq_dqb->dqb_bsoftlimit)
+		return QUOTA_NL_NOWARN;
+
+	if (dq_dqb->dqb_curspace - space <= dq_dqb->dqb_bsoftlimit)
+		return QUOTA_NL_BSOFTBELOW;
+
+	if (dq_dqb->dqb_curspace >= dq_dqb->dqb_bhardlimit &&
+	    dq_dqb->dqb_curspace - space < dq_dqb->dqb_bhardlimit)
+		return QUOTA_NL_BHARDBELOW;
+
+	return QUOTA_NL_NOWARN;
+}
+
+static void __ns_dquot_free_space(const struct inode *inode, qsize_t number,
+				  int flags)
+{
+	unsigned int cnt;
+	struct ns_dquot_warn warn[MAXQUOTAS];
+	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+
+	dqinfo = ns->ns_dqinfo;
+	if (!dqinfo)
+		return;
+
+	if (!ns_any_quota_loaded(ns))
+		return;
+
+	spin_lock(&dqinfo->dq_list_lock);
+	for (cnt = 0; cnt < MAXQUOTAS; cnt++) {
+		int wtype;
+		unsigned int id;
+		struct ns_dquot *dquot;
+		warn[cnt].w_type = QUOTA_NL_NOWARN;
+
+		switch (cnt) {
+		case USRQUOTA:
+			id = inode->i_uid;
+			break;
+		case GRPQUOTA:
+			id = inode->i_gid;
+			break;
+		}
+
+		dquot = find_ns_dquot(ns, id, cnt);
+		if (!dquot)
+			continue;
+
+		wtype = ns_info_bdq_free(dquot, number);
+		if (wtype != QUOTA_NL_NOWARN)
+			prepare_warning(&warn[cnt], dquot, wtype);
+		spin_lock(&dqinfo->dq_data_lock);
+		ns_dquot_decr_space(dquot, number);
+		spin_unlock(&dqinfo->dq_data_lock);
+	}
+	spin_unlock(&dqinfo->dq_list_lock);
+	flush_warnings(warn);
+}
+
+void ns_dquot_free_block(struct inode *inode, qsize_t nr)
+{
+	__ns_dquot_free_space(inode, nr << inode->i_blkbits, 0);
+}
+EXPORT_SYMBOL(ns_dquot_free_block);
+
+void ns_dquot_release_reservation_block(struct inode *inode, qsize_t nr)
+{
+	__ns_dquot_free_space(inode, nr << inode->i_blkbits,
+			      DQUOT_SPACE_RESERVE);
+}
+EXPORT_SYMBOL(ns_dquot_release_reservation_block);
+
+static int ns_info_idq_free(struct ns_dquot *dquot, qsize_t inodes)
+{
+	struct mem_dqblk *dq_dqb = &dquot->dq_dqb;
+	qsize_t newinodes;
+
+	if (dq_dqb->dqb_curinodes <= dq_dqb->dqb_isoftlimit ||
+	    !ns_has_quota_limit_enabled(dquot->dq_ns, dquot->dq_type))
+		return QUOTA_NL_NOWARN;
+
+	newinodes = dq_dqb->dqb_curinodes - inodes;
+	if (newinodes <= dq_dqb->dqb_isoftlimit)
+		return QUOTA_NL_ISOFTBELOW;
+
+	if (dq_dqb->dqb_curinodes >= dq_dqb->dqb_ihardlimit &&
+	    newinodes < dq_dqb->dqb_ihardlimit)
+		return QUOTA_NL_IHARDBELOW;
+
+	return QUOTA_NL_NOWARN;
+}
+
+/* Exported routine for inode removing. */
+void ns_dquot_free_inode(const struct inode *inode)
+{
+	unsigned int cnt;
+	struct ns_dquot_warn warn[MAXQUOTAS];
+	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+
+	if (!dqinfo)
+		return;
+
+	if (!ns_any_quota_loaded(ns))
+		return;
+
+	spin_lock(&dqinfo->dq_list_lock);
+	for (cnt = 0; cnt < MAXQUOTAS; cnt++) {
+		unsigned int id;
+		struct ns_dquot *dquot;
+		int wtype;
+
+		switch (cnt) {
+		case USRQUOTA:
+			id = inode->i_uid;
+			break;
+		case GRPQUOTA:
+			id = inode->i_gid;
+			break;
+		}
+
+		dquot = find_ns_dquot(ns, id, cnt);
+		if (!dquot)
+			continue;
+
+		warn[cnt].w_type = QUOTA_NL_NOWARN;
+		wtype = ns_info_idq_free(dquot, 1);
+		if (wtype != QUOTA_NL_NOWARN)
+			prepare_warning(&warn[cnt], dquot, wtype);
+		spin_lock(&dqinfo->dq_data_lock);
+		ns_dquot_decr_inodes(dquot, 1);
+		spin_unlock(&dqinfo->dq_data_lock);
+	}
+	spin_unlock(&dqinfo->dq_list_lock);
+}
+EXPORT_SYMBOL(ns_dquot_free_inode);
+
+/*
+ * Definitions of diskquota operations.
+ */
+const struct ns_dquot_ops ns_dquot_operations = {
+	.alloc_dquot	= ns_dquot_alloc,
+	.destroy_dquot	= ns_dquot_destroy,
+};
+
+/*
+ * Transfer the number of inode and blocks from one diskquota to an other.
+ * On success, dquot references in transfer_to are consumed and references
+ * to original dquots that need to be released are placed there. On failure,
+ * references are kept untouched.
+ *
+ * This operation can block, but only after everything is updated
+ * A transaction must be started when entering this function.
+ */
+static int __ns_dquot_transfer(struct mnt_namespace *ns, struct inode *inode,
+			       struct ns_dquot **transfer_to)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+	struct ns_dquot *transfer_from[MAXQUOTAS] = {};
+	struct ns_dquot_warn warn[MAXQUOTAS];
+	char is_valid[MAXQUOTAS] = {};
+	int cnt, ret = 0;
+	qsize_t space;
+
+	spin_lock(&dqinfo->dq_data_lock);
+	space = inode_get_bytes(inode);
+
+	/* Build the transfer_from list and check the limits */
+	for (cnt = 0; cnt < MAXQUOTAS; cnt++) {
+		unsigned int id;
+		warn[cnt].w_type = QUOTA_NL_NOWARN;
+		/*
+		 * Skip changes for same uid or gid or for turned off
+		 * quota-type.
+		 */
+		if (!transfer_to[cnt])
+			continue;
+
+		/* Avoid races with quotaoff() */
+		if (!ns_has_quota_loaded(ns, cnt))
+			continue;
+
+		is_valid[cnt] = 1;
+		switch (cnt) {
+		case USRQUOTA:
+			id = inode->i_uid;
+			break;
+		case GRPQUOTA:
+			id = inode->i_gid;
+			break;
+		}
+
+		transfer_from[cnt] = find_ns_dquot(ns, id, cnt);
+		ret = ns_check_idq(transfer_to[cnt], 1, &warn[cnt]);
+		if (ret)
+			goto over_quota;
+
+		ret = ns_check_bdq(transfer_to[cnt], space, &warn[cnt]);
+		if (ret)
+			goto over_quota;
+	}
+
+	/*
+	 * Finally perform the needed transfer from transfer_from to
+	 * transfer_to.
+	 */
+	for (cnt = 0; cnt < MAXQUOTAS; cnt++) {
+		if (!is_valid[cnt])
+			continue;
+
+		/*
+		 * Due to IO error we might not have transfer_from[]
+		 * structure.
+		 */
+		if (transfer_from[cnt]) {
+			ns_dquot_decr_inodes(transfer_from[cnt], 1);
+			ns_dquot_decr_space(transfer_from[cnt], space);
+		}
+
+		ns_dquot_incr_inodes(transfer_to[cnt], 1);
+		ns_dquot_incr_space(transfer_to[cnt], space);
+	}
+
+over_quota:
+	spin_unlock(&dqinfo->dq_data_lock);
+	return ret;
+}
+
+/*
+ * Wrapper for transferring ownership of an inode for uid/gid only
+ * Called from FSXXX_setattr()
+ */
+int ns_dquot_transfer(struct inode *inode, struct iattr *iattr)
+{
+	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+	struct ns_dquot *transfer_to[MAXQUOTAS] = {};
+	int ret = 0;
+
+	if (!dqinfo)
+		return ret;
+
+	if (!ns_any_quota_loaded(ns))
+		return ret;
+
+	spin_lock(&dqinfo->dq_list_lock);
+	if (iattr->ia_valid & ATTR_UID && iattr->ia_uid != inode->i_uid)
+		transfer_to[USRQUOTA] = find_ns_dquot(ns, iattr->ia_uid,
+						      USRQUOTA);
+	if (iattr->ia_valid & ATTR_GID && iattr->ia_gid != inode->i_gid)
+		transfer_to[GRPQUOTA] = find_ns_dquot(ns, iattr->ia_gid,
+						      GRPQUOTA);
+
+	ret = __ns_dquot_transfer(ns, inode, transfer_to);
+	spin_unlock(&dqinfo->dq_list_lock);
+
+	return ret;
+}
+EXPORT_SYMBOL(ns_dquot_transfer);
+
+unsigned int ns_dquot_getfmt(struct mnt_namespace *ns, int type)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+
+	if (!dqinfo || !ns_has_quota_loaded(ns, type))
+		return -ESRCH;
+
+	return QFMT_NS;
+}
+
+/*
+ * Activate disk quota on a particular namespace.
+ */
+static int ns_dquot_quota_on(struct mnt_namespace *ns, int type)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+	unsigned int flags;
+	int ret = 0;
+
+	if (!dqinfo)
+		return -ENOSYS;
+
+	mutex_lock(&dqinfo->dqonoff_mutex);
+	if (ns_has_quota_limit_enabled(ns, type)) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	/* Both disk quota usage and limits should be turn on */
+	flags = DQUOT_USAGE_ENABLED | DQUOT_LIMITS_ENABLED;
+	spin_lock(&ns_dq_state_lock);
+	dqinfo->dq_flags |= dquot_state_flag(flags, type);
+	spin_unlock(&ns_dq_state_lock);
+
+out_unlock:
+	mutex_unlock(&dqinfo->dqonoff_mutex);
+	return ret;
+}
+
+static int ns_dquot_disable(struct mnt_namespace *ns, int type,
+			    unsigned int flags)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+	int cnt;
+
+	if (!dqinfo)
+		return -ENOSYS;
+
+	mutex_lock(&dqinfo->dqonoff_mutex);
+	if (!ns_any_quota_loaded(ns))
+		goto out_unlock;
+
+	for (cnt = 0; cnt < MAXQUOTAS; cnt++) {
+		if (type != -1 && cnt != type)
+			continue;
+		if (!ns_has_quota_loaded(ns, cnt))
+			continue;
+
+		spin_lock(&ns_dq_state_lock);
+		dqinfo->dq_flags &= ~dquot_state_flag(flags, cnt);
+		spin_unlock(&ns_dq_state_lock);
+	}
+
+out_unlock:
+	mutex_unlock(&dqinfo->dqonoff_mutex);
+	return 0;
+}
+
+static int ns_dquot_quota_off(struct mnt_namespace *ns, int type)
+{
+	return ns_dquot_disable(ns, type,
+				DQUOT_USAGE_ENABLED | DQUOT_LIMITS_ENABLED);
+}
+
+/*
+ * FIXME:
+ * Below two routines are copied from general quota, they can be
+ * can be shared.
+ */
+static inline qsize_t qbtos(qsize_t blocks)
+{
+	return blocks << QIF_DQBLKSIZE_BITS;
+}
+
+static inline qsize_t stoqb(qsize_t space)
+{
+	return (space + QIF_DQBLKSIZE - 1) >> QIF_DQBLKSIZE_BITS;
+}
+
+/* Generic routine for getting common part of quota structure */
+static void do_get_ns_dqblk(struct ns_dquot *dquot, struct fs_disk_quota *di)
+{
+	struct ns_quota_info *dqinfo = dquot->dq_ns->ns_dqinfo;
+	struct mem_dqblk *dm = &dquot->dq_dqb;
+
+	memset(di, 0, sizeof(*di));
+	di->d_version = FS_DQUOT_VERSION;
+	di->d_flags = dquot->dq_type == USRQUOTA ?
+					FS_USER_QUOTA : FS_GROUP_QUOTA;
+	di->d_id = dquot->dq_id;
+
+	spin_lock(&dqinfo->dq_data_lock);
+	di->d_blk_hardlimit = stoqb(dm->dqb_bhardlimit);
+	di->d_blk_softlimit = stoqb(dm->dqb_bsoftlimit);
+	di->d_ino_hardlimit = dm->dqb_ihardlimit;
+	di->d_ino_softlimit = dm->dqb_isoftlimit;
+	di->d_bcount = dm->dqb_curspace + dm->dqb_rsvspace;
+	di->d_icount = dm->dqb_curinodes;
+	di->d_btimer = dm->dqb_btime;
+	di->d_itimer = dm->dqb_itime;
+	spin_unlock(&dqinfo->dq_data_lock);
+}
+
+static int ns_dquot_get_dqblk(struct mnt_namespace *ns, int type, qid_t id,
+			      struct fs_disk_quota *di)
+{
+	struct ns_dquot *dquot;
+
+	dquot = ns_dqget(ns, id, type);
+	if (!dquot)
+		return -ESRCH;
+
+	do_get_ns_dqblk(dquot, di);
+	return 0;
+}
+
+static int do_set_ns_dqblk(struct ns_dquot *dquot, struct fs_disk_quota *di)
+{
+	struct ns_quota_info *dqinfo = dquot->dq_ns->ns_dqinfo;
+	struct mem_dqblk *dm = &dquot->dq_dqb;
+
+	if (di->d_fieldmask & ~VFS_FS_DQ_MASK)
+		return -EINVAL;
+
+	spin_lock(&dqinfo->dq_data_lock);
+	if (di->d_fieldmask & FS_DQ_BCOUNT)
+		dm->dqb_curspace = di->d_bcount - dm->dqb_rsvspace;
+
+	if (di->d_fieldmask & FS_DQ_BSOFT)
+		dm->dqb_bsoftlimit = qbtos(di->d_blk_softlimit);
+
+	if (di->d_fieldmask & FS_DQ_BHARD)
+		dm->dqb_bhardlimit = qbtos(di->d_blk_hardlimit);
+
+	if (di->d_fieldmask & FS_DQ_ICOUNT)
+		dm->dqb_curinodes = di->d_icount;
+
+	if (di->d_fieldmask & FS_DQ_ISOFT)
+		dm->dqb_isoftlimit = di->d_ino_softlimit;
+
+	if (di->d_fieldmask & FS_DQ_IHARD)
+		dm->dqb_ihardlimit = di->d_ino_hardlimit;
+
+	if (di->d_fieldmask & FS_DQ_BTIMER)
+		dm->dqb_btime = di->d_btimer;
+
+	if (di->d_fieldmask & FS_DQ_ITIMER)
+		dm->dqb_itime = di->d_itimer;
+	spin_unlock(&dqinfo->dq_data_lock);
+
+	return 0;
+}
+
+static int ns_dquot_set_dqblk(struct mnt_namespace *ns, int type,
+			      qid_t id, struct fs_disk_quota *di)
+{
+	struct ns_dquot *dquot;
+
+	dquot = ns_dqget(ns, id, type);
+	if (!dquot)
+		return -ESRCH;
+
+	return do_set_ns_dqblk(dquot, di);
+}
+
+static int ns_dquot_get_dqinfo(struct mnt_namespace *ns, int type,
+			       struct if_dqinfo *ii)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+	struct ns_mem_dqinfo *mi;
+	int ret = 0;
+
+	if (!dqinfo)
+		return 0;
+
+	mutex_lock(&dqinfo->dqonoff_mutex);
+	if (!ns_has_quota_active(ns, type)) {
+		ret = -ESRCH;
+		goto out_unlock;
+	}
+
+	mi = dqinfo->dqinfo + type;
+	spin_lock(&dqinfo->dq_data_lock);
+	ii->dqi_bgrace = mi->dqi_bgrace;
+	ii->dqi_igrace = mi->dqi_bgrace;
+	ii->dqi_flags = mi->dqi_flags & DQF_GETINFO_MASK;
+	ii->dqi_valid = IIF_ALL;
+	spin_unlock(&dqinfo->dq_data_lock);
+
+out_unlock:
+	mutex_unlock(&dqinfo->dqonoff_mutex);
+	return ret;
+}
+
+static int ns_dquot_set_dqinfo(struct mnt_namespace *ns, int type,
+			       struct if_dqinfo *ii)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+	struct ns_mem_dqinfo *mi;
+	int ret = 0;
+
+	if (!dqinfo)
+		return 0;
+
+	mutex_lock(&dqinfo->dqonoff_mutex);
+	if (!ns_has_quota_loaded(ns, type)) {
+		ret = -ESRCH;
+		goto out;
+	}
+
+	mi = dqinfo->dqinfo + type;
+	spin_lock(&dqinfo->dq_data_lock);
+	if (ii->dqi_valid & IIF_BGRACE)
+		mi->dqi_bgrace = ii->dqi_bgrace;
+	if (ii->dqi_valid & IIF_IGRACE)
+		mi->dqi_igrace = ii->dqi_igrace;
+	if (ii->dqi_valid & IIF_FLAGS)
+		mi->dqi_flags = (mi->dqi_flags & ~DQF_SETINFO_MASK) |
+				(ii->dqi_flags & DQF_SETINFO_MASK);
+	spin_unlock(&dqinfo->dq_data_lock);
+
+out:
+	mutex_unlock(&dqinfo->dqonoff_mutex);
+	return ret;
+}
+
+const struct ns_quotactl_ops ns_quotactl_operations = {
+	.quota_on	= ns_dquot_quota_on,
+	.quota_off	= ns_dquot_quota_off,
+	.get_dqblk	= ns_dquot_get_dqblk,
+	.set_dqblk	= ns_dquot_set_dqblk,
+	.get_info	= ns_dquot_get_dqinfo,
+	.set_info	= ns_dquot_set_dqinfo,
+};
+
+int ns_dqinfo_init(struct mnt_namespace *ns)
+{
+	struct ns_quota_info *dqinfo;
+	char tmp[16];
+	int i;
+
+	ns->ns_dqinfo = kmalloc(sizeof(struct ns_quota_info), GFP_NOFS);
+	if (!ns->ns_dqinfo)
+		return -ENOMEM;
+
+	dqinfo = ns->ns_dqinfo;
+	dqinfo->dq_flags = 0;	/* Disk quota is disabled by default */
+	mutex_init(&dqinfo->dqonoff_mutex);
+	spin_lock_init(&dqinfo->dq_list_lock);
+	spin_lock_init(&dqinfo->dq_data_lock);
+
+	/*
+	 * Currently, using "ns_dquot_" combine with operation process id
+	 * to indentify dquot cache per mount namespace.
+	 * FIXME:
+	 * Need to examine a reasonable identifier for that.
+	 */
+	snprintf(tmp, sizeof(tmp), "ns_dquot_%d", current->pid);
+	dqinfo->dquot_cachep = kmem_cache_create(tmp, sizeof(struct ns_dquot),
+						 0, SLAB_PANIC, NULL);
+	if (!dqinfo->dquot_cachep) {
+		kfree(dqinfo);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < NS_DQHASH_SZ; ++i) {
+		INIT_HLIST_HEAD(dqinfo->u_dquots + i);
+		INIT_HLIST_HEAD(dqinfo->g_dquots + i);
+	}
+
+	for (i = 0; i < MAXQUOTAS; i++) {
+		/* Used space is stored as unsigned 64-bit value, 2^64 - 1 */
+		dqinfo->dqinfo[i].dqi_maxblimit = 0xffffffffffffffffULL;
+		dqinfo->dqinfo[i].dqi_maxilimit = 0xffffffffffffffffULL;
+
+		/* Grace time is stored as (7*24*60*60) 1 week */
+		dqinfo->dqinfo[i].dqi_igrace = NS_MAX_IQ_TIME;
+		dqinfo->dqinfo[i].dqi_bgrace = NS_MAX_DQ_TIME;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(ns_dqinfo_init);
+
+/*
+ * Free the all allocated disk quotas if a mount namespace with disk
+ * quota enabled will be destroyed.
+ */
+void ns_dqinfo_destroy(struct mnt_namespace *ns)
+{
+	struct ns_quota_info *dqinfo = ns->ns_dqinfo;
+	int i;
+
+	if (!dqinfo)
+		return;
+
+	for (i = 0; i < NS_DQHASH_SZ; ++i) {
+		__remove_dq_hash_list(&dqinfo->u_dquots[i]);
+		__remove_dq_hash_list(&dqinfo->g_dquots[i]);
+	}
+
+	kmem_cache_destroy(dqinfo->dquot_cachep);
+	kfree(dqinfo);
+}
+EXPORT_SYMBOL(ns_dqinfo_destroy);
+
+/*
+ * FIXME:
+ * Need printing out debug information like current container
+ * disk quota VERSION?
+ */
+static int __init ns_dquot_init(void)
+{
+	return 0;
+}
+
+static void __exit ns_dquot_exit(void)
+{
+	return;
+}
+
+module_init(ns_dquot_init);
+module_exit(ns_dquot_exit);
diff --git a/fs/ns_quotaops.h b/fs/ns_quotaops.h
new file mode 100644
index 0000000..6eed233
--- /dev/null
+++ b/fs/ns_quotaops.h
@@ -0,0 +1,72 @@
+#ifndef _LINUX_NS_QUOTAOPS_
+#define _LINUX_NS_QUOTAOPS_
+
+#include <linux/fs.h>
+
+#ifdef CONFIG_NS_QUOTA
+
+extern int do_quotactl_for_container(const char __user *);
+extern int do_container_quotactl(int, int, qid_t, void __user *);
+
+int ns_dquot_alloc_inode(const struct inode *inode);
+void ns_dquot_free_inode(const struct inode *inode);
+int ns_dquot_alloc_block(const struct inode *inode, qsize_t nr);
+void ns_dquot_alloc_block_nofail(const struct inode *inode, qsize_t nr);
+void ns_dquot_free_block(const struct inode *inode, qsize_t nr);
+int ns_dquot_transfer(struct inode *inode, struct iattr *iattr);
+int ns_dquot_reserve_block(struct inode *inode, qsize_t nr);
+void ns_dquot_claim_block(struct inode *inode, qsize_t nr);
+void ns_dquot_release_reservation_block(struct inode *inode, qsize_t nr);
+
+/*
+ * Operations supported for mount namespace disk quotas.
+ */
+extern const struct ns_quotactl_ops ns_quotactl_operations;
+extern const struct ns_dquot_ops ns_dquot_operations;
+
+#else
+
+static inline int ns_dquot_alloc_inode(const struct inode *inode)
+{
+	return 0;
+}
+
+static inline void ns_dquot_free_inode(const struct inode *inode)
+{
+}
+
+static inline void ns_dquot_alloc_block_nofail(const struct inode *inode,
+					       qsize_t nr)
+{
+}
+
+static int ns_dquot_alloc_block(const struct inode *inode, qsize_t nr)
+{
+	return 0;
+}
+
+static void ns_dquot_free_block(const struct inode *inode, qsize_t nr)
+{
+}
+
+static int ns_dquot_transfer(struct inode *inode, struct iattr *iattr)
+{
+	return 0;
+}
+
+static void ns_dquot_claim_block(struct inode *inode, qsize_t nr)
+{
+}
+
+static void ns_dquot_release_reservation_block(struct inode *inode, qsize_t nr)
+{
+}
+
+static int ns_dquot_reserve_block(struct inode *inode, qsize_t nr)
+{
+	return 0;
+}
+
+#endif /* __CONFIG_NS_QUOTA__ */
+
+#endif /* _LINUX_NS_QUOTAOPS_ */
-- 
1.7.9
