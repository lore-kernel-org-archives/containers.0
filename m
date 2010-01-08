From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [RFC] [PATCH 2/2] cgroups: blkio subsystem as module
Date: Fri, 8 Jan 2010 00:30:21 -0500
Message-ID: <20100108053021.GC13168__14022.4996292547$1262928722$gmane$org@andrew.cmu.edu>
References: <20091231051050.GA714@andrew.cmu.edu>
	<20100106160414.bd555474.akpm@linux-foundation.org>
	<20100107012606.GA25577@andrew.cmu.edu>
	<20100107120732.97d502bd.kamezawa.hiroyu@jp.fujitsu.com>
	<4B45824B.9030108@cn.fujitsu.com>
	<20100108052734.GA13168@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: attachment; filename="cgroups-blkio-as-module.patch"
In-Reply-To: <20100108052734.GA13168-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Andrew Morton <akpm@linux-foun>
List-Id: containers.vger.kernel.org

Convert blk-cgroup to be buildable as a module

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

This patch modifies the Block I/O cgroup subsystem to be able to be built as a
module. As the CFQ disk scheduler optionally depends on blk-cgroup, config
options in block/Kconfig, block/Kconfig.iosched, and block/blk-cgroup.h are
enhanced to support the new module dependency.

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
---
 block/Kconfig             |    2 +-
 block/Kconfig.iosched     |    2 +-
 block/blk-cgroup.c        |   53 +++++++++++++++++++++++++++++++++++----------
 block/blk-cgroup.h        |   10 +++++++-
 include/linux/iocontext.h |    2 +-
 kernel/cgroup.c           |    8 +++++++
 6 files changed, 60 insertions(+), 17 deletions(-)

diff --git a/block/Kconfig b/block/Kconfig
index e20fbde..62a5921 100644
--- a/block/Kconfig
+++ b/block/Kconfig
@@ -78,7 +78,7 @@ config BLK_DEV_INTEGRITY
 	Protection.  If in doubt, say N.
 
 config BLK_CGROUP
-	bool
+	tristate
 	depends on CGROUPS
 	default n
 	---help---
diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index b71abfb..fc71cf0 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -23,6 +23,7 @@ config IOSCHED_DEADLINE
 
 config IOSCHED_CFQ
 	tristate "CFQ I/O scheduler"
+	select BLK_CGROUP if CFQ_GROUP_IOSCHED
 	default y
 	---help---
 	  The CFQ I/O scheduler tries to distribute bandwidth equally
@@ -35,7 +36,6 @@ config IOSCHED_CFQ
 config CFQ_GROUP_IOSCHED
 	bool "CFQ Group Scheduling support"
 	depends on IOSCHED_CFQ && CGROUPS
-	select BLK_CGROUP
 	default n
 	---help---
 	  Enable group IO scheduling in CFQ.
diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 1fa2654..6c73380 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -23,6 +23,31 @@ static LIST_HEAD(blkio_list);
 struct blkio_cgroup blkio_root_cgroup = { .weight = 2*BLKIO_WEIGHT_DEFAULT };
 EXPORT_SYMBOL_GPL(blkio_root_cgroup);
 
+static struct cgroup_subsys_state *blkiocg_create(struct cgroup_subsys *,
+						  struct cgroup *);
+static int blkiocg_can_attach(struct cgroup_subsys *, struct cgroup *,
+			      struct task_struct *, bool);
+static void blkiocg_attach(struct cgroup_subsys *, struct cgroup *,
+			   struct cgroup *, struct task_struct *, bool);
+static void blkiocg_destroy(struct cgroup_subsys *, struct cgroup *);
+static int blkiocg_populate(struct cgroup_subsys *, struct cgroup *);
+
+struct cgroup_subsys blkio_subsys = {
+	.name = "blkio",
+	.create = blkiocg_create,
+	.can_attach = blkiocg_can_attach,
+	.attach = blkiocg_attach,
+	.destroy = blkiocg_destroy,
+	.populate = blkiocg_populate,
+#ifdef CONFIG_BLK_CGROUP
+	/* note: blkio_subsys_id is otherwise defined in blk-cgroup.h */
+	.subsys_id = blkio_subsys_id,
+#endif
+	.use_id = 1,
+	.module = THIS_MODULE,
+};
+EXPORT_SYMBOL_GPL(blkio_subsys);
+
 bool blkiocg_css_tryget(struct blkio_cgroup *blkcg)
 {
 	if (!css_tryget(&blkcg->css))
@@ -267,7 +292,8 @@ remove_entry:
 done:
 	free_css_id(&blkio_subsys, &blkcg->css);
 	rcu_read_unlock();
-	kfree(blkcg);
+	if (blkcg != &blkio_root_cgroup)
+		kfree(blkcg);
 }
 
 static struct cgroup_subsys_state *
@@ -333,17 +359,6 @@ static void blkiocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
 	task_unlock(tsk);
 }
 
