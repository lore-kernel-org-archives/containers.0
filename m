From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V7 06/10] audit: log creation and deletion of namespace
	instances
Date: Tue, 12 May 2015 16:02:43 -0400
Message-ID: <02c6575184deb854ea02ae800cb93be3172e29c2.1431451547.git.rgb@redhat.com>
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

Log the creation and deletion of namespace instances in all 6 types of
namespaces.

Twelve new audit message types have been introduced:
AUDIT_NS_INIT_MNT       1330    /* Record mount namespace instance creation */
AUDIT_NS_INIT_UTS       1331    /* Record UTS namespace instance creation */
AUDIT_NS_INIT_IPC       1332    /* Record IPC namespace instance creation */
AUDIT_NS_INIT_USER      1333    /* Record USER namespace instance creation */
AUDIT_NS_INIT_PID       1334    /* Record PID namespace instance creation */
AUDIT_NS_INIT_NET       1335    /* Record NET namespace instance creation */
AUDIT_NS_DEL_MNT        1336    /* Record mount namespace instance deletion */
AUDIT_NS_DEL_UTS        1337    /* Record UTS namespace instance deletion */
AUDIT_NS_DEL_IPC        1338    /* Record IPC namespace instance deletion */
AUDIT_NS_DEL_USER       1339    /* Record USER namespace instance deletion */
AUDIT_NS_DEL_PID        1340    /* Record PID namespace instance deletion */
AUDIT_NS_DEL_NET        1341    /* Record NET namespace instance deletion */

As suggested by Eric Paris, there are 12 message types, one for each of
creation and deletion, one for each type of namespace so that text searches are
easier in conjunction with the AUDIT_NS_INFO message type, being able to search
for all records such as "netns=7 " and to avoid fields disappearing per message
type to make ausearch more efficient.

A typical startup would look roughly like:

	type=AUDIT_NS_INIT_UTS msg=audit(1408577534.868:5): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_utsns=(none) utsns=2 res=1
	type=AUDIT_NS_INIT_USER msg=audit(1408577534.868:6): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_userns=(none) userns=3 res=1
	type=AUDIT_NS_INIT_PID msg=audit(1408577534.868:7): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_pidns=(none) pidns=4 res=1
	type=AUDIT_NS_INIT_MNT msg=audit(1408577534.868:8): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_mntns=(none) mntns=5 res=1
	type=AUDIT_NS_INIT_IPC msg=audit(1408577534.868:9): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_ipcns=(none) ipcns=1 res=1
	type=AUDIT_NS_INIT_NET msg=audit(1408577533.500:10): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_netns=(none) netns=7 res=1

And a CLONE action would result in:
	type=type=AUDIT_NS_INIT_NET msg=audit(1408577535.306:81): pid=481 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 dev=00:03 old_netns=7 netns=8 res=1

While deleting a namespace would result in:
	type=type=AUDIT_NS_DEL_MNT msg=audit(1408577552.221:85): pid=481 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 dev=00:03 mntns=5 res=1

If not "(none)", old_XXXns lists the namespace from which it was cloned.

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 fs/namespace.c             |   13 ++++++++
 include/linux/audit.h      |   14 ++++++++
 include/uapi/linux/audit.h |   12 +++++++
 ipc/namespace.c            |   12 +++++++
 kernel/audit.c             |   73 ++++++++++++++++++++++++++++++++++++++++++++
 kernel/pid_namespace.c     |   12 +++++++
 kernel/user_namespace.c    |   12 +++++++
 kernel/utsname.c           |   11 ++++++
 net/core/net_namespace.c   |   11 ++++++
 9 files changed, 170 insertions(+), 0 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index c680675..e583a7c 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -24,6 +24,7 @@
 #include <linux/magic.h>
 #include <linux/bootmem.h>
 #include <linux/task_work.h>
+#include <linux/audit.h>
 #include "pnode.h"
 #include "internal.h"
 
