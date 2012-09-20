From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 08/25] userns: Convert befs to use kuid/kgid where appropriate
Date: Thu, 20 Sep 2012 04:41:49 -0700
Message-ID: <1348141326-23355-8-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/befs/befs.h     |    4 ++--
 fs/befs/linuxvfs.c |   27 +++++++++++++++++++--------
 init/Kconfig       |    1 -
 3 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/fs/befs/befs.h b/fs/befs/befs.h
index d9a40ab..b266428 100644
--- a/fs/befs/befs.h
+++ b/fs/befs/befs.h
@@ -20,8 +20,8 @@ typedef u64 befs_blocknr_t;
  */
 
 typedef struct befs_mount_options {
-	gid_t gid;
-	uid_t uid;
+	kgid_t gid;
+	kuid_t uid;
 	int use_gid;
 	int use_uid;
 	int debug;
diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index cf7f3c6..7f73a69 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -15,6 +15,7 @@
 #include <linux/vfs.h>
 #include <linux/parser.h>
 #include <linux/namei.h>
+#include <linux/sched.h>
 
 #include "befs.h"
 #include "btree.h"
@@ -352,9 +353,11 @@ static struct inode *befs_iget(struct super_block *sb, unsigned long ino)
 	 */   
 
 	inode->i_uid = befs_sb->mount_opts.use_uid ?
-	    befs_sb->mount_opts.uid : (uid_t) fs32_to_cpu(sb, raw_inode->uid);
+		befs_sb->mount_opts.uid :
+		make_kuid(&init_user_ns, fs32_to_cpu(sb, raw_inode->uid));
 	inode->i_gid = befs_sb->mount_opts.use_gid ?
-	    befs_sb->mount_opts.gid : (gid_t) fs32_to_cpu(sb, raw_inode->gid);
+		befs_sb->mount_opts.gid :
+		make_kgid(&init_user_ns, fs32_to_cpu(sb, raw_inode->gid));
 
 	set_nlink(inode, 1);
 
@@ -674,10 +677,12 @@ parse_options(char *options, befs_mount_options * opts)
 	char *p;
 	substring_t args[MAX_OPT_ARGS];
 	int option;
+	kuid_t uid;
+	kgid_t gid;
 
 	/* Initialize options */
-	opts->uid = 0;
-	opts->gid = 0;
+	opts->uid = GLOBAL_ROOT_UID;
+	opts->gid = GLOBAL_ROOT_GID;
 	opts->use_uid = 0;
 	opts->use_gid = 0;
 	opts->iocharset = NULL;
@@ -696,23 +701,29 @@ parse_options(char *options, befs_mount_options * opts)
 		case Opt_uid:
 			if (match_int(&args[0], &option))
 				return 0;
-			if (option < 0) {
+			uid = INVALID_UID;
+			if (option >= 0)
+				uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(uid)) {
 				printk(KERN_ERR "BeFS: Invalid uid %d, "
 						"using default\n", option);
 				break;
 			}
-			opts->uid = option;
+			opts->uid = uid;
 			opts->use_uid = 1;
 			break;
 		case Opt_gid:
 			if (match_int(&args[0], &option))
 				return 0;
-			if (option < 0) {
+			gid = INVALID_GID;
+			if (option >= 0)
+				gid = make_kgid(current_user_ns(), option);
+			if (!gid_valid(gid)) {
 				printk(KERN_ERR "BeFS: Invalid gid %d, "
 						"using default\n", option);
 				break;
 			}
-			opts->gid = option;
+			opts->gid = gid;
 			opts->use_gid = 1;
 			break;
 		case Opt_charset:
diff --git a/init/Kconfig b/init/Kconfig
index 20ddf0d..d9bb344 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -936,7 +936,6 @@ config UIDGID_CONVERTED
 	depends on AFFS_FS = n
 	depends on AFS_FS = n
 	depends on AUTOFS4_FS = n
-	depends on BEFS_FS = n
 	depends on BFS_FS = n
 	depends on BTRFS_FS = n
 	depends on CEPH_FS = n
-- 
1.7.5.4
