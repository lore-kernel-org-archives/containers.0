From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 08/10] Parse the relink=%s mount option
Date: Mon, 28 Feb 2011 20:05:14 -0800
Message-ID: <3d0a3c702e5986a45676987a4f3a6607d28725e7.1298952288.git.matthltc@us.ibm.com>
References: <1298952316-15763-1-git-send-email-matthltc@us.ibm.com>
	<a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc@us.ibm.com>
	<cbc5f629ca02554497bcb385039a2a300ef897f0.1298952288.git.matthltc@us.ibm.com>
	<6f547f7b0dd12d409f993dba3fbc899dc52f2a78.1298952288.git.matthltc@us.ibm.com>
	<1a7a344ddd1d68ac862ec2248be77f2dd9f138c8.1298952288.git.matthltc@us.ibm.com>
	<dbe36642be44152833a63e8173e8f0490dc1573f.1298952288.git.matthltc@us.ibm.com>
	<ac2a9431a97bbb45bdecf2ccd011f70ee99f2731.1298952288.git.matthltc@us.ibm.com>
	<24a5e0d9179d6e3c29ec0197a3251963ff2a4dbd.1298952288.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <24a5e0d9179d6e3c29ec0197a3251963ff2a4dbd.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Add a generic string mount option for relinking during checkpoint/restart.
It can be passed via mount commands. The specified path is relative to the
filesystem root and must remain within the filesystem being mounted.

Use of this mount option looks like (... for the uninteresting bits):

	mount ... -o ...,relink="qux/quux/" ...

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/super.c         |   77 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/fs.h |    2 +
 2 files changed, 77 insertions(+), 2 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index ca69615..2bda808 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -127,6 +127,9 @@ static inline void destroy_super(struct super_block *s)
 	free_percpu(s->s_files);
 #endif
 	security_sb_free(s);
+#ifdef CONFIG_CHECKPOINT
+	kfree(s->s_relink_dir);
+#endif
 	kfree(s->s_subtype);
 	kfree(s->s_options);
 	kfree(s);
@@ -952,12 +955,58 @@ int get_sb_single(struct file_system_type *fs_type,
 
 EXPORT_SYMBOL(get_sb_single);
 
+#ifdef CONFIG_CHECKPOINT
+static int parse_relink_opt(char *data, char *result, int max_result_len)
+{
+	char *s = data;
+	char *next;
+	char *opt_start;
+	int len = 0;
+
+	while (*s != '\0') {
+		next = strchr(s, ',');
+		if (!next) {
+			next = s + strlen(s);
+			len = next - s;
+		} else {
+			len = next - s;
+			next++;
+		}
+		if (strncmp(s, "relink=", 7)) {
+			s = next;
+			len = 0;
+			continue;
+		}
+		opt_start = s;
+		len -= 7;
+		s += 7;
+
+		/* Extract the relink=["]/path/to/foo["] option */
+		if (*s == '"' && s[len - 1] == '"') {
+			s++;
+			len -= 2;
+		}
+		len = max(min(len, max_result_len), 0);
+		strncpy(result, s, len);
+
+		/* Erase the relink= option */
+		memmove(opt_start, next, strlen(next) + 1);
+		break;
+	}
+	result[len] = '\0';
+	return len;
+}
+#endif
+
 struct vfsmount *
 vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void *data)
 {
 	struct vfsmount *mnt;
 	struct dentry *root;
 	char *secdata = NULL;
+#ifdef CONFIG_CHECKPOINT
+	char *relink_dir;
+#endif
 	int error;
 
 	if (!type)
@@ -970,16 +1019,33 @@ vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void
 
 	if (flags & MS_KERNMOUNT)
 		mnt->mnt_flags = MNT_INTERNAL;
-
+#ifdef CONFIG_CHECKPOINT
+	relink_dir = kmalloc(PATH_MAX, GFP_KERNEL);
+	if (!relink_dir)
+		goto out_mnt;
+	*relink_dir = '\0';
+#endif
 	if (data && !(type->fs_flags & FS_BINARY_MOUNTDATA)) {
 		secdata = alloc_secdata();
 		if (!secdata)
-			goto out_mnt;
+			goto out_relink_dir;
 
 		error = security_sb_copy_data(data, secdata);
 		if (error)
 			goto out_free_secdata;
+#ifdef CONFIG_CHECKPOINT
+		if (parse_relink_opt(data, relink_dir, PATH_MAX) < 1) {
+			kfree(relink_dir);
+			relink_dir = NULL;
+		}
+#endif
+	}
+#ifdef CONFIG_CHECKPOINT
+	else {
+		kfree(relink_dir);
+		relink_dir = NULL;
 	}
+#endif
 
 	if (type->mount) {
 		root = type->mount(type, flags, name, data);
@@ -1014,6 +1080,9 @@ vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void
 
 	mnt->mnt_mountpoint = mnt->mnt_root;
 	mnt->mnt_parent = mnt;
+#ifdef CONFIG_CHECKPOINT
+	mnt->mnt_sb->s_relink_dir = relink_dir;
+#endif
 	up_write(&mnt->mnt_sb->s_umount);
 	free_secdata(secdata);
 	return mnt;
@@ -1022,7 +1091,11 @@ out_sb:
 	deactivate_locked_super(mnt->mnt_sb);
 out_free_secdata:
 	free_secdata(secdata);
+out_relink_dir:
+#ifdef CONFIG_CHECKPOINT
+	kfree(relink_dir);
 out_mnt:
+#endif
 	free_vfsmnt(mnt);
 out:
 	return ERR_PTR(error);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 826df6f..ab97ceb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1427,7 +1427,9 @@ struct super_block {
 	 */
 	char __rcu *s_options;
 
+#ifdef CONFIG_CHECKPOINT
 	char *s_relink_dir;
+#endif
 };
 
 extern struct timespec current_fs_time(struct super_block *sb);
-- 
1.6.3.3
