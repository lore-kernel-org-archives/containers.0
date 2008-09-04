From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 4/11][v3]: Simplify devpts_pty_new()
Date: Wed, 3 Sep 2008 22:32:00 -0700
Message-ID: <20080904053200.GE3680@us.ibm.com>
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
Subject: [PATCH 4/11]: Simplify devpts_pty_new()

devpts_pty_new() is called when setting up a new pty and would not
have an existing dentry or inode for the pty. So don't bother looking
for an existing dentry - just create a new one.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---
 fs/devpts/inode.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

Index: linux-2.6.27-rc3-tty/fs/devpts/inode.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/fs/devpts/inode.c	2008-08-28 18:01:11.000000000 -0700
+++ linux-2.6.27-rc3-tty/fs/devpts/inode.c	2008-08-28 18:46:55.000000000 -0700
@@ -220,6 +220,7 @@ int devpts_pty_new(struct inode *ptmx_in
 	dev_t device = MKDEV(driver->major, driver->minor_start+number);
 	struct dentry *dentry;
 	struct inode *inode = new_inode(devpts_mnt->mnt_sb);
+	char s[12];
 
 	/* We're supposed to be given the slave end of a pty */
 	BUG_ON(driver->type != TTY_DRIVER_TYPE_PTY);
@@ -235,9 +236,13 @@ int devpts_pty_new(struct inode *ptmx_in
 	init_special_inode(inode, S_IFCHR|config.mode, device);
 	inode->i_private = tty;
 
-	dentry = get_node(number);
-	if (!IS_ERR(dentry) && !dentry->d_inode) {
-		d_instantiate(dentry, inode);
+	sprintf(s, "%d", number);
+
+	mutex_lock(&devpts_root->d_inode->i_mutex);
+
+	dentry = d_alloc_name(devpts_root, s);
+	if (!IS_ERR(dentry)) {
+		d_add(dentry, inode);
 		fsnotify_create(devpts_root->d_inode, dentry);
 	}
