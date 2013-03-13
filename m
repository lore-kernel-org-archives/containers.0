From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 07/14] xfs: Update ioctl(XFS_IOC_FREE_EOFBLOCKS) to handle
	callers in any userspace
Date: Wed, 13 Mar 2013 15:23:08 -0700
Message-ID: <1363213395-10988-7-git-send-email-ebiederm__35875.800313852$1363213565$gmane$org@xmission.com>
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

- Modify the ioctl to convert from uids, gid, and projids in the
  current user namespace to kuids, kgids, and kprojids, and to report
  an error if the conversion fails.

- Create struct xfs_internal_eofblocks to hold the same information as
  struct xfs_eofblocks but with uids, gids, and projids stored as
  kuids, kgids, and kprojids preventing confusion.

- Pass struct xfs_interanl_eofblocks into xfs_icache_free_eofblocks
  and it's helpers ensuring there will not be confusing about which
  user namespace identifiers that need to be compared are in.

Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/xfs/xfs_icache.c |    8 ++++----
 fs/xfs/xfs_icache.h |   11 ++++++++++-
 fs/xfs/xfs_ioctl.c  |   22 +++++++++++++++++++++-
 3 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 03a4427..032c28c 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -1199,7 +1199,7 @@ xfs_reclaim_inodes_count(
 STATIC int
 xfs_inode_match_id(
 	struct xfs_inode	*ip,
-	struct xfs_eofblocks	*eofb)
+	struct xfs_internal_eofblocks	*eofb)
 {
 	if (eofb->eof_flags & XFS_EOF_FLAGS_UID &&
 	    !uid_eq(ip->i_d.di_uid, eofb->eof_uid))
@@ -1210,7 +1210,7 @@ xfs_inode_match_id(
 		return 0;
 
 	if (eofb->eof_flags & XFS_EOF_FLAGS_PRID &&
-	    !projid_eq(ip->i_d.di_projid, eofb->eof_prid))
+	    !projid_eq(ip->i_d.di_projid, eofb->eof_projid))
 		return 0;
 
 	return 1;
@@ -1224,7 +1224,7 @@ xfs_inode_free_eofblocks(
 	void			*args)
 {
 	int ret;
-	struct xfs_eofblocks *eofb = args;
+	struct xfs_internal_eofblocks *eofb = args;
 
 	if (!xfs_can_free_eofblocks(ip, false)) {
 		/* inode could be preallocated or append-only */
@@ -1263,7 +1263,7 @@ xfs_inode_free_eofblocks(
 int
 xfs_icache_free_eofblocks(
 	struct xfs_mount	*mp,
-	struct xfs_eofblocks	*eofb)
+	struct xfs_internal_eofblocks	*eofb)
 {
 	int flags = SYNC_TRYLOCK;
 
diff --git a/fs/xfs/xfs_icache.h b/fs/xfs/xfs_icache.h
index e0f138c..260dc27 100644
--- a/fs/xfs/xfs_icache.h
+++ b/fs/xfs/xfs_icache.h
@@ -35,9 +35,18 @@ void xfs_reclaim_inodes_nr(struct xfs_mount *mp, int nr_to_scan);
 
 void xfs_inode_set_reclaim_tag(struct xfs_inode *ip);
 
+struct xfs_internal_eofblocks {
+	u32		eof_version;
+	u32		eof_flags;
+	kuid_t		eof_uid;
+	kgid_t		eof_gid;
+	kprojid_t	eof_projid;
+	u64		eof_min_file_size;
+};
+
 void xfs_inode_set_eofblocks_tag(struct xfs_inode *ip);
 void xfs_inode_clear_eofblocks_tag(struct xfs_inode *ip);
-int xfs_icache_free_eofblocks(struct xfs_mount *, struct xfs_eofblocks *);
+int xfs_icache_free_eofblocks(struct xfs_mount *, struct xfs_internal_eofblocks *);
 void xfs_eofblocks_worker(struct work_struct *);
 
 int xfs_sync_inode_grab(struct xfs_inode *ip);
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 9aeecfb..8c933e5 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1615,6 +1615,7 @@ xfs_file_ioctl(
 
 	case XFS_IOC_FREE_EOFBLOCKS: {
 		struct xfs_eofblocks eofb;
+		struct xfs_internal_eofblocks keofb;
 
 		if (copy_from_user(&eofb, arg, sizeof(eofb)))
 			return -XFS_ERROR(EFAULT);
@@ -1629,7 +1630,26 @@ xfs_file_ioctl(
 		    memchr_inv(eofb.pad64, 0, sizeof(eofb.pad64)))
 			return -XFS_ERROR(EINVAL);
 
-		error = xfs_icache_free_eofblocks(mp, &eofb);
+		keofb.eof_version = eofb.eof_version;
+		keofb.eof_flags   = eofb.eof_flags;
+		if (eofb.eof_flags & XFS_EOF_FLAGS_UID) {
+			keofb.eof_uid = make_kuid(current_user_ns(), eofb.eof_uid);
+			if (!uid_valid(keofb.eof_uid))
+				return -XFS_ERROR(EINVAL);
+		}
+		if (eofb.eof_flags & XFS_EOF_FLAGS_GID) {
+			keofb.eof_gid = make_kgid(current_user_ns(), eofb.eof_gid);
+			if (!gid_valid(keofb.eof_gid))
+				return -XFS_ERROR(EINVAL);
+		}
+		if (eofb.eof_flags & XFS_EOF_FLAGS_PRID) {
+			keofb.eof_projid = make_kprojid(current_user_ns(), eofb.eof_prid);
+			if (!projid_valid(keofb.eof_projid))
+				return -XFS_ERROR(EINVAL);
+		}
+		keofb.eof_min_file_size = eofb.eof_min_file_size;
+
+		error = xfs_icache_free_eofblocks(mp, &keofb);
 		return -error;
 	}
 
-- 
1.7.5.4
