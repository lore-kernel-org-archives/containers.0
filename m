From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH] lost content of /proc/sys/fs/binfmt_misc
Date: Wed, 5 Dec 2007 17:35:18 +0300
Message-ID: <20071205143518.GA24886@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcus-sJr3legBufCzQB+pC5nmwQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

/proc/sys/fs/binfmt_misc dentry disappeared during d_revalidate.
d_revalidate only dentries from shadowed one and below.
http://bugzilla.kernel.org/show_bug.cgi?id=9504

CC: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
CC: Marcus Better <marcus-sJr3legBufCzQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 5fccfe2..1497ac4 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -380,12 +380,17 @@ static int proc_revalidate_dentry(struct dentry *dentry, struct nameidata *nd)
 	return 0;
 }
 
-static struct dentry_operations proc_dentry_operations =
+static struct dentry_operations proc_dentry_shadow_operations =
 {
 	.d_delete	= proc_delete_dentry,
 	.d_revalidate	= proc_revalidate_dentry,
 };
 
+static struct dentry_operations proc_dentry_operations =
+{
+	.d_delete	= proc_delete_dentry,
+};
+
 /*
  * Don't create negative dentries here, return -ENOENT by hand
  * instead.
@@ -394,6 +399,7 @@ struct dentry *proc_lookup(struct inode * dir, struct dentry *dentry, struct nam
 {
 	struct inode *inode = NULL;
 	struct proc_dir_entry * de;
+	int use_shadow = 0;
 	int error = -ENOENT;
 
 	lock_kernel();
@@ -406,8 +412,10 @@ struct dentry *proc_lookup(struct inode * dir, struct dentry *dentry, struct nam
 			if (!memcmp(dentry->d_name.name, de->name, de->namelen)) {
 				unsigned int ino;
 
-				if (de->shadow_proc)
+				if (de->shadow_proc) {
 					de = de->shadow_proc(current, de);
+					use_shadow = 1;
+				}
 				ino = de->low_ino;
 				de_get(de);
 				spin_unlock(&proc_subdir_lock);
@@ -423,6 +431,8 @@ struct dentry *proc_lookup(struct inode * dir, struct dentry *dentry, struct nam
 
 	if (inode) {
 		dentry->d_op = &proc_dentry_operations;
+		dentry->d_op = use_shadow ?
+			&proc_dentry_shadow_operations : dentry->d_parent->d_op;
 		d_add(dentry, inode);
 		return NULL;
 	}
