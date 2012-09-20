From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 23/27] userns: Modify dqget to take struct kqid
Date: Wed, 19 Sep 2012 18:52:25 -0700
Message-ID: <1348105949-25454-23-git-send-email-ebiederm@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Modify dqget to take struct kqid instead of a type and an identifier
pair.

Modify the callers of dqget in ocfs2 and dquot to take generate
a struct kqid so they can continue to call dqget.  The conversion
to create struct kqid should all be the final conversions that
are needed in those code paths.

Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>
Cc: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ocfs2/file.c          |    6 ++----
 fs/ocfs2/quota_local.c   |    4 +++-
 fs/quota/dquot.c         |   20 +++++++++++---------
 include/linux/quotaops.h |    2 +-
 4 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 46a1f6d..5a4ee77 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -1184,8 +1184,7 @@ int ocfs2_setattr(struct dentry *dentry, struct iattr *attr)
 		if (attr->ia_valid & ATTR_UID && attr->ia_uid != inode->i_uid
 		    && OCFS2_HAS_RO_COMPAT_FEATURE(sb,
 		    OCFS2_FEATURE_RO_COMPAT_USRQUOTA)) {
-			transfer_to[USRQUOTA] = dqget(sb, attr->ia_uid,
-						      USRQUOTA);
+			transfer_to[USRQUOTA] = dqget(sb, make_kqid_uid(attr->ia_uid));
 			if (!transfer_to[USRQUOTA]) {
 				status = -ESRCH;
 				goto bail_unlock;
@@ -1194,8 +1193,7 @@ int ocfs2_setattr(struct dentry *dentry, struct iattr *attr)
 		if (attr->ia_valid & ATTR_GID && attr->ia_gid != inode->i_gid
 		    && OCFS2_HAS_RO_COMPAT_FEATURE(sb,
 		    OCFS2_FEATURE_RO_COMPAT_GRPQUOTA)) {
-			transfer_to[GRPQUOTA] = dqget(sb, attr->ia_gid,
-						      GRPQUOTA);
+			transfer_to[GRPQUOTA] = dqget(sb, make_kqid_gid(attr->ia_gid));
 			if (!transfer_to[GRPQUOTA]) {
 				status = -ESRCH;
 				goto bail_unlock;
diff --git a/fs/ocfs2/quota_local.c b/fs/ocfs2/quota_local.c
index f100bf7..020f0ba 100644
--- a/fs/ocfs2/quota_local.c
+++ b/fs/ocfs2/quota_local.c
@@ -501,7 +501,9 @@ static int ocfs2_recover_local_quota_file(struct inode *lqinode,
 			}
 			dqblk = (struct ocfs2_local_disk_dqblk *)(qbh->b_data +
 				ol_dqblk_block_off(sb, chunk, bit));
-			dquot = dqget(sb, le64_to_cpu(dqblk->dqb_id), type);
+			dquot = dqget(sb,
+				      make_kqid(&init_user_ns, type,
+						le64_to_cpu(dqblk->dqb_id)));
 			if (!dquot) {
 				status = -EIO;
 				mlog(ML_ERROR, "Failed to get quota structure "
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 80d3378..53e377a 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -829,8 +829,10 @@ static struct dquot *get_empty_dquot(struct super_block *sb, int type)
  *   a) checking for quota flags under dq_list_lock and
  *   b) getting a reference to dquot before we release dq_list_lock
  */
-struct dquot *dqget(struct super_block *sb, unsigned int id, int type)
+struct dquot *dqget(struct super_block *sb, struct kqid qid)
 {
+	unsigned int type = qid.type;
+	unsigned int id = from_kqid(&init_user_ns, qid);
 	unsigned int hashent = hashfn(sb, id, type);
 	struct dquot *dquot = NULL, *empty = NULL;
 
@@ -1390,7 +1392,6 @@ static int dquot_active(const struct inode *inode)
  */
 static void __dquot_initialize(struct inode *inode, int type)
 {
-	unsigned int id = 0;
 	int cnt;
 	struct dquot *got[MAXQUOTAS];
 	struct super_block *sb = inode->i_sb;
@@ -1403,18 +1404,19 @@ static void __dquot_initialize(struct inode *inode, int type)
 
 	/* First get references to structures we might need. */
 	for (cnt = 0; cnt < MAXQUOTAS; cnt++) {
+		struct kqid qid;
 		got[cnt] = NULL;
 		if (type != -1 && cnt != type)
 			continue;
 		switch (cnt) {
 		case USRQUOTA:
-			id = inode->i_uid;
+			qid = make_kqid_uid(inode->i_uid);
 			break;
 		case GRPQUOTA:
-			id = inode->i_gid;
+			qid = make_kqid_gid(inode->i_gid);
 			break;
 		}
-		got[cnt] = dqget(sb, id, cnt);
+		got[cnt] = dqget(sb, qid);
 	}
 
 	down_write(&sb_dqopt(sb)->dqptr_sem);
@@ -1898,9 +1900,9 @@ int dquot_transfer(struct inode *inode, struct iattr *iattr)
 		return 0;
 
 	if (iattr->ia_valid & ATTR_UID && iattr->ia_uid != inode->i_uid)
-		transfer_to[USRQUOTA] = dqget(sb, iattr->ia_uid, USRQUOTA);
+		transfer_to[USRQUOTA] = dqget(sb, make_kqid_uid(iattr->ia_uid));
 	if (iattr->ia_valid & ATTR_GID && iattr->ia_gid != inode->i_gid)
-		transfer_to[GRPQUOTA] = dqget(sb, iattr->ia_gid, GRPQUOTA);
+		transfer_to[GRPQUOTA] = dqget(sb, make_kqid_gid(iattr->ia_gid));
 
 	ret = __dquot_transfer(inode, transfer_to);
 	dqput_all(transfer_to);
@@ -2381,7 +2383,7 @@ int dquot_get_dqblk(struct super_block *sb, struct kqid qid,
 {
 	struct dquot *dquot;
 
-	dquot = dqget(sb, qid.type, from_kqid(&init_user_ns, qid));
+	dquot = dqget(sb, qid);
 	if (!dquot)
 		return -ESRCH;
 	do_get_dqblk(dquot, di);
@@ -2494,7 +2496,7 @@ int dquot_set_dqblk(struct super_block *sb, struct kqid qid,
 	struct dquot *dquot;
 	int rc;
 
-	dquot = dqget(sb, qid.type, from_kqid(&init_user_ns, qid));
+	dquot = dqget(sb, qid);
 	if (!dquot) {
 		rc = -ESRCH;
 		goto out;
diff --git a/include/linux/quotaops.h b/include/linux/quotaops.h
index bd3730d..1c50093 100644
--- a/include/linux/quotaops.h
+++ b/include/linux/quotaops.h
@@ -44,7 +44,7 @@ void inode_sub_rsv_space(struct inode *inode, qsize_t number);
 
 void dquot_initialize(struct inode *inode);
 void dquot_drop(struct inode *inode);
-struct dquot *dqget(struct super_block *sb, unsigned int id, int type);
+struct dquot *dqget(struct super_block *sb, struct kqid qid);
 void dqput(struct dquot *dquot);
 int dquot_scan_active(struct super_block *sb,
 		      int (*fn)(struct dquot *dquot, unsigned long priv),
-- 
1.7.5.4
