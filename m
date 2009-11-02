From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [RFC][PATCH 2/3] cgroups: subsystem module interface
Date: Mon, 2 Nov 2009 16:30:22 -0500
Message-ID: <20091102213022.GC13692@andrew.cmu.edu>
References: <20091102212825.GA13692@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: attachment;
	filename="cgroups-subsys-module-interface.patch"
In-Reply-To: <20091102212825.GA13692-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lizf-zuA2N8Q4brPw3oLZptLEjg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org
List-Id: containers.vger.kernel.org

Add interface between cgroups subsystem management and module loading

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

This patch implements rudimentary module-loading support for cgroups - namely,
a cgroup_load_subsys (similar to cgroup_init_subsys) for use as a module
initcall, and a struct module pointer in struct cgroup_subsys. Support for
subsystem unloading not here, yet to be done (requires more advanced reference
counting, for one thing).

I tested compiling a subsystem outside of the kernel source tree, and it was
apparent that I wanted the EXPORT_SYMBOL for several functions, but I'm not
sure what else it might be good to put them on. Suggestions welcome.

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
---

 include/linux/cgroup.h |    4 ++
 kernel/cgroup.c        |   92 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 96 insertions(+), 0 deletions(-)


diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index d7f1545..c8474c4 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -38,6 +38,7 @@ extern void cgroup_fork_failed(struct task_struct *p, int run_callbacks,
 			       unsigned long clone_flags);
 extern int cgroupstats_build(struct cgroupstats *stats,
 				struct dentry *dentry);
+extern int cgroup_load_subsys(struct cgroup_subsys *ss);
 
 extern struct file_operations proc_cgroup_operations;
 
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
index 9966dfe..8eba8a5 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2491,6 +2491,7 @@ int cgroup_add_file(struct cgroup *cgrp,
 		error = PTR_ERR(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(cgroup_add_file);
 
 int cgroup_add_files(struct cgroup *cgrp,
 			struct cgroup_subsys *subsys,
@@ -2505,6 +2506,7 @@ int cgroup_add_files(struct cgroup *cgrp,
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cgroup_add_files);
 
 /**
  * cgroup_task_count - count the number of tasks in a cgroup.
@@ -3650,7 +3652,97 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
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
+	/* check name validity */
+	if (ss->name == NULL || strlen(ss->name) > MAX_CGROUP_TYPE_NAMELEN)
+		return -EINVAL;
+
+	/* we don't support callbacks in modular subsystems. this check is
+	 * before the ss->module check for consistency - a module that *could*
+	 * be a module should still have no callbacks for consistency. */
+	if (ss->fork || ss->exit)
+		return -EINVAL;
+
+	/* an optionally modular subsystem is built-in: we want to do nothing,
+	 * since cgroup_init_subsys will take care of it. */
+	if (ss->module == NULL) {
+		/* sanity: ss->module NULL only if the subsys is built-in and
+		 * appears in subsys[] already. */
+		BUG_ON(ss->subsys_id >= CGROUP_BUILTIN_SUBSYS_COUNT);
+		BUG_ON(subsys[ss->subsys_id] != ss);
+		return 0;
+	}
+
+	/* need to register a subsys id before anything else - for example,
+	 * init_cgroup_css needs it. also, subsys_mutex needs to nest outside
+	 * cgroup_mutex. */
+	down_write(&subsys_mutex);
+	/* find the first empty slot in the array */
+	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
+		if (subsys[i] == NULL)
+			break;
+	}
+	if (i == CGROUP_SUBSYS_COUNT) {
+		/* maximum number of subsystems already registered! */
+		up_write(&subsys_mutex);
+		return -EBUSY;
+	}
+	/* assign ourselves the subsys_id */
+	ss->subsys_id = i;
+	subsys[i] = ss;
+
+	mutex_lock(&cgroup_mutex);
+	/* no ss->create seems to need anything important in the ss struct, so
+	 * this can happen first (i.e. before the rootnode attachment). */
+	css = ss->create(ss, dummytop);
+	if (IS_ERR(css)) {
+		/* failure case - need to deassign the subsys[] slot. */
+		mutex_unlock(&cgroup_mutex);
+		subsys[i] = NULL;
+		up_write(&subsys_mutex);
+		return PTR_ERR(css);
+	}
+
+	list_add(&ss->sibling, &rootnode.subsys_list);
+	ss->root = &rootnode;
+
+	init_cgroup_css(css, ss, dummytop);
+	init_css_set.subsys[ss->subsys_id] = dummytop->subsys[ss->subsys_id];
+
+	mutex_init(&ss->hierarchy_mutex);
+	lockdep_set_class(&ss->hierarchy_mutex, &ss->subsys_key);
+	ss->active = 1;
+
+	/* pin the subsystem's module so it doesn't go away. this shouldn't
+	 * fail, since the module's initcall calls us.
+	 * TODO: with module unloading, move this elsewhere */
+	BUG_ON(!try_module_get(ss->module));
+
+	/* success! */
+	mutex_unlock(&cgroup_mutex);
+	up_write(&subsys_mutex);
+	return 0;
 }
+EXPORT_SYMBOL_GPL(cgroup_load_subsys);
 
 /**
  * cgroup_init_early - cgroup initialization at system boot