@@ -2640,6 +2641,7 @@ dput_out:
 
 static void free_mnt_ns(struct mnt_namespace *ns)
 {
+	audit_log_ns_del(AUDIT_NS_DEL_MNT, &ns->ns);
 	ns_free_inum(&ns->ns);
 	put_user_ns(ns->user_ns);
 	kfree(ns);
@@ -2701,6 +2703,7 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
 	new_ns->ns.dev = ns->ns.dev;
 	if (IS_ERR(new_ns))
 		return new_ns;
+	audit_log_ns_init(AUDIT_NS_INIT_MNT, &ns->ns, &new_ns->ns);
 
 	namespace_lock();
 	/* First pass: copy the tree topology */
@@ -3013,6 +3016,16 @@ static void __init init_mount_tree(void)
 	set_fs_root(current->fs, &root);
 }
 
+/* log the ID of init mnt namespace after audit service starts */
+static int __init mnt_ns_init_log(void)
+{
+	struct mnt_namespace *init_mnt_ns = init_task.nsproxy->mnt_ns;
+
+	audit_log_ns_init(AUDIT_NS_INIT_MNT, 0, &init_mnt_ns->ns);
+	return 0;
+}
+late_initcall(mnt_ns_init_log);
+
 void __init mnt_init(void)
 {
 	unsigned u;
diff --git a/include/linux/audit.h b/include/linux/audit.h
index acc4685..f922ea6 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -26,6 +26,7 @@
 #include <linux/sched.h>
 #include <linux/ptrace.h>
 #include <uapi/linux/audit.h>
+#include <linux/proc_ns.h>
 
 struct audit_sig_info {
 	uid_t		uid;
@@ -486,9 +487,17 @@ extern void audit_log_task_info(struct audit_buffer *ab,
 				struct task_struct *tsk);
 #ifdef CONFIG_NAMESPACES
 extern void		    audit_log_ns_info(struct task_struct *tsk);
+extern void		    audit_log_ns_init(int type, struct ns_common *old_ns,
+					      struct ns_common *ns);
+extern void		    audit_log_ns_del(int type, struct ns_common *ns);
 #else
 static inline void	    audit_log_ns_info(struct task_struct *tsk)
 { }
+static inline void	    audit_log_ns_init(int type, struct ns_common *old_ns,
+					      struct ns_common *ns)
+{ }
+static inline void	    audit_log_ns_del(int type, struct ns_common *ns)
+{ }
 #endif
 
 extern int		    audit_update_lsm_rules(void);
@@ -548,6 +557,11 @@ static inline void audit_log_task_info(struct audit_buffer *ab,
 { }
 static inline void audit_log_ns_info(struct task_struct *tsk)
 { }
+static inline void audit_log_ns_init(int type, struct ns_common *old_ns,
+				    struct ns_common *ns)
+{ }
+static inline void audit_log_ns_del(int type, struct ns_common *ns)
+{ }
 #define audit_enabled 0
 #endif /* CONFIG_AUDIT */
 static inline void audit_log_string(struct audit_buffer *ab, const char *buf)
diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
index 8eca5ae..c4b7f15 100644
--- a/include/uapi/linux/audit.h
+++ b/include/uapi/linux/audit.h
@@ -111,6 +111,18 @@
 #define AUDIT_PROCTITLE		1327	/* Proctitle emit event */
 #define AUDIT_FEATURE_CHANGE	1328	/* audit log listing feature changes */
 #define AUDIT_NS_INFO		1329	/* Record process namespace IDs */
+#define AUDIT_NS_INIT_MNT	1330	/* Record mount namespace instance creation */
+#define AUDIT_NS_INIT_UTS	1331	/* Record UTS namespace instance creation */
+#define AUDIT_NS_INIT_IPC	1332	/* Record IPC namespace instance creation */
+#define AUDIT_NS_INIT_USER	1333	/* Record USER namespace instance creation */
+#define AUDIT_NS_INIT_PID	1334	/* Record PID namespace instance creation */
+#define AUDIT_NS_INIT_NET	1335	/* Record NET namespace instance creation */
+#define AUDIT_NS_DEL_MNT	1336	/* Record mount namespace instance deletion */
+#define AUDIT_NS_DEL_UTS	1337	/* Record UTS namespace instance deletion */
+#define AUDIT_NS_DEL_IPC	1338	/* Record IPC namespace instance deletion */
+#define AUDIT_NS_DEL_USER	1339	/* Record USER namespace instance deletion */
+#define AUDIT_NS_DEL_PID	1340	/* Record PID namespace instance deletion */
+#define AUDIT_NS_DEL_NET	1341	/* Record NET namespace instance deletion */
 
 #define AUDIT_AVC		1400	/* SE Linux avc denial or grant */
 #define AUDIT_SELINUX_ERR	1401	/* Internal SE Linux Errors */
diff --git a/ipc/namespace.c b/ipc/namespace.c
index b24da44..494ccd1 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -13,6 +13,7 @@
 #include <linux/mount.h>
 #include <linux/user_namespace.h>
 #include <linux/proc_ns.h>
+#include <linux/audit.h>
 
 #include "util.h"
 
@@ -43,6 +44,8 @@ static struct ipc_namespace *create_ipc_ns(struct user_namespace *user_ns,
 	}
 	atomic_inc(&nr_ipc_ns);
 
+	audit_log_ns_init(AUDIT_NS_INIT_IPC, &old_ns->ns, &ns->ns);
+
 	sem_init_ns(ns);
 	msg_init_ns(ns);
 	shm_init_ns(ns);
@@ -99,6 +102,7 @@ static void free_ipc_ns(struct ipc_namespace *ns)
 	atomic_dec(&nr_ipc_ns);
 
 	put_user_ns(ns->user_ns);
+	audit_log_ns_del(AUDIT_NS_DEL_IPC, &ns->ns);
 	ns_free_inum(&ns->ns);
 	kfree(ns);
 }
@@ -174,3 +178,11 @@ const struct proc_ns_operations ipcns_operations = {
 	.put		= ipcns_put,
 	.install	= ipcns_install,
 };
+
+/* log the ID of init IPC namespace after audit service starts */
+static int __init ipc_namespaces_init(void)
+{
+	audit_log_ns_init(AUDIT_NS_INIT_IPC, 0, &init_ipc_ns.ns);
+	return 0;
+}
+late_initcall(ipc_namespaces_init);
diff --git a/kernel/audit.c b/kernel/audit.c
index 81ffa5b..229fd5a 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1956,6 +1956,79 @@ out:
 	kfree(name);
 }
 
+#ifdef CONFIG_NAMESPACES
+static char *ns_name[] = {
+	"mnt",
+	"uts",
+	"ipc",
+	"user",
+	"pid",
+	"net",
+};
+
+/**
+ * audit_log_ns_init - report a namespace instance creation
+ * @type: type of audit namespace instance created message
+ * @old_ns: the ns_common of the cloned namespace instance
+ * @ns: the ns_common of the new namespace instance
+ */
+void  audit_log_ns_init(int type, struct ns_common *old_ns, struct ns_common *ns)
+{
+	struct audit_buffer *ab;
+	char *audit_ns_name = ns_name[type - AUDIT_NS_INIT_MNT];
+	char old_ns_s[16];
+
+	if (!audit_enabled)
+		return;
+
+	if (type < AUDIT_NS_INIT_MNT || type > AUDIT_NS_INIT_NET) {
+		WARN(1, "audit_log_ns_init: type:%d out of range", type);
+		return;
+	}
+	if (!ns) {
+		WARN(1, "ns should not be NULL");
+		return;
+	}
+	if (!old_ns || !old_ns->inum)
+		sprintf(old_ns_s, "(none)");
+	else
+		sprintf(old_ns_s, "%d", old_ns->inum);
+	ab = audit_log_start(current->audit_context, GFP_KERNEL, type);
+	if (unlikely(!ab))
+		return;
+	audit_log_format(ab, "dev=%02x:%02x old_%sns=%s %sns=%d res=1",
+			 MAJOR(ns->dev), MINOR(ns->dev), audit_ns_name, old_ns_s,
+			 audit_ns_name, ns->inum);
+	audit_log_end(ab);
+}
+
+/**
+ * audit_log_ns_del - report a namespace instance deleted
+ * @type: type of audit namespace instance deleted message
+ * @ns: the ns_common of the namespace instance
+ */
+void audit_log_ns_del(int type, struct ns_common *ns)
+{
+	struct audit_buffer *ab;
+	char *audit_ns_name = ns_name[type - AUDIT_NS_DEL_MNT];
+
+	if (!audit_enabled)
+		return;
+
+	if (type < AUDIT_NS_DEL_MNT || type > AUDIT_NS_DEL_NET) {
+		WARN(1, "audit_log_ns_del: type:%d out of range", type);
+		return;
+	}
+	ab = audit_log_start(current->audit_context, GFP_KERNEL, type);
+	if (unlikely(!ab))
+		return;
+	audit_log_format(ab, "dev=%02x:%02x %sns=%d res=1",
+			 MAJOR(ns->dev), MINOR(ns->dev), audit_ns_name,
+			 ns->inum);
+	audit_log_end(ab);
+}
+#endif /* CONFIG_NAMESPACES */
+
 /**
  * audit_log_end - end one audit record
  * @ab: the audit_buffer
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index 691b9ac..21cffe1 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -18,6 +18,7 @@
 #include <linux/proc_ns.h>
 #include <linux/reboot.h>
 #include <linux/export.h>
+#include <linux/audit.h>
 
 struct pid_cache {
 	int nr_ids;
@@ -111,6 +112,8 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
 	ns->ns.dev = parent_pid_ns->ns.dev;
 	ns->ns.ops = &pidns_operations;
 
+	audit_log_ns_init(AUDIT_NS_INIT_PID, &parent_pid_ns->ns, &ns->ns);
+
 	kref_init(&ns->kref);
 	ns->level = level;
 	ns->parent = get_pid_ns(parent_pid_ns);
@@ -144,6 +147,7 @@ static void destroy_pid_namespace(struct pid_namespace *ns)
 {
 	int i;
 
+	audit_log_ns_del(AUDIT_NS_DEL_PID, &ns->ns);
 	ns_free_inum(&ns->ns);
 	for (i = 0; i < PIDMAP_ENTRIES; i++)
 		kfree(ns->pidmap[i].page);
@@ -408,3 +412,11 @@ static __init int pid_namespaces_init(void)
 }
 
 __initcall(pid_namespaces_init);
+
+/* log the ID of init PID namespace after audit service starts */
+static __init int pid_namespaces_late_init(void)
+{
+	audit_log_ns_init(AUDIT_NS_INIT_PID, 0, &init_pid_ns.ns);
+	return 0;
+}
+late_initcall(pid_namespaces_late_init);
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index ec29cd9..2dbf601 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -22,6 +22,7 @@
 #include <linux/ctype.h>
 #include <linux/projid.h>
 #include <linux/fs_struct.h>
+#include <linux/audit.h>
 
 static struct kmem_cache *user_ns_cachep __read_mostly;
 static DEFINE_MUTEX(userns_state_mutex);
@@ -95,6 +96,8 @@ int create_user_ns(struct cred *new)
 	ns->ns.dev = parent_ns->ns.dev;
 	ns->ns.ops = &userns_operations;
 
+	audit_log_ns_init(AUDIT_NS_INIT_USER, &parent_ns->ns, &ns->ns);
+
 	atomic_set(&ns->count, 1);
 	/* Leave the new->user_ns reference with the new user namespace. */
 	ns->parent = parent_ns;
@@ -144,6 +147,7 @@ void free_user_ns(struct user_namespace *ns)
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 		key_put(ns->persistent_keyring_register);
 #endif
+		audit_log_ns_del(AUDIT_NS_DEL_USER, &ns->ns);
 		ns_free_inum(&ns->ns);
 		kmem_cache_free(user_ns_cachep, ns);
 		ns = parent;
@@ -1011,3 +1015,11 @@ static __init int user_namespaces_init(void)
 	return 0;
 }
 subsys_initcall(user_namespaces_init);
