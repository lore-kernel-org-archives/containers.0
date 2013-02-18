From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 11/16] xfs: Modify xfs_qm_dqget to take a struct kqid.
Date: Sun, 17 Feb 2013 17:11:04 -0800
Message-ID: <1361149870-27732-11-git-send-email-ebiederm@xmission.com>
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

- Modify xfs_qm_dqget, xfs_qm_dqattach_one, and xfs_qm_qutoacheck_dqadjust
  to take a struct kqid instead of an id and type pair.

- Modify their callers to pass them a struct kqid.

- Move xfs_qutoa_type into xfs_dquot.c where it is now used.

Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/xfs/xfs_dquot.c       |   24 +++++++++++++++++++-----
 fs/xfs/xfs_dquot.h       |    4 ++--
 fs/xfs/xfs_qm.c          |   42 +++++++++++++++++++-----------------------
 fs/xfs/xfs_qm_bhv.c      |    2 +-
 fs/xfs/xfs_qm_syscalls.c |   20 ++------------------
 5 files changed, 43 insertions(+), 49 deletions(-)

diff --git a/fs/xfs/xfs_dquot.c b/fs/xfs/xfs_dquot.c
index 9e1bf52..6be5a29 100644
--- a/fs/xfs/xfs_dquot.c
+++ b/fs/xfs/xfs_dquot.c
@@ -63,6 +63,19 @@ static struct kmem_zone		*xfs_qm_dqzone;
 
 static struct lock_class_key xfs_dquot_other_class;
 
+STATIC int
+xfs_quota_type(int type)
+{
+	switch (type) {
+	case USRQUOTA:
+		return XFS_DQ_USER;
+	case GRPQUOTA:
+		return XFS_DQ_GROUP;
+	default:
+		return XFS_DQ_PROJ;
+	}
+}
+
 /*
  * This is called to free all the memory associated with a dquot
  */
