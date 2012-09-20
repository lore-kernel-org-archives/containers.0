From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 22/27] userns: Convert qutoactl
Date: Wed, 19 Sep 2012 18:52:24 -0700
Message-ID: <1348105949-25454-22-git-send-email-ebiederm@xmission.com>
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
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Update the quotactl user space interface to successfull compile with
user namespaces support enabled and to hand off quota identifiers to
lower layers of the kernel in struct kqid instead of type and qid
pairs.

The quota on function is not converted because while it takes a quota
type and an id.  The id is the on disk quota format to use, which
is something completely different.

The signature of two struct quotactl_ops methods were changed to take
struct kqid argumetns get_dqblk and set_dqblk.

The dquot, xfs, and ocfs2 implementations of get_dqblk and set_dqblk
are minimally changed so that the code continues to work with
the change in parameter type.

This is the first in a series of changes to always store quota
identifiers in the kernel in struct kqid and only use raw type and qid
values when interacting with on disk structures or userspace.  Always
using struct kqid internally makes it hard to miss places that need
conversion to or from the kernel internal values.

Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>
Cc: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/gfs2/quota.c          |   20 +++++++++++---------
 fs/quota/dquot.c         |    8 ++++----
 fs/quota/quota.c         |   28 ++++++++++++++++++++++------
 fs/xfs/xfs_quotaops.c    |   12 ++++++------
 include/linux/quota.h    |    4 ++--
 include/linux/quotaops.h |    4 ++--
 init/Kconfig             |    2 +-
 7 files changed, 48 insertions(+), 30 deletions(-)

diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index a3bde91..b311539 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -1469,7 +1469,7 @@ static int gfs2_quota_get_xstate(struct super_block *sb,
 	return 0;
 }
 
