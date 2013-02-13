From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 28/85] gfs2: Split NO_QUOTA_CHANGE inot
	NO_UID_QUTOA_CHANGE and NO_GID_QUTOA_CHANGE
Date: Wed, 13 Feb 2013 09:51:17 -0800
Message-ID: <1360777934-5663-28-git-send-email-ebiederm__12235.6812273667$1360778416$gmane$org@xmission.com>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1360777934-5663-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Split NO_QUOTA_CHANGE into NO_UID_QUTOA_CHANGE and NO_GID_QUTOA_CHANGE
so the constants may be well typed.

Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/gfs2/bmap.c  |    2 +-
 fs/gfs2/dir.c   |    2 +-
 fs/gfs2/inode.c |   10 +++++-----
 fs/gfs2/quota.c |    4 ++--
 fs/gfs2/quota.h |    5 +++--
 fs/gfs2/super.c |    2 +-
 fs/gfs2/xattr.c |    4 ++--
 7 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index a68e91b..10c54e3 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -1098,7 +1098,7 @@ static int trunc_dealloc(struct gfs2_inode *ip, u64 size)
 	if (error)
 		return error;
 
-	error = gfs2_quota_hold(ip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
+	error = gfs2_quota_hold(ip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
 	if (error)
 		return error;
 
diff --git a/fs/gfs2/dir.c b/fs/gfs2/dir.c
index 9a35670..6d3e3e2 100644
--- a/fs/gfs2/dir.c
+++ b/fs/gfs2/dir.c
@@ -1849,7 +1849,7 @@ static int leaf_dealloc(struct gfs2_inode *dip, u32 index, u32 len,
 	if (!ht)
 		return -ENOMEM;
 
-	error = gfs2_quota_hold(dip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
+	error = gfs2_quota_hold(dip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
 	if (error)
 		goto out;
 
diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
index 2b6f569..aa10502 100644
--- a/fs/gfs2/inode.c
+++ b/fs/gfs2/inode.c
@@ -548,7 +548,7 @@ static int link_dinode(struct gfs2_inode *dip, const struct qstr *name,
 	if (error)
 		return error;
 
-	error = gfs2_quota_lock(dip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
+	error = gfs2_quota_lock(dip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
 	if (error)
 		goto fail;
 
@@ -1589,15 +1589,15 @@ static int setattr_chown(struct inode *inode, struct iattr *attr)
 	ngid = attr->ia_gid;
 
 	if (!(attr->ia_valid & ATTR_UID) || ouid == nuid)
-		ouid = nuid = NO_QUOTA_CHANGE;
+		ouid = nuid = NO_UID_QUOTA_CHANGE;
 	if (!(attr->ia_valid & ATTR_GID) || ogid == ngid)
-		ogid = ngid = NO_QUOTA_CHANGE;
+		ogid = ngid = NO_GID_QUOTA_CHANGE;
 
 	error = gfs2_quota_lock(ip, nuid, ngid);
 	if (error)
 		return error;
 
-	if (ouid != NO_QUOTA_CHANGE || ogid != NO_QUOTA_CHANGE) {
+	if (ouid != NO_UID_QUOTA_CHANGE || ogid != NO_GID_QUOTA_CHANGE) {
 		error = gfs2_quota_check(ip, nuid, ngid);
 		if (error)
 			goto out_gunlock_q;
@@ -1611,7 +1611,7 @@ static int setattr_chown(struct inode *inode, struct iattr *attr)
 	if (error)
 		goto out_end_trans;
 
-	if (ouid != NO_QUOTA_CHANGE || ogid != NO_QUOTA_CHANGE) {
+	if (ouid != NO_UID_QUOTA_CHANGE || ogid != NO_GID_QUOTA_CHANGE) {
 		u64 blocks = gfs2_get_inode_blocks(&ip->i_inode);
 		gfs2_quota_change(ip, -blocks, ouid, ogid);
 		gfs2_quota_change(ip, blocks, nuid, ngid);
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index e4f6ccf..dbfacaa 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -524,7 +524,7 @@ int gfs2_quota_hold(struct gfs2_inode *ip, u32 uid, u32 gid)
 	ip->i_res->rs_qa_qd_num++;
 	qd++;
 
-	if (uid != NO_QUOTA_CHANGE && uid != ip->i_inode.i_uid) {
+	if (uid != NO_UID_QUOTA_CHANGE && uid != ip->i_inode.i_uid) {
 		error = qdsb_get(sdp, QUOTA_USER, uid, qd);
 		if (error)
 			goto out;
@@ -532,7 +532,7 @@ int gfs2_quota_hold(struct gfs2_inode *ip, u32 uid, u32 gid)
 		qd++;
 	}
 
-	if (gid != NO_QUOTA_CHANGE && gid != ip->i_inode.i_gid) {
+	if (gid != NO_GID_QUOTA_CHANGE && gid != ip->i_inode.i_gid) {
 		error = qdsb_get(sdp, QUOTA_GROUP, gid, qd);
 		if (error)
 			goto out;
diff --git a/fs/gfs2/quota.h b/fs/gfs2/quota.h
index f25d98b..7f67323 100644
--- a/fs/gfs2/quota.h
+++ b/fs/gfs2/quota.h
@@ -14,7 +14,8 @@ struct gfs2_inode;
 struct gfs2_sbd;
 struct shrink_control;
 
-#define NO_QUOTA_CHANGE ((u32)-1)
+#define NO_UID_QUOTA_CHANGE INVALID_UID
+#define NO_GID_QUOTA_CHANGE INVALID_GID
 
 extern int gfs2_quota_hold(struct gfs2_inode *ip, u32 uid, u32 gid);
 extern void gfs2_quota_unhold(struct gfs2_inode *ip);
@@ -41,7 +42,7 @@ static inline int gfs2_quota_lock_check(struct gfs2_inode *ip)
 	int ret;
 	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
 		return 0;
-	ret = gfs2_quota_lock(ip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
+	ret = gfs2_quota_lock(ip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
 	if (ret)
 		return ret;
 	if (sdp->sd_args.ar_quota != GFS2_QUOTA_ON)
diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
index d648867..7cc5a60 100644
--- a/fs/gfs2/super.c
+++ b/fs/gfs2/super.c
@@ -1429,7 +1429,7 @@ static int gfs2_dinode_dealloc(struct gfs2_inode *ip)
 	if (error)
 		return error;
 
-	error = gfs2_quota_hold(ip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
+	error = gfs2_quota_hold(ip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
 	if (error)
 		return error;
 
diff --git a/fs/gfs2/xattr.c b/fs/gfs2/xattr.c
index 76c144b..80c25ae 100644
--- a/fs/gfs2/xattr.c
+++ b/fs/gfs2/xattr.c
@@ -331,7 +331,7 @@ static int ea_remove_unstuffed(struct gfs2_inode *ip, struct buffer_head *bh,
 	if (error)
 		return error;
 
-	error = gfs2_quota_hold(ip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
+	error = gfs2_quota_hold(ip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
 	if (error)
 		goto out_alloc;
 
@@ -1461,7 +1461,7 @@ int gfs2_ea_dealloc(struct gfs2_inode *ip)
 	if (error)
 		return error;
 
-	error = gfs2_quota_hold(ip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
+	error = gfs2_quota_hold(ip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
 	if (error)
 		return error;
 
-- 
1.7.5.4
