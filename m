From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 76/85] cifs: Use kuids and kgids SID to uid/gid mapping
Date: Wed, 13 Feb 2013 09:52:05 -0800
Message-ID: <1360777934-5663-76-git-send-email-ebiederm__22381.9319079213$1360778883$gmane$org@xmission.com>
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
Cc: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Update id_mode_to_cifs_acl to take a kuid_t and a kgid_t.

Replace NO_CHANGE_32 with INVALID_UID and INVALID_GID, and tests for
NO_CHANGE_32 with uid_valid and gid_valid.

Carefully unpack the value returned from request_key.  memcpy the
value into the expected type.  The convert the uid/gid into a
kuid/kgid.  And then only if the result is a valid kuid or kgid update
fuid/fgid.

Cc: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/cifs/cifsacl.c   |   43 +++++++++++++++++++++++++++++--------------
 fs/cifs/cifspdu.h   |    1 -
 fs/cifs/cifsproto.h |    2 +-
 fs/cifs/inode.c     |    8 ++++----
 4 files changed, 34 insertions(+), 20 deletions(-)

diff --git a/fs/cifs/cifsacl.c b/fs/cifs/cifsacl.c
index aaaf5ce..f1e3f25 100644
--- a/fs/cifs/cifsacl.c
+++ b/fs/cifs/cifsacl.c
@@ -266,8 +266,8 @@ sid_to_id(struct cifs_sb_info *cifs_sb, struct cifs_sid *psid,
 	struct key *sidkey;
 	char *sidstr;
 	const struct cred *saved_cred;
-	uid_t fuid = cifs_sb->mnt_uid;
-	gid_t fgid = cifs_sb->mnt_gid;
+	kuid_t fuid = cifs_sb->mnt_uid;
+	kgid_t fgid = cifs_sb->mnt_gid;
 
 	/*
 	 * If we have too many subauthorities, then something is really wrong.
@@ -306,10 +306,21 @@ sid_to_id(struct cifs_sb_info *cifs_sb, struct cifs_sid *psid,
 		goto out_key_put;
 	}
 
-	if (sidtype == SIDOWNER)
-		memcpy(&fuid, &sidkey->payload.value, sizeof(uid_t));
-	else
-		memcpy(&fgid, &sidkey->payload.value, sizeof(gid_t));
+	if (sidtype == SIDOWNER) {
+		kuid_t uid;
+		uid_t id;
+		memcpy(&id, &sidkey->payload.value, sizeof(uid_t));
+		uid = make_kuid(&init_user_ns, id);
+		if (uid_valid(uid))
+			fuid = uid;
+	} else {
+		kgid_t gid;
+		gid_t id;
+		memcpy(&id, &sidkey->payload.value, sizeof(gid_t));
+		gid = make_kgid(&init_user_ns, id);
+		if (gid_valid(gid))
+			fgid = gid;
+	}
 
 out_key_put:
 	key_put(sidkey);
@@ -776,7 +787,7 @@ static int parse_sec_desc(struct cifs_sb_info *cifs_sb,
 
 /* Convert permission bits from mode to equivalent CIFS ACL */
 static int build_sec_desc(struct cifs_ntsd *pntsd, struct cifs_ntsd *pnntsd,
-	__u32 secdesclen, __u64 nmode, uid_t uid, gid_t gid, int *aclflag)
+	__u32 secdesclen, __u64 nmode, kuid_t uid, kgid_t gid, int *aclflag)
 {
 	int rc = 0;
 	__u32 dacloffset;
@@ -808,17 +819,19 @@ static int build_sec_desc(struct cifs_ntsd *pntsd, struct cifs_ntsd *pnntsd,
 		*aclflag = CIFS_ACL_DACL;
 	} else {
 		memcpy(pnntsd, pntsd, secdesclen);
-		if (uid != NO_CHANGE_32) { /* chown */
+		if (uid_valid(uid)) { /* chown */
+			uid_t id;
 			owner_sid_ptr = (struct cifs_sid *)((char *)pnntsd +
 					le32_to_cpu(pnntsd->osidoffset));
 			nowner_sid_ptr = kmalloc(sizeof(struct cifs_sid),
 								GFP_KERNEL);
 			if (!nowner_sid_ptr)
 				return -ENOMEM;
-			rc = id_to_sid(uid, SIDOWNER, nowner_sid_ptr);
+			id = from_kuid(&init_user_ns, uid);
+			rc = id_to_sid(id, SIDOWNER, nowner_sid_ptr);
 			if (rc) {
 				cFYI(1, "%s: Mapping error %d for owner id %d",
-						__func__, rc, uid);
+						__func__, rc, id);
 				kfree(nowner_sid_ptr);
 				return rc;
 			}
@@ -826,17 +839,19 @@ static int build_sec_desc(struct cifs_ntsd *pntsd, struct cifs_ntsd *pnntsd,
 			kfree(nowner_sid_ptr);
 			*aclflag = CIFS_ACL_OWNER;
 		}
-		if (gid != NO_CHANGE_32) { /* chgrp */
+		if (gid_valid(gid)) { /* chgrp */
+			gid_t id;
 			group_sid_ptr = (struct cifs_sid *)((char *)pnntsd +
 					le32_to_cpu(pnntsd->gsidoffset));
 			ngroup_sid_ptr = kmalloc(sizeof(struct cifs_sid),
 								GFP_KERNEL);
 			if (!ngroup_sid_ptr)
 				return -ENOMEM;
-			rc = id_to_sid(gid, SIDGROUP, ngroup_sid_ptr);
+			id = from_kgid(&init_user_ns, gid);
+			rc = id_to_sid(id, SIDGROUP, ngroup_sid_ptr);
 			if (rc) {
 				cFYI(1, "%s: Mapping error %d for group id %d",
-						__func__, rc, gid);
+						__func__, rc, id);
 				kfree(ngroup_sid_ptr);
 				return rc;
 			}
@@ -1004,7 +1019,7 @@ cifs_acl_to_fattr(struct cifs_sb_info *cifs_sb, struct cifs_fattr *fattr,
 /* Convert mode bits to an ACL so we can update the ACL on the server */
 int
 id_mode_to_cifs_acl(struct inode *inode, const char *path, __u64 nmode,
-			uid_t uid, gid_t gid)
+			kuid_t uid, kgid_t gid)
 {
 	int rc = 0;
 	int aclflag = CIFS_ACL_DACL; /* default flag to set */
diff --git a/fs/cifs/cifspdu.h b/fs/cifs/cifspdu.h
index b9d59a9..e996ff6 100644
--- a/fs/cifs/cifspdu.h
+++ b/fs/cifs/cifspdu.h
@@ -277,7 +277,6 @@
 #define CIFS_NO_HANDLE        0xFFFF
 
 #define NO_CHANGE_64          0xFFFFFFFFFFFFFFFFULL
-#define NO_CHANGE_32          0xFFFFFFFFUL
 
 /* IPC$ in ASCII */
 #define CIFS_IPC_RESOURCE "\x49\x50\x43\x24"
diff --git a/fs/cifs/cifsproto.h b/fs/cifs/cifsproto.h
index 1988c1b..0060ec2 100644
--- a/fs/cifs/cifsproto.h
+++ b/fs/cifs/cifsproto.h
@@ -161,7 +161,7 @@ extern int cifs_acl_to_fattr(struct cifs_sb_info *cifs_sb,
 			      struct cifs_fattr *fattr, struct inode *inode,
 			      const char *path, const __u16 *pfid);
 extern int id_mode_to_cifs_acl(struct inode *inode, const char *path, __u64,
-					uid_t, gid_t);
+					kuid_t, kgid_t);
 extern struct cifs_ntsd *get_cifs_acl(struct cifs_sb_info *, struct inode *,
 					const char *, u32 *);
 extern int set_cifs_acl(struct cifs_ntsd *, __u32, struct inode *,
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index d7ea2a6..d4cf750 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -2090,8 +2090,8 @@ static int
 cifs_setattr_nounix(struct dentry *direntry, struct iattr *attrs)
 {
 	unsigned int xid;
-	uid_t uid = NO_CHANGE_32;
-	gid_t gid = NO_CHANGE_32;
+	kuid_t uid = INVALID_UID;
+	kgid_t gid = INVALID_GID;
 	struct inode *inode = direntry->d_inode;
 	struct cifs_sb_info *cifs_sb = CIFS_SB(inode->i_sb);
 	struct cifsInodeInfo *cifsInode = CIFS_I(inode);
@@ -2150,7 +2150,7 @@ cifs_setattr_nounix(struct dentry *direntry, struct iattr *attrs)
 
 #ifdef CONFIG_CIFS_ACL
 	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_ACL) {
-		if (uid != NO_CHANGE_32 || gid != NO_CHANGE_32) {
+		if (uid_valid(uid) || gid_valid(gid)) {
 			rc = id_mode_to_cifs_acl(inode, full_path, NO_CHANGE_64,
 							uid, gid);
 			if (rc) {
@@ -2174,7 +2174,7 @@ cifs_setattr_nounix(struct dentry *direntry, struct iattr *attrs)
 #ifdef CONFIG_CIFS_ACL
 		if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_ACL) {
 			rc = id_mode_to_cifs_acl(inode, full_path, mode,
-						NO_CHANGE_32, NO_CHANGE_32);
+						INVALID_UID, INVALID_GID);
 			if (rc) {
 				cFYI(1, "%s: Setting ACL failed with error: %d",
 					__func__, rc);
-- 
1.7.5.4
