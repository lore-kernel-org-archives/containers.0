From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 07/10] Add relink_dir superblock field
Date: Mon, 28 Feb 2011 20:05:13 -0800
Message-ID: <24a5e0d9179d6e3c29ec0197a3251963ff2a4dbd.1298952288.git.matthltc@us.ibm.com>
References: <1298952316-15763-1-git-send-email-matthltc@us.ibm.com>
	<a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc@us.ibm.com>
	<cbc5f629ca02554497bcb385039a2a300ef897f0.1298952288.git.matthltc@us.ibm.com>
	<6f547f7b0dd12d409f993dba3fbc899dc52f2a78.1298952288.git.matthltc@us.ibm.com>
	<1a7a344ddd1d68ac862ec2248be77f2dd9f138c8.1298952288.git.matthltc@us.ibm.com>
	<dbe36642be44152833a63e8173e8f0490dc1573f.1298952288.git.matthltc@us.ibm.com>
	<ac2a9431a97bbb45bdecf2ccd011f70ee99f2731.1298952288.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ac2a9431a97bbb45bdecf2ccd011f70ee99f2731.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch adds the pointer for a relink mount(8) option which specifies a
path to a directory within the given filesystem where checkpoint/restart
may relink files. If the option is unset then checkpoint/restart tries
to use "lost+found".

A subsequent patch will enable userspace to set a relink=/foo/bar
option when mounting a filesystem.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/namei.c         |    6 ++++--
 fs/namespace.c     |    6 ++++++
 include/linux/fs.h |    2 ++
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 6dea3b1..fcf35b3 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2535,7 +2535,7 @@ SYSCALL_DEFINE2(link, const char __user *, oldname, const char __user *, newname
 #ifdef CONFIG_CHECKPOINT
 
 /* Path relative to the mounted filesystem's root -- not a "global" root or even a namespace root. The unique_name_count is unique for the entire checkpoint. */
-#define CKPT_RELINKAT_FMT "lost+found/checkpoint-%d/relinked-%u"
+#define CKPT_RELINKAT_FMT "%s/checkpoint-%d/relinked-%u"
 
 static int checkpoint_fill_relink_fname(struct ckpt_ctx *ctx,
 					struct file *for_file,
@@ -2569,7 +2569,9 @@ static int checkpoint_fill_relink_fname(struct ckpt_ctx *ctx,
 		len++;
 	}
 	len += snprintf(tmp, PATH_MAX - len, CKPT_RELINKAT_FMT,
-			ctx->crid, ++ctx->unique_name_count);
+			relink_dir_path.mnt->mnt_sb->s_relink_dir ? relink_dir_path.mnt->mnt_sb->s_relink_dir : "lost+found",
+			ctx->crid,
+			 ++ctx->unique_name_count);
 	relink_dir_pathname[len] = '\0';
 	*lenp = len;
 	return 0;
diff --git a/fs/namespace.c b/fs/namespace.c
index 8c83cd3..31fe15f 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -810,6 +810,12 @@ static int show_sb_opts(struct seq_file *m, struct super_block *sb)
 		if (sb->s_flags & fs_infop->flag)
 			seq_puts(m, fs_infop->str);
 	}
+#ifdef CONFIG_CHECKPOINT
+	if (sb->s_relink_dir) {
+		seq_puts(m, ",relink=");
+		seq_puts(m, sb->s_relink_dir);
+	}
+#endif /* CONFIG_CHECKPOINT */
 
 	return security_sb_show_options(m, sb);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index af1cb0e..826df6f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1426,6 +1426,8 @@ struct super_block {
 	 * generic_show_options()
 	 */
 	char __rcu *s_options;
+
+	char *s_relink_dir;
 };
 
 extern struct timespec current_fs_time(struct super_block *sb);
-- 
1.6.3.3
