From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 3/11][v3]: Simplify devpts_get_tty()
Date: Wed, 3 Sep 2008 22:31:32 -0700
Message-ID: <20080904053132.GD3680@us.ibm.com>
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
Subject: [PATCH 3/11]: Simplify devpts_get_tty()

As pointed out by H. Peter Anvin, since the inode for the pty is known,
we don't need to look it up.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---
 fs/devpts/inode.c |   17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

Index: linux-2.6.27-rc3-tty/fs/devpts/inode.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/fs/devpts/inode.c	2008-08-28 17:59:15.000000000 -0700
+++ linux-2.6.27-rc3-tty/fs/devpts/inode.c	2008-08-28 18:01:11.000000000 -0700
@@ -27,6 +27,7 @@
 #define DEVPTS_SUPER_MAGIC 0x1cd1
 
 #define DEVPTS_DEFAULT_MODE 0600
+#define PTMX_MINOR	2
 
 extern int pty_limit;			/* Config limit on Unix98 ptys */
 static DEFINE_IDA(allocated_ptys);
@@ -247,19 +248,11 @@ int devpts_pty_new(struct inode *ptmx_in
 
 struct tty_struct *devpts_get_tty(struct inode *pts_inode, int number)
 {
-	struct dentry *dentry = get_node(number);
-	struct tty_struct *tty;
-
-	tty = NULL;
-	if (!IS_ERR(dentry)) {
-		if (dentry->d_inode)
-			tty = dentry->d_inode->i_private;
-		dput(dentry);
-	}
-
-	mutex_unlock(&devpts_root->d_inode->i_mutex);
+	BUG_ON(pts_inode->i_rdev == MKDEV(TTYAUX_MAJOR, PTMX_MINOR));
 
-	return tty;
+	if (pts_inode->i_sb->s_magic == DEVPTS_SUPER_MAGIC)
+		return (struct tty_struct *)pts_inode->i_private;
+	return NULL;
 }
 
 void devpts_pty_kill(struct tty_struct *tty)
