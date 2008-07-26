From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/6] user namespaces: rig generic_permission for simple
	userns check
Date: Fri, 25 Jul 2008 19:27:42 -0500
Message-ID: <20080726002742.GC29874@us.ibm.com>
References: <20080726002700.GA29686@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080726002700.GA29686-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

From f6d09b06a1106936010bffd420267f5b7ee66238 Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Wed, 23 Jul 2008 17:01:09 -0500
Subject: [PATCH 3/6] user namespaces: rig generic_permission for simple userns check

Filesystems can provide their own permission() functions to do
advanced inter-user_namespace userid equivalence checks.

For those filesystems which do not support that, we will do
a simple check that current's user namespace is equivalent to
the user_namespace which mounted the filesystem.  If it is
not equivalent, then the task can only have user nobody (that
is, the 'other') permissions to a file.

For now, we actually just compare the user's user_ns to the
init_user_ns.  Next we will set the sb->user_ns to that of
the task mounting a filesystem, and use inode->i_sb->user_ns
instead of init_user_ns.  By punting even on that, the
implications, and therefore (in)correctness of this patch should
be all the easier to verify.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/namei.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 01e67dd..d5336fd 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -31,6 +31,7 @@
 #include <linux/file.h>
 #include <linux/fcntl.h>
 #include <linux/device_cgroup.h>
+#include <linux/nsproxy.h>
 #include <asm/namei.h>
 #include <asm/uaccess.h>
 
@@ -168,7 +169,7 @@ void putname(const char *name)
 EXPORT_SYMBOL(putname);
 #endif
 
-
+extern struct user_namespace init_user_ns;
 /**
  * generic_permission  -  check for access rights on a Posix-like filesystem
  * @inode:	inode to check access rights for
@@ -184,7 +185,15 @@ int generic_permission(struct inode *inode, int mask,
 		int (*check_acl)(struct inode *inode, int mask))
 {
 	umode_t			mode = inode->i_mode;
+	int same_userns = (current->user->user_ns == &init_user_ns);
 
+	/*
+	 * If we're not in the inode's user namespace, we get
+	 * user nobody permissions, and we ignore acls
+	 * (bc serge doesn't know how to handle acls in this case)
+	 */
+	if (!same_userns)
+		goto check;
 	if (current->fsuid == inode->i_uid)
 		mode >>= 6;
 	else {
@@ -200,11 +209,14 @@ int generic_permission(struct inode *inode, int mask,
 			mode >>= 3;
 	}
 
+check:
 	/*
 	 * If the DACs are ok we don't need any capability check.
 	 */
 	if (((mode & mask & (MAY_READ|MAY_WRITE|MAY_EXEC)) == mask))
 		return 0;
+	if (!same_userns)
+		return -EACCES;
 
  check_capabilities:
 	/*
-- 
1.5.4.3
