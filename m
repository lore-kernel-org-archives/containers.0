From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 25/27] userns: Convert struct dquot dq_id to be a struct kqid
Date: Wed, 19 Sep 2012 18:52:27 -0700
Message-ID: <1348105949-25454-25-git-send-email-ebiederm@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Change struct dquot dq_id to a struct kqid and remove the now
unecessary dq_type.

Make minimal changes to dquot, quota_tree, quota_v1, quota_v2, ext3,
ext4, and ocfs2 to deal with the change in quota structures and
signatures.  The ocfs2 changes are larger than most because of the
extensive tracing throughout the ocfs2 quota code that prints out
dq_id.

quota_tree.c:get_index is modified to take a struct kqid instead of a
qid_t because all of it's callers pass in dquot->dq_id and it allows
me to introduce only a single conversion.

The rest of the changes are either just replacing dq_type with dq_id.type,
adding conversions to deal with the change in type and occassionally
adding qid_eq to allow quota id comparisons in a user namespace safe way.

Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>
Cc: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>
Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ext3/super.c         |    2 +-
 fs/ext4/super.c         |    2 +-
 fs/ocfs2/quota_global.c |   43 +++++++++++++++++++------------
 fs/ocfs2/quota_local.c  |   11 ++++---
 fs/quota/dquot.c        |   63 ++++++++++++++++++++++++-----------------------
 fs/quota/quota_tree.c   |   22 +++++++++------
 fs/quota/quota_v1.c     |   12 +++++---
 fs/quota/quota_v2.c     |   26 +++++++++++--------
 include/linux/quota.h   |    3 +-
 9 files changed, 102 insertions(+), 82 deletions(-)

diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index ff9bcdc..73e42f5 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -2814,7 +2814,7 @@ static int ext3_statfs (struct dentry * dentry, struct kstatfs * buf)
 
 static inline struct inode *dquot_to_inode(struct dquot *dquot)
 {
-	return sb_dqopt(dquot->dq_sb)->files[dquot->dq_type];
+	return sb_dqopt(dquot->dq_sb)->files[dquot->dq_id.type];
 }
 
 static int ext3_write_dquot(struct dquot *dquot)
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index d76ec82..78e6036 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -4796,7 +4796,7 @@ static int ext4_statfs(struct dentry *dentry, struct kstatfs *buf)
 
 static inline struct inode *dquot_to_inode(struct dquot *dquot)
 {
-	return sb_dqopt(dquot->dq_sb)->files[dquot->dq_type];
+	return sb_dqopt(dquot->dq_sb)->files[dquot->dq_id.type];
 }
 
 static int ext4_write_dquot(struct dquot *dquot)
diff --git a/fs/ocfs2/quota_global.c b/fs/ocfs2/quota_global.c
index 0a86e30..332a281 100644
--- a/fs/ocfs2/quota_global.c
+++ b/fs/ocfs2/quota_global.c
@@ -95,7 +95,7 @@ static void ocfs2_global_mem2diskdqb(void *dp, struct dquot *dquot)
 	struct ocfs2_global_disk_dqblk *d = dp;
 	struct mem_dqblk *m = &dquot->dq_dqb;
 
-	d->dqb_id = cpu_to_le32(dquot->dq_id);
+	d->dqb_id = cpu_to_le32(from_kqid(&init_user_ns, dquot->dq_id));
 	d->dqb_use_count = cpu_to_le32(OCFS2_DQUOT(dquot)->dq_use_count);
 	d->dqb_ihardlimit = cpu_to_le64(m->dqb_ihardlimit);
 	d->dqb_isoftlimit = cpu_to_le64(m->dqb_isoftlimit);
@@ -112,11 +112,14 @@ static int ocfs2_global_is_id(void *dp, struct dquot *dquot)
 {
 	struct ocfs2_global_disk_dqblk *d = dp;
 	struct ocfs2_mem_dqinfo *oinfo =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_id.type)->dqi_priv;
 
 	if (qtree_entry_unused(&oinfo->dqi_gi, dp))
 		return 0;
