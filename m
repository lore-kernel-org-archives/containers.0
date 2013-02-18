From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 03/16] xfs: Always read uids and gids from the vfs inode
Date: Sun, 17 Feb 2013 17:10:56 -0800
Message-ID: <1361149870-27732-3-git-send-email-ebiederm@xmission.com>
References: <87txpaph4n.fsf@xmission.com>
	<1361149870-27732-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1361149870-27732-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Add xfs_set_uid and xfs_set_gid to encapsulate the double write
needed when updating uid and gids, and uset them for all uid
and gid writes.

Update VFS()->i_uid and VFS_I()->i_gid immediately after reading
on-disk inode values so that all of the cached uid and gid values
are always in sync allowing VFS()->i_uid and VFS()->i_gid to safely
be used everywhere.

Replace reads of i_d.di_uid and i_d.di_gid with VFS_I()->i_uid and
VFS_I()->i_gid.

This is a precursor to pushing kuids and kgids down into xfs.

Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/xfs/xfs_icache.c |    4 ++--
 fs/xfs/xfs_inode.c  |   10 ++++++----
 fs/xfs/xfs_inode.h  |   12 ++++++++++++
 fs/xfs/xfs_ioctl.c  |    6 +++---
 fs/xfs/xfs_iops.c   |   20 ++++++++------------
 fs/xfs/xfs_itable.c |    4 ++--
 fs/xfs/xfs_qm.c     |   22 +++++++++++-----------
 7 files changed, 44 insertions(+), 34 deletions(-)

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 4f109ca..eba1dbd 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -1202,11 +1202,11 @@ xfs_inode_match_id(
 	struct xfs_eofblocks	*eofb)
 {
 	if (eofb->eof_flags & XFS_EOF_FLAGS_UID &&
-	    ip->i_d.di_uid != eofb->eof_uid)
+	    VFS_I(ip)->i_uid != eofb->eof_uid)
 		return 0;
 
 	if (eofb->eof_flags & XFS_EOF_FLAGS_GID &&
-	    ip->i_d.di_gid != eofb->eof_gid)
+	    VFS_I(ip)->i_gid != eofb->eof_gid)
 		return 0;
 
 	if (eofb->eof_flags & XFS_EOF_FLAGS_PRID &&
diff --git a/fs/xfs/xfs_inode.c b/fs/xfs/xfs_inode.c
index 51c2597..846166d 100644
--- a/fs/xfs/xfs_inode.c
+++ b/fs/xfs/xfs_inode.c
@@ -1016,6 +1016,8 @@ xfs_iread(
 
 		ip->i_projid = ((projid_t)ip->i_d.di_projid_hi << 16) |
 					  ip->i_d.di_projid_lo;
+		VFS_I(ip)->i_uid = ip->i_d.di_uid;
+		VFS_I(ip)->i_gid = ip->i_d.di_gid;
 
 		error = xfs_iformat(ip, dip);
 		if (error)  {
@@ -1201,8 +1203,8 @@ xfs_ialloc(
 	ip->i_d.di_onlink = 0;
 	ip->i_d.di_nlink = nlink;
 	ASSERT(ip->i_d.di_nlink == nlink);
-	ip->i_d.di_uid = current_fsuid();
-	ip->i_d.di_gid = current_fsgid();
+	xfs_set_uid(ip, current_fsuid());
+	xfs_set_gid(ip, current_fsgid());
 	xfs_set_projid(ip, prid);
 	memset(&(ip->i_d.di_pad[0]), 0, sizeof(ip->i_d.di_pad));
 
@@ -1228,7 +1230,7 @@ xfs_ialloc(
 		xfs_bump_ino_vers2(tp, ip);
 
 	if (pip && XFS_INHERIT_GID(pip)) {
-		ip->i_d.di_gid = pip->i_d.di_gid;
+		xfs_set_gid(ip, VFS_I(pip)->i_gid);
 		if ((pip->i_d.di_mode & S_ISGID) && S_ISDIR(mode)) {
 			ip->i_d.di_mode |= S_ISGID;
 		}
@@ -1241,7 +1243,7 @@ xfs_ialloc(
 	 */
 	if ((irix_sgid_inherit) &&
 	    (ip->i_d.di_mode & S_ISGID) &&
-	    (!in_group_p((gid_t)ip->i_d.di_gid))) {
+	    (!in_group_p(VFS_I(ip)->i_gid))) {
 		ip->i_d.di_mode &= ~S_ISGID;
 	}
 
diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
index b9e4389..f503aed 100644
--- a/fs/xfs/xfs_inode.h
+++ b/fs/xfs/xfs_inode.h
@@ -370,6 +370,18 @@ xfs_set_projid(struct xfs_inode *ip,
 	ip->i_d.di_projid_lo = (__uint16_t) (projid & 0xffff);
 }
 
+static inline void xfs_set_uid(struct xfs_inode *ip, uid_t uid)
+{
+	VFS_I(ip)->i_uid = uid;
+	ip->i_d.di_uid = uid;
+}
+
+static inline void xfs_set_gid(struct xfs_inode *ip, gid_t gid)
+{
+	VFS_I(ip)->i_gid = gid;
+	ip->i_d.di_gid = gid;
+}
+
 /*
  * In-core inode flags.
  */
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 4afb509..db274d4 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -949,8 +949,8 @@ xfs_ioctl_setattr(
 	 * because the i_*dquot fields will get updated anyway.
 	 */
 	if (XFS_IS_QUOTA_ON(mp) && (mask & FSX_PROJID)) {
-		code = xfs_qm_vop_dqalloc(ip, ip->i_d.di_uid,
-					 ip->i_d.di_gid, fa->fsx_projid,
+		code = xfs_qm_vop_dqalloc(ip, VFS_I(ip)->i_uid,
+					 VFS_I(ip)->i_gid, fa->fsx_projid,
 					 XFS_QMOPT_PQUOTA, &udqp, &gdqp);
 		if (code)
 			return code;
@@ -975,7 +975,7 @@ xfs_ioctl_setattr(
 	 * to the file owner ID, except in cases where the
 	 * CAP_FSETID capability is applicable.
 	 */
-	if (current_fsuid() != ip->i_d.di_uid && !capable(CAP_FOWNER)) {
+	if (current_fsuid() != VFS_I(ip)->i_uid && !capable(CAP_FOWNER)) {
 		code = XFS_ERROR(EPERM);
 		goto error_return;
 	}
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index 643f55a..235a48c 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -420,8 +420,8 @@ xfs_vn_getattr(
 	stat->dev = inode->i_sb->s_dev;
 	stat->mode = ip->i_d.di_mode;
 	stat->nlink = ip->i_d.di_nlink;
-	stat->uid = ip->i_d.di_uid;
-	stat->gid = ip->i_d.di_gid;
+	stat->uid = VFS_I(ip)->i_uid;
+	stat->gid = VFS_I(ip)->i_gid;
 	stat->ino = ip->i_ino;
 	stat->atime = inode->i_atime;
 	stat->mtime = inode->i_mtime;
@@ -500,13 +500,13 @@ xfs_setattr_nonsize(
 			uid = iattr->ia_uid;
 			qflags |= XFS_QMOPT_UQUOTA;
 		} else {
-			uid = ip->i_d.di_uid;
+			uid = VFS_I(ip)->i_uid;
 		}
 		if ((mask & ATTR_GID) && XFS_IS_GQUOTA_ON(mp)) {
 			gid = iattr->ia_gid;
 			qflags |= XFS_QMOPT_GQUOTA;
 		}  else {
-			gid = ip->i_d.di_gid;
+			gid = VFS_I(ip)->i_gid;
 		}
 
 		/*
@@ -539,8 +539,8 @@ xfs_setattr_nonsize(
 		 * while we didn't have the inode locked, inode's dquot(s)
 		 * would have changed also.
 		 */
-		iuid = ip->i_d.di_uid;
-		igid = ip->i_d.di_gid;
+		iuid = VFS_I(ip)->i_uid;
+		igid = VFS_I(ip)->i_gid;
 		gid = (mask & ATTR_GID) ? iattr->ia_gid : igid;
 		uid = (mask & ATTR_UID) ? iattr->ia_uid : iuid;
 
@@ -587,8 +587,7 @@ xfs_setattr_nonsize(
 				olddquot1 = xfs_qm_vop_chown(tp, ip,
 							&ip->i_udquot, udqp);
 			}
-			ip->i_d.di_uid = uid;
-			inode->i_uid = uid;
+			xfs_set_uid(ip, uid);
 		}
 		if (igid != gid) {
 			if (XFS_IS_QUOTA_RUNNING(mp) && XFS_IS_GQUOTA_ON(mp)) {
@@ -598,8 +597,7 @@ xfs_setattr_nonsize(
 				olddquot2 = xfs_qm_vop_chown(tp, ip,
 							&ip->i_gdquot, gdqp);
 			}
-			ip->i_d.di_gid = gid;
-			inode->i_gid = gid;
+			xfs_set_gid(ip, gid);
 		}
 	}
 
@@ -1155,8 +1153,6 @@ xfs_setup_inode(
 
 	inode->i_mode	= ip->i_d.di_mode;
 	set_nlink(inode, ip->i_d.di_nlink);
-	inode->i_uid	= ip->i_d.di_uid;
-	inode->i_gid	= ip->i_d.di_gid;
 
 	switch (inode->i_mode & S_IFMT) {
 	case S_IFBLK:
diff --git a/fs/xfs/xfs_itable.c b/fs/xfs/xfs_itable.c
index cf5b1d0..a9e07dd 100644
--- a/fs/xfs/xfs_itable.c
+++ b/fs/xfs/xfs_itable.c
@@ -95,8 +95,8 @@ xfs_bulkstat_one_int(
 	buf->bs_projid_hi = (u16)(ip->i_projid >> 16);
 	buf->bs_ino = ino;
 	buf->bs_mode = dic->di_mode;
-	buf->bs_uid = dic->di_uid;
-	buf->bs_gid = dic->di_gid;
+	buf->bs_uid = VFS_I(ip)->i_uid;
+	buf->bs_gid = VFS_I(ip)->i_gid;
 	buf->bs_size = dic->di_size;
 	buf->bs_atime.tv_sec = dic->di_atime.t_sec;
 	buf->bs_atime.tv_nsec = dic->di_atime.t_nsec;
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index e5f48a7..c1310ed 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -516,7 +516,7 @@ xfs_qm_dqattach_locked(
 	ASSERT(xfs_isilocked(ip, XFS_ILOCK_EXCL));
 
 	if (XFS_IS_UQUOTA_ON(mp)) {
-		error = xfs_qm_dqattach_one(ip, ip->i_d.di_uid, XFS_DQ_USER,
+		error = xfs_qm_dqattach_one(ip, VFS_I(ip)->i_uid, XFS_DQ_USER,
 						flags & XFS_QMOPT_DQALLOC,
 						NULL, &ip->i_udquot);
 		if (error)
@@ -527,7 +527,7 @@ xfs_qm_dqattach_locked(
 	ASSERT(xfs_isilocked(ip, XFS_ILOCK_EXCL));
 	if (XFS_IS_OQUOTA_ON(mp)) {
 		error = XFS_IS_GQUOTA_ON(mp) ?
-			xfs_qm_dqattach_one(ip, ip->i_d.di_gid, XFS_DQ_GROUP,
+			xfs_qm_dqattach_one(ip, VFS_I(ip)->i_gid, XFS_DQ_GROUP,
 						flags & XFS_QMOPT_DQALLOC,
 						ip->i_udquot, &ip->i_gdquot) :
 			xfs_qm_dqattach_one(ip, ip->i_projid, XFS_DQ_PROJ,
@@ -1158,14 +1158,14 @@ xfs_qm_dqusage_adjust(
 	 * and quotaoffs don't race. (Quotachecks happen at mount time only).
 	 */
 	if (XFS_IS_UQUOTA_ON(mp)) {
-		error = xfs_qm_quotacheck_dqadjust(ip, ip->i_d.di_uid,
+		error = xfs_qm_quotacheck_dqadjust(ip, VFS_I(ip)->i_uid,
 						   XFS_DQ_USER, nblks, rtblks);
 		if (error)
 			goto error0;
 	}
 
 	if (XFS_IS_GQUOTA_ON(mp)) {
-		error = xfs_qm_quotacheck_dqadjust(ip, ip->i_d.di_gid,
+		error = xfs_qm_quotacheck_dqadjust(ip, VFS_I(ip)->i_gid,
 						   XFS_DQ_GROUP, nblks, rtblks);
 		if (error)
 			goto error0;
@@ -1634,7 +1634,7 @@ xfs_qm_vop_dqalloc(
 	xfs_ilock(ip, lockflags);
 
 	if ((flags & XFS_QMOPT_INHERIT) && XFS_INHERIT_GID(ip))
-		gid = ip->i_d.di_gid;
+		gid = VFS_I(ip)->i_gid;
 
 	/*
 	 * Attach the dquot(s) to this inode, doing a dquot allocation
@@ -1650,7 +1650,7 @@ xfs_qm_vop_dqalloc(
 
 	uq = gq = NULL;
 	if ((flags & XFS_QMOPT_UQUOTA) && XFS_IS_UQUOTA_ON(mp)) {
-		if (ip->i_d.di_uid != uid) {
+		if (VFS_I(ip)->i_uid != uid) {
 			/*
 			 * What we need is the dquot that has this uid, and
 			 * if we send the inode to dqget, the uid of the inode
@@ -1685,7 +1685,7 @@ xfs_qm_vop_dqalloc(
 		}
 	}
 	if ((flags & XFS_QMOPT_GQUOTA) && XFS_IS_GQUOTA_ON(mp)) {
-		if (ip->i_d.di_gid != gid) {
+		if (VFS_I(ip)->i_gid != gid) {
 			xfs_iunlock(ip, lockflags);
 			if ((error = xfs_qm_dqget(mp, NULL, (xfs_dqid_t)gid,
 						 XFS_DQ_GROUP,
@@ -1806,7 +1806,7 @@ xfs_qm_vop_chown_reserve(
 			XFS_QMOPT_RES_RTBLKS : XFS_QMOPT_RES_REGBLKS;
 
 	if (XFS_IS_UQUOTA_ON(mp) && udqp &&
-	    ip->i_d.di_uid != (uid_t)be32_to_cpu(udqp->q_core.d_id)) {
+	    VFS_I(ip)->i_uid != (uid_t)be32_to_cpu(udqp->q_core.d_id)) {
 		delblksudq = udqp;
 		/*
 		 * If there are delayed allocation blocks, then we have to
@@ -1825,7 +1825,7 @@ xfs_qm_vop_chown_reserve(
 
 		if (prjflags ||
 		    (XFS_IS_GQUOTA_ON(ip->i_mount) &&
-		     ip->i_d.di_gid != be32_to_cpu(gdqp->q_core.d_id))) {
+		     VFS_I(ip)->i_gid != be32_to_cpu(gdqp->q_core.d_id))) {
 			delblksgdq = gdqp;
 			if (delblks) {
 				ASSERT(ip->i_gdquot);
@@ -1909,7 +1909,7 @@ xfs_qm_vop_create_dqattach(
 	if (udqp) {
 		ASSERT(ip->i_udquot == NULL);
 		ASSERT(XFS_IS_UQUOTA_ON(mp));
-		ASSERT(ip->i_d.di_uid == be32_to_cpu(udqp->q_core.d_id));
+		ASSERT(VFS_I(ip)->i_uid == be32_to_cpu(udqp->q_core.d_id));
 
 		ip->i_udquot = xfs_qm_dqhold(udqp);
 		xfs_trans_mod_dquot(tp, udqp, XFS_TRANS_DQ_ICOUNT, 1);
@@ -1918,7 +1918,7 @@ xfs_qm_vop_create_dqattach(
 		ASSERT(ip->i_gdquot == NULL);
 		ASSERT(XFS_IS_OQUOTA_ON(mp));
 		ASSERT((XFS_IS_GQUOTA_ON(mp) ?
-			ip->i_d.di_gid : ip->i_projid) ==
+			VFS_I(ip)->i_gid : ip->i_projid) ==
 				be32_to_cpu(gdqp->q_core.d_id));
 
 		ip->i_gdquot = xfs_qm_dqhold(gdqp);
-- 
1.7.5.4
