From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v2 4/4] parse options in the vfs level
Date: Fri,  5 Aug 2011 04:35:44 +0400
Message-ID: <1312504544-1108-5-git-send-email-glommer__13760.5533040643$1312504653$gmane$org@parallels.com>
References: <1312504544-1108-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1312504544-1108-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, David Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch introduces a simple generic vfs option parser.
Right now, the only option we have is to limit the size of the dcache.

So any user that wants to have a dcache entries limit, can specify:

  mount -o whatever_options,vfs_dcache_size=XXX <dev> <mntpoint>

It is supposed to work well with remounts, allowing it to change
multiple over the course of the filesystem's lifecycle.

I find mount a natural interface for handling filesystem options,
so that's what I've choosen. Feel free to yell at it at will if
you disagree.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
---
 fs/dcache.c            |    7 +++
 fs/namespace.c         |  105 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/dcache.h |    4 ++
 3 files changed, 116 insertions(+), 0 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 52a0faf..ace5670 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1202,6 +1202,13 @@ static int dcache_mem_check(struct super_block *sb)
 	return -ENOMEM;
 }
 
+int vfs_set_dcache_size(struct super_block *sb, int size)
+{
+	sb->s_nr_dentry_max = size;
+
+	return dcache_mem_check(sb);
+}
+
 /**
  * __d_alloc	-	allocate a dcache entry
  * @sb: filesystem it will belong to
diff --git a/fs/namespace.c b/fs/namespace.c
index 22bfe82..43b2cdb 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -31,6 +31,7 @@
 #include <linux/idr.h>
 #include <linux/fs_struct.h>
 #include <linux/fsnotify.h>
+#include <linux/parser.h>
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
 #include "pnode.h"
@@ -958,6 +959,9 @@ static int show_sb_opts(struct seq_file *m, struct super_block *sb)
 	};
 	const struct proc_fs_info *fs_infop;
 
+	if (sb->s_nr_dentry_max != INT_MAX)
+		seq_printf(m, ",vfs_dcache_size=%d",sb->s_nr_dentry_max);
+
 	for (fs_infop = fs_info; fs_infop->flag; fs_infop++) {
 		if (sb->s_flags & fs_infop->flag)
 			seq_puts(m, fs_infop->str);
@@ -2271,6 +2275,94 @@ int copy_mount_string(const void __user *data, char **where)
 	return 0;
 }
 
+static const match_table_t tokens = {
+	{1, "vfs_dcache_size=%u"},
+};
+
+struct vfs_options {
+	unsigned long vfs_dcache_size;
+};
+
+/**
+ * Generic option parsing for the VFS.
+ *
+ * Since most of the filesystems already do their own option parsing, and with
+ * very few code shared between them, this function strips out any options that
+ * we succeed in parsing ourselves. Passing them forward would just give the
+ * underlying fs an option it does not expect, leading it to fail.
+ *
+ * We don't yet have a pointer to the super block as well, since this is
+ * pre-mount. We accumulate in struct vfs_options whatever data we collected,
+ * and act on it later.
+ */
+static int vfs_parse_options(char *options, struct vfs_options *ops)
+{
+	substring_t args[MAX_OPT_ARGS];
+	int option;
+	char *p;
+	char *opt;
+	char *start = NULL;
+	int ret;
+	
+	if (!options)
+		return 0;
+
+	opt = kstrdup(options, GFP_KERNEL);
+	if (!opt)
+		return 1;
+	
+	ret = 1;
+
+	start = opt;
+	while ((p = strsep(&opt, ",")) != NULL) {
+		int token;
+		if (!*p)
+			continue;
+
+		/*
+		 * Initialize args struct so we know whether arg was
+		 * found; some options take optional arguments.
+		 */
+		args[0].to = args[0].from = 0;
+		token = match_token(p, tokens, args);
+		switch (token) {
+		case 1:
+			if (!args[0].from)
+				break;
+
+			if (match_int(&args[0], &option))
+				break;
+
+			if (option < DCACHE_MIN_SIZE) {
+				printk(KERN_INFO "dcache size %d smaller than "
+				       "minimum (%d)\n", option, DCACHE_MIN_SIZE);
+				option = DCACHE_MIN_SIZE;
+			}
+
+			ops->vfs_dcache_size = option;
+
+			/*
+			 * The actual filesystems don't expect any option
+			 * they don't understand to be received in the option
+			 * string. So we strip off anything we processed, and
+			 * give them a clean options string.
+			 */
+			ret = 0;
+			if (!opt) /* it is the last option listed */
+				*(options + (p - start)) = '\0';
+			else
+				strcpy(options + (p - start), opt);
+			break;
+		default:
+			ret = 0;
+			break;
+		}
+	}
+
+	kfree(start);
+	return ret;
+}
+
 /*
  * Flags is a 32-bit value that allows up to 31 non-fs dependent flags to
  * be given to the mount() call (ie: read-only, no-dev, no-suid etc).
@@ -2291,6 +2383,7 @@ long do_mount(char *dev_name, char *dir_name, char *type_page,
 	struct path path;
 	int retval = 0;
 	int mnt_flags = 0;
+	struct vfs_options vfs_options;
 
 	/* Discard magic */
 	if ((flags & MS_MGC_MSK) == MS_MGC_VAL)
@@ -2318,6 +2411,12 @@ long do_mount(char *dev_name, char *dir_name, char *type_page,
 	if (!(flags & MS_NOATIME))
 		mnt_flags |= MNT_RELATIME;
 
+
+	vfs_options.vfs_dcache_size = INT_MAX;
+	retval = vfs_parse_options(data_page, &vfs_options);
+	if (retval)
+		goto dput_out;
+
 	/* Separate the per-mountpoint flags */
 	if (flags & MS_NOSUID)
 		mnt_flags |= MNT_NOSUID;
@@ -2350,6 +2449,12 @@ long do_mount(char *dev_name, char *dir_name, char *type_page,
 	else
 		retval = do_new_mount(&path, type_page, flags, mnt_flags,
 				      dev_name, data_page);
+
+	/* bind mounts get to respect their parents decision */
+	if (!retval && !(flags & MS_BIND))
+		vfs_set_dcache_size(path.mnt->mnt_sb,
+				    vfs_options.vfs_dcache_size);
+			
 dput_out:
 	path_put(&path);
 	return retval;
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index d37d2a7..1a309f3 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -251,6 +251,10 @@ extern int d_invalidate(struct dentry *);
 
 /* only used at mount-time */
 extern struct dentry * d_alloc_root(struct inode *);
+extern int vfs_set_dcache_size(struct super_block *sb, int size);
+
+#define DCACHE_MIN_SIZE 1024
+extern int vfs_set_dcache_size(struct super_block *sb, int size);
 
 /* <clickety>-<click> the ramfs-type tree */
 extern void d_genocide(struct dentry *);
-- 
1.7.6
