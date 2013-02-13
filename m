From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 80/85] cifs: Convert struct cifs_fattr to use kuid and
	kgids
Date: Wed, 13 Feb 2013 09:52:09 -0800
Message-ID: <1360777934-5663-80-git-send-email-ebiederm@xmission.com>
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

In cifs_unix_to_basic_fattr only update the cifs_fattr with an id if
it is valid after conversion.

Cc: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/cifs/cifsglob.h |    4 ++--
 fs/cifs/inode.c    |   14 ++++++++++----
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index 7993a7a..98312fd 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -1245,8 +1245,8 @@ struct cifs_fattr {
 	u64		cf_eof;
 	u64		cf_bytes;
 	u64		cf_createtime;
-	uid_t		cf_uid;
-	gid_t		cf_gid;
+	kuid_t		cf_uid;
+	kgid_t		cf_gid;
 	umode_t		cf_mode;
 	dev_t		cf_rdev;
 	unsigned int	cf_nlink;
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 7376439..9638233 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -247,15 +247,21 @@ cifs_unix_basic_to_fattr(struct cifs_fattr *fattr, FILE_UNIX_BASIC_INFO *info,
 	fattr->cf_uid = cifs_sb->mnt_uid;
 	if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_UID)) {
 		u64 id = le64_to_cpu(info->Uid);
-		if (id < ((uid_t)-1))
-			fattr->cf_uid = id;
+		if (id < ((uid_t)-1)) {
+			kuid_t uid = make_kuid(&init_user_ns, id);
+			if (uid_valid(uid))
+				fattr->cf_uid = uid;
+		}
 	}
 	
 	fattr->cf_gid = cifs_sb->mnt_gid;
 	if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID)) {
 		u64 id = le64_to_cpu(info->Gid);
-		if (id < ((gid_t)-1))
-			fattr->cf_gid = id;
+		if (id < ((gid_t)-1)) {
+			kgid_t gid = make_kgid(&init_user_ns, id);
+			if (gid_valid(gid))
+				fattr->cf_gid = gid;
+		}
 	}
 
 	fattr->cf_nlink = le64_to_cpu(info->Nlinks);
-- 
1.7.5.4
