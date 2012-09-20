From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 15/25] userns: Convert isofs to use kuid/kgid where appropriate
Date: Thu, 20 Sep 2012 04:41:56 -0700
Message-ID: <1348141326-23355-15-git-send-email-ebiederm@xmission.com>
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

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/isofs/inode.c |   17 +++++++++++------
 fs/isofs/isofs.h |    4 ++--
 fs/isofs/rock.c  |    4 ++--
 init/Kconfig     |    1 -
 4 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index 29037c3..a7d8e6c 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -21,6 +21,7 @@
 #include <linux/cdrom.h>
 #include <linux/parser.h>
 #include <linux/mpage.h>
+#include <linux/user_namespace.h>
 
 #include "isofs.h"
 #include "zisofs.h"
@@ -171,8 +172,8 @@ struct iso9660_options{
 	unsigned int blocksize;
 	umode_t fmode;
 	umode_t dmode;
-	gid_t gid;
-	uid_t uid;
+	kgid_t gid;
+	kuid_t uid;
 	char *iocharset;
 	/* LVE */
 	s32 session;
@@ -383,8 +384,8 @@ static int parse_options(char *options, struct iso9660_options *popt)
 	popt->fmode = popt->dmode = ISOFS_INVALID_MODE;
 	popt->uid_set = 0;
 	popt->gid_set = 0;
-	popt->gid = 0;
-	popt->uid = 0;
+	popt->gid = GLOBAL_ROOT_GID;
+	popt->uid = GLOBAL_ROOT_UID;
 	popt->iocharset = NULL;
 	popt->utf8 = 0;
 	popt->overriderockperm = 0;
@@ -460,13 +461,17 @@ static int parse_options(char *options, struct iso9660_options *popt)
 		case Opt_uid:
 			if (match_int(&args[0], &option))
 				return 0;
-			popt->uid = option;
+			popt->uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(popt->uid))
+				return 0;
 			popt->uid_set = 1;
 			break;
 		case Opt_gid:
 			if (match_int(&args[0], &option))
 				return 0;
-			popt->gid = option;
+			popt->gid = make_kgid(current_user_ns(), option);
+			if (!gid_valid(popt->gid))
+				return 0;
 			popt->gid_set = 1;
 			break;
 		case Opt_mode:
diff --git a/fs/isofs/isofs.h b/fs/isofs/isofs.h
index 3620ad1..9916723 100644
--- a/fs/isofs/isofs.h
+++ b/fs/isofs/isofs.h
@@ -52,8 +52,8 @@ struct isofs_sb_info {
 
 	umode_t s_fmode;
 	umode_t s_dmode;
-	gid_t s_gid;
-	uid_t s_uid;
+	kgid_t s_gid;
+	kuid_t s_uid;
 	struct nls_table *s_nls_iocharset; /* Native language support table */
 };
 
diff --git a/fs/isofs/rock.c b/fs/isofs/rock.c
index 70e79d0..c0bf424 100644
--- a/fs/isofs/rock.c
+++ b/fs/isofs/rock.c
@@ -364,8 +364,8 @@ repeat:
 		case SIG('P', 'X'):
 			inode->i_mode = isonum_733(rr->u.PX.mode);
 			set_nlink(inode, isonum_733(rr->u.PX.n_links));
-			inode->i_uid = isonum_733(rr->u.PX.uid);
-			inode->i_gid = isonum_733(rr->u.PX.gid);
+			i_uid_write(inode, isonum_733(rr->u.PX.uid));
+			i_gid_write(inode, isonum_733(rr->u.PX.gid));
 			break;
 		case SIG('P', 'N'):
 			{
diff --git a/init/Kconfig b/init/Kconfig
index 9cf8cb1..88f6571 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -944,7 +944,6 @@ config UIDGID_CONVERTED
 	depends on FUSE_FS = n
 	depends on GFS2_FS = n
 	depends on HPFS_FS = n
-	depends on ISO9660_FS = n
 	depends on JFFS2_FS = n
 	depends on JFS_FS = n
 	depends on LOGFS = n
-- 
1.7.5.4
