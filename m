From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 13/16] xfs: Use q_id instead of q_core.d_id.
Date: Sun, 17 Feb 2013 17:11:06 -0800
Message-ID: <1361149870-27732-13-git-send-email-ebiederm@xmission.com>
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

- Use qid_lt on q_id when compariting two quota entries for order.
- Use qid_eq or !qid_eq when comparing a quota entry for equality or inequality.
- Use is_superquota when testing for the magic quota id of 0.
- Use make_kqid_uid, make_kqid_gid, and make_kqid_projid when comparing
  a quota id against a uids, gids, or projids as appropriate.
- For tracing use from_kqid and map to the init user namespace.
  Tracers outside of the initial user namespace are not allowed.

- For generating ondisk values continue to use q_core.d_id.
- For cases where we want an index and don't care which quota
  it is continue to use be32_to_cpu(...->q_core.d_id)

Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/xfs/xfs_dquot.c       |    3 +--
 fs/xfs/xfs_qm.c          |   18 +++++++++---------
 fs/xfs/xfs_trace.h       |    2 +-
 fs/xfs/xfs_trans_dquot.c |    8 ++------
 4 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/fs/xfs/xfs_dquot.c b/fs/xfs/xfs_dquot.c
index 53c8f67..6f6e6ea 100644
--- a/fs/xfs/xfs_dquot.c
+++ b/fs/xfs/xfs_dquot.c
@@ -1092,8 +1092,7 @@ xfs_dqlock2(
 {
 	if (d1 && d2) {
 		ASSERT(d1 != d2);
-		if (be32_to_cpu(d1->q_core.d_id) >
-		    be32_to_cpu(d2->q_core.d_id)) {
+		if (qid_lt(d2->q_id, d1->q_id)) {
 			mutex_lock(&d2->q_qlock);
 			mutex_lock_nested(&d1->q_qlock, XFS_QLOCK_NESTED);
 		} else {
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 7e19147..60444b0 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -407,7 +407,7 @@ xfs_qm_dqattach_one(
 		 * hold the ilock.
 		 */
 		dqp = udqhint->q_gdquot;
-		if (dqp && qid_eq(make_kqid(&init_user_ns, id.type, be32_to_cpu(dqp->q_core.d_id)), id)) {
+		if (dqp && qid_eq(dqp->q_id, id)) {
 			ASSERT(*IO_idqpp == NULL);
 
 			*IO_idqpp = xfs_qm_dqhold(dqp);
@@ -1057,7 +1057,7 @@ xfs_qm_quotacheck_dqadjust(
 	 *
 	 * There are no timers for the default values set in the root dquot.
 	 */
-	if (dqp->q_core.d_id) {
+	if (!is_superquota(dqp->q_id, &init_user_ns)) {
 		xfs_qm_adjust_dqlimits(mp, &dqp->q_core);
 		xfs_qm_adjust_dqtimers(mp, &dqp->q_core);
 	}
@@ -1805,7 +1805,7 @@ xfs_qm_vop_chown_reserve(
 			XFS_QMOPT_RES_RTBLKS : XFS_QMOPT_RES_REGBLKS;
 
 	if (XFS_IS_UQUOTA_ON(mp) && udqp &&
-	    !uid_eq(VFS_I(ip)->i_uid, (uid_t)be32_to_cpu(udqp->q_core.d_id))) {
+	    !qid_eq(make_kqid_uid(VFS_I(ip)->i_uid), udqp->q_id)) {
 		delblksudq = udqp;
 		/*
 		 * If there are delayed allocation blocks, then we have to
@@ -1819,12 +1819,12 @@ xfs_qm_vop_chown_reserve(
 	}
 	if (XFS_IS_OQUOTA_ON(ip->i_mount) && gdqp) {
 		if (XFS_IS_PQUOTA_ON(ip->i_mount) &&
-		    !projid_eq(ip->i_projid, be32_to_cpu(gdqp->q_core.d_id)))
+		    !qid_eq(make_kqid_projid(ip->i_projid), gdqp->q_id))
 			prjflags = XFS_QMOPT_ENOSPC;
 
 		if (prjflags ||
 		    (XFS_IS_GQUOTA_ON(ip->i_mount) &&
-		     !gid_eq(VFS_I(ip)->i_gid, be32_to_cpu(gdqp->q_core.d_id)))) {
+		     !qid_eq(make_kqid_gid(VFS_I(ip)->i_gid), gdqp->q_id))) {
 			delblksgdq = gdqp;
 			if (delblks) {
 				ASSERT(ip->i_gdquot);
@@ -1908,7 +1908,7 @@ xfs_qm_vop_create_dqattach(
 	if (udqp) {
 		ASSERT(ip->i_udquot == NULL);
 		ASSERT(XFS_IS_UQUOTA_ON(mp));
-		ASSERT(uid_eq(VFS_I(ip)->i_uid, be32_to_cpu(udqp->q_core.d_id)));
+		ASSERT(qid_eq(make_kqid_uid(VFS_I(ip)->i_uid), udqp->q_id));
 
 		ip->i_udquot = xfs_qm_dqhold(udqp);
 		xfs_trans_mod_dquot(tp, udqp, XFS_TRANS_DQ_ICOUNT, 1);
@@ -1916,9 +1916,9 @@ xfs_qm_vop_create_dqattach(
 	if (gdqp) {
 		ASSERT(ip->i_gdquot == NULL);
 		ASSERT(XFS_IS_OQUOTA_ON(mp));
-		ASSERT(XFS_IS_GQUOTA_ON(mp) ?
-		       gid_eq(VFS_I(ip)->i_gid, be32_to_cpu(gdqp->q_core.d_id)):
-		       projid_eq(ip->i_projid, be32_to_cpu(gdqp->q_core.d_id)));
+		ASSERT(qid_eq(XFS_IS_GQUOTA_ON(mp) ?
+			      make_kqid_gid(VFS_I(ip)->i_gid) :
+			      make_kqid_projid(ip->i_projid), gdqp->q_id));
 
 		ip->i_gdquot = xfs_qm_dqhold(gdqp);
 		xfs_trans_mod_dquot(tp, gdqp, XFS_TRANS_DQ_ICOUNT, 1);
diff --git a/fs/xfs/xfs_trace.h b/fs/xfs/xfs_trace.h
index 2e137d4..3cda9b4 100644
--- a/fs/xfs/xfs_trace.h
+++ b/fs/xfs/xfs_trace.h
@@ -712,7 +712,7 @@ DECLARE_EVENT_CLASS(xfs_dquot_class,
 	), \
 	TP_fast_assign(
 		__entry->dev = dqp->q_mount->m_super->s_dev;
-		__entry->id = be32_to_cpu(dqp->q_core.d_id);
+		__entry->id = from_kqid(&init_user_ns, dqp->q_id);
 		__entry->flags = dqp->dq_flags;
 		__entry->nrefs = dqp->q_nrefs;
 		__entry->res_bcount = dqp->q_res_bcount;
diff --git a/fs/xfs/xfs_trans_dquot.c b/fs/xfs/xfs_trans_dquot.c
index 0c7fa54..5e5fdfe 100644
--- a/fs/xfs/xfs_trans_dquot.c
+++ b/fs/xfs/xfs_trans_dquot.c
@@ -578,11 +578,7 @@ xfs_quota_warn(
 	/* no warnings for project quotas - we just return ENOSPC later */
 	if (dqp->dq_flags & XFS_DQ_PROJ)
 		return;
-	quota_send_warning(make_kqid(&init_user_ns,
-				     (dqp->dq_flags & XFS_DQ_USER) ?
-				     USRQUOTA : GRPQUOTA,
-				     be32_to_cpu(dqp->q_core.d_id)),
-			   mp->m_super->s_dev, type);
+	quota_send_warning(dqp->q_id, mp->m_super->s_dev, type);
 }
 
 /*
@@ -638,7 +634,7 @@ xfs_trans_dqresv(
 	}
 
 	if ((flags & XFS_QMOPT_FORCE_RES) == 0 &&
-	    dqp->q_core.d_id &&
+	    !is_superquota(dqp->q_id, &init_user_ns) &&
 	    ((XFS_IS_UQUOTA_ENFORCED(dqp->q_mount) && XFS_QM_ISUDQ(dqp)) ||
 	     (XFS_IS_OQUOTA_ENFORCED(dqp->q_mount) &&
 	      (XFS_QM_ISPDQ(dqp) || XFS_QM_ISGDQ(dqp))))) {
-- 
1.7.5.4