-struct cgroup_subsys blkio_subsys = {
-	.name = "blkio",
-	.create = blkiocg_create,
-	.can_attach = blkiocg_can_attach,
-	.attach = blkiocg_attach,
-	.destroy = blkiocg_destroy,
-	.populate = blkiocg_populate,
-	.subsys_id = blkio_subsys_id,
-	.use_id = 1,
-};
-
 void blkio_policy_register(struct blkio_policy_type *blkiop)
 {
 	spin_lock(&blkio_list_lock);
@@ -359,3 +374,17 @@ void blkio_policy_unregister(struct blkio_policy_type *blkiop)
 	spin_unlock(&blkio_list_lock);
 }
 EXPORT_SYMBOL_GPL(blkio_policy_unregister);
+
+static int __init init_cgroup_blkio(void)
+{
+	return cgroup_load_subsys(&blkio_subsys);
+}
+
+static void __exit exit_cgroup_blkio(void)
+{
+	cgroup_unload_subsys(&blkio_subsys);
+}
+
+module_init(init_cgroup_blkio);
+module_exit(exit_cgroup_blkio);
+MODULE_LICENSE("GPL");
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 4d316df..57648c6 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -15,7 +15,13 @@
 
 #include <linux/cgroup.h>
 
-#ifdef CONFIG_BLK_CGROUP
+#if defined(CONFIG_BLK_CGROUP) || defined(CONFIG_BLK_CGROUP_MODULE)
+
+#ifndef CONFIG_BLK_CGROUP
+/* When blk-cgroup is a module, its subsys_id isn't a compile-time constant */
+extern struct cgroup_subsys blkio_subsys;
+#define blkio_subsys_id blkio_subsys.subsys_id
+#endif
 
 struct blkio_cgroup {
 	struct cgroup_subsys_state css;
@@ -94,7 +100,7 @@ static inline void blkiocg_update_blkio_group_dequeue_stats(
 			struct blkio_group *blkg, unsigned long dequeue) {}
 #endif
 
-#ifdef CONFIG_BLK_CGROUP
+#if defined(CONFIG_BLK_CGROUP) || defined(CONFIG_BLK_CGROUP_MODULE)
 extern struct blkio_cgroup blkio_root_cgroup;
 extern struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup);
 extern void blkiocg_add_blkio_group(struct blkio_cgroup *blkcg,
diff --git a/include/linux/iocontext.h b/include/linux/iocontext.h
index a632359..b9f109d 100644
--- a/include/linux/iocontext.h
+++ b/include/linux/iocontext.h
@@ -68,7 +68,7 @@ struct io_context {
 	unsigned short ioprio;
 	unsigned short ioprio_changed;
 
-#ifdef CONFIG_BLK_CGROUP
+#if defined(CONFIG_BLK_CGROUP) || defined(CONFIG_BLK_CGROUP_MODULE)
 	unsigned short cgroup_changed;
 #endif
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5af59eb..391ff41 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -690,6 +690,7 @@ void cgroup_lock(void)
 {
 	mutex_lock(&cgroup_mutex);
 }
+EXPORT_SYMBOL_GPL(cgroup_lock);
 
 /**
  * cgroup_unlock - release lock on cgroup changes
@@ -700,6 +701,7 @@ void cgroup_unlock(void)
 {
 	mutex_unlock(&cgroup_mutex);
 }
+EXPORT_SYMBOL_GPL(cgroup_unlock);
 
 /*
  * A couple of forward declarations required, due to cyclic reference loop:
@@ -1762,6 +1764,7 @@ bool cgroup_lock_live_group(struct cgroup *cgrp)
 	}
 	return true;
 }
+EXPORT_SYMBOL_GPL(cgroup_lock_live_group);
 
 static int cgroup_release_agent_write(struct cgroup *cgrp, struct cftype *cft,
 				      const char *buffer)
@@ -4034,6 +4037,7 @@ void __css_put(struct cgroup_subsys_state *css)
 	rcu_read_unlock();
 	WARN_ON_ONCE(val < 1);
 }
+EXPORT_SYMBOL_GPL(__css_put);
 
 /*
  * Notify userspace when a cgroup is released, by running the
@@ -4149,6 +4153,7 @@ unsigned short css_id(struct cgroup_subsys_state *css)
 		return cssid->id;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(css_id);
 
 unsigned short css_depth(struct cgroup_subsys_state *css)
 {
@@ -4158,6 +4163,7 @@ unsigned short css_depth(struct cgroup_subsys_state *css)
 		return cssid->depth;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(css_depth);
 
 bool css_is_ancestor(struct cgroup_subsys_state *child,
 		    const struct cgroup_subsys_state *root)
@@ -4194,6 +4200,7 @@ void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css)
 	spin_unlock(&ss->id_lock);
 	call_rcu(&id->rcu_head, __free_css_id_cb);
 }
+EXPORT_SYMBOL_GPL(free_css_id);
 
 /*
  * This is called by init or create(). Then, calls to this function are
@@ -4310,6 +4317,7 @@ struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)
 
 	return rcu_dereference(cssid->css);
 }
+EXPORT_SYMBOL_GPL(css_lookup);
 
 /**
  * css_get_next - lookup next cgroup under specified hierarchy.
