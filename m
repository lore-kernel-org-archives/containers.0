From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 05/16] xfs: Update xfs_ioctl_setattr to handle projids
	in any user namespace
Date: Sun, 17 Feb 2013 17:10:58 -0800
Message-ID: <1361149870-27732-5-git-send-email-ebiederm@xmission.com>
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

- Convert the userspace value in fa->fsx_projid into a kprojid and
  store it in the variable projid.
- Verify that xfs can store the projid after it is converted into
  xfs's user namespace.
- Replace uses of fa->fsx_projid with projid throughout
  xfs_ioctl_setattr.

Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/xfs/xfs_ioctl.c |   26 ++++++++++++++++++--------
 1 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 016624b..4a55f50 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -925,6 +925,7 @@ xfs_ioctl_setattr(
 	struct xfs_dquot	*gdqp = NULL;
 	struct xfs_dquot	*olddquot = NULL;
 	int			code;
+	kprojid_t		projid = INVALID_PROJID;
 
 	trace_xfs_ioctl_setattr(ip);
 
@@ -934,11 +935,20 @@ xfs_ioctl_setattr(
 		return XFS_ERROR(EIO);
 
 	/*
-	 * Disallow 32bit project ids when projid32bit feature is not enabled.
+	 * Verify the specifid project id is valid.
 	 */
-	if ((mask & FSX_PROJID) && (fa->fsx_projid > (__uint16_t)-1) &&
-			!xfs_sb_version_hasprojid32bit(&ip->i_mount->m_sb))
-		return XFS_ERROR(EINVAL);
+	if (mask & FSX_PROJID) {
+		projid = make_kprojid(current_user_ns(), fa->fsx_projid);
+		if (!projid_valid(projid))
+			return XFS_ERROR(EINVAL);
+
+		/*
+		 * Disallow 32bit project ids when projid32bit feature is not enabled.
+		 */
+		if ((from_kprojid(&init_user_ns, projid) > (__uint16_t)-1) &&
+		    !xfs_sb_version_hasprojid32bit(&ip->i_mount->m_sb))
+			return XFS_ERROR(EINVAL);
+	}
 
 	/*
 	 * If disk quotas is on, we make sure that the dquots do exist on disk,
@@ -950,7 +960,7 @@ xfs_ioctl_setattr(
 	 */
 	if (XFS_IS_QUOTA_ON(mp) && (mask & FSX_PROJID)) {
 		code = xfs_qm_vop_dqalloc(ip, VFS_I(ip)->i_uid,
-					 VFS_I(ip)->i_gid, fa->fsx_projid,
+					 VFS_I(ip)->i_gid, projid,
 					 XFS_QMOPT_PQUOTA, &udqp, &gdqp);
 		if (code)
 			return code;
@@ -986,7 +996,7 @@ xfs_ioctl_setattr(
 	if (mask & FSX_PROJID) {
 		if (XFS_IS_QUOTA_RUNNING(mp) &&
 		    XFS_IS_PQUOTA_ON(mp) &&
-		    !projid_eq(ip->i_projid, fa->fsx_projid)) {
+		    !projid_eq(ip->i_projid, projid)) {
 			ASSERT(tp);
 			code = xfs_qm_vop_chown_reserve(tp, ip, udqp, gdqp,
 						capable(CAP_FOWNER) ?
@@ -1104,12 +1114,12 @@ xfs_ioctl_setattr(
 		 * Change the ownerships and register quota modifications
 		 * in the transaction.
 		 */
-		if (!projid_eq(ip->i_projid, fa->fsx_projid)) {
+		if (!projid_eq(ip->i_projid, projid)) {
 			if (XFS_IS_QUOTA_RUNNING(mp) && XFS_IS_PQUOTA_ON(mp)) {
 				olddquot = xfs_qm_vop_chown(tp, ip,
 							&ip->i_gdquot, gdqp);
 			}
-			xfs_set_projid(ip, fa->fsx_projid);
+			xfs_set_projid(ip, projid);
 
 			/*
 			 * We may have to rev the inode as well as
-- 
1.7.5.4
