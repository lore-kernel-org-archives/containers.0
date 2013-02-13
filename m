From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 37/85] gfs2: Use uid_eq and gid_eq where appropriate
Date: Wed, 13 Feb 2013 09:51:26 -0800
Message-ID: <1360777934-5663-37-git-send-email-ebiederm@xmission.com>
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

Where kuid_t values are compared use uid_eq and where kgid_t values
are compared use gid_eq.  This is unfortunately necessary because
of the type safety that keeps someone from accidentally mixing
kuids and kgids with other types.

Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/gfs2/acl.c   |    2 +-
 fs/gfs2/inode.c |   19 +++++++++++--------
 fs/gfs2/quota.c |    6 ++++--
 3 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/fs/gfs2/acl.c b/fs/gfs2/acl.c
index f850020..f69ac0a 100644
--- a/fs/gfs2/acl.c
+++ b/fs/gfs2/acl.c
@@ -237,7 +237,7 @@ static int gfs2_xattr_system_set(struct dentry *dentry, const char *name,
 		return -EINVAL;
 	if (type == ACL_TYPE_DEFAULT && !S_ISDIR(inode->i_mode))
 		return value ? -EACCES : 0;
-	if ((current_fsuid() != inode->i_uid) && !capable(CAP_FOWNER))
+	if (!uid_eq(current_fsuid(), inode->i_uid) && !capable(CAP_FOWNER))
 		return -EPERM;
 	if (S_ISLNK(inode->i_mode))
 		return -EOPNOTSUPP;
diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
index ce07ce4..bb7c754 100644
--- a/fs/gfs2/inode.c
+++ b/fs/gfs2/inode.c
@@ -368,10 +368,11 @@ static void munge_mode_uid_gid(const struct gfs2_inode *dip,
 			       struct inode *inode)
 {
 	if (GFS2_SB(&dip->i_inode)->sd_args.ar_suiddir &&
-	    (dip->i_inode.i_mode & S_ISUID) && dip->i_inode.i_uid) {
+	    (dip->i_inode.i_mode & S_ISUID) &&
+	    !uid_eq(dip->i_inode.i_uid, GLOBAL_ROOT_UID)) {
 		if (S_ISDIR(inode->i_mode))
 			inode->i_mode |= S_ISUID;
-		else if (dip->i_inode.i_uid != current_fsuid())
+		else if (!uid_eq(dip->i_inode.i_uid, current_fsuid()))
 			inode->i_mode &= ~07111;
 		inode->i_uid = dip->i_inode.i_uid;
 	} else
@@ -978,8 +979,8 @@ static int gfs2_unlink_ok(struct gfs2_inode *dip, const struct qstr *name,
 		return -EPERM;
 
 	if ((dip->i_inode.i_mode & S_ISVTX) &&
-	    dip->i_inode.i_uid != current_fsuid() &&
-	    ip->i_inode.i_uid != current_fsuid() && !capable(CAP_FOWNER))
+	    !uid_eq(dip->i_inode.i_uid, current_fsuid()) &&
+	    !uid_eq(ip->i_inode.i_uid, current_fsuid()) && !capable(CAP_FOWNER))
 		return -EPERM;
 
 	if (IS_APPEND(&dip->i_inode))
@@ -1589,16 +1590,17 @@ static int setattr_chown(struct inode *inode, struct iattr *attr)
 	nuid = attr->ia_uid;
 	ngid = attr->ia_gid;
 
-	if (!(attr->ia_valid & ATTR_UID) || ouid == nuid)
+	if (!(attr->ia_valid & ATTR_UID) || uid_eq(ouid, nuid))
 		ouid = nuid = NO_UID_QUOTA_CHANGE;
-	if (!(attr->ia_valid & ATTR_GID) || ogid == ngid)
+	if (!(attr->ia_valid & ATTR_GID) || gid_eq(ogid, ngid))
 		ogid = ngid = NO_GID_QUOTA_CHANGE;
 
 	error = gfs2_quota_lock(ip, nuid, ngid);
 	if (error)
 		return error;
 
-	if (ouid != NO_UID_QUOTA_CHANGE || ogid != NO_GID_QUOTA_CHANGE) {
+	if (!uid_eq(ouid, NO_UID_QUOTA_CHANGE) ||
+	    !gid_eq(ogid, NO_GID_QUOTA_CHANGE)) {
 		error = gfs2_quota_check(ip, nuid, ngid);
 		if (error)
 			goto out_gunlock_q;
@@ -1612,7 +1614,8 @@ static int setattr_chown(struct inode *inode, struct iattr *attr)
 	if (error)
 		goto out_end_trans;
 
-	if (ouid != NO_UID_QUOTA_CHANGE || ogid != NO_GID_QUOTA_CHANGE) {
+	if (!uid_eq(ouid, NO_UID_QUOTA_CHANGE) ||
+	    !gid_eq(ogid, NO_GID_QUOTA_CHANGE)) {
 		u64 blocks = gfs2_get_inode_blocks(&ip->i_inode);
 		gfs2_quota_change(ip, -blocks, ouid, ogid);
 		gfs2_quota_change(ip, blocks, nuid, ngid);
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 87f2740..afd2e5d 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -525,7 +525,8 @@ int gfs2_quota_hold(struct gfs2_inode *ip, kuid_t uid, kgid_t gid)
 	ip->i_res->rs_qa_qd_num++;
 	qd++;
 
-	if (uid != NO_UID_QUOTA_CHANGE && uid != ip->i_inode.i_uid) {
+	if (!uid_eq(uid, NO_UID_QUOTA_CHANGE) &&
+	    !uid_eq(uid, ip->i_inode.i_uid)) {
 		error = qdsb_get(sdp, make_kqid_uid(uid), qd);
 		if (error)
 			goto out;
@@ -533,7 +534,8 @@ int gfs2_quota_hold(struct gfs2_inode *ip, kuid_t uid, kgid_t gid)
 		qd++;
 	}
 
-	if (gid != NO_GID_QUOTA_CHANGE && gid != ip->i_inode.i_gid) {
+	if (!gid_eq(gid, NO_GID_QUOTA_CHANGE) &&
+	    !gid_eq(gid, ip->i_inode.i_gid)) {
 		error = qdsb_get(sdp, make_kqid_gid(gid), qd);
 		if (error)
 			goto out;
-- 
1.7.5.4
