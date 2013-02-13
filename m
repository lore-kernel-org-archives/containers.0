From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 02/85] ceph: Translate between uid and gids in cap
	messages and kuids and kgids
Date: Wed, 13 Feb 2013 09:50:51 -0800
Message-ID: <1360777934-5663-2-git-send-email-ebiederm@xmission.com>
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

- Make the uid and gid arguments of send_cap_msg() used to compose
  ceph_mds_caps messages of type kuid_t and kgid_t.

- Pass inode->i_uid and inode->i_gid in __send_cap to send_cap_msg()
  through variables of type kuid_t and kgid_t.

- Modify struct ceph_cap_snap to store uids and gids in types kuid_t
  and kgid_t.  This allows capturing inode->i_uid and inode->i_gid in
  ceph_queue_cap_snap() without loss and pssing them to
  __ceph_flush_snaps() where they are removed from struct
  ceph_cap_snap and passed to send_cap_msg().

- In handle_cap_grant translate uid and gids in the initial user
  namespace stored in struct ceph_mds_cap into kuids and kgids
  before setting inode->i_uid and inode->i_gid.

Cc: Sage Weil <sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ceph/caps.c  |   14 +++++++-------
 fs/ceph/super.h |    4 ++--
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
index a1d9bb3..39eb466 100644
--- a/fs/ceph/caps.c
+++ b/fs/ceph/caps.c
@@ -930,7 +930,7 @@ static int send_cap_msg(struct ceph_mds_session *session,
 			u64 size, u64 max_size,
 			struct timespec *mtime, struct timespec *atime,
 			u64 time_warp_seq,
-			uid_t uid, gid_t gid, umode_t mode,
+			kuid_t uid, kgid_t gid, umode_t mode,
 			u64 xattr_version,
 			struct ceph_buffer *xattrs_buf,
 			u64 follows)
@@ -974,8 +974,8 @@ static int send_cap_msg(struct ceph_mds_session *session,
 		ceph_encode_timespec(&fc->atime, atime);
 	fc->time_warp_seq = cpu_to_le32(time_warp_seq);
 
-	fc->uid = cpu_to_le32(uid);
-	fc->gid = cpu_to_le32(gid);
+	fc->uid = cpu_to_le32(from_kuid(&init_user_ns, uid));
+	fc->gid = cpu_to_le32(from_kgid(&init_user_ns, gid));
 	fc->mode = cpu_to_le32(mode);
 
 	fc->xattr_version = cpu_to_le64(xattr_version);
@@ -1081,8 +1081,8 @@ static int __send_cap(struct ceph_mds_client *mdsc, struct ceph_cap *cap,
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
@@ -2359,8 +2359,8 @@ static void handle_cap_grant(struct inode *inode, struct ceph_mds_caps *grant,
 
 	if ((issued & CEPH_CAP_AUTH_EXCL) == 0) {
 		inode->i_mode = le32_to_cpu(grant->mode);
-		inode->i_uid = le32_to_cpu(grant->uid);
-		inode->i_gid = le32_to_cpu(grant->gid);
+		inode->i_uid = make_kuid(&init_user_ns, le32_to_cpu(grant->uid));
+		inode->i_gid = make_kgid(&init_user_ns, le32_to_cpu(grant->gid));
 		dout("%p mode 0%o uid.gid %d.%d\n", inode, inode->i_mode,
 		     inode->i_uid, inode->i_gid);
 	}
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
-- 
1.7.5.4
