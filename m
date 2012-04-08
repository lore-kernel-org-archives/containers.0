From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 12/43] userns: Replace the hard to write inode_userns with
	inode_capable.
Date: Sat,  7 Apr 2012 22:15:08 -0700
Message-ID: <1333862139-31737-12-git-send-email-ebiederm@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

This represents a change in strategy of how to handle user namespaces.
Instead of tagging everything explicitly with a user namespace and bulking
up all of the comparisons of uids and gids in the kernel,  all uids and gids
in use will have a mapping to a flat kuid and kgid spaces respectively.  This
allows much more of the existing logic to be preserved and in general
allows for faster code.

In this new and improved world we allow someone to utiliize capabilities
over an inode if the inodes owner mapps into the capabilities holders user
namespace and the user has capabilities in their user namespace.  Which
is simple and efficient.

Moving the fs uid comparisons to be comparisons in a flat kuid space
follows in later patches, something that is only significant if you
are using user namespaces.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/inode.c                 |    6 ++----
 fs/namei.c                 |   18 +++++-------------
 include/linux/capability.h |    2 ++
 include/linux/fs.h         |    6 ------
 kernel/capability.c        |   19 +++++++++++++++++++
 5 files changed, 28 insertions(+), 23 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 9f4f5fe..f0c4ace 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1732,11 +1732,9 @@ EXPORT_SYMBOL(inode_init_owner);
  */
 bool inode_owner_or_capable(const struct inode *inode)
 {
-	struct user_namespace *ns = inode_userns(inode);
-
-	if (current_user_ns() == ns && current_fsuid() == inode->i_uid)
+	if (current_fsuid() == inode->i_uid)
 		return true;
-	if (ns_capable(ns, CAP_FOWNER))
+	if (inode_capable(inode, CAP_FOWNER))
 		return true;
 	return false;
 }
diff --git a/fs/namei.c b/fs/namei.c
index 701954d..941c436 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -228,9 +228,6 @@ static int acl_permission_check(struct inode *inode, int mask)
 {
 	unsigned int mode = inode->i_mode;
 
-	if (current_user_ns() != inode_userns(inode))
-		goto other_perms;
-
 	if (likely(current_fsuid() == inode->i_uid))
 		mode >>= 6;
 	else {
@@ -244,7 +241,6 @@ static int acl_permission_check(struct inode *inode, int mask)
 			mode >>= 3;
 	}
 
-other_perms:
 	/*
 	 * If the DACs are ok we don't need any capability check.
 	 */
@@ -280,10 +276,10 @@ int generic_permission(struct inode *inode, int mask)
 
 	if (S_ISDIR(inode->i_mode)) {
 		/* DACs are overridable for directories */
-		if (ns_capable(inode_userns(inode), CAP_DAC_OVERRIDE))
+		if (inode_capable(inode, CAP_DAC_OVERRIDE))
 			return 0;
 		if (!(mask & MAY_WRITE))
-			if (ns_capable(inode_userns(inode), CAP_DAC_READ_SEARCH))
+			if (inode_capable(inode, CAP_DAC_READ_SEARCH))
 				return 0;
 		return -EACCES;
 	}
@@ -293,7 +289,7 @@ int generic_permission(struct inode *inode, int mask)
 	 * at least one exec bit set.
 	 */
 	if (!(mask & MAY_EXEC) || (inode->i_mode & S_IXUGO))
-		if (ns_capable(inode_userns(inode), CAP_DAC_OVERRIDE))
+		if (inode_capable(inode, CAP_DAC_OVERRIDE))
 			return 0;
 
 	/*
@@ -301,7 +297,7 @@ int generic_permission(struct inode *inode, int mask)
 	 */
 	mask &= MAY_READ | MAY_WRITE | MAY_EXEC;
 	if (mask == MAY_READ)
-		if (ns_capable(inode_userns(inode), CAP_DAC_READ_SEARCH))
+		if (inode_capable(inode, CAP_DAC_READ_SEARCH))
 			return 0;
 
 	return -EACCES;
@@ -1964,15 +1960,11 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
 
 	if (!(dir->i_mode & S_ISVTX))
 		return 0;
-	if (current_user_ns() != inode_userns(inode))
-		goto other_userns;
 	if (inode->i_uid == fsuid)
 		return 0;
 	if (dir->i_uid == fsuid)
 		return 0;
-
-other_userns:
-	return !ns_capable(inode_userns(inode), CAP_FOWNER);
+	return !inode_capable(inode, CAP_FOWNER);
 }
 
 /*
diff --git a/include/linux/capability.h b/include/linux/capability.h
index 12d52de..a76eca9 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -374,6 +374,7 @@ struct cpu_vfs_cap_data {
 
 #ifdef __KERNEL__
 
+struct inode;
 struct dentry;
 struct user_namespace;
 
@@ -548,6 +549,7 @@ extern bool has_ns_capability_noaudit(struct task_struct *t,
 extern bool capable(int cap);
 extern bool ns_capable(struct user_namespace *ns, int cap);
 extern bool nsown_capable(int cap);
+extern bool inode_capable(const struct inode *inode, int cap);
 
 /* audit system wants to get cap info from files as well */
 extern int get_vfs_caps_from_disk(const struct dentry *dentry, struct cpu_vfs_cap_data *cpu_caps);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 135693e..a6c5efb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1522,12 +1522,6 @@ enum {
 #define vfs_check_frozen(sb, level) \
 	wait_event((sb)->s_wait_unfrozen, ((sb)->s_frozen < (level)))
 
-/*
- * until VFS tracks user namespaces for inodes, just make all files
- * belong to init_user_ns
- */
-extern struct user_namespace init_user_ns;
-#define inode_userns(inode) (&init_user_ns)
 extern bool inode_owner_or_capable(const struct inode *inode);
 
 /* not quite ready to be deprecated, but... */
diff --git a/kernel/capability.c b/kernel/capability.c
index 3f1adb6..cc5f071 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -419,3 +419,22 @@ bool nsown_capable(int cap)
 {
 	return ns_capable(current_user_ns(), cap);
 }
+
+/**
+ * inode_capable - Check superior capability over inode
+ * @inode: The inode in question
+ * @cap: The capability in question
+ *
+ * Return true if the current task has the given superior capability
+ * targeted at it's own user namespace and that the given inode is owned
+ * by the current user namespace or a child namespace.
+ *
+ * Currently inodes can only be owned by the initial user namespace.
+ *
+ */
+bool inode_capable(const struct inode *inode, int cap)
+{
+	struct user_namespace *ns = current_user_ns();
+
+	return ns_capable(ns, cap) && (ns == &init_user_ns);
+}
-- 
1.7.2.5
