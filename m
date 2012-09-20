From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 20/25] userns: Convert omfs to use kuid and kgid where
	appropriate
Date: Thu, 20 Sep 2012 04:42:01 -0700
Message-ID: <1348141326-23355-20-git-send-email-ebiederm@xmission.com>
References: <877grox6ql.fsf@xmission.com>
	<1348141326-23355-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348141326-23355-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/omfs/inode.c |    8 ++++++--
 fs/omfs/omfs.h  |    4 ++--
 init/Kconfig    |    1 -
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/omfs/inode.c b/fs/omfs/inode.c
index e6213b3..25d715c 100644
--- a/fs/omfs/inode.c
+++ b/fs/omfs/inode.c
@@ -391,12 +391,16 @@ static int parse_options(char *options, struct omfs_sb_info *sbi)
 		case Opt_uid:
 			if (match_int(&args[0], &option))
 				return 0;
-			sbi->s_uid = option;
+			sbi->s_uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(sbi->s_uid))
+				return 0;
 			break;
 		case Opt_gid:
 			if (match_int(&args[0], &option))
 				return 0;
-			sbi->s_gid = option;
+			sbi->s_gid = make_kgid(current_user_ns(), option);
+			if (!gid_valid(sbi->s_gid))
+				return 0;
 			break;
 		case Opt_umask:
 			if (match_octal(&args[0], &option))
diff --git a/fs/omfs/omfs.h b/fs/omfs/omfs.h
index 8941f12..f0f8bc7 100644
--- a/fs/omfs/omfs.h
+++ b/fs/omfs/omfs.h
@@ -19,8 +19,8 @@ struct omfs_sb_info {
 	unsigned long **s_imap;
 	int s_imap_size;
 	struct mutex s_bitmap_lock;
-	int s_uid;
-	int s_gid;
+	kuid_t s_uid;
+	kgid_t s_gid;
 	int s_dmask;
 	int s_fmask;
 };
diff --git a/init/Kconfig b/init/Kconfig
index 0f65a02..390e629 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -950,7 +950,6 @@ config UIDGID_CONVERTED
 	depends on NFSD = n
 	depends on NFS_FS = n
 	depends on OCFS2_FS = n
-	depends on OMFS_FS = n
 	depends on QNX4FS_FS = n
 	depends on QNX6FS_FS = n
 	depends on REISERFS_FS = n
-- 
1.7.5.4