-static int gfs2_get_dqblk(struct super_block *sb, int type, qid_t id,
+static int gfs2_get_dqblk(struct super_block *sb, struct kqid qid,
 			  struct fs_disk_quota *fdq)
 {
 	struct gfs2_sbd *sdp = sb->s_fs_info;
@@ -1477,20 +1477,21 @@ static int gfs2_get_dqblk(struct super_block *sb, int type, qid_t id,
 	struct gfs2_quota_data *qd;
 	struct gfs2_holder q_gh;
 	int error;
+	int type;
 
 	memset(fdq, 0, sizeof(struct fs_disk_quota));
 
 	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
 		return -ESRCH; /* Crazy XFS error code */
 
-	if (type == USRQUOTA)
+	if (qid.type == USRQUOTA)
 		type = QUOTA_USER;
-	else if (type == GRPQUOTA)
+	else if (qid.type == GRPQUOTA)
 		type = QUOTA_GROUP;
 	else
 		return -EINVAL;
 
-	error = qd_get(sdp, type, id, &qd);
+	error = qd_get(sdp, type, from_kqid(&init_user_ns, qid), &qd);
 	if (error)
 		return error;
 	error = do_glock(qd, FORCE, &q_gh);
@@ -1500,7 +1501,7 @@ static int gfs2_get_dqblk(struct super_block *sb, int type, qid_t id,
 	qlvb = (struct gfs2_quota_lvb *)qd->qd_gl->gl_lvb;
 	fdq->d_version = FS_DQUOT_VERSION;
 	fdq->d_flags = (type == QUOTA_USER) ? FS_USER_QUOTA : FS_GROUP_QUOTA;
-	fdq->d_id = id;
+	fdq->d_id = from_kqid(&init_user_ns, qid);
 	fdq->d_blk_hardlimit = be64_to_cpu(qlvb->qb_limit) << sdp->sd_fsb2bb_shift;
 	fdq->d_blk_softlimit = be64_to_cpu(qlvb->qb_warn) << sdp->sd_fsb2bb_shift;
 	fdq->d_bcount = be64_to_cpu(qlvb->qb_value) << sdp->sd_fsb2bb_shift;
@@ -1514,7 +1515,7 @@ out:
 /* GFS2 only supports a subset of the XFS fields */
 #define GFS2_FIELDMASK (FS_DQ_BSOFT|FS_DQ_BHARD|FS_DQ_BCOUNT)
 
-static int gfs2_set_dqblk(struct super_block *sb, int type, qid_t id,
+static int gfs2_set_dqblk(struct super_block *sb, struct kqid qid,
 			  struct fs_disk_quota *fdq)
 {
 	struct gfs2_sbd *sdp = sb->s_fs_info;
@@ -1526,11 +1527,12 @@ static int gfs2_set_dqblk(struct super_block *sb, int type, qid_t id,
 	int alloc_required;
 	loff_t offset;
 	int error;
+	int type;
 
 	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
 		return -ESRCH; /* Crazy XFS error code */
 
-	switch(type) {
+	switch(qid.type) {
 	case USRQUOTA:
 		type = QUOTA_USER;
 		if (fdq->d_flags != FS_USER_QUOTA)
@@ -1547,10 +1549,10 @@ static int gfs2_set_dqblk(struct super_block *sb, int type, qid_t id,
 
 	if (fdq->d_fieldmask & ~GFS2_FIELDMASK)
 		return -EINVAL;
-	if (fdq->d_id != id)
+	if (fdq->d_id != from_kqid(&init_user_ns, qid))
 		return -EINVAL;
 
-	error = qd_get(sdp, type, id, &qd);
+	error = qd_get(sdp, type, from_kqid(&init_user_ns, qid), &qd);
 	if (error)
 		return error;
 
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 36a29b7..7714b16 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -2376,12 +2376,12 @@ static void do_get_dqblk(struct dquot *dquot, struct fs_disk_quota *di)
 	spin_unlock(&dq_data_lock);
 }
 
-int dquot_get_dqblk(struct super_block *sb, int type, qid_t id,
+int dquot_get_dqblk(struct super_block *sb, struct kqid qid,
 		    struct fs_disk_quota *di)
 {
 	struct dquot *dquot;
 
-	dquot = dqget(sb, id, type);
+	dquot = dqget(sb, qid.type, from_kqid(&init_user_ns, qid));
 	if (!dquot)
 		return -ESRCH;
 	do_get_dqblk(dquot, di);
@@ -2488,13 +2488,13 @@ static int do_set_dqblk(struct dquot *dquot, struct fs_disk_quota *di)
 	return 0;
 }
 
-int dquot_set_dqblk(struct super_block *sb, int type, qid_t id,
+int dquot_set_dqblk(struct super_block *sb, struct kqid qid,
 		  struct fs_disk_quota *di)
 {
 	struct dquot *dquot;
 	int rc;
 
-	dquot = dqget(sb, id, type);
+	dquot = dqget(sb, qid.type, from_kqid(&init_user_ns, qid));
 	if (!dquot) {
 		rc = -ESRCH;
 		goto out;
diff --git a/fs/quota/quota.c b/fs/quota/quota.c
index 6f15578..ff0135d 100644
--- a/fs/quota/quota.c
+++ b/fs/quota/quota.c
@@ -32,8 +32,8 @@ static int check_quotactl_permission(struct super_block *sb, int type, int cmd,
 	/* allow to query information for dquots we "own" */
 	case Q_GETQUOTA:
 	case Q_XGETQUOTA:
-		if ((type == USRQUOTA && current_euid() == id) ||
-		    (type == GRPQUOTA && in_egroup_p(id)))
+		if ((type == USRQUOTA && uid_eq(current_euid(), make_kuid(current_user_ns(), id))) ||
+		    (type == GRPQUOTA && in_egroup_p(make_kgid(current_user_ns(), id))))
 			break;
 		/*FALLTHROUGH*/
 	default:
@@ -130,13 +130,17 @@ static void copy_to_if_dqblk(struct if_dqblk *dst, struct fs_disk_quota *src)
 static int quota_getquota(struct super_block *sb, int type, qid_t id,
 			  void __user *addr)
 {
+	struct kqid qid;
 	struct fs_disk_quota fdq;
 	struct if_dqblk idq;
 	int ret;
 
 	if (!sb->s_qcop->get_dqblk)
 		return -ENOSYS;
-	ret = sb->s_qcop->get_dqblk(sb, type, id, &fdq);
+	qid = make_kqid(current_user_ns(), type, id);
+	if (!qid_valid(qid))
+		return -EINVAL;
+	ret = sb->s_qcop->get_dqblk(sb, qid, &fdq);
 	if (ret)
 		return ret;
 	copy_to_if_dqblk(&idq, &fdq);
@@ -176,13 +180,17 @@ static int quota_setquota(struct super_block *sb, int type, qid_t id,
 {
 	struct fs_disk_quota fdq;
 	struct if_dqblk idq;
+	struct kqid qid;
 
 	if (copy_from_user(&idq, addr, sizeof(idq)))
 		return -EFAULT;
 	if (!sb->s_qcop->set_dqblk)
 		return -ENOSYS;
+	qid = make_kqid(current_user_ns(), type, id);
+	if (!qid_valid(qid))
+		return -EINVAL;
 	copy_from_if_dqblk(&fdq, &idq);
-	return sb->s_qcop->set_dqblk(sb, type, id, &fdq);
+	return sb->s_qcop->set_dqblk(sb, qid, &fdq);
 }
 
 static int quota_setxstate(struct super_block *sb, int cmd, void __user *addr)
@@ -213,23 +221,31 @@ static int quota_setxquota(struct super_block *sb, int type, qid_t id,
 			   void __user *addr)
 {
 	struct fs_disk_quota fdq;
+	struct kqid qid;
 
 	if (copy_from_user(&fdq, addr, sizeof(fdq)))
 		return -EFAULT;
 	if (!sb->s_qcop->set_dqblk)
 		return -ENOSYS;
-	return sb->s_qcop->set_dqblk(sb, type, id, &fdq);
+	qid = make_kqid(current_user_ns(), type, id);
+	if (!qid_valid(qid))
+		return -EINVAL;
+	return sb->s_qcop->set_dqblk(sb, qid, &fdq);
 }
 
 static int quota_getxquota(struct super_block *sb, int type, qid_t id,
 			   void __user *addr)
 {
 	struct fs_disk_quota fdq;
+	struct kqid qid;
 	int ret;
 
 	if (!sb->s_qcop->get_dqblk)
 		return -ENOSYS;
-	ret = sb->s_qcop->get_dqblk(sb, type, id, &fdq);
+	qid = make_kqid(current_user_ns(), type, id);
+	if (!qid_valid(qid))
+		return -EINVAL;
+	ret = sb->s_qcop->get_dqblk(sb, qid, &fdq);
 	if (!ret && copy_to_user(addr, &fdq, sizeof(fdq)))
 		return -EFAULT;
 	return ret;
diff --git a/fs/xfs/xfs_quotaops.c b/fs/xfs/xfs_quotaops.c
index fed504f..71926d6 100644
--- a/fs/xfs/xfs_quotaops.c
+++ b/fs/xfs/xfs_quotaops.c
@@ -97,8 +97,7 @@ xfs_fs_set_xstate(
 STATIC int
 xfs_fs_get_dqblk(
 	struct super_block	*sb,
-	int			type,
-	qid_t			id,
+	struct kqid		qid,
 	struct fs_disk_quota	*fdq)
 {
 	struct xfs_mount	*mp = XFS_M(sb);
@@ -108,14 +107,14 @@ xfs_fs_get_dqblk(
 	if (!XFS_IS_QUOTA_ON(mp))
 		return -ESRCH;
 
-	return -xfs_qm_scall_getquota(mp, id, xfs_quota_type(type), fdq);
+	return -xfs_qm_scall_getquota(mp, from_kqid(&init_user_ns, qid),
+				      xfs_quota_type(qid.type), fdq);
 }
 
 STATIC int
 xfs_fs_set_dqblk(
 	struct super_block	*sb,
-	int			type,
-	qid_t			id,
+	struct kqid		qid,
 	struct fs_disk_quota	*fdq)
 {
 	struct xfs_mount	*mp = XFS_M(sb);
@@ -127,7 +126,8 @@ xfs_fs_set_dqblk(
 	if (!XFS_IS_QUOTA_ON(mp))
 		return -ESRCH;
 
-	return -xfs_qm_scall_setqlim(mp, id, xfs_quota_type(type), fdq);
+	return -xfs_qm_scall_setqlim(mp, from_kqid(&init_user_ns, qid),
+				     xfs_quota_type(qid.type), fdq);
 }
 
 const struct quotactl_ops xfs_quotactl_operations = {
diff --git a/include/linux/quota.h b/include/linux/quota.h
index 00ac8d8..f96427a 100644
--- a/include/linux/quota.h
+++ b/include/linux/quota.h
@@ -461,8 +461,8 @@ struct quotactl_ops {
 	int (*quota_sync)(struct super_block *, int);
 	int (*get_info)(struct super_block *, int, struct if_dqinfo *);
 	int (*set_info)(struct super_block *, int, struct if_dqinfo *);
-	int (*get_dqblk)(struct super_block *, int, qid_t, struct fs_disk_quota *);
-	int (*set_dqblk)(struct super_block *, int, qid_t, struct fs_disk_quota *);
+	int (*get_dqblk)(struct super_block *, struct kqid, struct fs_disk_quota *);
+	int (*set_dqblk)(struct super_block *, struct kqid, struct fs_disk_quota *);
 	int (*get_xstate)(struct super_block *, struct fs_quota_stat *);
 	int (*set_xstate)(struct super_block *, unsigned int, int);
 };
diff --git a/include/linux/quotaops.h b/include/linux/quotaops.h
index ec6b65f..bd3730d 100644
--- a/include/linux/quotaops.h
+++ b/include/linux/quotaops.h
@@ -87,9 +87,9 @@ int dquot_writeback_dquots(struct super_block *sb, int type);
 int dquot_quota_sync(struct super_block *sb, int type);
 int dquot_get_dqinfo(struct super_block *sb, int type, struct if_dqinfo *ii);
 int dquot_set_dqinfo(struct super_block *sb, int type, struct if_dqinfo *ii);
-int dquot_get_dqblk(struct super_block *sb, int type, qid_t id,
+int dquot_get_dqblk(struct super_block *sb, struct kqid id,
 		struct fs_disk_quota *di);
-int dquot_set_dqblk(struct super_block *sb, int type, qid_t id,
+int dquot_set_dqblk(struct super_block *sb, struct kqid id,
 		struct fs_disk_quota *di);
 
 int __dquot_transfer(struct inode *inode, struct dquot **transfer_to);
diff --git a/init/Kconfig b/init/Kconfig
index 33d231c..15bb1dc 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -928,7 +928,7 @@ config UIDGID_CONVERTED
 	depends on IMA = n
 	depends on EVM = n
 	depends on QUOTA = n
-	depends on QUOTACTL = n
+	depends on QUOTA_NETLINK_INTERFACE = n
 
 	# Networking
 	depends on NET_9P = n
-- 
1.7.5.4