+
+/* log the ID of init user namespace after audit service starts */
+static __init int user_namespaces_late_init(void)
+{
+	audit_log_ns_init(AUDIT_NS_INIT_USER, 0, &init_user_ns.ns);
+	return 0;
+}
+late_initcall(user_namespaces_late_init);
diff --git a/kernel/utsname.c b/kernel/utsname.c
index 54c45e1..c987ee6 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -16,6 +16,7 @@
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
 #include <linux/proc_ns.h>
+#include <linux/audit.h>
 
 static struct uts_namespace *create_uts_ns(void)
 {
@@ -50,6 +51,7 @@ static struct uts_namespace *clone_uts_ns(struct user_namespace *user_ns,
 
 	ns->ns.dev = old_ns->ns.dev;
 	ns->ns.ops = &utsns_operations;
+	audit_log_ns_init(AUDIT_NS_INIT_UTS, &old_ns->ns, &ns->ns);
 
 	down_read(&uts_sem);
 	memcpy(&ns->name, &old_ns->name, sizeof(ns->name));
@@ -87,6 +89,7 @@ void free_uts_ns(struct kref *kref)
 
 	ns = container_of(kref, struct uts_namespace, kref);
 	put_user_ns(ns->user_ns);
+	audit_log_ns_del(AUDIT_NS_DEL_UTS, &ns->ns);
 	ns_free_inum(&ns->ns);
 	kfree(ns);
 }
@@ -138,3 +141,11 @@ const struct proc_ns_operations utsns_operations = {
 	.put		= utsns_put,
 	.install	= utsns_install,
 };
+
+/* log the ID of init UTS namespace after audit service starts */
+static int __init uts_namespaces_init(void)
+{
+	audit_log_ns_init(AUDIT_NS_INIT_UTS, 0, &init_uts_ns.ns);
+	return 0;
+}
+late_initcall(uts_namespaces_init);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index a706cdd..38d6265 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -21,6 +21,7 @@
 #include <net/netlink.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <linux/audit.h>
 
 /*
  *	Our network namespace constructor/destructor lists
@@ -333,6 +334,7 @@ struct net *copy_net_ns(unsigned long flags,
 	rv = setup_net(net, user_ns);
 	if (rv == 0) {
 		net->ns.dev = old_net->ns.dev;
+		audit_log_ns_init(AUDIT_NS_INIT_NET, &old_net->ns, &net->ns);
 		rtnl_lock();
 		list_add_tail_rcu(&net->list, &net_namespace_list);
 		rtnl_unlock();
@@ -483,6 +485,7 @@ static __net_init int net_ns_net_init(struct net *net)
 
 static __net_exit void net_ns_net_exit(struct net *net)
 {
+	audit_log_ns_del(AUDIT_NS_DEL_NET, &net->ns);
 	ns_free_inum(&net->ns);
 }
 
@@ -657,6 +660,14 @@ static int __init net_ns_init(void)
 
 pure_initcall(net_ns_init);
 
+/* log the ID of init_net namespace after audit service starts */
+static int __init net_ns_init_log(void)
+{
+	audit_log_ns_init(AUDIT_NS_INIT_NET, 0, &init_net.ns);
+	return 0;
+}
+late_initcall(net_ns_init_log);
+
 #ifdef CONFIG_NET_NS
 static int __register_pernet_operations(struct list_head *list,
 					struct pernet_operations *ops)
-- 
1.7.1
