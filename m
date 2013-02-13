From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 60/85] nfs: kuid and kgid conversions for nfs/inode.c
Date: Wed, 13 Feb 2013 09:51:49 -0800
Message-ID: <1360777934-5663-60-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- Use uid_eq and gid_eq when comparing kuids and kgids.
- Use make_kuid(&init_user_ns, -2) and make_kgid(&init_user_ns, -2) as
  the initial uid and gid on nfs inodes, instead of using the typeunsafe
  value of -2.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfs/inode.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index ebeb94c..ce2b039 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -332,8 +332,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		inode->i_version = 0;
 		inode->i_size = 0;
 		clear_nlink(inode);
-		inode->i_uid = -2;
-		inode->i_gid = -2;
+		inode->i_uid = make_kuid(&init_user_ns, -2);
+		inode->i_gid = make_kgid(&init_user_ns, -2);
 		inode->i_blocks = 0;
 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
 		nfsi->write_io = 0;
@@ -1009,9 +1009,9 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	/* Have any file permissions changed? */
 	if ((fattr->valid & NFS_ATTR_FATTR_MODE) && (inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO))
 		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
-	if ((fattr->valid & NFS_ATTR_FATTR_OWNER) && inode->i_uid != fattr->uid)
+	if ((fattr->valid & NFS_ATTR_FATTR_OWNER) && !uid_eq(inode->i_uid, fattr->uid))
 		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
-	if ((fattr->valid & NFS_ATTR_FATTR_GROUP) && inode->i_gid != fattr->gid)
+	if ((fattr->valid & NFS_ATTR_FATTR_GROUP) && !gid_eq(inode->i_gid, fattr->gid))
 		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
 
 	/* Has the link count changed? */
@@ -1440,7 +1440,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				| NFS_INO_REVAL_FORCED);
 
 	if (fattr->valid & NFS_ATTR_FATTR_OWNER) {
-		if (inode->i_uid != fattr->uid) {
+		if (!uid_eq(inode->i_uid, fattr->uid)) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 			inode->i_uid = fattr->uid;
 		}
@@ -1451,7 +1451,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				| NFS_INO_REVAL_FORCED);
 
 	if (fattr->valid & NFS_ATTR_FATTR_GROUP) {
-		if (inode->i_gid != fattr->gid) {
+		if (!gid_eq(inode->i_gid, fattr->gid)) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 			inode->i_gid = fattr->gid;
 		}
-- 
1.7.5.4
