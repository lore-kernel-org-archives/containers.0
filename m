From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V3 6/6] audit: log creation and deletion of namespace instances
Date: Tue, 20 May 2014 09:12:07 -0400
Message-ID: <5207c2569e5def75d2960b91013c534271120ae1.1400271129.git.rgb@redhat.com>
References: <cover.1400271129.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1400271129.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1400271129.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1400271129.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Log the creation and deletion of namespace instances in all 6 types of
namespaces.

Two new audit message types have been introduced:
	AUDIT_NS_INIT	1329
	AUDIT_NS_DEL	1330

The output format should look roughly:

type=NS_INIT msg=audit(1400217435.706:94): pid=524 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:mount_t:s0 type=20000 old_snum=0 snum=a res=1
type=NS_DEL msg=audit(1400217435.730:95): pid=524 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:mount_t:s0 type=20000 snum=a res=1

If non-zero, old_snum lists the namespace from which it was cloned.
The types are CLONE_NEW* listed in include/uapi/linux/sched.h.

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 fs/namespace.c             |    4 ++++
 include/linux/audit.h      |    8 ++++++++
 include/uapi/linux/audit.h |    2 ++
 ipc/namespace.c            |   10 ++++++++++
 kernel/audit.c             |   32 ++++++++++++++++++++++++++++++++
 kernel/pid_namespace.c     |   10 ++++++++++
 kernel/user_namespace.c    |    9 +++++++++
 kernel/utsname.c           |   10 ++++++++++
 net/core/net_namespace.c   |    5 +++++
 9 files changed, 90 insertions(+), 0 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 74348c4..f33efb3 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -24,6 +24,7 @@
 #include <linux/proc_ns.h>
 #include <linux/magic.h>
 #include <linux/bootmem.h>
+#include <linux/audit.h>
 #include "pnode.h"
 #include "internal.h"
 
@@ -2445,6 +2446,7 @@ dput_out:
 
 static void free_mnt_ns(struct mnt_namespace *ns)
 {
+	audit_log_ns_del(CLONE_NEWNS, ns->serial_num);
 	proc_free_inum(ns->proc_inum);
 	put_user_ns(ns->user_ns);
 	kfree(ns);
@@ -2505,6 +2507,7 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
 	new_ns = alloc_mnt_ns(user_ns);
 	if (IS_ERR(new_ns))
 		return new_ns;
+	audit_log_ns_init(CLONE_NEWNS, ns->serial_num, new_ns->serial_num);
 
 	namespace_lock();
 	/* First pass: copy the tree topology */
@@ -2568,6 +2571,7 @@ static struct mnt_namespace *create_mnt_ns(struct vfsmount *m)
 		mnt->mnt_ns = new_ns;
 		new_ns->root = mnt;
 		list_add(&mnt->mnt_list, &new_ns->list);
+		audit_log_ns_init(CLONE_NEWNS, 0, new_ns->serial_num);
 	} else {
 		mntput(m);
 	}
diff --git a/include/linux/audit.h b/include/linux/audit.h
index 0ef404a..3ba8216 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -466,6 +466,9 @@ extern void		    audit_log_key(struct audit_buffer *ab,
 					  char *key);
 extern void		    audit_log_link_denied(const char *operation,
 						  struct path *link);
+extern int		    audit_log_ns_init(int type, long long old_snum,
+					      long long snum);
+extern int		    audit_log_ns_del(int type, long long snum);
 extern void		    audit_log_lost(const char *message);
 #ifdef CONFIG_SECURITY
 extern void 		    audit_log_secctx(struct audit_buffer *ab, u32 secid);
@@ -524,6 +527,11 @@ static inline void audit_log_key(struct audit_buffer *ab, char *key)
 static inline void audit_log_link_denied(const char *string,
 					 const struct path *link)
 { }
+static inline int audit_log_ns_init(int type, long long old_snum,
+				    long long snum)
+{ }
+static inline int audit_log_ns_del(int type, long long snum)
+{ }
 static inline void audit_log_secctx(struct audit_buffer *ab, u32 secid)
 { }
 static inline int audit_log_task_context(struct audit_buffer *ab)
diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
index 573dc36..ac177fd 100644
--- a/include/uapi/linux/audit.h
+++ b/include/uapi/linux/audit.h
@@ -110,6 +110,8 @@
 #define AUDIT_SECCOMP		1326	/* Secure Computing event */
 #define AUDIT_PROCTITLE		1327	/* Proctitle emit event */
 #define AUDIT_FEATURE_CHANGE	1328	/* audit log listing feature changes */
