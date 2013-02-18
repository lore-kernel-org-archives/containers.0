From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 02/16] xfs: Store projectid as a single variable.
Date: Sun, 17 Feb 2013 17:10:55 -0800
Message-ID: <1361149870-27732-2-git-send-email-ebiederm@xmission.com>
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

xfs_get_projid is torturous to read and it will not work at all when
project ids are stored in a kprojid_t.  So add a i_projid to
xfs_inode, that is cheap to read and can handle future needs, and
update all callers of xfs_get_projid to use i_projid.

Retain xfs_set_projid to handle the needed double updates, as there
are now two places the value needs to be set.

In xfs_iread after filling in i_d drom the on-disk inode update the
new i_projid field.

Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/xfs/xfs_icache.c   |    2 +-
 fs/xfs/xfs_inode.c    |    6 +++++-
 fs/xfs/xfs_inode.h    |    7 ++-----
 fs/xfs/xfs_ioctl.c    |    6 +++---
 fs/xfs/xfs_iops.c     |    2 +-
 fs/xfs/xfs_itable.c   |    4 ++--
 fs/xfs/xfs_qm.c       |   10 +++++-----
 fs/xfs/xfs_qm_bhv.c   |    2 +-
 fs/xfs/xfs_rename.c   |    2 +-
 fs/xfs/xfs_vnodeops.c |    6 +++---
 10 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 96e344e..4f109ca 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -1210,7 +1210,7 @@ xfs_inode_match_id(
 		return 0;
 
 	if (eofb->eof_flags & XFS_EOF_FLAGS_PRID &&
-	    xfs_get_projid(ip) != eofb->eof_prid)
+	    ip->i_projid != eofb->eof_prid)
 		return 0;
 
 	return 1;
