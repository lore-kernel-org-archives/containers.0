From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 08/14] xfs: Use kprojids when allocating inodes.
Date: Wed, 13 Mar 2013 15:23:09 -0700
Message-ID: <1363213395-10988-8-git-send-email-ebiederm__1010.94450005821$1363213579$gmane$org@xmission.com>
References: <87boan3prc.fsf@xmission.com>
	<1363213395-10988-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1363213395-10988-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, xfs-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

In xfs_create and xfs_symlink compute the desired kprojid and pass it
down into xfs_ialloc.

Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/xfs/xfs_inode.c    |    5 +++--
 fs/xfs/xfs_inode.h    |    2 +-
 fs/xfs/xfs_qm.c       |    4 +++-
 fs/xfs/xfs_utils.c    |    2 +-
 fs/xfs/xfs_utils.h    |    2 +-
 fs/xfs/xfs_vnodeops.c |    8 ++++----
 6 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/fs/xfs/xfs_inode.c b/fs/xfs/xfs_inode.c
index 8d77e49..bed6947 100644
--- a/fs/xfs/xfs_inode.c
+++ b/fs/xfs/xfs_inode.c
@@ -1226,7 +1226,7 @@ xfs_ialloc(
 	umode_t		mode,
 	xfs_nlink_t	nlink,
 	xfs_dev_t	rdev,
-	prid_t		prid,
+	kprojid_t	prid,
 	int		okalloc,
 	xfs_buf_t	**ialloc_context,
 	xfs_inode_t	**ipp)
@@ -1290,7 +1290,8 @@ xfs_ialloc(
 	/*
 	 * Project ids won't be stored on disk if we are using a version 1 inode.
 	 */
-	if ((prid != 0) && (ip->i_d.di_version == 1))
+	if (!projid_eq(prid, make_kprojid(&init_user_ns, 0)) &&
+	    (ip->i_d.di_version == 1))
 		xfs_bump_ino_vers2(tp, ip);
 
 	if (pip && XFS_INHERIT_GID(pip)) {
diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
index 095bcbb..efe279e 100644
--- a/fs/xfs/xfs_inode.h
+++ b/fs/xfs/xfs_inode.h
@@ -516,7 +516,7 @@ int		xfs_isilocked(xfs_inode_t *, uint);
 uint		xfs_ilock_map_shared(xfs_inode_t *);
 void		xfs_iunlock_map_shared(xfs_inode_t *, uint);
 int		xfs_ialloc(struct xfs_trans *, xfs_inode_t *, umode_t,
-			   xfs_nlink_t, xfs_dev_t, prid_t, int,
+			   xfs_nlink_t, xfs_dev_t, kprojid_t, int,
 			   struct xfs_buf **, xfs_inode_t **);
 
 uint		xfs_ip2xflags(struct xfs_inode *);
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 3324dd3..861e4e8 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -777,7 +777,9 @@ xfs_qm_qino_alloc(
 		return error;
 	}
 
-	error = xfs_dir_ialloc(&tp, NULL, S_IFREG, 1, 0, 0, 1, ip, &committed);
+	error = xfs_dir_ialloc(&tp, NULL, S_IFREG, 1, 0,
+			       make_kprojid(&init_user_ns, 0),
+			       1, ip, &committed);
 	if (error) {
 		xfs_trans_cancel(tp, XFS_TRANS_RELEASE_LOG_RES |
 				 XFS_TRANS_ABORT);
diff --git a/fs/xfs/xfs_utils.c b/fs/xfs/xfs_utils.c
index 0025c78..f0a9f1d 100644
--- a/fs/xfs/xfs_utils.c
+++ b/fs/xfs/xfs_utils.c
@@ -54,7 +54,7 @@ xfs_dir_ialloc(
 	umode_t		mode,
 	xfs_nlink_t	nlink,
 	xfs_dev_t	rdev,
-	prid_t		prid,		/* project id */
+	kprojid_t	prid,		/* project id */
 	int		okalloc,	/* ok to allocate new space */
 	xfs_inode_t	**ipp,		/* pointer to inode; it will be
 					   locked. */
diff --git a/fs/xfs/xfs_utils.h b/fs/xfs/xfs_utils.h
index 5eeab46..7757f7c 100644
--- a/fs/xfs/xfs_utils.h
+++ b/fs/xfs/xfs_utils.h
@@ -19,7 +19,7 @@
 #define __XFS_UTILS_H__
 
 extern int xfs_dir_ialloc(xfs_trans_t **, xfs_inode_t *, umode_t, xfs_nlink_t,
-				xfs_dev_t, prid_t, int, xfs_inode_t **, int *);
+				xfs_dev_t, kprojid_t, int, xfs_inode_t **, int *);
 extern int xfs_droplink(xfs_trans_t *, xfs_inode_t *);
 extern int xfs_bumplink(xfs_trans_t *, xfs_inode_t *);
 extern void xfs_bump_ino_vers2(xfs_trans_t *, xfs_inode_t *);
diff --git a/fs/xfs/xfs_vnodeops.c b/fs/xfs/xfs_vnodeops.c
index dab0ab3..863b979 100644
--- a/fs/xfs/xfs_vnodeops.c
+++ b/fs/xfs/xfs_vnodeops.c
@@ -728,7 +728,7 @@ xfs_create(
 	bool                    unlock_dp_on_error = false;
 	uint			cancel_flags;
 	int			committed;
-	prid_t			prid;
+	kprojid_t		prid;
 	struct xfs_dquot	*udqp = NULL;
 	struct xfs_dquot	*gdqp = NULL;
 	uint			resblks;
@@ -743,7 +743,7 @@ xfs_create(
 	if (dp->i_d.di_flags & XFS_DIFLAG_PROJINHERIT)
 		prid = dp->i_d.di_projid;
 	else
-		prid = XFS_PROJID_DEFAULT;
+		prid = make_kprojid(&init_user_ns, XFS_PROJID_DEFAULT);
 
 	/*
 	 * Make sure that we have allocated dquot(s) on disk.
@@ -1379,7 +1379,7 @@ xfs_symlink(
 	int			byte_cnt;
 	int			n;
 	xfs_buf_t		*bp;
-	prid_t			prid;
+	kprojid_t		prid;
 	struct xfs_dquot	*udqp, *gdqp;
 	uint			resblks;
 
@@ -1404,7 +1404,7 @@ xfs_symlink(
 	if (dp->i_d.di_flags & XFS_DIFLAG_PROJINHERIT)
 		prid = dp->i_d.di_projid;
 	else
-		prid = XFS_PROJID_DEFAULT;
+		prid = make_kprojid(&init_user_ns, XFS_PROJID_DEFAULT);
 
 	/*
 	 * Make sure that we have allocated dquot(s) on disk.
-- 
1.7.5.4
