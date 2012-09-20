From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 19/25] userns: Convert ntfs to use kuid and kgid where
	appropriate
Date: Thu, 20 Sep 2012 04:42:00 -0700
Message-ID: <1348141326-23355-19-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Anton Altaparmakov <anton-yrGDUoBaLx3QT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Anton Altaparmakov <anton-yrGDUoBaLx3QT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ntfs/inode.c  |    7 ++++---
 fs/ntfs/super.c  |   39 ++++++++++++++++++++++++++++++++-------
 fs/ntfs/volume.h |    5 +++--
 init/Kconfig     |    1 -
 4 files changed, 39 insertions(+), 13 deletions(-)

diff --git a/fs/ntfs/inode.c b/fs/ntfs/inode.c
index c6dbd3d..1d27331 100644
--- a/fs/ntfs/inode.c
+++ b/fs/ntfs/inode.c
@@ -2124,7 +2124,8 @@ int ntfs_read_inode_mount(struct inode *vi)
 			 * ntfs_read_inode() will have set up the default ones.
 			 */
 			/* Set uid and gid to root. */
-			vi->i_uid = vi->i_gid = 0;
+			vi->i_uid = GLOBAL_ROOT_UID;
+			vi->i_gid = GLOBAL_ROOT_GID;
 			/* Regular file. No access for anyone. */
 			vi->i_mode = S_IFREG;
 			/* No VFS initiated operations allowed for $MFT. */
@@ -2312,8 +2313,8 @@ int ntfs_show_options(struct seq_file *sf, struct dentry *root)
 	ntfs_volume *vol = NTFS_SB(root->d_sb);
 	int i;
 
-	seq_printf(sf, ",uid=%i", vol->uid);
-	seq_printf(sf, ",gid=%i", vol->gid);
+	seq_printf(sf, ",uid=%i", from_kuid_munged(&init_user_ns, vol->uid));
+	seq_printf(sf, ",gid=%i", from_kgid_munged(&init_user_ns, vol->gid));
 	if (vol->fmask == vol->dmask)
 		seq_printf(sf, ",umask=0%o", vol->fmask);
 	else {
diff --git a/fs/ntfs/super.c b/fs/ntfs/super.c
index 2bc149d..da01c16 100644
--- a/fs/ntfs/super.c
+++ b/fs/ntfs/super.c
@@ -102,8 +102,8 @@ static bool parse_options(ntfs_volume *vol, char *opt)
 	char *p, *v, *ov;
 	static char *utf8 = "utf8";
 	int errors = 0, sloppy = 0;
-	uid_t uid = (uid_t)-1;
-	gid_t gid = (gid_t)-1;
+	kuid_t uid = INVALID_UID;
+	kgid_t gid = INVALID_GID;
 	umode_t fmask = (umode_t)-1, dmask = (umode_t)-1;
 	int mft_zone_multiplier = -1, on_errors = -1;
 	int show_sys_files = -1, case_sensitive = -1, disable_sparse = -1;
@@ -128,6 +128,30 @@ static bool parse_options(ntfs_volume *vol, char *opt)
 		if (*v)							\
 			goto needs_val;					\
 	}
+#define NTFS_GETOPT_UID(option, variable)				\
+	if (!strcmp(p, option)) {					\
+		uid_t uid_value;					\
+		if (!v || !*v)						\
+			goto needs_arg;					\
+		uid_value = simple_strtoul(ov = v, &v, 0);		\
+		if (*v)							\
+			goto needs_val;					\
+		variable = make_kuid(current_user_ns(), uid_value);	\
+		if (!uid_valid(variable))				\
+			goto needs_val;					\
+	}
+#define NTFS_GETOPT_GID(option, variable)				\
+	if (!strcmp(p, option)) {					\
+		gid_t gid_value;					\
+		if (!v || !*v)						\
+			goto needs_arg;					\
+		gid_value = simple_strtoul(ov = v, &v, 0);		\
+		if (*v)							\
+			goto needs_val;					\
+		variable = make_kgid(current_user_ns(), gid_value);	\
+		if (!gid_valid(variable))				\
+			goto needs_val;					\
+	}
 #define NTFS_GETOPT_OCTAL(option, variable)				\
 	if (!strcmp(p, option)) {					\
 		if (!v || !*v)						\
@@ -165,8 +189,8 @@ static bool parse_options(ntfs_volume *vol, char *opt)
 	while ((p = strsep(&opt, ","))) {
 		if ((v = strchr(p, '=')))
 			*v++ = 0;
-		NTFS_GETOPT("uid", uid)
-		else NTFS_GETOPT("gid", gid)
+		NTFS_GETOPT_UID("uid", uid)
+		else NTFS_GETOPT_GID("gid", gid)
 		else NTFS_GETOPT_OCTAL("umask", fmask = dmask)
 		else NTFS_GETOPT_OCTAL("fmask", fmask)
 		else NTFS_GETOPT_OCTAL("dmask", dmask)
@@ -283,9 +307,9 @@ no_mount_options:
 		vol->on_errors = on_errors;
 	if (!vol->on_errors || vol->on_errors == ON_ERRORS_RECOVER)
 		vol->on_errors |= ON_ERRORS_CONTINUE;
-	if (uid != (uid_t)-1)
+	if (uid_valid(uid))
 		vol->uid = uid;
-	if (gid != (gid_t)-1)
+	if (gid_valid(gid))
 		vol->gid = gid;
 	if (fmask != (umode_t)-1)
 		vol->fmask = fmask;
@@ -1023,7 +1047,8 @@ static bool load_and_init_mft_mirror(ntfs_volume *vol)
 	 * ntfs_read_inode() will have set up the default ones.
 	 */
 	/* Set uid and gid to root. */
-	tmp_ino->i_uid = tmp_ino->i_gid = 0;
+	tmp_ino->i_uid = GLOBAL_ROOT_UID;
+	tmp_ino->i_gid = GLOBAL_ROOT_GID;
 	/* Regular file.  No access for anyone. */
 	tmp_ino->i_mode = S_IFREG;
 	/* No VFS initiated operations allowed for $MFTMirr. */
diff --git a/fs/ntfs/volume.h b/fs/ntfs/volume.h
index 15e3ba8..4f579b0 100644
--- a/fs/ntfs/volume.h
+++ b/fs/ntfs/volume.h
@@ -25,6 +25,7 @@
 #define _LINUX_NTFS_VOLUME_H
 
 #include <linux/rwsem.h>
+#include <linux/uidgid.h>
 
 #include "types.h"
 #include "layout.h"
@@ -46,8 +47,8 @@ typedef struct {
 					   sized blocks on the device. */
 	/* Configuration provided by user at mount time. */
 	unsigned long flags;		/* Miscellaneous flags, see below. */
-	uid_t uid;			/* uid that files will be mounted as. */
-	gid_t gid;			/* gid that files will be mounted as. */
+	kuid_t uid;			/* uid that files will be mounted as. */
+	kgid_t gid;			/* gid that files will be mounted as. */
 	umode_t fmask;			/* The mask for file permissions. */
 	umode_t dmask;			/* The mask for directory
 					   permissions. */
diff --git a/init/Kconfig b/init/Kconfig
index 90c9e06..0f65a02 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -949,7 +949,6 @@ config UIDGID_CONVERTED
 	depends on NCP_FS = n
 	depends on NFSD = n
 	depends on NFS_FS = n
-	depends on NTFS_FS = n
 	depends on OCFS2_FS = n
 	depends on OMFS_FS = n
 	depends on QNX4FS_FS = n
-- 
1.7.5.4
