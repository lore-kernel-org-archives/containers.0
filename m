From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V7 03/10] nsfs: add nsfs device ID to ns_common
Date: Tue, 12 May 2015 16:02:40 -0400
Message-ID: <e93778939669d6bbcab048051e2883042cc4b1fd.1431451547.git.rgb@redhat.com>
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

For speed and convenience of look-up, the nsfs device ID is looked up for the
first instance of a type of namespace, then copied to others of the same type
as they are spawned.

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 fs/namespace.c            |    2 ++
 fs/nsfs.c                 |   21 +++++++++++++++++++++
 include/linux/ns_common.h |    1 +
 include/linux/proc_ns.h   |    1 +
 ipc/namespace.c           |    1 +
 kernel/pid_namespace.c    |    1 +
 kernel/user_namespace.c   |    1 +
 kernel/utsname.c          |    1 +
 net/core/net_namespace.c  |    2 ++
 9 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 82ef140..c680675 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2698,6 +2698,7 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
 	old = ns->root;
 
 	new_ns = alloc_mnt_ns(user_ns);
+	new_ns->ns.dev = ns->ns.dev;
 	if (IS_ERR(new_ns))
 		return new_ns;
 
@@ -2762,6 +2763,7 @@ static struct mnt_namespace *create_mnt_ns(struct vfsmount *m)
 		struct mount *mnt = real_mount(m);
 		mnt->mnt_ns = new_ns;
 		new_ns->root = mnt;
+		new_ns->ns.dev = nsfs_dev();
 		list_add(&mnt->mnt_list, &new_ns->list);
 	} else {
 		mntput(m);
diff --git a/fs/nsfs.c b/fs/nsfs.c
index 1fcd529..cc785d3 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -4,6 +4,10 @@
 #include <linux/proc_ns.h>
 #include <linux/magic.h>
 #include <linux/ktime.h>
+#include <linux/init_task.h>
+#include <linux/utsname.h>
+#include <linux/pid_namespace.h>
+#include <linux/ipc_namespace.h>
 
 static struct vfsmount *nsfs_mnt;
 
@@ -158,6 +162,23 @@ void __init nsfs_init(void)
 	if (IS_ERR(nsfs_mnt))
 		panic("can't set nsfs up\n");
 	nsfs_mnt->mnt_sb->s_flags &= ~MS_NOUSER;
+	init_ipc_ns.ns.dev = init_uts_ns.ns.dev = init_pid_ns.ns.dev
+		= init_user_ns.ns.dev = nsfs_dev();
+}
+
+dev_t nsfs_dev(void)
+{
+	dev_t dev;
+
+	void nssb_to_dev(struct super_block *sb, void *arg){
+		dev_t *dev = arg;
+
+		if (sb->s_magic == NSFS_MAGIC)
+			*dev = sb->s_dev;
+	}
+
+	iterate_supers(nssb_to_dev, (void*)&dev);
+	return dev;
 }
 
 static DEFINE_IDA(ns_inum_ida);
diff --git a/include/linux/ns_common.h b/include/linux/ns_common.h
index 85a5c8c..6701070 100644
--- a/include/linux/ns_common.h
+++ b/include/linux/ns_common.h
@@ -7,6 +7,7 @@ struct ns_common {
 	atomic_long_t stashed;
 	const struct proc_ns_operations *ops;
 	unsigned int inum;
+	dev_t dev;
 };
 
 #endif
diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
index 721d0e2..904d9e7 100644
--- a/include/linux/proc_ns.h
+++ b/include/linux/proc_ns.h
@@ -71,4 +71,5 @@ extern int ns_get_name(char *buf, size_t size, struct task_struct *task,
 			const struct proc_ns_operations *ns_ops);
 extern void nsfs_init(void);
 
+extern dev_t nsfs_dev(void);
 #endif /* _LINUX_PROC_NS_H */
diff --git a/ipc/namespace.c b/ipc/namespace.c
index 068caf1..b24da44 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -31,6 +31,7 @@ static struct ipc_namespace *create_ipc_ns(struct user_namespace *user_ns,
 		kfree(ns);
 		return ERR_PTR(err);
 	}
+	ns->ns.dev = old_ns->ns.dev;
 	ns->ns.ops = &ipcns_operations;
 
 	atomic_set(&ns->count, 1);
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index a65ba13..691b9ac 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -108,6 +108,7 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
 	err = ns_alloc_inum(&ns->ns);
 	if (err)
 		goto out_free_map;
+	ns->ns.dev = parent_pid_ns->ns.dev;
 	ns->ns.ops = &pidns_operations;
 
 	kref_init(&ns->kref);
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 4109f83..ec29cd9 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -92,6 +92,7 @@ int create_user_ns(struct cred *new)
 		kmem_cache_free(user_ns_cachep, ns);
 		return ret;
 	}
+	ns->ns.dev = parent_ns->ns.dev;
 	ns->ns.ops = &userns_operations;
 
 	atomic_set(&ns->count, 1);
diff --git a/kernel/utsname.c b/kernel/utsname.c
index 831ea71..54c45e1 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -48,6 +48,7 @@ static struct uts_namespace *clone_uts_ns(struct user_namespace *user_ns,
 		return ERR_PTR(err);
 	}
 
+	ns->ns.dev = old_ns->ns.dev;
 	ns->ns.ops = &utsns_operations;
 
 	down_read(&uts_sem);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 70d3450..a706cdd 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -332,6 +332,7 @@ struct net *copy_net_ns(unsigned long flags,
 	mutex_lock(&net_mutex);
 	rv = setup_net(net, user_ns);
 	if (rv == 0) {
+		net->ns.dev = old_net->ns.dev;
 		rtnl_lock();
 		list_add_tail_rcu(&net->list, &net_namespace_list);
 		rtnl_unlock();
@@ -639,6 +640,7 @@ static int __init net_ns_init(void)
 	if (setup_net(&init_net, &init_user_ns))
 		panic("Could not setup the initial network namespace");
 
+	init_net.ns.dev = nsfs_dev();
 	rtnl_lock();
 	list_add_tail_rcu(&init_net.list, &net_namespace_list);
 	rtnl_unlock();
-- 
1.7.1
