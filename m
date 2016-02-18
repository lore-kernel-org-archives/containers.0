From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: [Patch 2/2] binfmt_misc: add persistently opened binary handler for
	containers
Date: Wed, 17 Feb 2016 17:05:25 -0800
Message-ID: <1455757525.7664.11.camel__7811.14844508028$1455757542$gmane$org@HansenPartnership.com>
References: <1455757372.7664.7.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1455757372.7664.7.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds a new flag 'F' to the binfmt handlers.  If you pass in
'F' the binary that runs the emulation will be opened immediately and
in future, will be cloned from the open file.

The net effect is that the handler survives both changeroots and mount
namespace changes, making it easy to work with foreign architecture
containers without contaminating the container image with the
emulator.

Signed-off-by: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
---
 fs/binfmt_misc.c | 42 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 40 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_misc.c b/fs/binfmt_misc.c
index 3a3ced7..c61ade2 100644
--- a/fs/binfmt_misc.c
+++ b/fs/binfmt_misc.c
@@ -26,6 +26,8 @@
 #include <linux/fs.h>
 #include <linux/uaccess.h>
 
+#include "internal.h"
+
 #ifdef DEBUG
 # define USE_DEBUG 1
 #else
@@ -43,6 +45,7 @@ enum {Enabled, Magic};
 #define MISC_FMT_PRESERVE_ARGV0 (1 << 31)
 #define MISC_FMT_OPEN_BINARY (1 << 30)
 #define MISC_FMT_CREDENTIALS (1 << 29)
+#define MISC_FMT_OPEN_FILE (1 << 28)
 
 typedef struct {
 	struct list_head list;
@@ -54,6 +57,7 @@ typedef struct {
 	char *interpreter;		/* filename of interpreter */
 	char *name;
 	struct dentry *dentry;
+	struct file *interp_file;
 } Node;
 
 static DEFINE_RWLOCK(entries_lock);
@@ -201,7 +205,13 @@ static int load_misc_binary(struct linux_binprm *bprm)
 	if (retval < 0)
 		goto error;
 
-	interp_file = open_exec(iname);
+	if (fmt->flags & MISC_FMT_OPEN_FILE && fmt->interp_file) {
+		interp_file = filp_clone_open(fmt->interp_file);
+		if (!IS_ERR(interp_file))
+			deny_write_access(interp_file);
+	} else {
+		interp_file = open_exec(iname);
+	}
 	retval = PTR_ERR(interp_file);
 	if (IS_ERR(interp_file))
 		goto error;
@@ -285,6 +295,11 @@ static char *check_special_flags(char *sfs, Node *e)
 			e->flags |= (MISC_FMT_CREDENTIALS |
 					MISC_FMT_OPEN_BINARY);
 			break;
+		case 'F':
+			pr_debug("register: flag: F: open interpreter file now\n");
+			p++;
+			e->flags |= MISC_FMT_OPEN_FILE;
+			break;
 		default:
 			cont = 0;
 		}
@@ -543,6 +558,8 @@ static void entry_status(Node *e, char *page)
 		*dp++ = 'O';
 	if (e->flags & MISC_FMT_CREDENTIALS)
 		*dp++ = 'C';
+	if (e->flags & MISC_FMT_OPEN_FILE)
+		*dp++ = 'F';
 	*dp++ = '\n';
 
 	if (!test_bit(Magic, &e->flags)) {
@@ -590,6 +607,12 @@ static void kill_node(Node *e)
 	}
 	write_unlock(&entries_lock);
 
+	if ((e->flags & MISC_FMT_OPEN_FILE) && e->interp_file) {
+		filp_close(e->interp_file, NULL);
+		fput(e->interp_file);
+		e->interp_file = NULL;
+	}
+
 	if (dentry) {
 		drop_nlink(d_inode(dentry));
 		d_drop(dentry);
@@ -698,6 +721,21 @@ static ssize_t bm_register_write(struct file *file, const char __user *buffer,
 		goto out2;
 	}
 
+	if (e->flags & MISC_FMT_OPEN_FILE) {
+		struct file *f;
+
+		f = open_exec(e->interpreter);
+		if (IS_ERR(f)) {
+			err = PTR_ERR(f);
+			pr_notice("register: failed to install interpreter file %s\n", e->interpreter);
+			simple_release_fs(&bm_mnt, &entry_count);
+			iput(inode);
+			inode = NULL;
+			goto out2;
+		}
+		e->interp_file = f;
+	}
+
 	e->dentry = dget(dentry);
 	inode->i_private = e;
 	inode->i_fop = &bm_entry_operations;
@@ -716,7 +754,7 @@ out:
 
 	if (err) {
 		kfree(e);
-		return -EINVAL;
+		return err;
 	}
 	return count;
 }
-- 
2.6.2