-	return le32_to_cpu(d->dqb_id) == dquot->dq_id;
+
+	return qid_eq(make_kqid(&init_user_ns, dquot->dq_id.type,
+				le32_to_cpu(d->dqb_id)),
+		      dquot->dq_id);
 }
 
 struct qtree_fmt_operations ocfs2_global_ops = {
@@ -475,7 +478,7 @@ int __ocfs2_sync_dquot(struct dquot *dquot, int freeing)
 {
 	int err, err2;
 	struct super_block *sb = dquot->dq_sb;
-	int type = dquot->dq_type;
+	int type = dquot->dq_id.type;
 	struct ocfs2_mem_dqinfo *info = sb_dqinfo(sb, type)->dqi_priv;
 	struct ocfs2_global_disk_dqblk dqblk;
 	s64 spacechange, inodechange;
@@ -504,7 +507,8 @@ int __ocfs2_sync_dquot(struct dquot *dquot, int freeing)
 	olditime = dquot->dq_dqb.dqb_itime;
 	oldbtime = dquot->dq_dqb.dqb_btime;
 	ocfs2_global_disk2memdqb(dquot, &dqblk);
-	trace_ocfs2_sync_dquot(dquot->dq_id, dquot->dq_dqb.dqb_curspace,
+	trace_ocfs2_sync_dquot(from_kqid(&init_user_ns, dquot->dq_id),
+			       dquot->dq_dqb.dqb_curspace,
 			       (long long)spacechange,
 			       dquot->dq_dqb.dqb_curinodes,
 			       (long long)inodechange);
@@ -555,8 +559,8 @@ int __ocfs2_sync_dquot(struct dquot *dquot, int freeing)
 	err = ocfs2_qinfo_lock(info, freeing);
 	if (err < 0) {
 		mlog(ML_ERROR, "Failed to lock quota info, losing quota write"
-			       " (type=%d, id=%u)\n", dquot->dq_type,
-			       (unsigned)dquot->dq_id);
+			       " (type=%d, id=%u)\n", dquot->dq_id.type,
+			       (unsigned)from_kqid(&init_user_ns, dquot->dq_id));
 		goto out;
 	}
 	if (freeing)
@@ -591,9 +595,10 @@ static int ocfs2_sync_dquot_helper(struct dquot *dquot, unsigned long type)
 	struct ocfs2_super *osb = OCFS2_SB(sb);
 	int status = 0;
 
-	trace_ocfs2_sync_dquot_helper(dquot->dq_id, dquot->dq_type,
+	trace_ocfs2_sync_dquot_helper(from_kqid(&init_user_ns, dquot->dq_id),
+				      dquot->dq_id.type,
 				      type, sb->s_id);
-	if (type != dquot->dq_type)
+	if (type != dquot->dq_id.type)
 		goto out;
 	status = ocfs2_lock_global_qf(oinfo, 1);
 	if (status < 0)
@@ -643,7 +648,8 @@ static int ocfs2_write_dquot(struct dquot *dquot)
 	struct ocfs2_super *osb = OCFS2_SB(dquot->dq_sb);
 	int status = 0;
 
-	trace_ocfs2_write_dquot(dquot->dq_id, dquot->dq_type);
+	trace_ocfs2_write_dquot(from_kqid(&init_user_ns, dquot->dq_id),
+				dquot->dq_id.type);
 
 	handle = ocfs2_start_trans(osb, OCFS2_QWRITE_CREDITS);
 	if (IS_ERR(handle)) {
@@ -677,11 +683,12 @@ static int ocfs2_release_dquot(struct dquot *dquot)
 {
 	handle_t *handle;
 	struct ocfs2_mem_dqinfo *oinfo =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_id.type)->dqi_priv;
 	struct ocfs2_super *osb = OCFS2_SB(dquot->dq_sb);
 	int status = 0;
 
-	trace_ocfs2_release_dquot(dquot->dq_id, dquot->dq_type);
+	trace_ocfs2_release_dquot(from_kqid(&init_user_ns, dquot->dq_id),
+				  dquot->dq_id.type);
 
 	mutex_lock(&dquot->dq_lock);
 	/* Check whether we are not racing with some other dqget() */
@@ -691,7 +698,7 @@ static int ocfs2_release_dquot(struct dquot *dquot)
 	if (status < 0)
 		goto out;
 	handle = ocfs2_start_trans(osb,
-		ocfs2_calc_qdel_credits(dquot->dq_sb, dquot->dq_type));
+		ocfs2_calc_qdel_credits(dquot->dq_sb, dquot->dq_id.type));
 	if (IS_ERR(handle)) {
 		status = PTR_ERR(handle);
 		mlog_errno(status);
@@ -733,13 +740,14 @@ static int ocfs2_acquire_dquot(struct dquot *dquot)
 	int ex = 0;
 	struct super_block *sb = dquot->dq_sb;
 	struct ocfs2_super *osb = OCFS2_SB(sb);
-	int type = dquot->dq_type;
+	int type = dquot->dq_id.type;
 	struct ocfs2_mem_dqinfo *info = sb_dqinfo(sb, type)->dqi_priv;
 	struct inode *gqinode = info->dqi_gqinode;
 	int need_alloc = ocfs2_global_qinit_alloc(sb, type);
 	handle_t *handle;
 
-	trace_ocfs2_acquire_dquot(dquot->dq_id, type);
+	trace_ocfs2_acquire_dquot(from_kqid(&init_user_ns, dquot->dq_id),
+				  type);
 	mutex_lock(&dquot->dq_lock);
 	/*
 	 * We need an exclusive lock, because we're going to update use count
@@ -821,12 +829,13 @@ static int ocfs2_mark_dquot_dirty(struct dquot *dquot)
 	int sync = 0;
 	int status;
 	struct super_block *sb = dquot->dq_sb;
-	int type = dquot->dq_type;
+	int type = dquot->dq_id.type;
 	struct ocfs2_mem_dqinfo *oinfo = sb_dqinfo(sb, type)->dqi_priv;
 	handle_t *handle;
 	struct ocfs2_super *osb = OCFS2_SB(sb);
 
-	trace_ocfs2_mark_dquot_dirty(dquot->dq_id, type);
+	trace_ocfs2_mark_dquot_dirty(from_kqid(&init_user_ns, dquot->dq_id),
+				     type);
 
 	/* In case user set some limits, sync dquot immediately to global
 	 * quota file so that information propagates quicker */
diff --git a/fs/ocfs2/quota_local.c b/fs/ocfs2/quota_local.c
index 020f0ba..27fe7ee 100644
--- a/fs/ocfs2/quota_local.c
+++ b/fs/ocfs2/quota_local.c
@@ -883,7 +883,8 @@ static void olq_set_dquot(struct buffer_head *bh, void *private)
 	dqblk = (struct ocfs2_local_disk_dqblk *)(bh->b_data
 		+ ol_dqblk_block_offset(sb, od->dq_local_off));
 
-	dqblk->dqb_id = cpu_to_le64(od->dq_dquot.dq_id);
+	dqblk->dqb_id = cpu_to_le64(from_kqid(&init_user_ns,
+					      od->dq_dquot.dq_id));
 	spin_lock(&dq_data_lock);
 	dqblk->dqb_spacemod = cpu_to_le64(od->dq_dquot.dq_dqb.dqb_curspace -
 					  od->dq_origspace);
@@ -893,7 +894,7 @@ static void olq_set_dquot(struct buffer_head *bh, void *private)
 	trace_olq_set_dquot(
 		(unsigned long long)le64_to_cpu(dqblk->dqb_spacemod),
 		(unsigned long long)le64_to_cpu(dqblk->dqb_inodemod),
-		od->dq_dquot.dq_id);
+		from_kqid(&init_user_ns, od->dq_dquot.dq_id));
 }
 
 /* Write dquot to local quota file */
@@ -902,7 +903,7 @@ int ocfs2_local_write_dquot(struct dquot *dquot)
 	struct super_block *sb = dquot->dq_sb;
 	struct ocfs2_dquot *od = OCFS2_DQUOT(dquot);
 	struct buffer_head *bh;
-	struct inode *lqinode = sb_dqopt(sb)->files[dquot->dq_type];
+	struct inode *lqinode = sb_dqopt(sb)->files[dquot->dq_id.type];
 	int status;
 
 	status = ocfs2_read_quota_phys_block(lqinode, od->dq_local_phys_blk,
@@ -1223,7 +1224,7 @@ static void olq_alloc_dquot(struct buffer_head *bh, void *private)
 int ocfs2_create_local_dquot(struct dquot *dquot)
 {
 	struct super_block *sb = dquot->dq_sb;
-	int type = dquot->dq_type;
+	int type = dquot->dq_id.type;
 	struct inode *lqinode = sb_dqopt(sb)->files[type];
 	struct ocfs2_quota_chunk *chunk;
 	struct ocfs2_dquot *od = OCFS2_DQUOT(dquot);
@@ -1277,7 +1278,7 @@ out:
 int ocfs2_local_release_dquot(handle_t *handle, struct dquot *dquot)
 {
 	int status;
-	int type = dquot->dq_type;
+	int type = dquot->dq_id.type;
 	struct ocfs2_dquot *od = OCFS2_DQUOT(dquot);
 	struct super_block *sb = dquot->dq_sb;
 	struct ocfs2_local_disk_chunk *dchunk;
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 53e377a..efaeed3 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -267,7 +267,7 @@ hashfn(const struct super_block *sb, unsigned int id, int type)
 static inline void insert_dquot_hash(struct dquot *dquot)
 {
 	struct hlist_head *head;
-	head = dquot_hash + hashfn(dquot->dq_sb, dquot->dq_id, dquot->dq_type);
+	head = dquot_hash + hashfn(dquot->dq_sb, from_kqid(&init_user_ns, dquot->dq_id), dquot->dq_id.type);
 	hlist_add_head(&dquot->dq_hash, head);
 }
 
@@ -279,13 +279,13 @@ static inline void remove_dquot_hash(struct dquot *dquot)
 static struct dquot *find_dquot(unsigned int hashent, struct super_block *sb,
 				unsigned int id, int type)
 {
+	struct kqid qid = make_kqid(&init_user_ns, type, id);
 	struct hlist_node *node;
 	struct dquot *dquot;
 
 	hlist_for_each (node, dquot_hash+hashent) {
 		dquot = hlist_entry(node, struct dquot, dq_hash);
-		if (dquot->dq_sb == sb && dquot->dq_id == id &&
-		    dquot->dq_type == type)
+		if (dquot->dq_sb == sb && qid_eq(dquot->dq_id, qid))
 			return dquot;
 	}
 	return NULL;
@@ -351,7 +351,7 @@ int dquot_mark_dquot_dirty(struct dquot *dquot)
 	spin_lock(&dq_list_lock);
 	if (!test_and_set_bit(DQ_MOD_B, &dquot->dq_flags)) {
 		list_add(&dquot->dq_dirty, &sb_dqopt(dquot->dq_sb)->
-				info[dquot->dq_type].dqi_dirty_list);
+				info[dquot->dq_id.type].dqi_dirty_list);
 		ret = 0;
 	}
 	spin_unlock(&dq_list_lock);
@@ -410,17 +410,17 @@ int dquot_acquire(struct dquot *dquot)
 	mutex_lock(&dquot->dq_lock);
 	mutex_lock(&dqopt->dqio_mutex);
 	if (!test_bit(DQ_READ_B, &dquot->dq_flags))
-		ret = dqopt->ops[dquot->dq_type]->read_dqblk(dquot);
+		ret = dqopt->ops[dquot->dq_id.type]->read_dqblk(dquot);
 	if (ret < 0)
 		goto out_iolock;
 	set_bit(DQ_READ_B, &dquot->dq_flags);
 	/* Instantiate dquot if needed */
 	if (!test_bit(DQ_ACTIVE_B, &dquot->dq_flags) && !dquot->dq_off) {
-		ret = dqopt->ops[dquot->dq_type]->commit_dqblk(dquot);
+		ret = dqopt->ops[dquot->dq_id.type]->commit_dqblk(dquot);
 		/* Write the info if needed */
-		if (info_dirty(&dqopt->info[dquot->dq_type])) {
-			ret2 = dqopt->ops[dquot->dq_type]->write_file_info(
-						dquot->dq_sb, dquot->dq_type);
+		if (info_dirty(&dqopt->info[dquot->dq_id.type])) {
+			ret2 = dqopt->ops[dquot->dq_id.type]->write_file_info(
+					dquot->dq_sb, dquot->dq_id.type);
 		}
 		if (ret < 0)
 			goto out_iolock;
@@ -455,7 +455,7 @@ int dquot_commit(struct dquot *dquot)
 	/* Inactive dquot can be only if there was error during read/init
 	 * => we have better not writing it */
 	if (test_bit(DQ_ACTIVE_B, &dquot->dq_flags))
-		ret = dqopt->ops[dquot->dq_type]->commit_dqblk(dquot);
+		ret = dqopt->ops[dquot->dq_id.type]->commit_dqblk(dquot);
 	else
 		ret = -EIO;
 out_sem:
@@ -477,12 +477,12 @@ int dquot_release(struct dquot *dquot)
 	if (atomic_read(&dquot->dq_count) > 1)
 		goto out_dqlock;
 	mutex_lock(&dqopt->dqio_mutex);
-	if (dqopt->ops[dquot->dq_type]->release_dqblk) {
-		ret = dqopt->ops[dquot->dq_type]->release_dqblk(dquot);
+	if (dqopt->ops[dquot->dq_id.type]->release_dqblk) {
+		ret = dqopt->ops[dquot->dq_id.type]->release_dqblk(dquot);
 		/* Write the info */
-		if (info_dirty(&dqopt->info[dquot->dq_type])) {
-			ret2 = dqopt->ops[dquot->dq_type]->write_file_info(
-						dquot->dq_sb, dquot->dq_type);
+		if (info_dirty(&dqopt->info[dquot->dq_id.type])) {
+			ret2 = dqopt->ops[dquot->dq_id.type]->write_file_info(
+						dquot->dq_sb, dquot->dq_id.type);
 		}
 		if (ret >= 0)
 			ret = ret2;
@@ -521,7 +521,7 @@ restart:
 	list_for_each_entry_safe(dquot, tmp, &inuse_list, dq_inuse) {
 		if (dquot->dq_sb != sb)
 			continue;
-		if (dquot->dq_type != type)
+		if (dquot->dq_id.type != type)
 			continue;
 		/* Wait for dquot users */
 		if (atomic_read(&dquot->dq_count)) {
@@ -741,7 +741,8 @@ void dqput(struct dquot *dquot)
 #ifdef CONFIG_QUOTA_DEBUG
 	if (!atomic_read(&dquot->dq_count)) {
 		quota_error(dquot->dq_sb, "trying to free free dquot of %s %d",
-			    quotatypes[dquot->dq_type], dquot->dq_id);
+			    quotatypes[dquot->dq_id.type],
+			    from_kqid(&init_user_ns, dquot->dq_id));
 		BUG();
 	}
 #endif
@@ -752,7 +753,7 @@ we_slept:
 		/* We have more than one user... nothing to do */
 		atomic_dec(&dquot->dq_count);
 		/* Releasing dquot during quotaoff phase? */
-		if (!sb_has_quota_active(dquot->dq_sb, dquot->dq_type) &&
+		if (!sb_has_quota_active(dquot->dq_sb, dquot->dq_id.type) &&
 		    atomic_read(&dquot->dq_count) == 1)
 			wake_up(&dquot->dq_wait_unused);
 		spin_unlock(&dq_list_lock);
@@ -815,7 +816,7 @@ static struct dquot *get_empty_dquot(struct super_block *sb, int type)
 	INIT_LIST_HEAD(&dquot->dq_dirty);
 	init_waitqueue_head(&dquot->dq_wait_unused);
 	dquot->dq_sb = sb;
-	dquot->dq_type = type;
+	dquot->dq_id.type = type;
 	atomic_set(&dquot->dq_count, 1);
 
 	return dquot;
@@ -859,7 +860,7 @@ we_slept:
 		}
 		dquot = empty;
 		empty = NULL;
-		dquot->dq_id = id;
+		dquot->dq_id = qid;
 		/* all dquots go on the inuse_list */
 		put_inuse(dquot);
 		/* hash it first so it can be found */
@@ -1219,8 +1220,8 @@ static void prepare_warning(struct dquot_warn *warn, struct dquot *dquot,
 		return;
 	warn->w_type = warntype;
 	warn->w_sb = dquot->dq_sb;
-	warn->w_dq_id = dquot->dq_id;
-	warn->w_dq_type = dquot->dq_type;
+	warn->w_dq_id = from_kqid(&init_user_ns, dquot->dq_id);
+	warn->w_dq_type = dquot->dq_id.type;
 }
 
 /*
@@ -1245,7 +1246,7 @@ static void flush_warnings(struct dquot_warn *warn)
 
 static int ignore_hardlimit(struct dquot *dquot)
 {
-	struct mem_dqinfo *info = &sb_dqopt(dquot->dq_sb)->info[dquot->dq_type];
+	struct mem_dqinfo *info = &sb_dqopt(dquot->dq_sb)->info[dquot->dq_id.type];
 
 	return capable(CAP_SYS_RESOURCE) &&
 	       (info->dqi_format->qf_fmt_id != QFMT_VFS_OLD ||
@@ -1258,7 +1259,7 @@ static int check_idq(struct dquot *dquot, qsize_t inodes,
 {
 	qsize_t newinodes = dquot->dq_dqb.dqb_curinodes + inodes;
 
-	if (!sb_has_quota_limits_enabled(dquot->dq_sb, dquot->dq_type) ||
+	if (!sb_has_quota_limits_enabled(dquot->dq_sb, dquot->dq_id.type) ||
 	    test_bit(DQ_FAKE_B, &dquot->dq_flags))
 		return 0;
 
@@ -1283,7 +1284,7 @@ static int check_idq(struct dquot *dquot, qsize_t inodes,
 	    dquot->dq_dqb.dqb_itime == 0) {
 		prepare_warning(warn, dquot, QUOTA_NL_ISOFTWARN);
 		dquot->dq_dqb.dqb_itime = get_seconds() +
-		    sb_dqopt(dquot->dq_sb)->info[dquot->dq_type].dqi_igrace;
+		    sb_dqopt(dquot->dq_sb)->info[dquot->dq_id.type].dqi_igrace;
 	}
 
 	return 0;
@@ -1296,7 +1297,7 @@ static int check_bdq(struct dquot *dquot, qsize_t space, int prealloc,
 	qsize_t tspace;
 	struct super_block *sb = dquot->dq_sb;
 
-	if (!sb_has_quota_limits_enabled(sb, dquot->dq_type) ||
+	if (!sb_has_quota_limits_enabled(sb, dquot->dq_id.type) ||
 	    test_bit(DQ_FAKE_B, &dquot->dq_flags))
 		return 0;
 
@@ -1327,7 +1328,7 @@ static int check_bdq(struct dquot *dquot, qsize_t space, int prealloc,
 		if (!prealloc) {
 			prepare_warning(warn, dquot, QUOTA_NL_BSOFTWARN);
 			dquot->dq_dqb.dqb_btime = get_seconds() +
-			    sb_dqopt(sb)->info[dquot->dq_type].dqi_bgrace;
+			    sb_dqopt(sb)->info[dquot->dq_id.type].dqi_bgrace;
 		}
 		else
 			/*
@@ -1346,7 +1347,7 @@ static int info_idq_free(struct dquot *dquot, qsize_t inodes)
 
 	if (test_bit(DQ_FAKE_B, &dquot->dq_flags) ||
 	    dquot->dq_dqb.dqb_curinodes <= dquot->dq_dqb.dqb_isoftlimit ||
-	    !sb_has_quota_limits_enabled(dquot->dq_sb, dquot->dq_type))
+	    !sb_has_quota_limits_enabled(dquot->dq_sb, dquot->dq_id.type))
 		return QUOTA_NL_NOWARN;
 
 	newinodes = dquot->dq_dqb.dqb_curinodes - inodes;
@@ -2362,9 +2363,9 @@ static void do_get_dqblk(struct dquot *dquot, struct fs_disk_quota *di)
 
 	memset(di, 0, sizeof(*di));
 	di->d_version = FS_DQUOT_VERSION;
-	di->d_flags = dquot->dq_type == USRQUOTA ?
+	di->d_flags = dquot->dq_id.type == USRQUOTA ?
 			FS_USER_QUOTA : FS_GROUP_QUOTA;
-	di->d_id = dquot->dq_id;
+	di->d_id = from_kqid_munged(current_user_ns(), dquot->dq_id);
 
 	spin_lock(&dq_data_lock);
 	di->d_blk_hardlimit = stoqb(dm->dqb_bhardlimit);
@@ -2403,7 +2404,7 @@ static int do_set_dqblk(struct dquot *dquot, struct fs_disk_quota *di)
 {
 	struct mem_dqblk *dm = &dquot->dq_dqb;
 	int check_blim = 0, check_ilim = 0;
-	struct mem_dqinfo *dqi = &sb_dqopt(dquot->dq_sb)->info[dquot->dq_type];
+	struct mem_dqinfo *dqi = &sb_dqopt(dquot->dq_sb)->info[dquot->dq_id.type];
 
 	if (di->d_fieldmask & ~VFS_FS_DQ_MASK)
 		return -EINVAL;
diff --git a/fs/quota/quota_tree.c b/fs/quota/quota_tree.c
index e41c1becf..d65877f 100644
--- a/fs/quota/quota_tree.c
+++ b/fs/quota/quota_tree.c
@@ -22,9 +22,10 @@ MODULE_LICENSE("GPL");
 
 #define __QUOTA_QT_PARANOIA
 
-static int get_index(struct qtree_mem_dqinfo *info, qid_t id, int depth)
+static int get_index(struct qtree_mem_dqinfo *info, struct kqid qid, int depth)
 {
 	unsigned int epb = info->dqi_usable_bs >> 2;
+	qid_t id = from_kqid(&init_user_ns, qid);
 
 	depth = info->dqi_qtree_depth - depth - 1;
 	while (depth--)
@@ -244,7 +245,7 @@ static uint find_free_dqentry(struct qtree_mem_dqinfo *info,
 		/* This is enough as the block is already zeroed and the entry
 		 * list is empty... */
 		info->dqi_free_entry = blk;
-		mark_info_dirty(dquot->dq_sb, dquot->dq_type);
+		mark_info_dirty(dquot->dq_sb, dquot->dq_id.type);
 	}
 	/* Block will be full? */
 	if (le16_to_cpu(dh->dqdh_entries) + 1 >= qtree_dqstr_in_blk(info)) {
@@ -357,7 +358,7 @@ static inline int dq_insert_tree(struct qtree_mem_dqinfo *info,
  */
 int qtree_write_dquot(struct qtree_mem_dqinfo *info, struct dquot *dquot)
 {
-	int type = dquot->dq_type;
+	int type = dquot->dq_id.type;
 	struct super_block *sb = dquot->dq_sb;
 	ssize_t ret;
 	char *ddquot = getdqbuf(info->dqi_entry_size);
@@ -538,8 +539,9 @@ static loff_t find_block_dqentry(struct qtree_mem_dqinfo *info,
 		ddquot += info->dqi_entry_size;
 	}
 	if (i == qtree_dqstr_in_blk(info)) {
-		quota_error(dquot->dq_sb, "Quota for id %u referenced "
-			    "but not present", dquot->dq_id);
+		quota_error(dquot->dq_sb,
+			    "Quota for id %u referenced but not present",
+			    from_kqid(&init_user_ns, dquot->dq_id));
 		ret = -EIO;
 		goto out_buf;
 	} else {
@@ -589,7 +591,7 @@ static inline loff_t find_dqentry(struct qtree_mem_dqinfo *info,
 
 int qtree_read_dquot(struct qtree_mem_dqinfo *info, struct dquot *dquot)
 {
-	int type = dquot->dq_type;
+	int type = dquot->dq_id.type;
 	struct super_block *sb = dquot->dq_sb;
 	loff_t offset;
 	char *ddquot;
@@ -607,8 +609,10 @@ int qtree_read_dquot(struct qtree_mem_dqinfo *info, struct dquot *dquot)
 		offset = find_dqentry(info, dquot);
 		if (offset <= 0) {	/* Entry not present? */
 			if (offset < 0)
-				quota_error(sb, "Can't read quota structure "
-					    "for id %u", dquot->dq_id);
+				quota_error(sb,"Can't read quota structure "
+					    "for id %u",
+					    from_kqid(&init_user_ns,
+						      dquot->dq_id));
 			dquot->dq_off = 0;
 			set_bit(DQ_FAKE_B, &dquot->dq_flags);
 			memset(&dquot->dq_dqb, 0, sizeof(struct mem_dqblk));
@@ -626,7 +630,7 @@ int qtree_read_dquot(struct qtree_mem_dqinfo *info, struct dquot *dquot)
 		if (ret >= 0)
 			ret = -EIO;
 		quota_error(sb, "Error while reading quota structure for id %u",
-			    dquot->dq_id);
+			    from_kqid(&init_user_ns, dquot->dq_id));
 		set_bit(DQ_FAKE_B, &dquot->dq_flags);
 		memset(&dquot->dq_dqb, 0, sizeof(struct mem_dqblk));
 		kfree(ddquot);
diff --git a/fs/quota/quota_v1.c b/fs/quota/quota_v1.c
index 34b37a6..469c684 100644
--- a/fs/quota/quota_v1.c
+++ b/fs/quota/quota_v1.c
@@ -54,7 +54,7 @@ static void v1_mem2disk_dqblk(struct v1_disk_dqblk *d, struct mem_dqblk *m)
 
 static int v1_read_dqblk(struct dquot *dquot)
 {
-	int type = dquot->dq_type;
+	int type = dquot->dq_id.type;
 	struct v1_disk_dqblk dqblk;
 
 	if (!sb_dqopt(dquot->dq_sb)->files[type])
@@ -63,7 +63,8 @@ static int v1_read_dqblk(struct dquot *dquot)
 	/* Set structure to 0s in case read fails/is after end of file */
 	memset(&dqblk, 0, sizeof(struct v1_disk_dqblk));
 	dquot->dq_sb->s_op->quota_read(dquot->dq_sb, type, (char *)&dqblk,
-			sizeof(struct v1_disk_dqblk), v1_dqoff(dquot->dq_id));
+			sizeof(struct v1_disk_dqblk),
+			v1_dqoff(from_kqid(&init_user_ns, dquot->dq_id)));
 
 	v1_disk2mem_dqblk(&dquot->dq_dqb, &dqblk);
 	if (dquot->dq_dqb.dqb_bhardlimit == 0 &&
@@ -78,12 +79,13 @@ static int v1_read_dqblk(struct dquot *dquot)
 
 static int v1_commit_dqblk(struct dquot *dquot)
 {
-	short type = dquot->dq_type;
+	short type = dquot->dq_id.type;
 	ssize_t ret;
 	struct v1_disk_dqblk dqblk;
 
 	v1_mem2disk_dqblk(&dqblk, &dquot->dq_dqb);
-	if (dquot->dq_id == 0) {
+	if (((type == USRQUOTA) && uid_eq(dquot->dq_id.uid, GLOBAL_ROOT_UID)) ||
+	    ((type == GRPQUOTA) && gid_eq(dquot->dq_id.gid, GLOBAL_ROOT_GID))) {
 		dqblk.dqb_btime =
 			sb_dqopt(dquot->dq_sb)->info[type].dqi_bgrace;
 		dqblk.dqb_itime =
@@ -93,7 +95,7 @@ static int v1_commit_dqblk(struct dquot *dquot)
 	if (sb_dqopt(dquot->dq_sb)->files[type])
 		ret = dquot->dq_sb->s_op->quota_write(dquot->dq_sb, type,
 			(char *)&dqblk, sizeof(struct v1_disk_dqblk),
-			v1_dqoff(dquot->dq_id));
+			v1_dqoff(from_kqid(&init_user_ns, dquot->dq_id)));
 	if (ret != sizeof(struct v1_disk_dqblk)) {
 		quota_error(dquot->dq_sb, "dquota write failed");
 		if (ret >= 0)
diff --git a/fs/quota/quota_v2.c b/fs/quota/quota_v2.c
index f1ab360..02751ec 100644
--- a/fs/quota/quota_v2.c
+++ b/fs/quota/quota_v2.c
@@ -196,7 +196,7 @@ static void v2r0_mem2diskdqb(void *dp, struct dquot *dquot)
 	struct v2r0_disk_dqblk *d = dp;
 	struct mem_dqblk *m = &dquot->dq_dqb;
 	struct qtree_mem_dqinfo *info =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_id.type)->dqi_priv;
 
 	d->dqb_ihardlimit = cpu_to_le32(m->dqb_ihardlimit);
 	d->dqb_isoftlimit = cpu_to_le32(m->dqb_isoftlimit);
@@ -206,7 +206,7 @@ static void v2r0_mem2diskdqb(void *dp, struct dquot *dquot)
 	d->dqb_bsoftlimit = cpu_to_le32(v2_stoqb(m->dqb_bsoftlimit));
 	d->dqb_curspace = cpu_to_le64(m->dqb_curspace);
 	d->dqb_btime = cpu_to_le64(m->dqb_btime);
-	d->dqb_id = cpu_to_le32(dquot->dq_id);
+	d->dqb_id = cpu_to_le32(from_kqid(&init_user_ns, dquot->dq_id));
 	if (qtree_entry_unused(info, dp))
 		d->dqb_itime = cpu_to_le64(1);
 }
@@ -215,11 +215,13 @@ static int v2r0_is_id(void *dp, struct dquot *dquot)
 {
 	struct v2r0_disk_dqblk *d = dp;
 	struct qtree_mem_dqinfo *info =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_id.type)->dqi_priv;
 
 	if (qtree_entry_unused(info, dp))
 		return 0;
-	return le32_to_cpu(d->dqb_id) == dquot->dq_id;
+	return qid_eq(make_kqid(&init_user_ns, dquot->dq_id.type,
+				le32_to_cpu(d->dqb_id)),
+		      dquot->dq_id);
 }
 
 static void v2r1_disk2memdqb(struct dquot *dquot, void *dp)
@@ -247,7 +249,7 @@ static void v2r1_mem2diskdqb(void *dp, struct dquot *dquot)
 	struct v2r1_disk_dqblk *d = dp;
 	struct mem_dqblk *m = &dquot->dq_dqb;
 	struct qtree_mem_dqinfo *info =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_id.type)->dqi_priv;
 
 	d->dqb_ihardlimit = cpu_to_le64(m->dqb_ihardlimit);
 	d->dqb_isoftlimit = cpu_to_le64(m->dqb_isoftlimit);
@@ -257,7 +259,7 @@ static void v2r1_mem2diskdqb(void *dp, struct dquot *dquot)
 	d->dqb_bsoftlimit = cpu_to_le64(v2_stoqb(m->dqb_bsoftlimit));
 	d->dqb_curspace = cpu_to_le64(m->dqb_curspace);
 	d->dqb_btime = cpu_to_le64(m->dqb_btime);
-	d->dqb_id = cpu_to_le32(dquot->dq_id);
+	d->dqb_id = cpu_to_le32(from_kqid(&init_user_ns, dquot->dq_id));
 	if (qtree_entry_unused(info, dp))
 		d->dqb_itime = cpu_to_le64(1);
 }
@@ -266,26 +268,28 @@ static int v2r1_is_id(void *dp, struct dquot *dquot)
 {
 	struct v2r1_disk_dqblk *d = dp;
 	struct qtree_mem_dqinfo *info =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_id.type)->dqi_priv;
 
 	if (qtree_entry_unused(info, dp))
 		return 0;
-	return le32_to_cpu(d->dqb_id) == dquot->dq_id;
+	return qid_eq(make_kqid(&init_user_ns, dquot->dq_id.type,
+				le32_to_cpu(d->dqb_id)),
+		      dquot->dq_id);
 }
 
 static int v2_read_dquot(struct dquot *dquot)
 {
-	return qtree_read_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv, dquot);
+	return qtree_read_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_id.type)->dqi_priv, dquot);
 }
 
 static int v2_write_dquot(struct dquot *dquot)
 {
-	return qtree_write_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv, dquot);
+	return qtree_write_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_id.type)->dqi_priv, dquot);
 }
 
 static int v2_release_dquot(struct dquot *dquot)
 {
-	return qtree_release_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv, dquot);
+	return qtree_release_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_id.type)->dqi_priv, dquot);
 }
 
 static int v2_free_file_info(struct super_block *sb, int type)
diff --git a/include/linux/quota.h b/include/linux/quota.h
index 8b27604..dcd5721 100644
--- a/include/linux/quota.h
+++ b/include/linux/quota.h
@@ -419,10 +419,9 @@ struct dquot {
 	atomic_t dq_count;		/* Use count */
 	wait_queue_head_t dq_wait_unused;	/* Wait queue for dquot to become unused */
 	struct super_block *dq_sb;	/* superblock this applies to */
-	unsigned int dq_id;		/* ID this applies to (uid, gid) */
+	struct kqid dq_id;		/* ID this applies to (uid, gid, projid) */
 	loff_t dq_off;			/* Offset of dquot on disk */
 	unsigned long dq_flags;		/* See DQ_* */
-	short dq_type;			/* Type of quota */
 	struct mem_dqblk dq_dqb;	/* Diskquota usage */
 };
 
-- 
1.7.5.4
