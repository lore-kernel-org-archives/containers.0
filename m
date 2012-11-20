From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC 03/12] userns: Convert ceph to use kuid/kgid where
	appropriate
Date: Tue, 20 Nov 2012 04:43:31 -0800
Message-ID: <1353415420-5457-3-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sage Weil <sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Sage Weil <sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ceph/caps.c       |   16 ++++++++--------
 fs/ceph/inode.c      |   18 +++++++++---------
 fs/ceph/mds_client.c |    4 ++--
 fs/ceph/super.h      |    4 ++--
 init/Kconfig         |    1 -
 5 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
index 3251e9c..ee29cc6 100644
--- a/fs/ceph/caps.c
+++ b/fs/ceph/caps.c
@@ -928,7 +928,7 @@ static int send_cap_msg(struct ceph_mds_session *session,
 			u64 size, u64 max_size,
 			struct timespec *mtime, struct timespec *atime,
 			u64 time_warp_seq,
-			uid_t uid, gid_t gid, umode_t mode,
+			kuid_t uid, kgid_t gid, umode_t mode,
 			u64 xattr_version,
 			struct ceph_buffer *xattrs_buf,
 			u64 follows)
@@ -972,8 +972,8 @@ static int send_cap_msg(struct ceph_mds_session *session,
 		ceph_encode_timespec(&fc->atime, atime);
 	fc->time_warp_seq = cpu_to_le32(time_warp_seq);
 
-	fc->uid = cpu_to_le32(uid);
-	fc->gid = cpu_to_le32(gid);
+	fc->uid = cpu_to_le32(from_kuid(&init_user_ns, uid));
+	fc->gid = cpu_to_le32(from_kgid(&init_user_ns, gid));
 	fc->mode = cpu_to_le32(mode);
 
 	fc->xattr_version = cpu_to_le64(xattr_version);
@@ -1079,8 +1079,8 @@ static int __send_cap(struct ceph_mds_client *mdsc, struct ceph_cap *cap,
 	struct timespec mtime, atime;
 	int wake = 0;
 	umode_t mode;
-	uid_t uid;
-	gid_t gid;
+	kuid_t uid;
+	kgid_t gid;
 	struct ceph_mds_session *session;
 	u64 xattr_version = 0;
 	struct ceph_buffer *xattr_blob = NULL;
@@ -2353,10 +2353,10 @@ static void handle_cap_grant(struct inode *inode, struct ceph_mds_caps *grant,
 
 	if ((issued & CEPH_CAP_AUTH_EXCL) == 0) {
 		inode->i_mode = le32_to_cpu(grant->mode);
-		inode->i_uid = le32_to_cpu(grant->uid);
-		inode->i_gid = le32_to_cpu(grant->gid);
+		i_uid_write(inode, le32_to_cpu(grant->uid));
+		i_gid_write(inode, le32_to_cpu(grant->gid));
 		dout("%p mode 0%o uid.gid %d.%d\n", inode, inode->i_mode,
-		     inode->i_uid, inode->i_gid);
+		     i_uid_read(inode), i_gid_read(inode));
 	}
 
 	if ((issued & CEPH_CAP_LINK_EXCL) == 0)
diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index ba95eea..195b7fd 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -612,10 +612,10 @@ static int fill_inode(struct inode *inode,
 
 	if ((issued & CEPH_CAP_AUTH_EXCL) == 0) {
 		inode->i_mode = le32_to_cpu(info->mode);
-		inode->i_uid = le32_to_cpu(info->uid);
-		inode->i_gid = le32_to_cpu(info->gid);
+		i_uid_write(inode, le32_to_cpu(info->uid));
+		i_gid_write(inode, le32_to_cpu(info->gid));
 		dout("%p mode 0%o uid.gid %d.%d\n", inode, inode->i_mode,
-		     inode->i_uid, inode->i_gid);
+		     i_uid_read(inode), i_gid_read(inode));
 	}
 
 	if ((issued & CEPH_CAP_LINK_EXCL) == 0)
@@ -1562,26 +1562,26 @@ int ceph_setattr(struct dentry *dentry, struct iattr *attr)
 
 	if (ia_valid & ATTR_UID) {
 		dout("setattr %p uid %d -> %d\n", inode,
-		     inode->i_uid, attr->ia_uid);
+		     i_uid_read(inode), from_kuid(&init_user_ns, attr->ia_uid));
 		if (issued & CEPH_CAP_AUTH_EXCL) {
 			inode->i_uid = attr->ia_uid;
 			dirtied |= CEPH_CAP_AUTH_EXCL;
 		} else if ((issued & CEPH_CAP_AUTH_SHARED) == 0 ||
-			   attr->ia_uid != inode->i_uid) {
-			req->r_args.setattr.uid = cpu_to_le32(attr->ia_uid);
+			   !uid_eq(attr->ia_uid, inode->i_uid)) {
+			req->r_args.setattr.uid = cpu_to_le32(from_kuid(&init_user_ns, attr->ia_uid));
 			mask |= CEPH_SETATTR_UID;
 			release |= CEPH_CAP_AUTH_SHARED;
 		}
 	}
 	if (ia_valid & ATTR_GID) {
 		dout("setattr %p gid %d -> %d\n", inode,
-		     inode->i_gid, attr->ia_gid);
+		     i_gid_read(inode), from_kgid(&init_user_ns, attr->ia_gid));
 		if (issued & CEPH_CAP_AUTH_EXCL) {
 			inode->i_gid = attr->ia_gid;
 			dirtied |= CEPH_CAP_AUTH_EXCL;
 		} else if ((issued & CEPH_CAP_AUTH_SHARED) == 0 ||
-			   attr->ia_gid != inode->i_gid) {
-			req->r_args.setattr.gid = cpu_to_le32(attr->ia_gid);
+			   !gid_eq(attr->ia_gid, inode->i_gid)) {
+			req->r_args.setattr.gid = cpu_to_le32(from_kgid(&init_user_ns, attr->ia_gid));
 			mask |= CEPH_SETATTR_GID;
 			release |= CEPH_CAP_AUTH_SHARED;
 		}
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index 1bcf712..59e45fe 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -578,8 +578,8 @@ static void __register_request(struct ceph_mds_client *mdsc,
 	ceph_mdsc_get_request(req);
 	__insert_request(mdsc, req);
 
-	req->r_uid = current_fsuid();
-	req->r_gid = current_fsgid();
+	req->r_uid = from_kuid(&init_user_ns, current_fsuid());
+	req->r_gid = from_kgid(&init_user_ns, current_fsgid());
 
 	if (dir) {
 		struct ceph_inode_info *ci = ceph_inode(dir);
diff --git a/fs/ceph/super.h b/fs/ceph/super.h
index 66ebe72..f053bbd 100644
--- a/fs/ceph/super.h
+++ b/fs/ceph/super.h
@@ -138,8 +138,8 @@ struct ceph_cap_snap {
 	struct ceph_snap_context *context;
 
 	umode_t mode;
-	uid_t uid;
-	gid_t gid;
+	kuid_t uid;
+	kgid_t gid;
 
 	struct ceph_buffer *xattr_blob;
 	u64 xattr_version;
diff --git a/init/Kconfig b/init/Kconfig
index dfa391d..cb2c46a 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -999,7 +999,6 @@ config UIDGID_CONVERTED
 	default y
 
 	# Filesystems
-	depends on CEPH_FS = n
 	depends on CIFS = n
 	depends on CODA_FS = n
 	depends on GFS2_FS = n
-- 
1.7.5.4