@@ -702,20 +715,21 @@ int
 xfs_qm_dqget(
 	xfs_mount_t	*mp,
 	xfs_inode_t	*ip,	  /* locked inode (optional) */
-	xfs_dqid_t	id,	  /* uid/projid/gid depending on type */
-	uint		type,	  /* XFS_DQ_USER/XFS_DQ_PROJ/XFS_DQ_GROUP */
+	struct kqid     qid,	  /* uid/projid/gid depending on type */
 	uint		flags,	  /* DQALLOC, DQSUSER, DQREPAIR, DOWARN */
 	xfs_dquot_t	**O_dqpp) /* OUT : locked incore dquot */
 {
 	struct xfs_quotainfo	*qi = mp->m_quotainfo;
+	uint			id = from_kqid(&init_user_ns, qid);
+	uint			type = xfs_quota_type(qid.type);
 	struct radix_tree_root *tree = XFS_DQUOT_TREE(qi, type);
 	struct xfs_dquot	*dqp;
 	int			error;
 
 	ASSERT(XFS_IS_QUOTA_RUNNING(mp));
-	if ((! XFS_IS_UQUOTA_ON(mp) && type == XFS_DQ_USER) ||
-	    (! XFS_IS_PQUOTA_ON(mp) && type == XFS_DQ_PROJ) ||
-	    (! XFS_IS_GQUOTA_ON(mp) && type == XFS_DQ_GROUP)) {
+	if ((! XFS_IS_UQUOTA_ON(mp) && qid.type == USRQUOTA) ||
+	    (! XFS_IS_PQUOTA_ON(mp) && qid.type == GRPQUOTA) ||
+	    (! XFS_IS_GQUOTA_ON(mp) && qid.type == PRJQUOTA)) {
 		return (ESRCH);
 	}
 
diff --git a/fs/xfs/xfs_dquot.h b/fs/xfs/xfs_dquot.h
index 2c197da..3566548 100644
--- a/fs/xfs/xfs_dquot.h
+++ b/fs/xfs/xfs_dquot.h
@@ -147,8 +147,8 @@ extern void		xfs_qm_adjust_dqtimers(xfs_mount_t *,
 					xfs_disk_dquot_t *);
 extern void		xfs_qm_adjust_dqlimits(xfs_mount_t *,
 					xfs_disk_dquot_t *);
-extern int		xfs_qm_dqget(xfs_mount_t *, xfs_inode_t *,
-					xfs_dqid_t, uint, uint, xfs_dquot_t **);
+extern int		xfs_qm_dqget(xfs_mount_t *, xfs_inode_t *, struct kqid,
+					uint, xfs_dquot_t **);
 extern void		xfs_qm_dqput(xfs_dquot_t *);
 
 extern void		xfs_dqlock2(struct xfs_dquot *, struct xfs_dquot *);
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 80b8c81..836d40d 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -367,8 +367,7 @@ xfs_qm_unmount_quotas(
 STATIC int
 xfs_qm_dqattach_one(
 	xfs_inode_t	*ip,
-	xfs_dqid_t	id,
-	uint		type,
+	struct kqid	id,
 	uint		doalloc,
 	xfs_dquot_t	*udqhint, /* hint */
 	xfs_dquot_t	**IO_idqpp)
@@ -397,7 +396,7 @@ xfs_qm_dqattach_one(
 	 * the user dquot.
 	 */
 	if (udqhint) {
-		ASSERT(type == XFS_DQ_GROUP || type == XFS_DQ_PROJ);
+		ASSERT(id.type == GRPQUOTA || id.type == PRJQUOTA);
 		xfs_dqlock(udqhint);
 
 		/*
@@ -408,7 +407,7 @@ xfs_qm_dqattach_one(
 		 * hold the ilock.
 		 */
 		dqp = udqhint->q_gdquot;
-		if (dqp && be32_to_cpu(dqp->q_core.d_id) == id) {
+		if (dqp && qid_eq(make_kqid(&init_user_ns, id.type, be32_to_cpu(dqp->q_core.d_id)), id)) {
 			ASSERT(*IO_idqpp == NULL);
 
 			*IO_idqpp = xfs_qm_dqhold(dqp);
@@ -432,7 +431,7 @@ xfs_qm_dqattach_one(
 	 * disk and we didn't ask it to allocate;
 	 * ESRCH if quotas got turned off suddenly.
 	 */
-	error = xfs_qm_dqget(ip->i_mount, ip, id, type,
+	error = xfs_qm_dqget(ip->i_mount, ip, id,
 			     doalloc | XFS_QMOPT_DOWARN, &dqp);
 	if (error)
 		return error;
@@ -516,7 +515,7 @@ xfs_qm_dqattach_locked(
 	ASSERT(xfs_isilocked(ip, XFS_ILOCK_EXCL));
 
 	if (XFS_IS_UQUOTA_ON(mp)) {
-		error = xfs_qm_dqattach_one(ip, VFS_I(ip)->i_uid, XFS_DQ_USER,
+		error = xfs_qm_dqattach_one(ip, make_kqid_uid(VFS_I(ip)->i_uid),
 						flags & XFS_QMOPT_DQALLOC,
 						NULL, &ip->i_udquot);
 		if (error)
@@ -527,10 +526,10 @@ xfs_qm_dqattach_locked(
 	ASSERT(xfs_isilocked(ip, XFS_ILOCK_EXCL));
 	if (XFS_IS_OQUOTA_ON(mp)) {
 		error = XFS_IS_GQUOTA_ON(mp) ?
-			xfs_qm_dqattach_one(ip, VFS_I(ip)->i_gid, XFS_DQ_GROUP,
+			xfs_qm_dqattach_one(ip, make_kqid_gid(VFS_I(ip)->i_gid),
 						flags & XFS_QMOPT_DQALLOC,
 						ip->i_udquot, &ip->i_gdquot) :
-			xfs_qm_dqattach_one(ip, ip->i_projid, XFS_DQ_PROJ,
+			xfs_qm_dqattach_one(ip, make_kqid_projid(ip->i_projid),
 						flags & XFS_QMOPT_DQALLOC,
 						ip->i_udquot, &ip->i_gdquot);
 		/*
@@ -1016,8 +1015,7 @@ out:
 STATIC int
 xfs_qm_quotacheck_dqadjust(
 	struct xfs_inode	*ip,
-	xfs_dqid_t		id,
-	uint			type,
+	struct kqid		id,
 	xfs_qcnt_t		nblks,
 	xfs_qcnt_t		rtblks)
 {
@@ -1025,7 +1023,7 @@ xfs_qm_quotacheck_dqadjust(
 	struct xfs_dquot	*dqp;
 	int			error;
 
-	error = xfs_qm_dqget(mp, ip, id, type,
+	error = xfs_qm_dqget(mp, ip, id,
 			     XFS_QMOPT_DQALLOC | XFS_QMOPT_DOWARN, &dqp);
 	if (error) {
 		/*
@@ -1160,22 +1158,22 @@ xfs_qm_dqusage_adjust(
 	 * and quotaoffs don't race. (Quotachecks happen at mount time only).
 	 */
 	if (XFS_IS_UQUOTA_ON(mp)) {
-		error = xfs_qm_quotacheck_dqadjust(ip, VFS_I(ip)->i_uid,
-						   XFS_DQ_USER, nblks, rtblks);
+		error = xfs_qm_quotacheck_dqadjust(ip, make_kqid_uid(VFS_I(ip)->i_uid),
+						   nblks, rtblks);
 		if (error)
 			goto error0;
 	}
 
 	if (XFS_IS_GQUOTA_ON(mp)) {
-		error = xfs_qm_quotacheck_dqadjust(ip, VFS_I(ip)->i_gid,
-						   XFS_DQ_GROUP, nblks, rtblks);
+		error = xfs_qm_quotacheck_dqadjust(ip, make_kqid_gid(VFS_I(ip)->i_gid),
+						   nblks, rtblks);
 		if (error)
 			goto error0;
 	}
 
 	if (XFS_IS_PQUOTA_ON(mp)) {
-		error = xfs_qm_quotacheck_dqadjust(ip, ip->i_projid,
-						   XFS_DQ_PROJ, nblks, rtblks);
+		error = xfs_qm_quotacheck_dqadjust(ip, make_kqid_projid(ip->i_projid),
+						   nblks, rtblks);
 		if (error)
 			goto error0;
 	}
@@ -1663,8 +1661,7 @@ xfs_qm_vop_dqalloc(
 			 * holding ilock.
 			 */
 			xfs_iunlock(ip, lockflags);
-			if ((error = xfs_qm_dqget(mp, NULL, (xfs_dqid_t) uid,
-						 XFS_DQ_USER,
+			if ((error = xfs_qm_dqget(mp, NULL, make_kqid_uid(uid),
 						 XFS_QMOPT_DQALLOC |
 						 XFS_QMOPT_DOWARN,
 						 &uq))) {
@@ -1689,8 +1686,7 @@ xfs_qm_vop_dqalloc(
 	if ((flags & XFS_QMOPT_GQUOTA) && XFS_IS_GQUOTA_ON(mp)) {
 		if (!gid_eq(VFS_I(ip)->i_gid, gid)) {
 			xfs_iunlock(ip, lockflags);
-			if ((error = xfs_qm_dqget(mp, NULL, (xfs_dqid_t)gid,
-						 XFS_DQ_GROUP,
+			if ((error = xfs_qm_dqget(mp, NULL, make_kqid_gid(gid),
 						 XFS_QMOPT_DQALLOC |
 						 XFS_QMOPT_DOWARN,
 						 &gq))) {
@@ -1709,8 +1705,8 @@ xfs_qm_vop_dqalloc(
 	} else if ((flags & XFS_QMOPT_PQUOTA) && XFS_IS_PQUOTA_ON(mp)) {
 		if (!projid_eq(ip->i_projid, prid)) {
 			xfs_iunlock(ip, lockflags);
-			if ((error = xfs_qm_dqget(mp, NULL, (xfs_dqid_t)prid,
-						 XFS_DQ_PROJ,
+			if ((error = xfs_qm_dqget(mp, NULL,
+						 make_kqid_projid(prid),
 						 XFS_QMOPT_DQALLOC |
 						 XFS_QMOPT_DOWARN,
 						 &gq))) {
diff --git a/fs/xfs/xfs_qm_bhv.c b/fs/xfs/xfs_qm_bhv.c
index 3abac1b..aceb81e 100644
--- a/fs/xfs/xfs_qm_bhv.c
+++ b/fs/xfs/xfs_qm_bhv.c
@@ -79,7 +79,7 @@ xfs_qm_statvfs(
 	xfs_mount_t		*mp = ip->i_mount;
 	xfs_dquot_t		*dqp;
 
-	if (!xfs_qm_dqget(mp, NULL, ip->i_projid, XFS_DQ_PROJ, 0, &dqp)) {
+	if (!xfs_qm_dqget(mp, NULL, make_kqid_projid(ip->i_projid), 0, &dqp)) {
 		xfs_fill_statvfs_from_dquot(statp, dqp);
 		xfs_qm_dqput(dqp);
 	}
diff --git a/fs/xfs/xfs_qm_syscalls.c b/fs/xfs/xfs_qm_syscalls.c
index 5666b1c..90f6255 100644
--- a/fs/xfs/xfs_qm_syscalls.c
+++ b/fs/xfs/xfs_qm_syscalls.c
@@ -48,19 +48,6 @@ STATIC int	xfs_qm_log_quotaoff_end(xfs_mount_t *, xfs_qoff_logitem_t *,
 STATIC uint	xfs_qm_export_flags(uint);
 STATIC uint	xfs_qm_export_qtype_flags(uint);
 
-STATIC int
-xfs_quota_type(int type)
-{
-	switch (type) {
-	case USRQUOTA:
-		return XFS_DQ_USER;
-	case GRPQUOTA:
-		return XFS_DQ_GROUP;
-	default:
-		return XFS_DQ_PROJ;
-	}
-}
-
 /*
  * Turn off quota accounting and/or enforcement for all udquots and/or
  * gdquots. Called only at unmount time.
@@ -524,9 +511,7 @@ xfs_qm_scall_setqlim(
 	 * Get the dquot (locked), and join it to the transaction.
 	 * Allocate the dquot if this doesn't exist.
 	 */
-	if ((error = xfs_qm_dqget(mp, NULL, from_kqid(&init_user_ns, id),
-				  xfs_quota_type(id.type),
-				  XFS_QMOPT_DQALLOC, &dqp))) {
+	if ((error = xfs_qm_dqget(mp, NULL, id, XFS_QMOPT_DQALLOC, &dqp))) {
 		xfs_trans_cancel(tp, XFS_TRANS_ABORT);
 		ASSERT(error != ENOENT);
 		goto out_unlock;
@@ -746,8 +731,7 @@ xfs_qm_scall_getquota(
 	 * we aren't passing the XFS_QMOPT_DOALLOC flag. If it doesn't
 	 * exist, we'll get ENOENT back.
 	 */
-	error = xfs_qm_dqget(mp, NULL, from_kqid(&init_user_ns, id),
-			     xfs_quota_type(id.type), 0, &dqp);
+	error = xfs_qm_dqget(mp, NULL, id, 0, &dqp);
 	if (error)
 		return error;
 
-- 
1.7.5.4
