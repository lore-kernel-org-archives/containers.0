From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 01/11] userns: Convert affs to use kuid/kgid wherwe appropriate
Date: Fri, 21 Sep 2012 18:35:02 -0700
Message-ID: <1348277712-30055-1-git-send-email-ebiederm@xmission.com>
References: <877grmj115.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877grmj115.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/affs/affs.h  |    4 ++--
 fs/affs/inode.c |   20 ++++++++++----------
 fs/affs/super.c |   18 +++++++++++-------
 init/Kconfig    |    1 -
 4 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/fs/affs/affs.h b/fs/affs/affs.h
index 6e21641..3952121 100644
--- a/fs/affs/affs.h
+++ b/fs/affs/affs.h
@@ -88,8 +88,8 @@ struct affs_sb_info {
 	u32 s_root_block;		/* FFS root block number. */
 	int s_hashsize;			/* Size of hash table. */
 	unsigned long s_flags;		/* See below. */
-	uid_t s_uid;			/* uid to override */
-	gid_t s_gid;			/* gid to override */
+	kuid_t s_uid;			/* uid to override */
+	kgid_t s_gid;			/* gid to override */
 	umode_t s_mode;			/* mode to override */
 	struct buffer_head *s_root_bh;	/* Cached root block. */
 	struct mutex s_bmlock;		/* Protects bitmap access. */
diff --git a/fs/affs/inode.c b/fs/affs/inode.c
index 8bc4a59..15c4842 100644
--- a/fs/affs/inode.c
+++ b/fs/affs/inode.c
@@ -80,17 +80,17 @@ struct inode *affs_iget(struct super_block *sb, unsigned long ino)
 	if (id == 0 || sbi->s_flags & SF_SETUID)
 		inode->i_uid = sbi->s_uid;
 	else if (id == 0xFFFF && sbi->s_flags & SF_MUFS)
-		inode->i_uid = 0;
+		i_uid_write(inode, 0);
 	else
-		inode->i_uid = id;
+		i_uid_write(inode, id);
 
 	id = be16_to_cpu(tail->gid);
 	if (id == 0 || sbi->s_flags & SF_SETGID)
 		inode->i_gid = sbi->s_gid;
 	else if (id == 0xFFFF && sbi->s_flags & SF_MUFS)
-		inode->i_gid = 0;
+		i_gid_write(inode, 0);
 	else
-		inode->i_gid = id;
+		i_gid_write(inode, id);
 
 	switch (be32_to_cpu(tail->stype)) {
 	case ST_ROOT:
@@ -193,13 +193,13 @@ affs_write_inode(struct inode *inode, struct writeback_control *wbc)
 		tail->size = cpu_to_be32(inode->i_size);
 		secs_to_datestamp(inode->i_mtime.tv_sec,&tail->change);
 		if (!(inode->i_ino == AFFS_SB(sb)->s_root_block)) {
-			uid = inode->i_uid;
-			gid = inode->i_gid;
+			uid = i_uid_read(inode);
+			gid = i_gid_read(inode);
 			if (AFFS_SB(sb)->s_flags & SF_MUFS) {
-				if (inode->i_uid == 0 || inode->i_uid == 0xFFFF)
-					uid = inode->i_uid ^ ~0;
-				if (inode->i_gid == 0 || inode->i_gid == 0xFFFF)
-					gid = inode->i_gid ^ ~0;
+				if (uid == 0 || uid == 0xFFFF)
+					uid = uid ^ ~0;
+				if (gid == 0 || gid == 0xFFFF)
+					gid = gid ^ ~0;
 			}
 			if (!(AFFS_SB(sb)->s_flags & SF_SETUID))
 				tail->uid = cpu_to_be16(uid);
diff --git a/fs/affs/super.c b/fs/affs/super.c
index c70f1e5..966c8c0 100644
--- a/fs/affs/super.c
+++ b/fs/affs/super.c
@@ -188,7 +188,7 @@ static const match_table_t tokens = {
 };
 
 static int
-parse_options(char *options, uid_t *uid, gid_t *gid, int *mode, int *reserved, s32 *root,
+parse_options(char *options, kuid_t *uid, kgid_t *gid, int *mode, int *reserved, s32 *root,
 		int *blocksize, char **prefix, char *volume, unsigned long *mount_opts)
 {
 	char *p;
@@ -253,13 +253,17 @@ parse_options(char *options, uid_t *uid, gid_t *gid, int *mode, int *reserved, s
 		case Opt_setgid:
 			if (match_int(&args[0], &option))
 				return 0;
-			*gid = option;
+			*gid = make_kgid(current_user_ns(), option);
+			if (!gid_valid(*gid))
+				return 0;
 			*mount_opts |= SF_SETGID;
 			break;
 		case Opt_setuid:
 			if (match_int(&args[0], &option))
 				return 0;
-			*uid = option;
+			*uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(*uid))
+				return 0;
 			*mount_opts |= SF_SETUID;
 			break;
 		case Opt_verbose:
@@ -301,8 +305,8 @@ static int affs_fill_super(struct super_block *sb, void *data, int silent)
 	int			 num_bm;
 	int			 i, j;
 	s32			 key;
-	uid_t			 uid;
-	gid_t			 gid;
+	kuid_t			 uid;
+	kgid_t			 gid;
 	int			 reserved;
 	unsigned long		 mount_flags;
 	int			 tmp_flags;	/* fix remount prototype... */
@@ -527,8 +531,8 @@ affs_remount(struct super_block *sb, int *flags, char *data)
 {
 	struct affs_sb_info	*sbi = AFFS_SB(sb);
 	int			 blocksize;
-	uid_t			 uid;
-	gid_t			 gid;
+	kuid_t			 uid;
+	kgid_t			 gid;
 	int			 mode;
 	int			 reserved;
 	int			 root_block;
diff --git a/init/Kconfig b/init/Kconfig
index 8691098..a358f4a 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -928,7 +928,6 @@ config UIDGID_CONVERTED
 
 	# Filesystems
 	depends on 9P_FS = n
-	depends on AFFS_FS = n
 	depends on AFS_FS = n
 	depends on AUTOFS4_FS = n
 	depends on BFS_FS = n
-- 
1.7.5.4
