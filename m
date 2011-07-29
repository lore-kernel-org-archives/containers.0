From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 4/4] parse options in the vfs level
Date: Fri, 29 Jul 2011 17:44:19 +0400
Message-ID: <1311947059-17209-5-git-send-email-glommer__14882.5361080982$1311947206$gmane$org@parallels.com>
References: <1311947059-17209-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1311947059-17209-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
 fs/namespace.c |   89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 89 insertions(+), 0 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 22bfe82..11ce45d 100644
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
@@ -2271,6 +2272,82 @@ int copy_mount_string(const void __user *data, char **where)
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
+	unsigned int option;
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
+			else
+				ops->vfs_dcache_size = option;
+
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
@@ -2291,6 +2368,7 @@ long do_mount(char *dev_name, char *dir_name, char *type_page,
 	struct path path;
 	int retval = 0;
 	int mnt_flags = 0;
+	struct vfs_options vfs_options;
 
 	/* Discard magic */
 	if ((flags & MS_MGC_MSK) == MS_MGC_VAL)
@@ -2318,6 +2396,12 @@ long do_mount(char *dev_name, char *dir_name, char *type_page,
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
@@ -2350,6 +2434,11 @@ long do_mount(char *dev_name, char *dir_name, char *type_page,
 	else
 		retval = do_new_mount(&path, type_page, flags, mnt_flags,
 				      dev_name, data_page);
+
+	if (!retval)
+		vfs_set_dcache_size(path.mnt->mnt_sb,
+				    vfs_options.vfs_dcache_size);
+			
 dput_out:
 	path_put(&path);
 	return retval;
-- 
1.7.6