diff --git a/fs/xfs/xfs_inode.c b/fs/xfs/xfs_inode.c
index 66282dc..51c2597 100644
--- a/fs/xfs/xfs_inode.c
+++ b/fs/xfs/xfs_inode.c
@@ -1013,6 +1013,10 @@ xfs_iread(
 	 */
 	if (dip->di_mode) {
 		xfs_dinode_from_disk(&ip->i_d, dip);
+
+		ip->i_projid = ((projid_t)ip->i_d.di_projid_hi << 16) |
+					  ip->i_d.di_projid_lo;
+
 		error = xfs_iformat(ip, dip);
 		if (error)  {
 #ifdef DEBUG
@@ -2839,7 +2843,7 @@ xfs_iflush_int(
 			memset(&(ip->i_d.di_pad[0]), 0, sizeof(ip->i_d.di_pad));
 			memset(&(dip->di_pad[0]), 0,
 			      sizeof(dip->di_pad));
-			ASSERT(xfs_get_projid(ip) == 0);
+			ASSERT(ip->i_projid == 0);
 		}
 	}
 
diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
index 22baf6e..b9e4389 100644
--- a/fs/xfs/xfs_inode.h
+++ b/fs/xfs/xfs_inode.h
@@ -244,6 +244,7 @@ typedef struct xfs_inode {
 	unsigned int		i_delayed_blks;	/* count of delay alloc blks */
 
 	xfs_icdinode_t		i_d;		/* most of ondisk inode */
+	projid_t		i_projid;	/* Project id */
 
 	/* VFS inode */
 	struct inode		i_vnode;	/* embedded VFS inode */
@@ -359,16 +360,12 @@ xfs_iflags_test_and_set(xfs_inode_t *ip, unsigned short flags)
  * and using two 16bit values to hold new 32bit projid was chosen
  * to retain compatibility with "old" filesystems).
  */
-static inline prid_t
-xfs_get_projid(struct xfs_inode *ip)
-{
-	return (prid_t)ip->i_d.di_projid_hi << 16 | ip->i_d.di_projid_lo;
-}
 
 static inline void
 xfs_set_projid(struct xfs_inode *ip,
 		prid_t projid)
 {
+	ip->i_projid = projid;
 	ip->i_d.di_projid_hi = (__uint16_t) (projid >> 16);
 	ip->i_d.di_projid_lo = (__uint16_t) (projid & 0xffff);
 }
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index c1c3ef8..4afb509 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -815,7 +815,7 @@ xfs_ioc_fsgetxattr(
 	xfs_ilock(ip, XFS_ILOCK_SHARED);
 	fa.fsx_xflags = xfs_ip2xflags(ip);
 	fa.fsx_extsize = ip->i_d.di_extsize << ip->i_mount->m_sb.sb_blocklog;
-	fa.fsx_projid = xfs_get_projid(ip);
+	fa.fsx_projid = ip->i_projid;
 
 	if (attr) {
 		if (ip->i_afp) {
@@ -986,7 +986,7 @@ xfs_ioctl_setattr(
 	if (mask & FSX_PROJID) {
 		if (XFS_IS_QUOTA_RUNNING(mp) &&
 		    XFS_IS_PQUOTA_ON(mp) &&
-		    xfs_get_projid(ip) != fa->fsx_projid) {
+		    ip->i_projid != fa->fsx_projid) {
 			ASSERT(tp);
 			code = xfs_qm_vop_chown_reserve(tp, ip, udqp, gdqp,
 						capable(CAP_FOWNER) ?
@@ -1104,7 +1104,7 @@ xfs_ioctl_setattr(
 		 * Change the ownerships and register quota modifications
 		 * in the transaction.
 		 */
-		if (xfs_get_projid(ip) != fa->fsx_projid) {
+		if (ip->i_projid != fa->fsx_projid) {
 			if (XFS_IS_QUOTA_RUNNING(mp) && XFS_IS_PQUOTA_ON(mp)) {
 				olddquot = xfs_qm_vop_chown(tp, ip,
 							&ip->i_gdquot, gdqp);
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index d82efaa..643f55a 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -516,7 +516,7 @@ xfs_setattr_nonsize(
 		 */
 		ASSERT(udqp == NULL);
 		ASSERT(gdqp == NULL);
-		error = xfs_qm_vop_dqalloc(ip, uid, gid, xfs_get_projid(ip),
+		error = xfs_qm_vop_dqalloc(ip, uid, gid, ip->i_projid,
 					 qflags, &udqp, &gdqp);
 		if (error)
 			return error;
diff --git a/fs/xfs/xfs_itable.c b/fs/xfs/xfs_itable.c
index 2ea7d40..cf5b1d0 100644
--- a/fs/xfs/xfs_itable.c
+++ b/fs/xfs/xfs_itable.c
@@ -91,8 +91,8 @@ xfs_bulkstat_one_int(
 	 * further change.
 	 */
 	buf->bs_nlink = dic->di_nlink;
-	buf->bs_projid_lo = dic->di_projid_lo;
-	buf->bs_projid_hi = dic->di_projid_hi;
+	buf->bs_projid_lo = (u16)(ip->i_projid & 0xffff);
+	buf->bs_projid_hi = (u16)(ip->i_projid >> 16);
 	buf->bs_ino = ino;
 	buf->bs_mode = dic->di_mode;
 	buf->bs_uid = dic->di_uid;
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 60eff47..e5f48a7 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -530,7 +530,7 @@ xfs_qm_dqattach_locked(
 			xfs_qm_dqattach_one(ip, ip->i_d.di_gid, XFS_DQ_GROUP,
 						flags & XFS_QMOPT_DQALLOC,
 						ip->i_udquot, &ip->i_gdquot) :
-			xfs_qm_dqattach_one(ip, xfs_get_projid(ip), XFS_DQ_PROJ,
+			xfs_qm_dqattach_one(ip, ip->i_projid, XFS_DQ_PROJ,
 						flags & XFS_QMOPT_DQALLOC,
 						ip->i_udquot, &ip->i_gdquot);
 		/*
@@ -1172,7 +1172,7 @@ xfs_qm_dqusage_adjust(
 	}
 
 	if (XFS_IS_PQUOTA_ON(mp)) {
-		error = xfs_qm_quotacheck_dqadjust(ip, xfs_get_projid(ip),
+		error = xfs_qm_quotacheck_dqadjust(ip, ip->i_projid,
 						   XFS_DQ_PROJ, nblks, rtblks);
 		if (error)
 			goto error0;
@@ -1705,7 +1705,7 @@ xfs_qm_vop_dqalloc(
 			gq = xfs_qm_dqhold(ip->i_gdquot);
 		}
 	} else if ((flags & XFS_QMOPT_PQUOTA) && XFS_IS_PQUOTA_ON(mp)) {
-		if (xfs_get_projid(ip) != prid) {
+		if (ip->i_projid != prid) {
 			xfs_iunlock(ip, lockflags);
 			if ((error = xfs_qm_dqget(mp, NULL, (xfs_dqid_t)prid,
 						 XFS_DQ_PROJ,
@@ -1820,7 +1820,7 @@ xfs_qm_vop_chown_reserve(
 	}
 	if (XFS_IS_OQUOTA_ON(ip->i_mount) && gdqp) {
 		if (XFS_IS_PQUOTA_ON(ip->i_mount) &&
-		     xfs_get_projid(ip) != be32_to_cpu(gdqp->q_core.d_id))
+		     ip->i_projid != be32_to_cpu(gdqp->q_core.d_id))
 			prjflags = XFS_QMOPT_ENOSPC;
 
 		if (prjflags ||
@@ -1918,7 +1918,7 @@ xfs_qm_vop_create_dqattach(
 		ASSERT(ip->i_gdquot == NULL);
 		ASSERT(XFS_IS_OQUOTA_ON(mp));
 		ASSERT((XFS_IS_GQUOTA_ON(mp) ?
-			ip->i_d.di_gid : xfs_get_projid(ip)) ==
+			ip->i_d.di_gid : ip->i_projid) ==
 				be32_to_cpu(gdqp->q_core.d_id));
 
 		ip->i_gdquot = xfs_qm_dqhold(gdqp);
diff --git a/fs/xfs/xfs_qm_bhv.c b/fs/xfs/xfs_qm_bhv.c
index 6b39115..3abac1b 100644
--- a/fs/xfs/xfs_qm_bhv.c
+++ b/fs/xfs/xfs_qm_bhv.c
@@ -79,7 +79,7 @@ xfs_qm_statvfs(
 	xfs_mount_t		*mp = ip->i_mount;
 	xfs_dquot_t		*dqp;
 
-	if (!xfs_qm_dqget(mp, NULL, xfs_get_projid(ip), XFS_DQ_PROJ, 0, &dqp)) {
+	if (!xfs_qm_dqget(mp, NULL, ip->i_projid, XFS_DQ_PROJ, 0, &dqp)) {
 		xfs_fill_statvfs_from_dquot(statp, dqp);
 		xfs_qm_dqput(dqp);
 	}
diff --git a/fs/xfs/xfs_rename.c b/fs/xfs/xfs_rename.c
index 30ff5f4..89981bb 100644
--- a/fs/xfs/xfs_rename.c
+++ b/fs/xfs/xfs_rename.c
@@ -171,7 +171,7 @@ xfs_rename(
 	 * tree quota mechanism would be circumvented.
 	 */
 	if (unlikely((target_dp->i_d.di_flags & XFS_DIFLAG_PROJINHERIT) &&
-		     (xfs_get_projid(target_dp) != xfs_get_projid(src_ip)))) {
+		     (target_dp->i_projid != src_ip->i_projid))) {
 		error = XFS_ERROR(EXDEV);
 		goto error_return;
 	}
diff --git a/fs/xfs/xfs_vnodeops.c b/fs/xfs/xfs_vnodeops.c
index d95f565..7a2c2a0 100644
--- a/fs/xfs/xfs_vnodeops.c
+++ b/fs/xfs/xfs_vnodeops.c
@@ -741,7 +741,7 @@ xfs_create(
 		return XFS_ERROR(EIO);
 
 	if (dp->i_d.di_flags & XFS_DIFLAG_PROJINHERIT)
-		prid = xfs_get_projid(dp);
+		prid = dp->i_projid;
 	else
 		prid = XFS_PROJID_DEFAULT;
 
@@ -1305,7 +1305,7 @@ xfs_link(
 	 * the tree quota mechanism could be circumvented.
 	 */
 	if (unlikely((tdp->i_d.di_flags & XFS_DIFLAG_PROJINHERIT) &&
-		     (xfs_get_projid(tdp) != xfs_get_projid(sip)))) {
+		     (tdp->i_projid != sip->i_projid))) {
 		error = XFS_ERROR(EXDEV);
 		goto error_return;
 	}
@@ -1402,7 +1402,7 @@ xfs_symlink(
 
 	udqp = gdqp = NULL;
 	if (dp->i_d.di_flags & XFS_DIFLAG_PROJINHERIT)
-		prid = xfs_get_projid(dp);
+		prid = dp->i_projid;
 	else
 		prid = XFS_PROJID_DEFAULT;
 
-- 
1.7.5.4
