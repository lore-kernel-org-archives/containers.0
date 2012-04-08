From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 34/43] userns: Convert devpts to use kuid/kgid where
	appropriate
Date: Sat,  7 Apr 2012 22:15:30 -0700
Message-ID: <1333862139-31737-34-git-send-email-ebiederm@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/devpts/inode.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 10f5e0b..979c1e3 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -98,8 +98,8 @@ static struct vfsmount *devpts_mnt;
 struct pts_mount_opts {
 	int setuid;
 	int setgid;
-	uid_t   uid;
-	gid_t   gid;
+	kuid_t   uid;
+	kgid_t   gid;
 	umode_t mode;
 	umode_t ptmxmode;
 	int newinstance;
@@ -158,11 +158,13 @@ static inline struct super_block *pts_sb_from_inode(struct inode *inode)
 static int parse_mount_options(char *data, int op, struct pts_mount_opts *opts)
 {
 	char *p;
+	kuid_t uid;
+	kgid_t gid;
 
 	opts->setuid  = 0;
 	opts->setgid  = 0;
-	opts->uid     = 0;
-	opts->gid     = 0;
+	opts->uid     = GLOBAL_ROOT_UID;
+	opts->gid     = GLOBAL_ROOT_GID;
 	opts->mode    = DEVPTS_DEFAULT_MODE;
 	opts->ptmxmode = DEVPTS_DEFAULT_PTMX_MODE;
 	opts->max     = NR_UNIX98_PTY_MAX;
@@ -184,13 +186,19 @@ static int parse_mount_options(char *data, int op, struct pts_mount_opts *opts)
 		case Opt_uid:
 			if (match_int(&args[0], &option))
 				return -EINVAL;
-			opts->uid = option;
+			uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(uid))
+				return -EINVAL;
+			opts->uid = uid;
 			opts->setuid = 1;
 			break;
 		case Opt_gid:
 			if (match_int(&args[0], &option))
 				return -EINVAL;
-			opts->gid = option;
+			gid = make_kgid(current_user_ns(), option);
+			if (!gid_valid(gid))
+				return -EINVAL;
+			opts->gid = gid;
 			opts->setgid = 1;
 			break;
 		case Opt_mode:
@@ -315,9 +323,9 @@ static int devpts_show_options(struct seq_file *seq, struct dentry *root)
 	struct pts_mount_opts *opts = &fsi->mount_opts;
 
 	if (opts->setuid)
-		seq_printf(seq, ",uid=%u", opts->uid);
+		seq_printf(seq, ",uid=%u", from_kuid_munged(&init_user_ns, opts->uid));
 	if (opts->setgid)
-		seq_printf(seq, ",gid=%u", opts->gid);
+		seq_printf(seq, ",gid=%u", from_kgid_munged(&init_user_ns, opts->gid));
 	seq_printf(seq, ",mode=%03o", opts->mode);
 #ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
 	seq_printf(seq, ",ptmxmode=%03o", opts->ptmxmode);
-- 
1.7.2.5
