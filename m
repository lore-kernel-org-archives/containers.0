From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 83/85] cifs: Convert struct cifs_sb_info to use kuids
	and kgids
Date: Wed, 13 Feb 2013 09:52:12 -0800
Message-ID: <1360777934-5663-83-git-send-email-ebiederm__18575.7030304105$1360778917$gmane$org@xmission.com>
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

Cc: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/cifs/cifs_fs_sb.h |    8 ++++----
 fs/cifs/cifsfs.c     |   14 ++++++++++----
 fs/cifs/connect.c    |    2 +-
 fs/cifs/misc.c       |    2 +-
 4 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/cifs/cifs_fs_sb.h b/fs/cifs/cifs_fs_sb.h
index c865bfd..37e4a72 100644
--- a/fs/cifs/cifs_fs_sb.h
+++ b/fs/cifs/cifs_fs_sb.h
@@ -55,10 +55,10 @@ struct cifs_sb_info {
 	unsigned int wsize;
 	unsigned long actimeo; /* attribute cache timeout (jiffies) */
 	atomic_t active;
-	uid_t	mnt_uid;
-	gid_t	mnt_gid;
-	uid_t	mnt_backupuid;
-	gid_t	mnt_backupgid;
+	kuid_t	mnt_uid;
+	kgid_t	mnt_gid;
+	kuid_t	mnt_backupuid;
+	kgid_t	mnt_backupgid;
 	umode_t	mnt_file_mode;
 	umode_t	mnt_dir_mode;
 	unsigned int mnt_cifs_flags;
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index f653835..1759073 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -376,13 +376,15 @@ cifs_show_options(struct seq_file *s, struct dentry *root)
 				   (int)(srcaddr->sa_family));
 	}
 
-	seq_printf(s, ",uid=%u", cifs_sb->mnt_uid);
+	seq_printf(s, ",uid=%u",
+		   from_kuid_munged(&init_user_ns, cifs_sb->mnt_uid));
 	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_UID)
 		seq_printf(s, ",forceuid");
 	else
 		seq_printf(s, ",noforceuid");
 
-	seq_printf(s, ",gid=%u", cifs_sb->mnt_gid);
+	seq_printf(s, ",gid=%u",
+		   from_kgid_munged(&init_user_ns, cifs_sb->mnt_gid));
 	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID)
 		seq_printf(s, ",forcegid");
 	else
@@ -437,9 +439,13 @@ cifs_show_options(struct seq_file *s, struct dentry *root)
 	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_NO_PERM)
 		seq_printf(s, ",noperm");
 	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_BACKUPUID)
-		seq_printf(s, ",backupuid=%u", cifs_sb->mnt_backupuid);
+		seq_printf(s, ",backupuid=%u",
+			   from_kuid_munged(&init_user_ns,
+					    cifs_sb->mnt_backupuid));
 	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_BACKUPGID)
-		seq_printf(s, ",backupgid=%u", cifs_sb->mnt_backupgid);
+		seq_printf(s, ",backupgid=%u",
+			   from_kgid_munged(&init_user_ns,
+					    cifs_sb->mnt_backupgid));
 
 	seq_printf(s, ",rsize=%u", cifs_sb->rsize);
 	seq_printf(s, ",wsize=%u", cifs_sb->wsize);
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 9bd13a7..01279b8 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -2743,7 +2743,7 @@ compare_mount_options(struct super_block *sb, struct cifs_mnt_data *mnt_data)
 	if (new->rsize && new->rsize < old->rsize)
 		return 0;
 
-	if (old->mnt_uid != new->mnt_uid || old->mnt_gid != new->mnt_gid)
+	if (!uid_eq(old->mnt_uid, new->mnt_uid) || !gid_eq(old->mnt_gid, new->mnt_gid))
 		return 0;
 
 	if (old->mnt_file_mode != new->mnt_file_mode ||
diff --git a/fs/cifs/misc.c b/fs/cifs/misc.c
index 3a00c0d..1b15bf8 100644
--- a/fs/cifs/misc.c
+++ b/fs/cifs/misc.c
@@ -569,7 +569,7 @@ bool
 backup_cred(struct cifs_sb_info *cifs_sb)
 {
 	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_BACKUPUID) {
-		if (cifs_sb->mnt_backupuid == current_fsuid())
+		if (uid_eq(cifs_sb->mnt_backupuid, current_fsuid()))
 			return true;
 	}
 	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_BACKUPGID) {
-- 
1.7.5.4