+#define AUDIT_NS_INIT		1329	/* Record namespace instance creation */
+#define AUDIT_NS_DEL		1330	/* Record namespace instance deletion */
 
 #define AUDIT_AVC		1400	/* SE Linux avc denial or grant */
 #define AUDIT_SELINUX_ERR	1401	/* Internal SE Linux Errors */
diff --git a/ipc/namespace.c b/ipc/namespace.c
index 36ce7ff..5b2b897 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -13,6 +13,7 @@
 #include <linux/mount.h>
 #include <linux/user_namespace.h>
 #include <linux/proc_ns.h>
+#include <linux/audit.h>
 
 #include "util.h"
 
@@ -42,6 +43,7 @@ static struct ipc_namespace *create_ipc_ns(struct user_namespace *user_ns,
 	atomic_inc(&nr_ipc_ns);
 
 	ns->serial_num = ns_serial();
+	audit_log_ns_init(CLONE_NEWIPC, old_ns->serial_num, ns->serial_num);
 
 	sem_init_ns(ns);
 	msg_init_ns(ns);
@@ -121,6 +123,7 @@ static void free_ipc_ns(struct ipc_namespace *ns)
 	 */
 	ipcns_notify(IPCNS_REMOVED);
 	put_user_ns(ns->user_ns);
+	audit_log_ns_del(CLONE_NEWIPC, ns->serial_num);
 	proc_free_inum(ns->proc_inum);
 	kfree(ns);
 }
@@ -207,3 +210,10 @@ const struct proc_ns_operations ipcns_operations = {
 	.inum		= ipcns_inum,
 	.snum		= ipcns_snum,
 };
+
+static int __init ipc_namespaces_init(void)
+{
+	return audit_log_ns_init(CLONE_NEWIPC, 0, init_ipc_ns.serial_num);
+}
+
+late_initcall(ipc_namespaces_init);
diff --git a/kernel/audit.c b/kernel/audit.c
index 6452278..820e9f0 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1917,6 +1917,38 @@ out:
 }
 
 /**
+ * audit_log_ns_init - report a namespace instance creation
+ * @type: type of namespace instance created
+ * @old_snum: the serial number of the cloned namespace instance
+ * @snum: the serial number of the new namespace instance
+ */
+int audit_log_ns_init(int type, long long old_snum, long long snum)
+{
+	struct audit_buffer *ab;
+
+	audit_log_common_recv_msg(&ab, AUDIT_NS_INIT);
+	audit_log_format(ab, " type=%x old_snum=%llx snum=%llx res=1",
+			 type, old_snum, snum);
+	audit_log_end(ab);
+	return 0;
+}
+
+/**
+ * audit_log_ns_del - report a namespace instance deleted
+ * @type: type of namespace instance deleted
+ * @snum: the serial number of the namespace instance
+ */
+int audit_log_ns_del(int type, long long snum)
+{
+	struct audit_buffer *ab;
+
+	audit_log_common_recv_msg(&ab, AUDIT_NS_DEL);
+	audit_log_format(ab, " type=%x snum=%llx res=1", type, snum);
+	audit_log_end(ab);
+	return 0;
+}
+
+/**
  * audit_log_end - end one audit record
  * @ab: the audit_buffer
  *
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index 5473364..d765b8d 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -18,6 +18,7 @@
 #include <linux/proc_ns.h>
 #include <linux/reboot.h>
 #include <linux/export.h>
+#include <linux/audit.h>
 
 struct pid_cache {
 	int nr_ids;
@@ -110,6 +111,8 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
 		goto out_free_map;
 
 	ns->serial_num = ns_serial();
+	audit_log_ns_init(CLONE_NEWPID, parent_pid_ns->serial_num,
+			  ns->serial_num);
 
 	kref_init(&ns->kref);
 	ns->level = level;
@@ -144,6 +147,7 @@ static void destroy_pid_namespace(struct pid_namespace *ns)
 {
 	int i;
 
+	audit_log_ns_del(CLONE_NEWPID, ns->serial_num);
 	proc_free_inum(ns->proc_inum);
 	for (i = 0; i < PIDMAP_ENTRIES; i++)
 		kfree(ns->pidmap[i].page);
@@ -395,3 +399,9 @@ static __init int pid_namespaces_init(void)
 }
 
 __initcall(pid_namespaces_init);
+
+static __init int pid_namespaces_late_init(void)
+{
+	return audit_log_ns_init(CLONE_NEWPID, 0, init_pid_ns.serial_num);
+}
+late_initcall(pid_namespaces_late_init);
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index d2e9365..d0927a0 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -22,6 +22,7 @@
 #include <linux/ctype.h>
 #include <linux/projid.h>
 #include <linux/fs_struct.h>
+#include <linux/audit.h>
 
 static struct kmem_cache *user_ns_cachep __read_mostly;
 
@@ -93,6 +94,7 @@ int create_user_ns(struct cred *new)
 	}
 
 	ns->serial_num = ns_serial();
+	audit_log_ns_init(CLONE_NEWUSER, parent_ns->serial_num, ns->serial_num);
 
 	atomic_set(&ns->count, 1);
 	/* Leave the new->user_ns reference with the new user namespace. */
