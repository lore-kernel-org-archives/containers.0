From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 36/38] C/R: checkpoint/restore struct pid
Date: Fri, 22 May 2009 08:55:30 +0400
Message-ID: <1242968132-1044-36-git-send-email-adobriyan__20367.7673860968$1242969688$gmane$org@gmail.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1242968132-1044-1-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Deal with struct pid in general and task pids in particular.

Guess what, references to outside pids are banned which means
that if child is created with simple CLONE_NEWPID, it's PIDTYPE_PGID
and PIDTYPE_SID will be outside of newborn pidns.

On restore we don't know to where glue them and they weren't saved at all.
So abort checkpointing in this case.

New-born container inits should use setpgrp(2) and setsid(2)!

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/kstate-image.h   |   13 +++
 include/linux/kstate.h         |    5 +
 include/linux/pid.h            |    2 +-
 kernel/fork.c                  |    2 +-
 kernel/kstate/cpt-sys.c        |    6 +
 kernel/kstate/kstate-context.c |    5 +
 kernel/kstate/kstate-object.c  |    3 +
 kernel/kstate/kstate-task.c    |   80 ++++++++++++++++
 kernel/pid.c                   |  199 +++++++++++++++++++++++++++++++++++++++-
 9 files changed, 308 insertions(+), 7 deletions(-)

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index a573833..108bb2d 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -53,6 +53,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_GROUP_INFO	13
 #define KSTATE_OBJ_USER_STRUCT	14
 #define KSTATE_OBJ_USER_NS	15
