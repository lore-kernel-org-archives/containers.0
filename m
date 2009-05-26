From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 1/8] cr: break out new_user_ns()
Date: Tue, 26 May 2009 12:33:01 -0500
Message-ID: <20090526173301.GA13991@us.ibm.com>
References: <20090526173242.GA13757@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090526173242.GA13757@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Break out the core function which checks privilege and (if
allowed) creates a new user namespace, with the passed-in
creating user_struct.  Note that a user_namespace, unlike
other namespace pointers, is not stored in the nsproxy.
Rather it is purely a property of user_structs.

This will let us keep the task restore code simpler.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/user_namespace.h |    8 ++++++
 kernel/user_namespace.c        |   53 ++++++++++++++++++++++++++++------------
 2 files changed, 45 insertions(+), 16 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index cc4f453..a2b82d5 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -20,6 +20,8 @@ extern struct user_namespace init_user_ns;
 
 #ifdef CONFIG_USER_NS
 
+struct user_namespace *new_user_ns(struct user_struct *creator,
+				   struct user_struct **newroot);
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 {
 	if (ns)
@@ -38,6 +40,12 @@ static inline void put_user_ns(struct user_namespace *ns)
 
 #else
 
+static inline struct user_namespace *new_user_ns(struct user_struct *creator,
+				   struct user_struct **newroot)
+{
+	return -EINVAL;
+}
+
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 {
 	return &init_user_ns;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 076c7c8..e624b0f 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -11,15 +11,8 @@
 #include <linux/user_namespace.h>
 #include <linux/cred.h>
 
-/*
- * Create a new user namespace, deriving the creator from the user in the
- * passed credentials, and replacing that user with the new root user for the
- * new namespace.
- *
- * This is called by copy_creds(), which will finish setting the target task's
- * credentials.
- */
-int create_user_ns(struct cred *new)
+static struct user_namespace *_new_user_ns(struct user_struct *creator,
+				   struct user_struct **newroot)
 {
 	struct user_namespace *ns;
 	struct user_struct *root_user;
@@ -27,7 +20,7 @@ int create_user_ns(struct cred *new)
 
 	ns = kmalloc(sizeof(struct user_namespace), GFP_KERNEL);
 	if (!ns)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 
 	kref_init(&ns->kref);
 
@@ -38,12 +31,43 @@ int create_user_ns(struct cred *new)
 	root_user = alloc_uid(ns, 0);
 	if (!root_user) {
 		kfree(ns);
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 	}
 
 	/* set the new root user in the credentials under preparation */
-	ns->creator = new->user;
-	new->user = root_user;
+	ns->creator = creator;
+
+	/* alloc_uid() incremented the userns refcount.  Just set it to 1 */
+	kref_set(&ns->kref, 1);
+
+	*newroot = root_user;
+	return ns;
+}
+
+struct user_namespace *new_user_ns(struct user_struct *creator,
+				   struct user_struct **newroot)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return ERR_PTR(-EPERM);
+	return _new_user_ns(creator, newroot);
+}
+
+/*
+ * Create a new user namespace, deriving the creator from the user in the
+ * passed credentials, and replacing that user with the new root user for the
+ * new namespace.
+ *
+ * This is called by copy_creds(), which will finish setting the target task's
+ * credentials.
+ */
+int create_user_ns(struct cred *new)
+{
+	struct user_namespace *ns;
+
+	ns = new_user_ns(new->user, &new->user);
+	if (IS_ERR(ns))
+		return PTR_ERR(ns);
+
 	new->uid = new->euid = new->suid = new->fsuid = 0;
 	new->gid = new->egid = new->sgid = new->fsgid = 0;
 	put_group_info(new->group_info);
@@ -54,9 +78,6 @@ int create_user_ns(struct cred *new)
 #endif
 	/* tgcred will be cleared in our caller bc CLONE_THREAD won't be set */
 
-	/* alloc_uid() incremented the userns refcount.  Just set it to 1 */
-	kref_set(&ns->kref, 1);
-
 	return 0;
 }
 
-- 
1.6.1