@@ -138,6 +140,7 @@ void free_user_ns(struct user_namespace *ns)
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 		key_put(ns->persistent_keyring_register);
 #endif
+		audit_log_ns_del(CLONE_NEWUSER, ns->serial_num);
 		proc_free_inum(ns->proc_inum);
 		kmem_cache_free(user_ns_cachep, ns);
 		ns = parent;
@@ -912,3 +915,9 @@ static __init int user_namespaces_init(void)
 	return 0;
 }
 module_init(user_namespaces_init);
+
+static __init int user_namespaces_late_init(void)
+{
+	return audit_log_ns_init(CLONE_NEWUSER, 0, init_user_ns.serial_num);
+}
+late_initcall(user_namespaces_late_init);
diff --git a/kernel/utsname.c b/kernel/utsname.c
index ffeac1b..c6709b8 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -16,6 +16,7 @@
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
 #include <linux/proc_ns.h>
+#include <linux/audit.h>
 
 static struct uts_namespace *create_uts_ns(void)
 {
@@ -49,6 +50,7 @@ static struct uts_namespace *clone_uts_ns(struct user_namespace *user_ns,
 	}
 
 	ns->serial_num = ns_serial();
+	audit_log_ns_init(CLONE_NEWUTS, old_ns->serial_num, ns->serial_num);
 
 	down_read(&uts_sem);
 	memcpy(&ns->name, &old_ns->name, sizeof(ns->name));
@@ -86,6 +88,7 @@ void free_uts_ns(struct kref *kref)
 
 	ns = container_of(kref, struct uts_namespace, kref);
 	put_user_ns(ns->user_ns);
+	audit_log_ns_del(CLONE_NEWUTS, ns->serial_num);
 	proc_free_inum(ns->proc_inum);
 	kfree(ns);
 }
@@ -148,3 +151,10 @@ const struct proc_ns_operations utsns_operations = {
 	.inum		= utsns_inum,
 	.snum		= utsns_snum,
 };
+
+static int __init uts_namespaces_init(void)
+{
+	return audit_log_ns_init(CLONE_NEWUTS, 0, init_uts_ns.serial_num);
+}
+
+late_initcall(uts_namespaces_init);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index dd7c085..d508993 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -17,6 +17,7 @@
 #include <linux/user_namespace.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <linux/audit.h>
 
 /*
  *	Our network namespace constructor/destructor lists
@@ -253,6 +254,8 @@ struct net *copy_net_ns(unsigned long flags,
 	mutex_lock(&net_mutex);
 	rv = setup_net(net, user_ns);
 	if (rv == 0) {
+		audit_log_ns_init(CLONE_NEWNET, old_net->serial_num,
+				  net->serial_num);
 		rtnl_lock();
 		list_add_tail_rcu(&net->list, &net_namespace_list);
 		rtnl_unlock();
@@ -395,6 +398,7 @@ static __net_init int net_ns_net_init(struct net *net)
 
 static __net_exit void net_ns_net_exit(struct net *net)
 {
+	audit_log_ns_del(CLONE_NEWNET, net->serial_num);
 	proc_free_inum(net->proc_inum);
 }
 
@@ -428,6 +432,7 @@ static int __init net_ns_init(void)
 	if (setup_net(&init_net, &init_user_ns))
 		panic("Could not setup the initial network namespace");
 
+	audit_log_ns_init(CLONE_NEWNET, 0, init_net.serial_num);
 	rtnl_lock();
 	list_add_tail_rcu(&init_net.list, &net_namespace_list);
 	rtnl_unlock();
-- 
1.7.1