+#define KSTATE_OBJ_PID		16
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -80,6 +81,10 @@ struct kstate_image_task_struct {
 	kstate_ref_t	ref_real_cred;
 	kstate_ref_t	ref_cred;
 
+	kstate_ref_t	ref_pid;
+	kstate_ref_t	ref_pgid;
+	kstate_ref_t	ref_sid;
+
 	__u8		comm[16];
 
 	/* Native arch of task, one of KSTATE_ARCH_*. */
@@ -305,4 +310,12 @@ struct kstate_image_user_ns {
 	 */
 	kstate_ref_t	ref_creator;
 } __packed;
+
+struct kstate_image_pid {
+	struct kstate_object_header hdr;
+
+	kstate_ref_t	ref_pid_ns;	/* last-level pid_ns */
+	__u32		level;
+	__u32		nr[1];
+} __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index f0c8e09..99a4345 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -33,6 +33,7 @@ enum kstate_context_obj_type {
 	KSTATE_CTX_NET_NS,
 #endif
 	KSTATE_CTX_NSPROXY,
+	KSTATE_CTX_PID,
 	KSTATE_CTX_PID_NS,
 	KSTATE_CTX_TASK_STRUCT,
 	KSTATE_CTX_USER_NS,
@@ -144,6 +145,10 @@ int kstate_collect_all_user_ns(struct kstate_context *ctx);
 int kstate_dump_all_user_ns(struct kstate_context *ctx);
 int kstate_restore_user_ns(struct kstate_context *ctx, kstate_ref_t *ref);
 
+int kstate_collect_all_pid(struct kstate_context *ctx);
+int kstate_dump_all_pid(struct kstate_context *ctx);
+int kstate_restore_pid(struct kstate_context *ctx, kstate_ref_t *ref);
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/include/linux/pid.h b/include/linux/pid.h
index 49f1c2f..f775a85 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -119,7 +119,7 @@ extern struct pid *find_get_pid(int nr);
 extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
 int next_pidmap(struct pid_namespace *pid_ns, int last);
 
-extern struct pid *alloc_pid(struct pid_namespace *ns);
+extern struct pid *alloc_pid(struct pid_namespace *ns, int *nr, unsigned int level);
 extern void free_pid(struct pid *pid);
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index ed377ad..97521ab 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1117,7 +1117,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 
 	if (pid != &init_struct_pid) {
 		retval = -ENOMEM;
-		pid = alloc_pid(p->nsproxy->pid_ns);
+		pid = alloc_pid(p->nsproxy->pid_ns, NULL, 0);
 		if (!pid)
 			goto bad_fork_cleanup_io;
 
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index 3df776e..119940d 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -101,6 +101,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_user_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_pid(ctx);
+	if (rv < 0)
+		return rv;
 	return 0;
 }
 
@@ -154,6 +157,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_pid_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_pid(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_user_ns(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index f8168cc..9acb441 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -81,6 +81,11 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_PID) {
+		put_pid((struct pid *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_PID_NS) {
 		put_pid_ns((struct pid_namespace *)obj->o_obj);
 		list_del(&obj->o_list);
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index eb77027..ab026f0 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -64,6 +64,9 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_NSPROXY:
 		get_nsproxy((struct nsproxy *)obj->o_obj);
 		break;
+	case KSTATE_CTX_PID:
+		get_pid((struct pid *)obj->o_obj);
+		break;
 	case KSTATE_CTX_PID_NS:
 		get_pid_ns((struct pid_namespace *)obj->o_obj);
 		break;
diff --git a/kernel/kstate/kstate-task.c b/kernel/kstate/kstate-task.c
index dc2387b..4a3524e 100644
--- a/kernel/kstate/kstate-task.c
+++ b/kernel/kstate/kstate-task.c
@@ -128,6 +128,13 @@ static int dump_task_struct(struct kstate_context *ctx, struct kstate_object *ob
 	tmp = find_kstate_obj_by_ptr(ctx, tsk->cred, KSTATE_CTX_CRED);
 	i->ref_cred = tmp->o_ref;
 
+	tmp = find_kstate_obj_by_ptr(ctx, tsk->pids[PIDTYPE_PID].pid, KSTATE_CTX_PID);
+	i->ref_pid = tmp->o_ref;
+	tmp = find_kstate_obj_by_ptr(ctx, tsk->pids[PIDTYPE_PGID].pid, KSTATE_CTX_PID);
+	i->ref_pgid = tmp->o_ref;
+	tmp = find_kstate_obj_by_ptr(ctx, tsk->pids[PIDTYPE_SID].pid, KSTATE_CTX_PID);
+	i->ref_sid = tmp->o_ref;
+
 	BUILD_BUG_ON(sizeof(i->comm) != sizeof(tsk->comm));
 	strlcpy((char *)i->comm, (const char *)tsk->comm, sizeof(i->comm));
 
@@ -280,6 +287,70 @@ static int restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 	return 0;
 }
 
+static int restore_pid(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct pid *pid;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_PID);
+	if (!tmp) {
+		rv = kstate_restore_pid(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_PID);
+	}
+	pid = tmp->o_obj;
+
+	write_lock_irq(&tasklist_lock);
+	change_pid(current, PIDTYPE_PID, get_pid(pid));
+	current->pid = current->tgid = pid_nr(pid);
+	write_unlock_irq(&tasklist_lock);
+	return 0;
+}
+
+static int restore_pgid(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct pid *pid;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_PID);
+	if (!tmp) {
+		rv = kstate_restore_pid(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_PID);
+	}
+	pid = tmp->o_obj;
+
+	write_lock_irq(&tasklist_lock);
+	change_pid(current, PIDTYPE_PGID, pid);
+	write_unlock_irq(&tasklist_lock);
+	return 0;
+}
+
+static int restore_sid(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct pid *pid;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_PID);
+	if (!tmp) {
+		rv = kstate_restore_pid(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_PID);
+	}
+	pid = tmp->o_obj;
+
+	write_lock_irq(&tasklist_lock);
+	change_pid(current, PIDTYPE_SID, pid);
+	write_unlock_irq(&tasklist_lock);
+	return 0;
+}
+
 struct task_struct_restore_context {
 	struct kstate_context *ctx;
 	struct kstate_image_task_struct *i;
@@ -334,6 +405,15 @@ static int task_struct_restorer(void *_tsk_ctx)
 	rv = restore_cred(ctx, &i->ref_cred);
 	if (rv < 0)
 		goto out;
+	rv = restore_pid(ctx, &i->ref_pid);
+	if (rv < 0)
+		goto out;
+	rv = restore_pgid(ctx, &i->ref_pgid);
+	if (rv < 0)
+		goto out;
+	rv = restore_sid(ctx, &i->ref_sid);
+	if (rv < 0)
+		goto out;
 
 out:
 	tsk_ctx->rv = rv;
diff --git a/kernel/pid.c b/kernel/pid.c
index b2e5f78..bacf279 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -23,6 +23,7 @@
  *    (C) 2007 Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, OpenVZ, SWsoft Inc.
  *    (C) 2007 Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, IBM
  *     Many thanks to Oleg Nesterov for comments and help
+ * Copyright (C) 2000-2009 Parallels Holdings, Ltd.
  *
  */
 
@@ -182,6 +183,36 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 	return -1;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int set_pidmap(struct pid_namespace *pid_ns, pid_t pid)
+{
+	int offset;
+	struct pidmap *map;
+
+	offset = pid & BITS_PER_PAGE_MASK;
+	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
+	if (!map->page) {
+		void *page = kzalloc(PAGE_SIZE, GFP_KERNEL);
+		/*
+		 * Free the page if someone raced with us
+		 * installing it.
+		 */
+		spin_lock_irq(&pidmap_lock);
+		if (map->page)
+			kfree(page);
+		else
+			map->page = page;
+		spin_unlock_irq(&pidmap_lock);
+		if (unlikely(!map->page))
+			return -ENOMEM;
+	}
+	if (test_and_set_bit(offset, map->page))
+		return -EBUSY;
+	atomic_dec(&map->nr_free);
+	return pid;
+}
+#endif
+
 int next_pidmap(struct pid_namespace *pid_ns, int last)
 {
 	int offset;
@@ -239,11 +270,12 @@ void free_pid(struct pid *pid)
 	call_rcu(&pid->rcu, delayed_put_pid);
 }
 
-struct pid *alloc_pid(struct pid_namespace *ns)
+/* Last level + 1 pid numbers are predefined. */
+struct pid *alloc_pid(struct pid_namespace *ns, int *nr, unsigned int level)
 {
 	struct pid *pid;
 	enum pid_type type;
-	int i, nr;
+	int i, pid_nr;
 	struct pid_namespace *tmp;
 	struct upid *upid;
 
@@ -253,11 +285,16 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 
 	tmp = ns;
 	for (i = ns->level; i >= 0; i--) {
-		nr = alloc_pidmap(tmp);
-		if (nr < 0)
+#ifdef CONFIG_CHECKPOINT
+		if (nr && ns->level - i <= level)
+			pid_nr = set_pidmap(tmp, nr[ns->level - i]);
+		else
+#endif
+			pid_nr = alloc_pidmap(tmp);
+		if (pid_nr < 0)
 			goto out_free;
 
-		pid->numbers[i].nr = nr;
+		pid->numbers[i].nr = pid_nr;
 		pid->numbers[i].ns = tmp;
 		tmp = tmp->parent;
 	}
@@ -537,3 +574,155 @@ void __init pidmap_init(void)
 	init_pid_ns.pid_cachep = KMEM_CACHE(pid,
 			SLAB_HWCACHE_ALIGN | SLAB_PANIC);
 }
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int collect_pid(struct kstate_context *ctx, struct pid *pid)
+{
+	int rv;
+
+	rv = kstate_collect_object(ctx, pid, KSTATE_CTX_PID);
+	pr_debug("collect pid %p: rv %d\n", pid, rv);
+	return rv;
+}
+
+static int collect_task_pid(struct kstate_context *ctx, struct pid *pid)
+{
+	unsigned int level0, level;
+
+	level0 = ctx->init_tsk->nsproxy->pid_ns->level;
+	if (pid->level < level0) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	for (level = level0; level <= pid->level; level++) {
+		struct pid_namespace *pid_ns;
+		struct kstate_object *tmp;
+
+		pid_ns = pid->numbers[level].ns;
+		tmp = find_kstate_obj_by_ptr(ctx, pid_ns, KSTATE_CTX_PID_NS);
+		if (!tmp) {
+			WARN_ON(1);
+			return -EINVAL;
+		}
+	}
+	return collect_pid(ctx, pid);
+}
+
+int kstate_collect_all_pid(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = collect_task_pid(ctx, tsk->pids[PIDTYPE_PID].pid);
+		if (rv < 0)
+			return rv;
+		rv = collect_task_pid(ctx, tsk->pids[PIDTYPE_PGID].pid);
+		if (rv < 0)
+			return rv;
+		rv = collect_task_pid(ctx, tsk->pids[PIDTYPE_SID].pid);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int dump_pid(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct pid *pid = obj->o_obj;
+	struct kstate_image_pid *i;
+	struct kstate_object *tmp;
+	unsigned int level0, level;
+	unsigned int image_len;
+	int rv;
+
+	level0 = ctx->init_tsk->nsproxy->pid_ns->level;
+	image_len = sizeof(*i) + (pid->level - level0 + 1) * sizeof(__u32);
+	i = kstate_prepare_image(KSTATE_OBJ_PID, image_len);
+	if (!i)
+		return -ENOMEM;
+
+	tmp = find_kstate_obj_by_ptr(ctx, pid->numbers[pid->level].ns, KSTATE_CTX_PID_NS);
+	i->ref_pid_ns = tmp->o_ref;
+
+	i->level = pid->level - level0;
+	for (level = level0; level <= pid->level; level++)
+		i->nr[level - level0] = pid->numbers[level].nr;
+
+	rv = kstate_write_image(ctx, i, image_len, obj);
+	kfree(i);
+	pr_debug("dump pid %p: ref {%llu, %u}, rv %d\n", pid, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_pid(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_PID) {
+		rv = dump_pid(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_pid(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_pid *i;
+	struct pid *pid;
+	struct pid_namespace *pid_ns;
+	struct kstate_object *tmp;
+	unsigned int level0;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_PID, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+	if (i->level > ((__u32)-1 - sizeof(*i)) / sizeof(__u32) - 1) {
+		rv = -EINVAL;
+		goto out_free_image;
+	}
+	if (i->hdr.obj_len != sizeof(*i) + (i->level + 1) * sizeof(__u32)) {
+		rv = -EINVAL;
+		goto out_free_image;
+	}
+
+	tmp = find_kstate_obj_by_ref(ctx, &i->ref_pid_ns, KSTATE_CTX_PID_NS);
+	if (!tmp) {
+		rv = kstate_restore_pid_ns(ctx, &i->ref_pid_ns);
+		if (rv < 0)
+			goto out_free_image;
+		tmp = find_kstate_obj_by_ref(ctx, &i->ref_pid_ns, KSTATE_CTX_PID_NS);
+	}
+	pid_ns = tmp->o_obj;
+
+	level0 = ctx->init_tsk->nsproxy->pid_ns->level;
+	if (i->level >= pid_ns->level - level0) {
+		rv = -EINVAL;
+		goto out_free_image;
+	}
+
+	pid = alloc_pid(pid_ns, i->nr, i->level);
+	kfree(i);
+	if (!pid)
+		return -ENOMEM;
+
+	rv = kstate_restore_object(ctx, pid, KSTATE_CTX_PID, ref);
+	if (rv < 0)
+		put_pid(pid);
+	pr_debug("restore pid %p: ref {%lld, %u}, rv %d\n", pid, (unsigned long long)ref->pos, ref->id, rv);
+	return rv;
+
+out_free_image:
+	kfree(i);
+	pr_debug("%s: return %d, ref {%llu, %u}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
+	return rv;
+}
+#endif
-- 
1.5.6.5
