From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC 10/12] userns: Convert xfs to use kuid/kgid/kprojid where
	appropriate
Date: Tue, 20 Nov 2012 04:43:38 -0800
Message-ID: <1353415420-5457-10-git-send-email-ebiederm@xmission.com>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353415420-5457-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

- Modify the incore inode to use kuid_t, kgid_t and kprojid_t.
- Remove xfs_get_projid and xfs_set_projid with projid being stored
  in a single field they are unnecessary.
- Add dq_id (a struct kqid) to struct xfs_dquot to retain the incore
  version of the quota identifiers.
- Pass struct kquid all of the way into xfs_qm_dqgetn and xfs_qm_dqread,
  and move xfs_quota_type into xfs_dquot.c from xfs_quotaops.c to support
  this change.

Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/xfs/xfs_acl.c         |   23 ++++++++++--
 fs/xfs/xfs_dquot.c       |   36 +++++++++++++------
 fs/xfs/xfs_dquot.h       |    5 ++-
 fs/xfs/xfs_inode.c       |   33 ++++++++++-------
 fs/xfs/xfs_inode.h       |   32 +++--------------
 fs/xfs/xfs_ioctl.c       |   23 +++++++++---
 fs/xfs/xfs_iops.c        |   18 +++++-----
 fs/xfs/xfs_itable.c      |    8 ++--
 fs/xfs/xfs_qm.c          |   87 ++++++++++++++++++++++++---------------------
 fs/xfs/xfs_qm.h          |    4 +-
 fs/xfs/xfs_qm_bhv.c      |    3 +-
 fs/xfs/xfs_qm_syscalls.c |   24 +++++++------
 fs/xfs/xfs_quota.h       |    4 +-
 fs/xfs/xfs_quotaops.c    |   20 +---------
 fs/xfs/xfs_rename.c      |    2 +-
 fs/xfs/xfs_trans_dquot.c |    6 +---
 fs/xfs/xfs_utils.c       |    2 +-
 fs/xfs/xfs_utils.h       |    2 +-
 fs/xfs/xfs_vnodeops.c    |   14 ++++----
 init/Kconfig             |    1 -
 20 files changed, 179 insertions(+), 168 deletions(-)

diff --git a/fs/xfs/xfs_acl.c b/fs/xfs/xfs_acl.c
index 1d32f1d..ca2aade 100644
--- a/fs/xfs/xfs_acl.c
+++ b/fs/xfs/xfs_acl.c
@@ -64,14 +64,17 @@ xfs_acl_from_disk(struct xfs_acl *aclp)
 
 		switch (acl_e->e_tag) {
 		case ACL_USER:
+			acl_e->e_uid = make_kuid(&init_user_ns,
+						 be32_to_cpu(ace->ae_id));
+			break;
 		case ACL_GROUP:
-			acl_e->e_id = be32_to_cpu(ace->ae_id);
+			acl_e->e_gid = make_kgid(&init_user_ns,
+						 be32_to_cpu(ace->ae_id));
 			break;
 		case ACL_USER_OBJ:
 		case ACL_GROUP_OBJ:
 		case ACL_MASK:
 		case ACL_OTHER:
-			acl_e->e_id = ACL_UNDEFINED_ID;
 			break;
 		default:
 			goto fail;
@@ -97,8 +100,20 @@ xfs_acl_to_disk(struct xfs_acl *aclp, const struct posix_acl *acl)
 		acl_e = &acl->a_entries[i];
 
 		ace->ae_tag = cpu_to_be32(acl_e->e_tag);
-		ace->ae_id = cpu_to_be32(acl_e->e_id);
 		ace->ae_perm = cpu_to_be16(acl_e->e_perm);
+		switch(acl_e->e_tag) {
+		case ACL_USER:
+			ace->ae_id = cpu_to_be32(
+				from_kuid(&init_user_ns, acl_e->e_uid));
+			break;
+		case ACL_GROUP:
+			ace->ae_id = cpu_to_be32(
+				from_kgid(&init_user_ns, acl_e->e_gid));
+			break;
+		default:
+			ace->ae_id = cpu_to_be32(ACL_UNDEFINED_ID);
+			break;
+		}
 	}
 }
 
