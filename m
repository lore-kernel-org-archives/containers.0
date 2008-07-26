From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/6] user namespaces: add user_ns to super block
Date: Fri, 25 Jul 2008 19:27:54 -0500
Message-ID: <20080726002754.GD29874@us.ibm.com>
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

From 420d6e81ce29d7a6fe3ab7b43c1171e105f8b697 Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 24 Jul 2008 18:00:54 -0500
Subject: [PATCH 4/6] user namespaces: add user_ns to super block

Add a user_ns to the super_block, and set it to the user_ns of
the process which mounted the fs.

In generic_permission() compare the current user_ns to that
of the user_ns which mounted the inode's filesystem.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/namei.c         |    6 ++++--
 fs/super.c         |    3 +++
 include/linux/fs.h |    5 +++++
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index d5336fd..adf5f1b 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -169,7 +169,6 @@ void putname(const char *name)
 EXPORT_SYMBOL(putname);
 #endif
 
-extern struct user_namespace init_user_ns;
 /**
  * generic_permission  -  check for access rights on a Posix-like filesystem
  * @inode:	inode to check access rights for
@@ -185,7 +184,10 @@ int generic_permission(struct inode *inode, int mask,
 		int (*check_acl)(struct inode *inode, int mask))
 {
 	umode_t			mode = inode->i_mode;
-	int same_userns = (current->user->user_ns == &init_user_ns);
+	int same_userns = 1;
+
+	if (current->user->user_ns != inode->i_sb->user_ns)
+		same_userns = 0;
 
 	/*
 	 * If we're not in the inode's user namespace, we get
diff --git a/fs/super.c b/fs/super.c
index 453877c..12865ac 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -39,6 +39,7 @@
 #include <linux/mutex.h>
 #include <linux/file.h>
 #include <asm/uaccess.h>
+#include <linux/user_namespace.h>
 #include "internal.h"
 
 
@@ -92,6 +93,7 @@ static struct super_block *alloc_super(struct file_system_type *type)
 		s->s_qcop = sb_quotactl_ops;
 		s->s_op = &default_op;
 		s->s_time_gran = 1000000000;
+		s->user_ns = get_user_ns(current->user->user_ns);
 	}
 out:
 	return s;
@@ -108,6 +110,7 @@ static inline void destroy_super(struct super_block *s)
 	security_sb_free(s);
 	kfree(s->s_subtype);
 	kfree(s->s_options);
+	put_user_ns(s->user_ns);
 	kfree(s);
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9c2ac5c..68066a4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1092,6 +1092,11 @@ struct super_block {
 	 * generic_show_options()
 	 */
 	char *s_options;
+
+	/*
+	 * namespace of the user which mounted the sb
+	 */
+	struct user_namespace *user_ns;
 };
 
 extern struct timespec current_fs_time(struct super_block *sb);
-- 
1.5.4.3
