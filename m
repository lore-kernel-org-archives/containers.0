From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V7 02/10] nsfs: switch to dedicated inode pool
Date: Tue, 12 May 2015 16:02:39 -0400
Message-ID: <c1f994224f850483c563903af1219575e7e08785.1431451547.git.rgb__15992.095883894$1431461030$gmane$org@redhat.com>
References: <cover.1431451547.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1431451547.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1431451547.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1431451547.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Instead of borrowing proc's inode pool and starting at a custom offset, give
nsfs its own dedicated inode pool without an offset.

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 fs/nsfs.c               |   44 ++++++++++++++++++++++++++++++++++++++++++++
 fs/proc/internal.h      |    2 ++
 include/linux/proc_ns.h |   20 ++++++++------------
 init/version.c          |    2 +-
 ipc/msgutil.c           |    2 +-
 kernel/pid.c            |    2 +-
 kernel/user.c           |    2 +-
 7 files changed, 58 insertions(+), 16 deletions(-)

diff --git a/fs/nsfs.c b/fs/nsfs.c
index af1b24f..1fcd529 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -159,3 +159,47 @@ void __init nsfs_init(void)
 		panic("can't set nsfs up\n");
 	nsfs_mnt->mnt_sb->s_flags &= ~MS_NOUSER;
 }
+
+static DEFINE_IDA(ns_inum_ida);
+static DEFINE_SPINLOCK(ns_inum_lock); /* protects the above */
+
+/*
+ * Return an inode number between PROC_DYNAMIC_FIRST and
+ * 0xffffffff, or zero on failure.
+ */
+int ns_alloc_inum(struct ns_common *ns)
+{
+	unsigned int i;
+	int error;
+
+	atomic_long_set(&ns->stashed, 0);
+retry:
+	if (!ida_pre_get(&ns_inum_ida, GFP_KERNEL))
+		return -ENOMEM;
+
+	spin_lock_irq(&ns_inum_lock);
+	error = ida_get_new(&ns_inum_ida, &i);
+	spin_unlock_irq(&ns_inum_lock);
+	if (error == -EAGAIN)
+		goto retry;
+	else if (error)
+		return error;
+
+	if (i > UINT_MAX) {
+		spin_lock_irq(&ns_inum_lock);
+		ida_remove(&ns_inum_ida, i);
+		spin_unlock_irq(&ns_inum_lock);
+		return -ENOSPC;
+	}
+	ns->inum = NS_DYNAMIC_FIRST + i;
+	return 0;
+}
+
+void ns_free_inum(struct ns_common *ns)
+{
+	unsigned long flags;
+	spin_lock_irqsave(&ns_inum_lock, flags);
+	ida_remove(&ns_inum_ida, ns->inum - NS_DYNAMIC_FIRST);
+	spin_unlock_irqrestore(&ns_inum_lock, flags);
+}
+
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index c835b94..8f89cbb 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -18,6 +18,8 @@
 struct ctl_table_header;
 struct mempolicy;
 
+#define PROC_ROOT_INO 1
+
 /*
  * This is not completely implemented yet. The idea is to
  * create an in-memory tree (like the actual /proc filesystem
diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
index 2654550..721d0e2 100644
--- a/include/linux/proc_ns.h
+++ b/include/linux/proc_ns.h
@@ -30,11 +30,12 @@ extern const struct proc_ns_operations *ns_entries[];
  * We always define these enumerators
  */
 enum {
-	PROC_ROOT_INO		= 1,
-	PROC_IPC_INIT_INO	= 0xEFFFFFFFU,
-	PROC_UTS_INIT_INO	= 0xEFFFFFFEU,
-	PROC_USER_INIT_INO	= 0xEFFFFFFDU,
-	PROC_PID_INIT_INO	= 0xEFFFFFFCU,
+	NS_NULL_INIT_INO,
+	NS_IPC_INIT_INO,
+	NS_UTS_INIT_INO,
+	NS_USER_INIT_INO,
+	NS_PID_INIT_INO,
+	NS_DYNAMIC_FIRST,
 };
 
 #ifdef CONFIG_PROC_FS
@@ -58,13 +59,8 @@ static inline void proc_free_inum(unsigned int inum) {}
 
 #endif /* CONFIG_PROC_FS */
 
-static inline int ns_alloc_inum(struct ns_common *ns)
-{
-	atomic_long_set(&ns->stashed, 0);
-	return proc_alloc_inum(&ns->inum);
-}
-
-#define ns_free_inum(ns) proc_free_inum((ns)->inum)
+extern int ns_alloc_inum(struct ns_common *ns);
+extern void ns_free_inum(struct ns_common *ns);
 
 extern struct file *proc_ns_fget(int fd);
 #define get_proc_ns(inode) ((struct ns_common *)(inode)->i_private)
diff --git a/init/version.c b/init/version.c
index fe41a63..050dda0 100644
--- a/init/version.c
+++ b/init/version.c
@@ -35,7 +35,7 @@ struct uts_namespace init_uts_ns = {
 		.domainname	= UTS_DOMAINNAME,
 	},
 	.user_ns = &init_user_ns,
-	.ns.inum = PROC_UTS_INIT_INO,
+	.ns.inum = NS_UTS_INIT_INO,
 #ifdef CONFIG_UTS_NS
 	.ns.ops = &utsns_operations,
 #endif
diff --git a/ipc/msgutil.c b/ipc/msgutil.c
index 2b49159..aca24bb 100644
--- a/ipc/msgutil.c
+++ b/ipc/msgutil.c
@@ -31,7 +31,7 @@ DEFINE_SPINLOCK(mq_lock);
 struct ipc_namespace init_ipc_ns = {
 	.count		= ATOMIC_INIT(1),
 	.user_ns = &init_user_ns,
-	.ns.inum = PROC_IPC_INIT_INO,
+	.ns.inum = NS_IPC_INIT_INO,
 #ifdef CONFIG_IPC_NS
 	.ns.ops = &ipcns_operations,
 #endif
diff --git a/kernel/pid.c b/kernel/pid.c
index cd36a5e..a06abc2 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -79,7 +79,7 @@ struct pid_namespace init_pid_ns = {
 	.level = 0,
 	.child_reaper = &init_task,
 	.user_ns = &init_user_ns,
-	.ns.inum = PROC_PID_INIT_INO,
+	.ns.inum = NS_PID_INIT_INO,
 #ifdef CONFIG_PID_NS
 	.ns.ops = &pidns_operations,
 #endif
diff --git a/kernel/user.c b/kernel/user.c
index b069ccb..deaf107 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -50,7 +50,7 @@ struct user_namespace init_user_ns = {
 	.count = ATOMIC_INIT(3),
 	.owner = GLOBAL_ROOT_UID,
 	.group = GLOBAL_ROOT_GID,
-	.ns.inum = PROC_USER_INIT_INO,
+	.ns.inum = NS_USER_INIT_INO,
 #ifdef CONFIG_USER_NS
 	.ns.ops = &userns_operations,
 #endif
-- 
1.7.1