@@ -355,7 +370,7 @@ xfs_xattr_acl_set(struct dentry *dentry, const char *name,
 		return -EINVAL;
 	if (type == ACL_TYPE_DEFAULT && !S_ISDIR(inode->i_mode))
 		return value ? -EACCES : 0;
-	if ((current_fsuid() != inode->i_uid) && !capable(CAP_FOWNER))
+	if ((!uid_eq(current_fsuid(), inode->i_uid)) && !capable(CAP_FOWNER))
 		return -EPERM;
 
 	if (!value)
diff --git a/fs/xfs/xfs_dquot.c b/fs/xfs/xfs_dquot.c
index bf27fcc..428926c 100644
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
@@ -480,8 +493,7 @@ xfs_qm_dqtobp(
 int
 xfs_qm_dqread(
 	struct xfs_mount	*mp,
-	xfs_dqid_t		id,
-	uint			type,
+	struct kqid		id,
 	uint			flags,
 	struct xfs_dquot	**O_dqpp)
 {
@@ -495,8 +507,9 @@ xfs_qm_dqread(
 
 	dqp = kmem_zone_zalloc(xfs_qm_dqzone, KM_SLEEP);
 
-	dqp->dq_flags = type;
-	dqp->q_core.d_id = cpu_to_be32(id);
+	dqp->dq_id = id;
+	dqp->dq_flags = xfs_quota_type(id.type);
+	dqp->q_core.d_id = cpu_to_be32(from_kqid(&init_user_ns, id));
 	dqp->q_mount = mp;
 	INIT_LIST_HEAD(&dqp->q_lru);
 	mutex_init(&dqp->q_qlock);
@@ -514,7 +527,7 @@ xfs_qm_dqread(
 	 * Make sure group quotas have a different lock class than user
 	 * quotas.
 	 */
-	if (!(type & XFS_DQ_USER))
+	if (id.type != USRQUOTA)
 		lockdep_set_class(&dqp->q_qlock, &xfs_dquot_other_class);
 
 	XFS_STATS_INC(xs_qm_dquot);
@@ -614,12 +627,12 @@ int
 xfs_qm_dqget(
 	xfs_mount_t	*mp,
 	xfs_inode_t	*ip,	  /* locked inode (optional) */
-	xfs_dqid_t	id,	  /* uid/projid/gid depending on type */
-	uint		type,	  /* XFS_DQ_USER/XFS_DQ_PROJ/XFS_DQ_GROUP */
+	struct kqid	id,	  /* uid/projid/gid depending on type */
 	uint		flags,	  /* DQALLOC, DQSUSER, DQREPAIR, DOWARN */
 	xfs_dquot_t	**O_dqpp) /* OUT : locked incore dquot */
 {
 	struct xfs_quotainfo	*qi = mp->m_quotainfo;
+	uint type = xfs_quota_type(id.type);
 	struct radix_tree_root *tree = XFS_DQUOT_TREE(qi, type);
 	struct xfs_dquot	*dqp;
 	int			error;
@@ -651,7 +664,7 @@ xfs_qm_dqget(
 
 restart:
 	mutex_lock(&qi->qi_tree_lock);
-	dqp = radix_tree_lookup(tree, id);
+	dqp = radix_tree_lookup(tree, from_kqid(&init_user_ns, id));
 	if (dqp) {
 		xfs_dqlock(dqp);
 		if (dqp->dq_flags & XFS_DQ_FREEING) {
@@ -683,7 +696,7 @@ restart:
 	if (ip)
 		xfs_iunlock(ip, XFS_ILOCK_EXCL);
 
-	error = xfs_qm_dqread(mp, id, type, flags, &dqp);
+	error = xfs_qm_dqread(mp, id, flags, &dqp);
 
 	if (ip)
 		xfs_ilock(ip, XFS_ILOCK_EXCL);
@@ -714,7 +727,7 @@ restart:
 	}
 
 	mutex_lock(&qi->qi_tree_lock);
-	error = -radix_tree_insert(tree, id, dqp);
+	error = -radix_tree_insert(tree, from_kqid(&init_user_ns, id), dqp);
 	if (unlikely(error)) {
 		WARN_ON(error != EEXIST);
 
@@ -990,8 +1003,7 @@ xfs_dqlock2(
 {
 	if (d1 && d2) {
 		ASSERT(d1 != d2);
-		if (be32_to_cpu(d1->q_core.d_id) >
-		    be32_to_cpu(d2->q_core.d_id)) {
+		if (qid_lt(d2->dq_id, d1->dq_id)) {
 			mutex_lock(&d2->q_qlock);
 			mutex_lock_nested(&d1->q_qlock, XFS_QLOCK_NESTED);
 		} else {
diff --git a/fs/xfs/xfs_dquot.h b/fs/xfs/xfs_dquot.h
index 7d20af2..1f19b87 100644
--- a/fs/xfs/xfs_dquot.h
+++ b/fs/xfs/xfs_dquot.h
@@ -36,6 +36,7 @@ struct xfs_trans;
  * The incore dquot structure
  */
 typedef struct xfs_dquot {
+	struct kqid	 dq_id;		/* Quota identifier */
 	uint		 dq_flags;	/* various flags (XFS_DQ_*) */
 	struct list_head q_lru;		/* global free list of dquots */
 	struct xfs_mount*q_mount;	/* filesystem this relates to */
@@ -138,7 +139,7 @@ static inline xfs_dquot_t *xfs_inode_dquot(struct xfs_inode *ip, int type)
 				 XFS_DQ_TO_QINF(dqp)->qi_uquotaip : \
 				 XFS_DQ_TO_QINF(dqp)->qi_gquotaip)
 
-extern int		xfs_qm_dqread(struct xfs_mount *, xfs_dqid_t, uint,
+extern int		xfs_qm_dqread(struct xfs_mount *, struct kqid,
 					uint, struct xfs_dquot	**);
 extern void		xfs_qm_dqdestroy(xfs_dquot_t *);
 extern int		xfs_qm_dqflush(struct xfs_dquot *, struct xfs_buf **);
@@ -148,7 +149,7 @@ extern void		xfs_qm_adjust_dqtimers(xfs_mount_t *,
 extern void		xfs_qm_adjust_dqlimits(xfs_mount_t *,
 					xfs_disk_dquot_t *);
 extern int		xfs_qm_dqget(xfs_mount_t *, xfs_inode_t *,
-					xfs_dqid_t, uint, uint, xfs_dquot_t **);
+					struct kqid, uint, xfs_dquot_t **);
 extern void		xfs_qm_dqput(xfs_dquot_t *);
 
 extern void		xfs_dqlock2(struct xfs_dquot *, struct xfs_dquot *);
diff --git a/fs/xfs/xfs_inode.c b/fs/xfs/xfs_inode.c
index 2778258..3656b88 100644
--- a/fs/xfs/xfs_inode.c
+++ b/fs/xfs/xfs_inode.c
@@ -570,11 +570,12 @@ xfs_dinode_from_disk(
 	to->di_version = from ->di_version;
 	to->di_format = from->di_format;
 	to->di_onlink = be16_to_cpu(from->di_onlink);
-	to->di_uid = be32_to_cpu(from->di_uid);
-	to->di_gid = be32_to_cpu(from->di_gid);
+	to->di_uid = make_kuid(&init_user_ns, be32_to_cpu(from->di_uid));
+	to->di_gid = make_kgid(&init_user_ns, be32_to_cpu(from->di_gid));
 	to->di_nlink = be32_to_cpu(from->di_nlink);
-	to->di_projid_lo = be16_to_cpu(from->di_projid_lo);
-	to->di_projid_hi = be16_to_cpu(from->di_projid_hi);
+	to->di_projid = make_kprojid(&init_user_ns,
+				     be16_to_cpu(from->di_projid_lo) |
+				     (be16_to_cpu(from->di_projid_hi) << 16));
 	memcpy(to->di_pad, from->di_pad, sizeof(to->di_pad));
 	to->di_flushiter = be16_to_cpu(from->di_flushiter);
 	to->di_atime.t_sec = be32_to_cpu(from->di_atime.t_sec);
@@ -601,16 +602,18 @@ xfs_dinode_to_disk(
 	xfs_dinode_t		*to,
 	xfs_icdinode_t		*from)
 {
+	projid_t projid = from_kprojid(&init_user_ns, from->di_projid);
+
 	to->di_magic = cpu_to_be16(from->di_magic);
 	to->di_mode = cpu_to_be16(from->di_mode);
 	to->di_version = from ->di_version;
 	to->di_format = from->di_format;
 	to->di_onlink = cpu_to_be16(from->di_onlink);
-	to->di_uid = cpu_to_be32(from->di_uid);
-	to->di_gid = cpu_to_be32(from->di_gid);
+	to->di_uid = cpu_to_be32(from_kuid(&init_user_ns, from->di_uid));
+	to->di_gid = cpu_to_be32(from_kgid(&init_user_ns, from->di_gid));
 	to->di_nlink = cpu_to_be32(from->di_nlink);
-	to->di_projid_lo = cpu_to_be16(from->di_projid_lo);
-	to->di_projid_hi = cpu_to_be16(from->di_projid_hi);
+	to->di_projid_lo = cpu_to_be16(projid & 0xffff);
+	to->di_projid_hi = cpu_to_be16(projid >> 16);
 	memcpy(to->di_pad, from->di_pad, sizeof(to->di_pad));
 	to->di_flushiter = cpu_to_be16(from->di_flushiter);
 	to->di_atime.t_sec = cpu_to_be32(from->di_atime.t_sec);
@@ -778,7 +781,7 @@ xfs_iread(
 	if (ip->i_d.di_version == 1) {
 		ip->i_d.di_nlink = ip->i_d.di_onlink;
 		ip->i_d.di_onlink = 0;
-		xfs_set_projid(ip, 0);
+		ip->i_d.di_projid = make_kprojid(&init_user_ns, 0);
 	}
 
 	ip->i_delayed_blks = 0;
@@ -884,7 +887,7 @@ xfs_ialloc(
 	umode_t		mode,
 	xfs_nlink_t	nlink,
 	xfs_dev_t	rdev,
-	prid_t		prid,
+	kprojid_t	prid,
 	int		okalloc,
 	xfs_buf_t	**ialloc_context,
 	xfs_inode_t	**ipp)
@@ -927,7 +930,7 @@ xfs_ialloc(
 	ASSERT(ip->i_d.di_nlink == nlink);
 	ip->i_d.di_uid = current_fsuid();
 	ip->i_d.di_gid = current_fsgid();
-	xfs_set_projid(ip, prid);
+	ip->i_d.di_projid = prid;
 	memset(&(ip->i_d.di_pad[0]), 0, sizeof(ip->i_d.di_pad));
 
 	/*
@@ -948,7 +951,8 @@ xfs_ialloc(
 	/*
 	 * Project ids won't be stored on disk if we are using a version 1 inode.
 	 */
-	if ((prid != 0) && (ip->i_d.di_version == 1))
+	if (!projid_eq(prid, make_kprojid(&init_user_ns, 0)) &&
+	    (ip->i_d.di_version == 1))
 		xfs_bump_ino_vers2(tp, ip);
 
 	if (pip && XFS_INHERIT_GID(pip)) {
@@ -965,7 +969,7 @@ xfs_ialloc(
 	 */
 	if ((irix_sgid_inherit) &&
 	    (ip->i_d.di_mode & S_ISGID) &&
-	    (!in_group_p((gid_t)ip->i_d.di_gid))) {
+	    (!in_group_p(ip->i_d.di_gid))) {
 		ip->i_d.di_mode &= ~S_ISGID;
 	}
 
@@ -2554,7 +2558,8 @@ xfs_iflush_int(
 			memset(&(ip->i_d.di_pad[0]), 0, sizeof(ip->i_d.di_pad));
 			memset(&(dip->di_pad[0]), 0,
 			      sizeof(dip->di_pad));
-			ASSERT(xfs_get_projid(ip) == 0);
+			ASSERT(projid_eq(ip->i_d.di_projid,
+					 make_kprojid(&init_user_ns, 0)));
 		}
 	}
 
diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
index 94b32f9..973b252 100644
--- a/fs/xfs/xfs_inode.h
+++ b/fs/xfs/xfs_inode.h
@@ -120,8 +120,8 @@ typedef struct xfs_ictimestamp {
 } xfs_ictimestamp_t;
 
 /*
- * NOTE:  This structure must be kept identical to struct xfs_dinode
- * 	  in xfs_dinode.h except for the endianness annotations.
+ * NOTE:  This structure must contain all of the same informationas struct xfs_dinode
+ * 	  in xfs_dinode.h except in core format.
  */
 typedef struct xfs_icdinode {
 	__uint16_t	di_magic;	/* inode magic # = XFS_DINODE_MAGIC */
@@ -129,11 +129,10 @@ typedef struct xfs_icdinode {
 	__int8_t	di_version;	/* inode version */
 	__int8_t	di_format;	/* format of di_c data */
 	__uint16_t	di_onlink;	/* old number of links to file */
-	__uint32_t	di_uid;		/* owner's user id */
-	__uint32_t	di_gid;		/* owner's group id */
+	kuid_t		di_uid;		/* owner's user id */
+	kgid_t		di_gid;		/* owner's group id */
 	__uint32_t	di_nlink;	/* number of links to file */
-	__uint16_t	di_projid_lo;	/* lower part of owner's project id */
-	__uint16_t	di_projid_hi;	/* higher part of owner's project id */
+	kprojid_t	di_projid;	/* project id */
 	__uint8_t	di_pad[6];	/* unused, zeroed space */
 	__uint16_t	di_flushiter;	/* incremented on flush */
 	xfs_ictimestamp_t di_atime;	/* time last accessed */
@@ -355,25 +354,6 @@ xfs_iflags_test_and_set(xfs_inode_t *ip, unsigned short flags)
 }
 
 /*
- * Project quota id helpers (previously projid was 16bit only
- * and using two 16bit values to hold new 32bit projid was chosen
- * to retain compatibility with "old" filesystems).
- */
-static inline prid_t
-xfs_get_projid(struct xfs_inode *ip)
-{
-	return (prid_t)ip->i_d.di_projid_hi << 16 | ip->i_d.di_projid_lo;
-}
-
-static inline void
-xfs_set_projid(struct xfs_inode *ip,
-		prid_t projid)
-{
-	ip->i_d.di_projid_hi = (__uint16_t) (projid >> 16);
-	ip->i_d.di_projid_lo = (__uint16_t) (projid & 0xffff);
-}
-
-/*
  * In-core inode flags.
  */
 #define XFS_IRECLAIM		(1 << 0) /* started reclaiming this inode */
@@ -514,7 +494,7 @@ void		xfs_inode_free(struct xfs_inode *ip);
  * xfs_inode.c prototypes.
  */
 int		xfs_ialloc(struct xfs_trans *, xfs_inode_t *, umode_t,
-			   xfs_nlink_t, xfs_dev_t, prid_t, int,
+			   xfs_nlink_t, xfs_dev_t, kprojid_t, int,
 			   struct xfs_buf **, xfs_inode_t **);
 
 uint		xfs_ip2xflags(struct xfs_inode *);
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 8305f2a..434892e 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -814,7 +814,7 @@ xfs_ioc_fsgetxattr(
 	xfs_ilock(ip, XFS_ILOCK_SHARED);
 	fa.fsx_xflags = xfs_ip2xflags(ip);
 	fa.fsx_extsize = ip->i_d.di_extsize << ip->i_mount->m_sb.sb_blocklog;
-	fa.fsx_projid = xfs_get_projid(ip);
+	fa.fsx_projid = from_kprojid_munged(current_user_ns(), ip->i_d.di_projid);
 
 	if (attr) {
 		if (ip->i_afp) {
@@ -924,6 +924,7 @@ xfs_ioctl_setattr(
 	struct xfs_dquot	*gdqp = NULL;
 	struct xfs_dquot	*olddquot = NULL;
 	int			code;
+	kprojid_t		projid = INVALID_PROJID;
 
 	trace_xfs_ioctl_setattr(ip);
 
@@ -940,6 +941,15 @@ xfs_ioctl_setattr(
 		return XFS_ERROR(EINVAL);
 
 	/*
+	 * Verify the specifid project id is valid.
+	 */
+	if (mask & FSX_PROJID) {
+		projid = make_kprojid(current_user_ns(), fa->fsx_projid);
+		if (!projid_valid(projid))
+			return XFS_ERROR(EINVAL);
+	}
+
+	/*
 	 * If disk quotas is on, we make sure that the dquots do exist on disk,
 	 * before we start any other transactions. Trying to do this later
 	 * is messy. We don't care to take a readlock to look at the ids
@@ -949,7 +959,7 @@ xfs_ioctl_setattr(
 	 */
 	if (XFS_IS_QUOTA_ON(mp) && (mask & FSX_PROJID)) {
 		code = xfs_qm_vop_dqalloc(ip, ip->i_d.di_uid,
-					 ip->i_d.di_gid, fa->fsx_projid,
+					 ip->i_d.di_gid, projid,
 					 XFS_QMOPT_PQUOTA, &udqp, &gdqp);
 		if (code)
 			return code;
@@ -974,7 +984,8 @@ xfs_ioctl_setattr(
 	 * to the file owner ID, except in cases where the
 	 * CAP_FSETID capability is applicable.
 	 */
-	if (current_fsuid() != ip->i_d.di_uid && !capable(CAP_FOWNER)) {
+	if (!uid_eq(current_fsuid(), ip->i_d.di_uid) &&
+	    !capable(CAP_FOWNER)) {
 		code = XFS_ERROR(EPERM);
 		goto error_return;
 	}
@@ -985,7 +996,7 @@ xfs_ioctl_setattr(
 	if (mask & FSX_PROJID) {
 		if (XFS_IS_QUOTA_RUNNING(mp) &&
 		    XFS_IS_PQUOTA_ON(mp) &&
-		    xfs_get_projid(ip) != fa->fsx_projid) {
+		    !projid_eq(ip->i_d.di_projid, projid)) {
 			ASSERT(tp);
 			code = xfs_qm_vop_chown_reserve(tp, ip, udqp, gdqp,
 						capable(CAP_FOWNER) ?
@@ -1103,12 +1114,12 @@ xfs_ioctl_setattr(
 		 * Change the ownerships and register quota modifications
 		 * in the transaction.
 		 */
-		if (xfs_get_projid(ip) != fa->fsx_projid) {
+		if (!projid_eq(ip->i_d.di_projid, projid)) {
 			if (XFS_IS_QUOTA_RUNNING(mp) && XFS_IS_PQUOTA_ON(mp)) {
 				olddquot = xfs_qm_vop_chown(tp, ip,
 							&ip->i_gdquot, gdqp);
 			}
-			xfs_set_projid(ip, fa->fsx_projid);
+			ip->i_d.di_projid = projid;
 
 			/*
 			 * We may have to rev the inode as well as
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index 4e00cf0..ff80a0d 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -465,8 +465,8 @@ xfs_setattr_nonsize(
 	int			mask = iattr->ia_valid;
 	xfs_trans_t		*tp;
 	int			error;
-	uid_t			uid = 0, iuid = 0;
-	gid_t			gid = 0, igid = 0;
+	kuid_t			uid = GLOBAL_ROOT_UID, iuid = GLOBAL_ROOT_UID;
+	kgid_t			gid = GLOBAL_ROOT_GID, igid = GLOBAL_ROOT_GID;
 	struct xfs_dquot	*udqp = NULL, *gdqp = NULL;
 	struct xfs_dquot	*olddquot1 = NULL, *olddquot2 = NULL;
 
@@ -515,7 +515,7 @@ xfs_setattr_nonsize(
 		 */
 		ASSERT(udqp == NULL);
 		ASSERT(gdqp == NULL);
-		error = xfs_qm_vop_dqalloc(ip, uid, gid, xfs_get_projid(ip),
+		error = xfs_qm_vop_dqalloc(ip, uid, gid, ip->i_d.di_projid,
 					 qflags, &udqp, &gdqp);
 		if (error)
 			return error;
@@ -548,8 +548,8 @@ xfs_setattr_nonsize(
 		 * going to change.
 		 */
 		if (XFS_IS_QUOTA_RUNNING(mp) &&
-		    ((XFS_IS_UQUOTA_ON(mp) && iuid != uid) ||
-		     (XFS_IS_GQUOTA_ON(mp) && igid != gid))) {
+		    ((XFS_IS_UQUOTA_ON(mp) && !uid_eq(iuid, uid)) ||
+		     (XFS_IS_GQUOTA_ON(mp) && !gid_eq(igid, gid)))) {
 			ASSERT(tp);
 			error = xfs_qm_vop_chown_reserve(tp, ip, udqp, gdqp,
 						capable(CAP_FOWNER) ?
@@ -579,7 +579,7 @@ xfs_setattr_nonsize(
 		 * Change the ownerships and register quota modifications
 		 * in the transaction.
 		 */
-		if (iuid != uid) {
+		if (!uid_eq(iuid, uid)) {
 			if (XFS_IS_QUOTA_RUNNING(mp) && XFS_IS_UQUOTA_ON(mp)) {
 				ASSERT(mask & ATTR_UID);
 				ASSERT(udqp);
@@ -589,7 +589,7 @@ xfs_setattr_nonsize(
 			ip->i_d.di_uid = uid;
 			inode->i_uid = uid;
 		}
-		if (igid != gid) {
+		if (!gid_eq(igid, gid)) {
 			if (XFS_IS_QUOTA_RUNNING(mp) && XFS_IS_GQUOTA_ON(mp)) {
 				ASSERT(!XFS_IS_PQUOTA_ON(mp));
 				ASSERT(mask & ATTR_GID);
@@ -1151,8 +1151,8 @@ xfs_setup_inode(
 
 	inode->i_mode	= ip->i_d.di_mode;
 	set_nlink(inode, ip->i_d.di_nlink);
-	inode->i_uid	= ip->i_d.di_uid;
-	inode->i_gid	= ip->i_d.di_gid;
+	inode->i_uid = ip->i_d.di_uid;
+	inode->i_gid = ip->i_d.di_gid;
 
 	switch (inode->i_mode & S_IFMT) {
 	case S_IFBLK:
diff --git a/fs/xfs/xfs_itable.c b/fs/xfs/xfs_itable.c
index 01d10a6..541fdd4 100644
--- a/fs/xfs/xfs_itable.c
+++ b/fs/xfs/xfs_itable.c
@@ -90,12 +90,12 @@ xfs_bulkstat_one_int(
 	 * further change.
 	 */
 	buf->bs_nlink = dic->di_nlink;
-	buf->bs_projid_lo = dic->di_projid_lo;
-	buf->bs_projid_hi = dic->di_projid_hi;
+	buf->bs_projid_lo = from_kprojid(current_user_ns(), dic->di_projid) & 0xffff;
+	buf->bs_projid_hi = from_kprojid(current_user_ns(), dic->di_projid) >> 16;
 	buf->bs_ino = ino;
 	buf->bs_mode = dic->di_mode;
-	buf->bs_uid = dic->di_uid;
-	buf->bs_gid = dic->di_gid;
+	buf->bs_uid = from_kuid(&init_user_ns, dic->di_uid);
+	buf->bs_gid = from_kgid(&init_user_ns, dic->di_gid);
 	buf->bs_size = dic->di_size;
 	buf->bs_atime.tv_sec = dic->di_atime.t_sec;
 	buf->bs_atime.tv_nsec = dic->di_atime.t_nsec;
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 2e86fa0..0f39a95 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -366,8 +366,7 @@ xfs_qm_unmount_quotas(
 STATIC int
 xfs_qm_dqattach_one(
 	xfs_inode_t	*ip,
-	xfs_dqid_t	id,
-	uint		type,
+	struct kqid	id,
 	uint		doalloc,
 	xfs_dquot_t	*udqhint, /* hint */
 	xfs_dquot_t	**IO_idqpp)
@@ -396,7 +395,7 @@ xfs_qm_dqattach_one(
 	 * the user dquot.
 	 */
 	if (udqhint) {
-		ASSERT(type == XFS_DQ_GROUP || type == XFS_DQ_PROJ);
+		ASSERT(id.type == GRPQUOTA || id.type == PRJQUOTA);
 		xfs_dqlock(udqhint);
 
 		/*
@@ -407,7 +406,7 @@ xfs_qm_dqattach_one(
 		 * hold the ilock.
 		 */
 		dqp = udqhint->q_gdquot;
-		if (dqp && be32_to_cpu(dqp->q_core.d_id) == id) {
+		if (dqp && qid_eq(dqp->dq_id, id)) {
 			ASSERT(*IO_idqpp == NULL);
 
 			*IO_idqpp = xfs_qm_dqhold(dqp);
@@ -431,7 +430,7 @@ xfs_qm_dqattach_one(
 	 * disk and we didn't ask it to allocate;
 	 * ESRCH if quotas got turned off suddenly.
 	 */
-	error = xfs_qm_dqget(ip->i_mount, ip, id, type,
+	error = xfs_qm_dqget(ip->i_mount, ip, id,
 			     doalloc | XFS_QMOPT_DOWARN, &dqp);
 	if (error)
 		return error;
@@ -515,7 +514,7 @@ xfs_qm_dqattach_locked(
 	ASSERT(xfs_isilocked(ip, XFS_ILOCK_EXCL));
 
 	if (XFS_IS_UQUOTA_ON(mp)) {
-		error = xfs_qm_dqattach_one(ip, ip->i_d.di_uid, XFS_DQ_USER,
+		error = xfs_qm_dqattach_one(ip, make_kqid_uid(ip->i_d.di_uid),
 						flags & XFS_QMOPT_DQALLOC,
 						NULL, &ip->i_udquot);
 		if (error)
@@ -526,10 +525,10 @@ xfs_qm_dqattach_locked(
 	ASSERT(xfs_isilocked(ip, XFS_ILOCK_EXCL));
 	if (XFS_IS_OQUOTA_ON(mp)) {
 		error = XFS_IS_GQUOTA_ON(mp) ?
-			xfs_qm_dqattach_one(ip, ip->i_d.di_gid, XFS_DQ_GROUP,
+			xfs_qm_dqattach_one(ip, make_kqid_gid(ip->i_d.di_gid),
 						flags & XFS_QMOPT_DQALLOC,
 						ip->i_udquot, &ip->i_gdquot) :
-			xfs_qm_dqattach_one(ip, xfs_get_projid(ip), XFS_DQ_PROJ,
+			xfs_qm_dqattach_one(ip, make_kqid_projid(ip->i_d.di_projid),
 						flags & XFS_QMOPT_DQALLOC,
 						ip->i_udquot, &ip->i_gdquot);
 		/*
@@ -673,10 +672,12 @@ xfs_qm_init_quotainfo(
 	 * Since we may not have done a quotacheck by this point, just read
 	 * the dquot without attaching it to any hashtables or lists.
 	 */
-	error = xfs_qm_dqread(mp, 0,
-			XFS_IS_UQUOTA_RUNNING(mp) ? XFS_DQ_USER :
-			 (XFS_IS_GQUOTA_RUNNING(mp) ? XFS_DQ_GROUP :
-			  XFS_DQ_PROJ),
+	error = xfs_qm_dqread(mp,
+			make_kqid(&init_user_ns,
+				  XFS_IS_UQUOTA_RUNNING(mp) ? USRQUOTA :
+				  (XFS_IS_GQUOTA_RUNNING(mp) ? GRPQUOTA :
+				   PRJQUOTA),
+				  0),
 			XFS_QMOPT_DOWARN, &dqp);
 	if (!error) {
 		xfs_disk_dquot_t	*ddqp = &dqp->q_core;
@@ -776,7 +777,9 @@ xfs_qm_qino_alloc(
 		return error;
 	}
 
-	error = xfs_dir_ialloc(&tp, NULL, S_IFREG, 1, 0, 0, 1, ip, &committed);
+	error = xfs_dir_ialloc(&tp, NULL, S_IFREG, 1, 0,
+			       make_kprojid(&init_user_ns, 0),
+			       1, ip, &committed);
 	if (error) {
 		xfs_trans_cancel(tp, XFS_TRANS_RELEASE_LOG_RES |
 				 XFS_TRANS_ABORT);
@@ -1011,8 +1014,7 @@ out:
 STATIC int
 xfs_qm_quotacheck_dqadjust(
 	struct xfs_inode	*ip,
-	xfs_dqid_t		id,
-	uint			type,
+	struct kqid		id,
 	xfs_qcnt_t		nblks,
 	xfs_qcnt_t		rtblks)
 {
@@ -1020,7 +1022,7 @@ xfs_qm_quotacheck_dqadjust(
 	struct xfs_dquot	*dqp;
 	int			error;
 
-	error = xfs_qm_dqget(mp, ip, id, type,
+	error = xfs_qm_dqget(mp, ip, id,
 			     XFS_QMOPT_DQALLOC | XFS_QMOPT_DOWARN, &dqp);
 	if (error) {
 		/*
@@ -1155,22 +1157,25 @@ xfs_qm_dqusage_adjust(
 	 * and quotaoffs don't race. (Quotachecks happen at mount time only).
 	 */
 	if (XFS_IS_UQUOTA_ON(mp)) {
-		error = xfs_qm_quotacheck_dqadjust(ip, ip->i_d.di_uid,
-						   XFS_DQ_USER, nblks, rtblks);
+		error = xfs_qm_quotacheck_dqadjust(ip,
+						   make_kqid_uid(ip->i_d.di_uid),
+						   nblks, rtblks);
 		if (error)
 			goto error0;
 	}
 
 	if (XFS_IS_GQUOTA_ON(mp)) {
-		error = xfs_qm_quotacheck_dqadjust(ip, ip->i_d.di_gid,
-						   XFS_DQ_GROUP, nblks, rtblks);
+		error = xfs_qm_quotacheck_dqadjust(ip,
+						   make_kqid_gid(ip->i_d.di_gid),
+						   nblks, rtblks);
 		if (error)
 			goto error0;
 	}
 
 	if (XFS_IS_PQUOTA_ON(mp)) {
-		error = xfs_qm_quotacheck_dqadjust(ip, xfs_get_projid(ip),
-						   XFS_DQ_PROJ, nblks, rtblks);
+		error = xfs_qm_quotacheck_dqadjust(ip,
+						   make_kqid_projid(ip->i_d.di_projid),
+						   nblks, rtblks);
 		if (error)
 			goto error0;
 	}
@@ -1434,7 +1439,7 @@ xfs_qm_dqfree_one(
 
 	mutex_lock(&qi->qi_tree_lock);
 	radix_tree_delete(XFS_DQUOT_TREE(qi, dqp->q_core.d_flags),
-			  be32_to_cpu(dqp->q_core.d_id));
+			  from_kqid(&init_user_ns, dqp->dq_id));
 
 	qi->qi_dquots--;
 	mutex_unlock(&qi->qi_tree_lock);
@@ -1613,9 +1618,9 @@ xfs_qm_write_sb_changes(
 int
 xfs_qm_vop_dqalloc(
 	struct xfs_inode	*ip,
-	uid_t			uid,
-	gid_t			gid,
-	prid_t			prid,
+	kuid_t			uid,
+	kgid_t			gid,
+	kprojid_t		prid,
 	uint			flags,
 	struct xfs_dquot	**O_udqpp,
 	struct xfs_dquot	**O_gdqpp)
@@ -1648,7 +1653,7 @@ xfs_qm_vop_dqalloc(
 
 	uq = gq = NULL;
 	if ((flags & XFS_QMOPT_UQUOTA) && XFS_IS_UQUOTA_ON(mp)) {
-		if (ip->i_d.di_uid != uid) {
+		if (!uid_eq(ip->i_d.di_uid, uid)) {
 			/*
 			 * What we need is the dquot that has this uid, and
 			 * if we send the inode to dqget, the uid of the inode
@@ -1659,8 +1664,8 @@ xfs_qm_vop_dqalloc(
 			 * holding ilock.
 			 */
 			xfs_iunlock(ip, lockflags);
-			if ((error = xfs_qm_dqget(mp, NULL, (xfs_dqid_t) uid,
-						 XFS_DQ_USER,
+			if ((error = xfs_qm_dqget(mp, NULL,
+						 make_kqid_uid(uid),
 						 XFS_QMOPT_DQALLOC |
 						 XFS_QMOPT_DOWARN,
 						 &uq))) {
@@ -1683,10 +1688,10 @@ xfs_qm_vop_dqalloc(
 		}
 	}
 	if ((flags & XFS_QMOPT_GQUOTA) && XFS_IS_GQUOTA_ON(mp)) {
-		if (ip->i_d.di_gid != gid) {
+		if (!gid_eq(ip->i_d.di_gid, gid)) {
 			xfs_iunlock(ip, lockflags);
-			if ((error = xfs_qm_dqget(mp, NULL, (xfs_dqid_t)gid,
-						 XFS_DQ_GROUP,
+			if ((error = xfs_qm_dqget(mp, NULL,
+						 make_kqid_gid(gid),
 						 XFS_QMOPT_DQALLOC |
 						 XFS_QMOPT_DOWARN,
 						 &gq))) {
@@ -1703,10 +1708,10 @@ xfs_qm_vop_dqalloc(
 			gq = xfs_qm_dqhold(ip->i_gdquot);
 		}
 	} else if ((flags & XFS_QMOPT_PQUOTA) && XFS_IS_PQUOTA_ON(mp)) {
-		if (xfs_get_projid(ip) != prid) {
+		if (!projid_eq(ip->i_d.di_projid, prid)) {
 			xfs_iunlock(ip, lockflags);
-			if ((error = xfs_qm_dqget(mp, NULL, (xfs_dqid_t)prid,
-						 XFS_DQ_PROJ,
+			if ((error = xfs_qm_dqget(mp, NULL,
+						 make_kqid_projid(prid),
 						 XFS_QMOPT_DQALLOC |
 						 XFS_QMOPT_DOWARN,
 						 &gq))) {
@@ -1804,7 +1809,7 @@ xfs_qm_vop_chown_reserve(
 			XFS_QMOPT_RES_RTBLKS : XFS_QMOPT_RES_REGBLKS;
 
 	if (XFS_IS_UQUOTA_ON(mp) && udqp &&
-	    ip->i_d.di_uid != (uid_t)be32_to_cpu(udqp->q_core.d_id)) {
+	    !uid_eq(ip->i_d.di_uid, udqp->dq_id.uid)) {
 		delblksudq = udqp;
 		/*
 		 * If there are delayed allocation blocks, then we have to
@@ -1818,12 +1823,12 @@ xfs_qm_vop_chown_reserve(
 	}
 	if (XFS_IS_OQUOTA_ON(ip->i_mount) && gdqp) {
 		if (XFS_IS_PQUOTA_ON(ip->i_mount) &&
-		     xfs_get_projid(ip) != be32_to_cpu(gdqp->q_core.d_id))
+		    !projid_eq(ip->i_d.di_projid, gdqp->dq_id.projid))
 			prjflags = XFS_QMOPT_ENOSPC;
 
 		if (prjflags ||
 		    (XFS_IS_GQUOTA_ON(ip->i_mount) &&
-		     ip->i_d.di_gid != be32_to_cpu(gdqp->q_core.d_id))) {
+		     !gid_eq(ip->i_d.di_gid, gdqp->dq_id.gid))) {
 			delblksgdq = gdqp;
 			if (delblks) {
 				ASSERT(ip->i_gdquot);
@@ -1907,7 +1912,7 @@ xfs_qm_vop_create_dqattach(
 	if (udqp) {
 		ASSERT(ip->i_udquot == NULL);
 		ASSERT(XFS_IS_UQUOTA_ON(mp));
-		ASSERT(ip->i_d.di_uid == be32_to_cpu(udqp->q_core.d_id));
+		ASSERT(uid_eq(ip->i_d.di_uid, udqp->dq_id.uid));
 
 		ip->i_udquot = xfs_qm_dqhold(udqp);
 		xfs_trans_mod_dquot(tp, udqp, XFS_TRANS_DQ_ICOUNT, 1);
@@ -1916,8 +1921,8 @@ xfs_qm_vop_create_dqattach(
 		ASSERT(ip->i_gdquot == NULL);
 		ASSERT(XFS_IS_OQUOTA_ON(mp));
 		ASSERT((XFS_IS_GQUOTA_ON(mp) ?
-			ip->i_d.di_gid : xfs_get_projid(ip)) ==
-				be32_to_cpu(gdqp->q_core.d_id));
+			gid_eq(ip->i_d.di_gid, gdqp->dq_id.gid) :
+			projid_eq(ip->i_d.di_projid, gdqp->dq_id.projid)));
 
 		ip->i_gdquot = xfs_qm_dqhold(gdqp);
 		xfs_trans_mod_dquot(tp, gdqp, XFS_TRANS_DQ_ICOUNT, 1);
diff --git a/fs/xfs/xfs_qm.h b/fs/xfs/xfs_qm.h
index 44b858b..ce478dc 100644
--- a/fs/xfs/xfs_qm.h
+++ b/fs/xfs/xfs_qm.h
@@ -114,9 +114,9 @@ extern void		xfs_qm_dqrele_all_inodes(xfs_mount_t *, uint);
 
 /* quota ops */
 extern int		xfs_qm_scall_trunc_qfiles(xfs_mount_t *, uint);
-extern int		xfs_qm_scall_getquota(xfs_mount_t *, xfs_dqid_t, uint,
+extern int		xfs_qm_scall_getquota(xfs_mount_t *, struct kqid,
 					fs_disk_quota_t *);
-extern int		xfs_qm_scall_setqlim(xfs_mount_t *, xfs_dqid_t, uint,
+extern int		xfs_qm_scall_setqlim(xfs_mount_t *, struct kqid,
 					fs_disk_quota_t *);
 extern int		xfs_qm_scall_getqstat(xfs_mount_t *, fs_quota_stat_t *);
 extern int		xfs_qm_scall_quotaon(xfs_mount_t *, uint);
diff --git a/fs/xfs/xfs_qm_bhv.c b/fs/xfs/xfs_qm_bhv.c
index 6b39115..e82f48b 100644
--- a/fs/xfs/xfs_qm_bhv.c
+++ b/fs/xfs/xfs_qm_bhv.c
@@ -79,7 +79,8 @@ xfs_qm_statvfs(
 	xfs_mount_t		*mp = ip->i_mount;
 	xfs_dquot_t		*dqp;
 
-	if (!xfs_qm_dqget(mp, NULL, xfs_get_projid(ip), XFS_DQ_PROJ, 0, &dqp)) {
+	if (!xfs_qm_dqget(mp, NULL, make_kqid_projid(ip->i_d.di_projid),
+			  0, &dqp)) {
 		xfs_fill_statvfs_from_dquot(statp, dqp);
 		xfs_qm_dqput(dqp);
 	}
diff --git a/fs/xfs/xfs_qm_syscalls.c b/fs/xfs/xfs_qm_syscalls.c
index 858a3b1..5b98821 100644
--- a/fs/xfs/xfs_qm_syscalls.c
+++ b/fs/xfs/xfs_qm_syscalls.c
@@ -472,8 +472,7 @@ xfs_qm_scall_getqstat(
 int
 xfs_qm_scall_setqlim(
 	xfs_mount_t		*mp,
-	xfs_dqid_t		id,
-	uint			type,
+	struct kqid		id,
 	fs_disk_quota_t		*newlim)
 {
 	struct xfs_quotainfo	*q = mp->m_quotainfo;
@@ -482,6 +481,7 @@ xfs_qm_scall_setqlim(
 	xfs_trans_t		*tp;
 	int			error;
 	xfs_qcnt_t		hard, soft;
+	bool			root_qid;
 
 	if (newlim->d_fieldmask & ~XFS_DQ_MASK)
 		return EINVAL;
@@ -495,6 +495,9 @@ xfs_qm_scall_setqlim(
 		return (error);
 	}
 
+	/* Are we setting the root users quota? */
+	root_qid = qid_eq(id, make_kqid(&init_user_ns, id.type, 0));
+
 	/*
 	 * We don't want to race with a quotaoff so take the quotaoff lock.
 	 * (We don't hold an inode lock, so there's nothing else to stop
@@ -507,7 +510,7 @@ xfs_qm_scall_setqlim(
 	 * Get the dquot (locked), and join it to the transaction.
 	 * Allocate the dquot if this doesn't exist.
 	 */
-	if ((error = xfs_qm_dqget(mp, NULL, id, type, XFS_QMOPT_DQALLOC, &dqp))) {
+	if ((error = xfs_qm_dqget(mp, NULL, id, XFS_QMOPT_DQALLOC, &dqp))) {
 		xfs_trans_cancel(tp, XFS_TRANS_ABORT);
 		ASSERT(error != ENOENT);
 		goto out_unlock;
@@ -527,7 +530,7 @@ xfs_qm_scall_setqlim(
 	if (hard == 0 || hard >= soft) {
 		ddq->d_blk_hardlimit = cpu_to_be64(hard);
 		ddq->d_blk_softlimit = cpu_to_be64(soft);
-		if (id == 0) {
+		if (root_qid) {
 			q->qi_bhardlimit = hard;
 			q->qi_bsoftlimit = soft;
 		}
@@ -543,7 +546,7 @@ xfs_qm_scall_setqlim(
 	if (hard == 0 || hard >= soft) {
 		ddq->d_rtb_hardlimit = cpu_to_be64(hard);
 		ddq->d_rtb_softlimit = cpu_to_be64(soft);
-		if (id == 0) {
+		if (root_qid) {
 			q->qi_rtbhardlimit = hard;
 			q->qi_rtbsoftlimit = soft;
 		}
@@ -560,7 +563,7 @@ xfs_qm_scall_setqlim(
 	if (hard == 0 || hard >= soft) {
 		ddq->d_ino_hardlimit = cpu_to_be64(hard);
 		ddq->d_ino_softlimit = cpu_to_be64(soft);
-		if (id == 0) {
+		if (root_qid) {
 			q->qi_ihardlimit = hard;
 			q->qi_isoftlimit = soft;
 		}
@@ -578,7 +581,7 @@ xfs_qm_scall_setqlim(
 	if (newlim->d_fieldmask & FS_DQ_RTBWARNS)
 		ddq->d_rtbwarns = cpu_to_be16(newlim->d_rtbwarns);
 
-	if (id == 0) {
+	if (root_qid) {
 		/*
 		 * Timelimits for the super user set the relative time
 		 * the other users can be over quota for this file system.
@@ -716,8 +719,7 @@ error0:
 int
 xfs_qm_scall_getquota(
 	struct xfs_mount	*mp,
-	xfs_dqid_t		id,
-	uint			type,
+	struct kqid		id,
 	struct fs_disk_quota	*dst)
 {
 	struct xfs_dquot	*dqp;
@@ -728,7 +730,7 @@ xfs_qm_scall_getquota(
 	 * we aren't passing the XFS_QMOPT_DOALLOC flag. If it doesn't
 	 * exist, we'll get ENOENT back.
 	 */
-	error = xfs_qm_dqget(mp, NULL, id, type, 0, &dqp);
+	error = xfs_qm_dqget(mp, NULL, id, 0, &dqp);
 	if (error)
 		return error;
 
@@ -744,7 +746,7 @@ xfs_qm_scall_getquota(
 	memset(dst, 0, sizeof(*dst));
 	dst->d_version = FS_DQUOT_VERSION;
 	dst->d_flags = xfs_qm_export_qtype_flags(dqp->q_core.d_flags);
-	dst->d_id = be32_to_cpu(dqp->q_core.d_id);
+	dst->d_id = from_kqid_munged(current_user_ns(), dqp->dq_id);
 	dst->d_blk_hardlimit =
 		XFS_FSB_TO_BB(mp, be64_to_cpu(dqp->q_core.d_blk_hardlimit));
 	dst->d_blk_softlimit =
diff --git a/fs/xfs/xfs_quota.h b/fs/xfs/xfs_quota.h
index b50ec5b..f48f801 100644
--- a/fs/xfs/xfs_quota.h
+++ b/fs/xfs/xfs_quota.h
@@ -311,7 +311,7 @@ extern int xfs_trans_reserve_quota_bydquots(struct xfs_trans *,
 		struct xfs_mount *, struct xfs_dquot *,
 		struct xfs_dquot *, long, long, uint);
 
-extern int xfs_qm_vop_dqalloc(struct xfs_inode *, uid_t, gid_t, prid_t, uint,
+extern int xfs_qm_vop_dqalloc(struct xfs_inode *, kuid_t, kgid_t, kprojid_t, uint,
 		struct xfs_dquot **, struct xfs_dquot **);
 extern void xfs_qm_vop_create_dqattach(struct xfs_trans *, struct xfs_inode *,
 		struct xfs_dquot *, struct xfs_dquot *);
@@ -332,7 +332,7 @@ extern void xfs_qm_unmount_quotas(struct xfs_mount *);
 
 #else
 static inline int
-xfs_qm_vop_dqalloc(struct xfs_inode *ip, uid_t uid, gid_t gid, prid_t prid,
+xfs_qm_vop_dqalloc(struct xfs_inode *ip, kuid_t uid, kgid_t gid, kprojid_t prid,
 		uint flags, struct xfs_dquot **udqp, struct xfs_dquot **gdqp)
 {
 	*udqp = NULL;
diff --git a/fs/xfs/xfs_quotaops.c b/fs/xfs/xfs_quotaops.c
index 71926d6..4d88faa 100644
--- a/fs/xfs/xfs_quotaops.c
+++ b/fs/xfs/xfs_quotaops.c
@@ -27,20 +27,6 @@
 #include "xfs_qm.h"
 #include <linux/quota.h>
 
-
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
 STATIC int
 xfs_fs_get_xstate(
 	struct super_block	*sb,
@@ -107,8 +93,7 @@ xfs_fs_get_dqblk(
 	if (!XFS_IS_QUOTA_ON(mp))
 		return -ESRCH;
 
-	return -xfs_qm_scall_getquota(mp, from_kqid(&init_user_ns, qid),
-				      xfs_quota_type(qid.type), fdq);
+	return -xfs_qm_scall_getquota(mp, qid, fdq);
 }
 
 STATIC int
@@ -126,8 +111,7 @@ xfs_fs_set_dqblk(
 	if (!XFS_IS_QUOTA_ON(mp))
 		return -ESRCH;
 
-	return -xfs_qm_scall_setqlim(mp, from_kqid(&init_user_ns, qid),
-				     xfs_quota_type(qid.type), fdq);
+	return -xfs_qm_scall_setqlim(mp, qid, fdq);
 }
 
 const struct quotactl_ops xfs_quotactl_operations = {
diff --git a/fs/xfs/xfs_rename.c b/fs/xfs/xfs_rename.c
index 30ff5f4..b919704 100644
--- a/fs/xfs/xfs_rename.c
+++ b/fs/xfs/xfs_rename.c
@@ -171,7 +171,7 @@ xfs_rename(
 	 * tree quota mechanism would be circumvented.
 	 */
 	if (unlikely((target_dp->i_d.di_flags & XFS_DIFLAG_PROJINHERIT) &&
-		     (xfs_get_projid(target_dp) != xfs_get_projid(src_ip)))) {
+		     !projid_eq(target_dp->i_d.di_projid, src_ip->i_d.di_projid))) {
 		error = XFS_ERROR(EXDEV);
 		goto error_return;
 	}
diff --git a/fs/xfs/xfs_trans_dquot.c b/fs/xfs/xfs_trans_dquot.c
index 0c7fa54..9a65ca6 100644
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
+	quota_send_warning(dqp->dq_id, mp->m_super->s_dev, type);
 }
 
 /*
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
index 2a5c6373..efc2420 100644
--- a/fs/xfs/xfs_vnodeops.c
+++ b/fs/xfs/xfs_vnodeops.c
@@ -727,7 +727,7 @@ xfs_create(
 	boolean_t		unlock_dp_on_error = B_FALSE;
 	uint			cancel_flags;
 	int			committed;
-	prid_t			prid;
+	kprojid_t		prid;
 	struct xfs_dquot	*udqp = NULL;
 	struct xfs_dquot	*gdqp = NULL;
 	uint			resblks;
@@ -740,9 +740,9 @@ xfs_create(
 		return XFS_ERROR(EIO);
 
 	if (dp->i_d.di_flags & XFS_DIFLAG_PROJINHERIT)
-		prid = xfs_get_projid(dp);
+		prid = dp->i_d.di_projid;
 	else
-		prid = XFS_PROJID_DEFAULT;
+		prid = make_kprojid(&init_user_ns, XFS_PROJID_DEFAULT);
 
 	/*
 	 * Make sure that we have allocated dquot(s) on disk.
@@ -1304,7 +1304,7 @@ xfs_link(
 	 * the tree quota mechanism could be circumvented.
 	 */
 	if (unlikely((tdp->i_d.di_flags & XFS_DIFLAG_PROJINHERIT) &&
-		     (xfs_get_projid(tdp) != xfs_get_projid(sip)))) {
+		     !projid_eq(tdp->i_d.di_projid, sip->i_d.di_projid))) {
 		error = XFS_ERROR(EXDEV);
 		goto error_return;
 	}
@@ -1378,7 +1378,7 @@ xfs_symlink(
 	int			byte_cnt;
 	int			n;
 	xfs_buf_t		*bp;
-	prid_t			prid;
+	kprojid_t		prid;
 	struct xfs_dquot	*udqp, *gdqp;
 	uint			resblks;
 
@@ -1401,9 +1401,9 @@ xfs_symlink(
 
 	udqp = gdqp = NULL;
 	if (dp->i_d.di_flags & XFS_DIFLAG_PROJINHERIT)
-		prid = xfs_get_projid(dp);
+		prid = dp->i_d.di_projid;
 	else
-		prid = XFS_PROJID_DEFAULT;
+		prid = make_kprojid(&init_user_ns, XFS_PROJID_DEFAULT);
 
 	/*
 	 * Make sure that we have allocated dquot(s) on disk.
diff --git a/init/Kconfig b/init/Kconfig
index ee7e5b6..fb5e192 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -999,7 +999,6 @@ config UIDGID_CONVERTED
 	default y
 
 	# Filesystems
-	depends on XFS_FS = n
 
 config UIDGID_STRICT_TYPE_CHECKS
 	bool "Require conversions between uid/gids and their internal representation"
-- 
1.7.5.4
