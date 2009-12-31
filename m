From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [PATCH v4 2/4] cgroups: subsystem module loading interface
Date: Thu, 31 Dec 2009 00:13:21 -0500
Message-ID: <20091231051321.GC714__35392.4674368047$1262236452$gmane$org@andrew.cmu.edu>
References: <20091231051050.GA714@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091231051050.GA714-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org
List-Id: containers.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


On Thu, Dec 31, 2009 at 12:10:50AM -0500, Ben Blum wrote:
> [This is a revision of http://lkml.org/lkml/2009/12/21/211 ]
> 
> This patch series implements support for building, loading, and
> unloading subsystems as modules, both within and outside the kernel
> source tree. It provides an interface cgroup_load_subsys() and
> cgroup_unload_subsys() which modular subsystems can use to register and
> depart during runtime. The net_cls classifier subsystem serves as the
> example for a subsystem which can be converted into a module using these
> changes.
> 
> Patch #1 sets up the subsys[] array so its contents can be dynamic as
> modules appear and (eventually) disappear. Iterations over the array are
> modified to handle when subsystems are absent, and the dynamic section
> of the array is protected by cgroup_mutex.
> 
> Patch #2 implements an interface for modules to load subsystems, called
> cgroup_load_subsys, similar to cgroup_init_subsys, and adds a module
> pointer in struct cgroup_subsys.
> 
> Patch #3 adds a mechanism for unloading modular subsystems, which
> includes a more advanced rework of the rudimentary reference counting
> introduced in patch 2.
> 
> Patch #4 modifies the net_cls subsystem, which already had some module
> declarations, to be configurable as a module, which also serves as a
> simple proof-of-concept.
> 
> Part of implementing patches 2 and 4 involved updating css pointers in
> each css_set when the module appears or leaves. In doing this, it was
> discovered that css_sets always remain linked to the dummy cgroup,
> regardless of whether or not any subsystems are actually bound to it
> (i.e., not mounted on an actual hierarchy). The subsystem loading and
> unloading code therefore should keep in mind the special cases where the
> added subsystem is the only one in the dummy cgroup (and therefore all
> css_sets need to be linked back into it) and where the removed subsys
> was the only one in the dummy cgroup (and therefore all css_sets should
> be unlinked from it) - however, as all css_sets always stay attached to
> the dummy cgroup anyway, these cases are ignored. Any fix that addresses
> this issue should also make sure these cases are addressed in the
> subsystem loading and unloading code.
> 
> -- bblum
> 
> ---
>  Documentation/cgroups/cgroups.txt |    9
>  include/linux/cgroup.h            |   18 +
>  kernel/cgroup.c                   |  388 +++++++++++++++++++++++++++++++++-----
>  net/sched/Kconfig                 |    5
>  net/sched/cls_cgroup.c            |   36 ++-
>  5 files changed, 400 insertions(+), 56 deletions(-)
> 
> 

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="cgroups-subsys-module-interface.patch"

Add interface between cgroups subsystem management and module loading

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

This patch implements rudimentary module-loading support for cgroups - namely,
a cgroup_load_subsys (similar to cgroup_init_subsys) for use as a module
initcall, and a struct module pointer in struct cgroup_subsys.

Several functions that might be wanted by modules have had EXPORT_SYMBOL added
to them, but it's unclear exactly which functions want it and which won't.

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Acked-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---

 Documentation/cgroups/cgroups.txt |    4 +
 include/linux/cgroup.h            |    4 +
 kernel/cgroup.c                   |  128 +++++++++++++++++++++++++++++++++++++
 3 files changed, 136 insertions(+), 0 deletions(-)


diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 0b33bfe..6ffcf81 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -488,6 +488,10 @@ Each subsystem should:
 - add an entry in linux/cgroup_subsys.h
 - define a cgroup_subsys object called <name>_subsys
 
+If a subsystem can be compiled as a module, it should also have in its
+module initcall a call to cgroup_load_subsys(&its_subsys_struct). It
+should also set its_subsys.module = THIS_MODULE in its .c file.
+
 Each subsystem may export the following methods. The only mandatory
 methods are create/destroy. Any others that are null are presumed to
 be successful no-ops.
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 83da43d..9461aed 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -36,6 +36,7 @@ extern void cgroup_post_fork(struct task_struct *p);
 extern void cgroup_exit(struct task_struct *p, int run_callbacks);
 extern int cgroupstats_build(struct cgroupstats *stats,
 				struct dentry *dentry);
+extern int cgroup_load_subsys(struct cgroup_subsys *ss);
 
 extern const struct file_operations proc_cgroup_operations;
 
@@ -477,6 +478,9 @@ struct cgroup_subsys {
 	/* used when use_id == true */
 	struct idr idr;
 	spinlock_t id_lock;
+
+	/* should be defined only by modular subsystems */
+	struct module *module;
 };
 
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 402e828..d7ca4cf 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -43,6 +43,7 @@
 #include <linux/string.h>
 #include <linux/sort.h>
 #include <linux/kmod.h>
+#include <linux/module.h>
 #include <linux/delayacct.h>
 #include <linux/cgroupstats.h>
 #include <linux/hash.h>
@@ -2084,6 +2085,7 @@ int cgroup_add_file(struct cgroup *cgrp,
 		error = PTR_ERR(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(cgroup_add_file);
 
 int cgroup_add_files(struct cgroup *cgrp,
 			struct cgroup_subsys *subsys,
@@ -2098,6 +2100,7 @@ int cgroup_add_files(struct cgroup *cgrp,
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cgroup_add_files);
 
 /**
  * cgroup_task_count - count the number of tasks in a cgroup.
@@ -3249,7 +3252,132 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	mutex_init(&ss->hierarchy_mutex);
 	lockdep_set_class(&ss->hierarchy_mutex, &ss->subsys_key);
 	ss->active = 1;
+
+	/* this function shouldn't be used with modular subsystems, since they
+	 * need to register a subsys_id, among other things */
+	BUG_ON(ss->module);
+}
+
+/**
+ * cgroup_load_subsys: load and register a modular subsystem at runtime
+ * @ss: the subsystem to load
+ *
+ * This function should be called in a modular subsystem's initcall. If the
+ * subsytem is built as a module, it will be assigned a new subsys_id and set
+ * up for use. If the subsystem is built-in anyway, work is delegated to the
+ * simpler cgroup_init_subsys.
+ */
+int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
+{
+	int i;
+	struct cgroup_subsys_state *css;
+
+	/* check name and function validity */
+	if (ss->name == NULL || strlen(ss->name) > MAX_CGROUP_TYPE_NAMELEN ||
+	    ss->create == NULL || ss->destroy == NULL)
+		return -EINVAL;
+
+	/*
+	 * we don't support callbacks in modular subsystems. this check is
+	 * before the ss->module check for consistency; a subsystem that could
+	 * be a module should still have no callbacks even if the user isn't
+	 * compiling it as one.
+	 */
+	if (ss->fork || ss->exit)
+		return -EINVAL;
+
+	/*
+	 * an optionally modular subsystem is built-in: we want to do nothing,
+	 * since cgroup_init_subsys will have already taken care of it.
+	 */
+	if (ss->module == NULL) {
+		/* a few sanity checks */
+		BUG_ON(ss->subsys_id >= CGROUP_BUILTIN_SUBSYS_COUNT);
+		BUG_ON(subsys[ss->subsys_id] != ss);
+		return 0;
+	}
+
+	/*
+	 * need to register a subsys id before anything else - for example,
+	 * init_cgroup_css needs it.
+	 */
+	mutex_lock(&cgroup_mutex);
+	/* find the first empty slot in the array */
+	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
+		if (subsys[i] == NULL)
+			break;
+	}
+	if (i == CGROUP_SUBSYS_COUNT) {
+		/* maximum number of subsystems already registered! */
+		mutex_unlock(&cgroup_mutex);
+		return -EBUSY;
+	}
+	/* assign ourselves the subsys_id */
+	ss->subsys_id = i;
+	subsys[i] = ss;
+
+	/*
+	 * no ss->create seems to need anything important in the ss struct, so
+	 * this can happen first (i.e. before the rootnode attachment).
+	 */
+	css = ss->create(ss, dummytop);
+	if (IS_ERR(css)) {
+		/* failure case - need to deassign the subsys[] slot. */
+		subsys[i] = NULL;
+		mutex_unlock(&cgroup_mutex);
+		return PTR_ERR(css);
+	}
+
+	list_add(&ss->sibling, &rootnode.subsys_list);
+	ss->root = &rootnode;
+
+	/* our new subsystem will be attached to the dummy hierarchy. */
+	init_cgroup_css(css, ss, dummytop);
+	/*
+	 * Now we need to entangle the css into the existing css_sets. unlike
+	 * in cgroup_init_subsys, there are now multiple css_sets, so each one
+	 * will need a new pointer to it; done by iterating the css_set_table.
+	 * furthermore, modifying the existing css_sets will corrupt the hash
+	 * table state, so each changed css_set will need its hash recomputed.
+	 * this is all done under the css_set_lock.
+	 */
+	write_lock(&css_set_lock);
+	for (i = 0; i < CSS_SET_TABLE_SIZE; i++) {
+		struct css_set *cg;
+		struct hlist_node *node, *tmp;
+		struct hlist_head *bucket = &css_set_table[i], *new_bucket;
+
+		hlist_for_each_entry_safe(cg, node, tmp, bucket, hlist) {
+			/* skip entries that we already rehashed */
+			if (cg->subsys[ss->subsys_id])
+				continue;
+			/* remove existing entry */
+			hlist_del(&cg->hlist);
+			/* set new value */
+			cg->subsys[ss->subsys_id] = css;
+			/* recompute hash and restore entry */
+			new_bucket = css_set_hash(cg->subsys);
+			hlist_add_head(&cg->hlist, new_bucket);
+		}
+	}
+	write_unlock(&css_set_lock);
+
+	mutex_init(&ss->hierarchy_mutex);
+	lockdep_set_class(&ss->hierarchy_mutex, &ss->subsys_key);
+	ss->active = 1;
+
+	/*
+	 * pin the subsystem's module so it doesn't go away. this shouldn't
+	 * fail, since the module's initcall calls us.
+	 * TODO: with module unloading, move this elsewhere
+	 */
+	BUG_ON(!try_module_get(ss->module));
+
+	/* success! */
+	mutex_unlock(&cgroup_mutex);
+	return 0;
 }
+EXPORT_SYMBOL_GPL(cgroup_load_subsys);
 
 /**
  * cgroup_init_early - cgroup initialization at system boot

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--oyUTqETQ0mS9luUI--
