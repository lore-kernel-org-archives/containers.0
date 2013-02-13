From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 05/85] ceph: Convert kuids and kgids before printing
	them.
Date: Wed, 13 Feb 2013 09:50:54 -0800
Message-ID: <1360777934-5663-5-git-send-email-ebiederm@xmission.com>
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

Before printing kuid and kgids values convert them into
the initial user namespace.

Cc: Sage Weil <sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ceph/caps.c  |    3 ++-
 fs/ceph/inode.c |    9 ++++++---
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
index 39eb466..ae2be69 100644
--- a/fs/ceph/caps.c
+++ b/fs/ceph/caps.c
@@ -2362,7 +2362,8 @@ static void handle_cap_grant(struct inode *inode, struct ceph_mds_caps *grant,
 		inode->i_uid = make_kuid(&init_user_ns, le32_to_cpu(grant->uid));
 		inode->i_gid = make_kgid(&init_user_ns, le32_to_cpu(grant->gid));
 		dout("%p mode 0%o uid.gid %d.%d\n", inode, inode->i_mode,
-		     inode->i_uid, inode->i_gid);
+		     from_kuid(&init_user_ns, inode->i_uid),
+		     from_kgid(&init_user_ns, inode->i_gid));
 	}
 
 	if ((issued & CEPH_CAP_LINK_EXCL) == 0)
diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index 40e0787..d45895f 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -615,7 +615,8 @@ static int fill_inode(struct inode *inode,
 		inode->i_uid = make_kuid(&init_user_ns, le32_to_cpu(info->uid));
 		inode->i_gid = make_kgid(&init_user_ns, le32_to_cpu(info->gid));
 		dout("%p mode 0%o uid.gid %d.%d\n", inode, inode->i_mode,
-		     inode->i_uid, inode->i_gid);
+		     from_kuid(&init_user_ns, inode->i_uid),
+		     from_kgid(&init_user_ns, inode->i_gid));
 	}
 
 	if ((issued & CEPH_CAP_LINK_EXCL) == 0)
@@ -1565,7 +1566,8 @@ int ceph_setattr(struct dentry *dentry, struct iattr *attr)
 
 	if (ia_valid & ATTR_UID) {
 		dout("setattr %p uid %d -> %d\n", inode,
-		     inode->i_uid, attr->ia_uid);
+		     from_kuid(&init_user_ns, inode->i_uid),
+		     from_kuid(&init_user_ns, attr->ia_uid));
 		if (issued & CEPH_CAP_AUTH_EXCL) {
 			inode->i_uid = attr->ia_uid;
 			dirtied |= CEPH_CAP_AUTH_EXCL;
@@ -1579,7 +1581,8 @@ int ceph_setattr(struct dentry *dentry, struct iattr *attr)
 	}
 	if (ia_valid & ATTR_GID) {
 		dout("setattr %p gid %d -> %d\n", inode,
-		     inode->i_gid, attr->ia_gid);
+		     from_kgid(&init_user_ns, inode->i_gid),
+		     from_kgid(&init_user_ns, attr->ia_gid));
 		if (issued & CEPH_CAP_AUTH_EXCL) {
 			inode->i_gid = attr->ia_gid;
 			dirtied |= CEPH_CAP_AUTH_EXCL;
-- 
1.7.5.4
