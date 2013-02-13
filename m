From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 03/85] ceph: Translate inode uid and gid attributes
	to/from kuids and kgids.
Date: Wed, 13 Feb 2013 09:50:52 -0800
Message-ID: <1360777934-5663-3-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sage Weil <sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- In fill_inode() transate uids and gids in the initial user namespace
  into kuids and kgids stored in inode->i_uid and inode->i_gid.

- In ceph_setattr() if they have changed convert inode->i_uid and
  inode->i_gid into initial user namespace uids and gids for
  transmission.

Cc: Sage Weil <sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ceph/inode.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index 2971eaa..40e0787 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -612,8 +612,8 @@ static int fill_inode(struct inode *inode,
 
 	if ((issued & CEPH_CAP_AUTH_EXCL) == 0) {
 		inode->i_mode = le32_to_cpu(info->mode);
-		inode->i_uid = le32_to_cpu(info->uid);
-		inode->i_gid = le32_to_cpu(info->gid);
+		inode->i_uid = make_kuid(&init_user_ns, le32_to_cpu(info->uid));
+		inode->i_gid = make_kgid(&init_user_ns, le32_to_cpu(info->gid));
 		dout("%p mode 0%o uid.gid %d.%d\n", inode, inode->i_mode,
 		     inode->i_uid, inode->i_gid);
 	}
@@ -1570,8 +1570,9 @@ int ceph_setattr(struct dentry *dentry, struct iattr *attr)
 			inode->i_uid = attr->ia_uid;
 			dirtied |= CEPH_CAP_AUTH_EXCL;
 		} else if ((issued & CEPH_CAP_AUTH_SHARED) == 0 ||
-			   attr->ia_uid != inode->i_uid) {
-			req->r_args.setattr.uid = cpu_to_le32(attr->ia_uid);
+			   !uid_eq(attr->ia_uid, inode->i_uid)) {
+			req->r_args.setattr.uid = cpu_to_le32(
+				from_kuid(&init_user_ns, attr->ia_uid));
 			mask |= CEPH_SETATTR_UID;
 			release |= CEPH_CAP_AUTH_SHARED;
 		}
@@ -1583,8 +1584,9 @@ int ceph_setattr(struct dentry *dentry, struct iattr *attr)
 			inode->i_gid = attr->ia_gid;
 			dirtied |= CEPH_CAP_AUTH_EXCL;
 		} else if ((issued & CEPH_CAP_AUTH_SHARED) == 0 ||
-			   attr->ia_gid != inode->i_gid) {
-			req->r_args.setattr.gid = cpu_to_le32(attr->ia_gid);
+			   !gid_eq(attr->ia_gid, inode->i_gid)) {
+			req->r_args.setattr.gid = cpu_to_le32(
+				from_kgid(&init_user_ns, attr->ia_gid));
 			mask |= CEPH_SETATTR_GID;
 			release |= CEPH_CAP_AUTH_SHARED;
 		}
-- 
1.7.5.4
