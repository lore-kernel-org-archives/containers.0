From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 5/11][v3]: Simplify devpts_pty_kill
Date: Wed, 3 Sep 2008 22:32:38 -0700
Message-ID: <20080904053238.GF3680@us.ibm.com>
References: <20080904052718.GA3680@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080904052718.GA3680-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 5/11]: Simplify devpts_pty_kill

When creating a new pty, save the pty's inode in the tty->driver_data.
Use this inode in pty_kill() to identify the devpts instance. Since
we now have the inode for the pty, we can skip get_node() lookup and
remove the unused get_node().

TODO: 
	- check if the mutex_lock is needed in pty_kill().

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---
 fs/devpts/inode.c |   29 ++++++++++++-----------------
 1 file changed, 12 insertions(+), 17 deletions(-)

Index: linux-2.6.27-rc3-tty/fs/devpts/inode.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/fs/devpts/inode.c	2008-08-28 18:46:55.000000000 -0700
+++ linux-2.6.27-rc3-tty/fs/devpts/inode.c	2008-08-28 23:27:20.000000000 -0700
@@ -170,14 +170,6 @@ static struct file_system_type devpts_fs
  * to the System V naming convention
  */
 
-static struct dentry *get_node(int num)
-{
-	char s[12];
-	struct dentry *root = devpts_root;
-	mutex_lock(&root->d_inode->i_mutex);
-	return lookup_one_len(s, root, sprintf(s, "%d", num));
-}
-
 int devpts_new_index(struct inode *ptmx_inode)
 {
 	int index;
@@ -235,6 +227,7 @@ int devpts_pty_new(struct inode *ptmx_in
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
 	init_special_inode(inode, S_IFCHR|config.mode, device);
 	inode->i_private = tty;
+	tty->driver_data = inode;
 
 	sprintf(s, "%d", number);
 
@@ -262,18 +255,20 @@ struct tty_struct *devpts_get_tty(struct
 
 void devpts_pty_kill(struct tty_struct *tty)
 {
-	int number = tty->index;
-	struct dentry *dentry = get_node(number);
+	struct inode *inode = tty->driver_data;
+	struct dentry *dentry;
 
-	if (!IS_ERR(dentry)) {
-		struct inode *inode = dentry->d_inode;
-		if (inode) {
-			inode->i_nlink--;
-			d_delete(dentry);
-			dput(dentry);
-		}
+	BUG_ON(inode->i_rdev == MKDEV(TTYAUX_MAJOR, PTMX_MINOR));
+
+	mutex_lock(&devpts_root->d_inode->i_mutex);
+
+	dentry = d_find_alias(inode);
+	if (dentry && !IS_ERR(dentry)) {
+		inode->i_nlink--;
+		d_delete(dentry);
 		dput(dentry);
 	}
+
 	mutex_unlock(&devpts_root->d_inode->i_mutex);
 }
