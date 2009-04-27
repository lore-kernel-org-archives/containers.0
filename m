From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: define CHECKPOINT_SUBTREE flag and sysctl
Date: Sun, 26 Apr 2009 23:37:31 -0500
Message-ID: <20090427043731.GA21173@us.ibm.com>
References: <20090424210608.GA16973@us.ibm.com> <m3vdotk34g.fsf@pobox.com>
	<20090425024515.GA4534@hallyn.com>
	<20090425025154.GA4596@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090425025154.GA4596-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> There's no need for a sysctl disallowing the CHECKPOINT_SUBTREE
> flag.  There should just be a unprivileged_checkpoint sysctl
> determining whether CAP_SYS_ADMIN is always needed.  Then
> the optional CHECKPOINT_SUBTREE is always allowed.
> 
> That makes much more sense.  Thanks, Nathan.
> 
> -serge

So here is the very slight rework:


From f1ee7090ba5896834952d46b7c73f086ca761721 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 23 Apr 2009 11:37:23 -0700
Subject: [PATCH 1/1] cr: define subtree flag and unpriv_allowed sysctl

Define a sysctl 'ckpt_unpriv_allowed' which determines
whether all checkpoints and restarts require CAP_SYS_ADMIN.
If it is 1, then regular permission checks are intended
to prevent privilege escalation, but leaving it at 0
prevents unprivileged users from exploiting any privilege
escalation bugs.

Define a CHECKPOINT_SUBTREE flag for sys_checkpoint() which
says it's ok if the the checkpointed set of tasks are not
a fully isolated container without leaks.

Finally, add a 'users' count to objhash items, and, for a
!CHECKPOINT_SUBTREE checkpoint, return an error code if
the actual objects' counts are higher, indicating leaks
(references to the objects from a task not being checkpointed).
Of course, by this time most of the checkpoint image has been
written out to disk, so this is purely advisory.  But then,
it's probably naive to argue that anything more than an
advisory 'this went wrong' error code is useful.

The comparison of the objhash user counts to object
refcounts as a basis for checking for leaks comes from
Alexey's OpenVZ-based c/r patchset.

TODO: I still need to figure out what to do about
CONFIG_*_NS dependencies in the cr_check_leaks() fn.

Changelog:
	Apr 24: save/restore mm->exefile separately as
		part of cr_{read,write}_mm as per
		Oren's suggestion.
	Apr 24: incorporated Oren's feedback (renamed
		the sysctl and flag, cleaned up the
		leaks check fn, moved the is_root check
		to start of checkpoint, return -EBUSY
		instead of -1, removed mm->exefile check
		from ckpt_file.c.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c        |   98 ++++++++++++++++++++++++++++++++++++++++
 checkpoint/ckpt_file.c         |    5 +-
 checkpoint/ckpt_mem.c          |   24 +++++++++-
 checkpoint/objhash.c           |   19 +++-----
 checkpoint/objhash.h           |   18 +++++++
 checkpoint/restart.c           |    2 +-
 checkpoint/rstr_mem.c          |   20 ++++++++
 checkpoint/sys.c               |   16 +++++-
 include/linux/checkpoint.h     |   13 ++++-
 include/linux/checkpoint_hdr.h |    2 +
 kernel/sysctl.c                |   17 +++++++
 11 files changed, 209 insertions(+), 25 deletions(-)
 create mode 100644 checkpoint/objhash.h

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 7382cc3..e42d3eb 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -25,6 +25,7 @@
 #include <linux/checkpoint_hdr.h>
 
 #include "checkpoint_arch.h"
+#include "objhash.h"
 
 /* unique checkpoint identifier (FIXME: should be per-container ?) */
 static atomic_t cr_ctx_count = ATOMIC_INIT(0);
@@ -487,6 +488,9 @@ static int cr_get_container(struct cr_ctx *ctx, pid_t pid)
 	ctx->root_nsproxy = nsproxy;
 	ctx->root_init = is_container_init(task);
 
+	if (!(ctx->flags & CHECKPOINT_SUBTREE) && !ctx->root_init)
+		return -EBUSY;
+
 	return 0;
 
  out:
@@ -523,6 +527,96 @@ static int cr_ctx_checkpoint(struct cr_ctx *ctx, pid_t pid)
 	return 0;
 }
 
+static int check_obj_isolated(struct cr_ctx *ctx, struct cr_objref *ref)
+{
+	struct uts_namespace *utsns;
+	struct ipc_namespace *ipcns;
+	struct file *file;
+	struct mm_struct *mm;
+	unsigned long cnt, cnt2;
+	int ret = 1;
+
+	/* note - one might think it worthwhile to put the ns
+	 * ones under #ifdefs for the CONFIG_X_NS, but instead
+	 * it CONFIG_CHECKPOINT should depend on all of those
+	 */
+	/* note2: the objhash has taken a reference, so we account
+	 * for that */
+
+	cnt = ref->users + 1;
+	switch (ref->type) {
+	case CR_OBJ_UTSNS:
+		utsns = ref->ptr;
+		cnt2 = (unsigned long) atomic_read(&utsns->kref.refcount);
+		if (cnt != cnt2) {
+			cr_debug("uts namespace leak\n");
+			printk(KERN_NOTICE "%s: uts: %lu users count %lu\n",
+				__func__, cnt, cnt2);
+			ret = 0;
+		}
+		break;
+	case CR_OBJ_IPCNS:
+		ipcns = ref->ptr;
+		cnt2 = (unsigned long) atomic_read(&ipcns->kref.refcount);
+		if (cnt != cnt2) {
+			cr_debug("ipc namespace leak\n");
+			printk(KERN_NOTICE "%s: ipc: %lu users count %lu\n",
+				__func__, cnt, cnt2);
+			ret = 0;
+		}
+		break;
+	case CR_OBJ_FILE:
+		file = ref->ptr;
+		if (file == ctx->file)
+			cnt++;
+		cnt2 = (unsigned long) atomic_long_read(&file->f_count);
+		if (cnt != cnt2) {
+			cr_debug("file usage leak\n");
+			printk(KERN_NOTICE "%s: file: %lu users count %lu\n",
+				__func__, cnt, cnt2);
+			printk(KERN_NOTICE "%s: filename is %s (%s)\n",
+				__func__, file->f_dentry->d_iname,
+				file->f_dentry->d_name.name);
+			ret = 0;
+		}
+		break;
+	case CR_OBJ_MM:
+		mm = ref->ptr;
+		cnt2 = (unsigned long) atomic_read(&mm->mm_users);
+		if (cnt != cnt2) {
+			cr_debug("mm usage leak\n");
+			printk(KERN_NOTICE "%s: mm: %lu users count %lu\n",
+				__func__, cnt, cnt2);
+			ret = 0;
+		}
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+static int cr_check_leaks(struct cr_ctx *ctx)
+{
+	struct cr_objref *ref;
+	struct hlist_node *node;
+
+	if (ctx->flags & CHECKPOINT_SUBTREE)
+		return 0;
+
+	/* Make sure the uts and ipc namespaces aren't
+	 * shared with any tasks not being checkpointed */
+	hlist_for_each_entry(ref, node, &ctx->objhash->all_nodes, next) {
+		if (!check_obj_isolated(ctx, ref))
+			return -EBUSY;
+	}
+
+	/* TODO: check netns, etc */
+
+	return 0;
+}
+
 int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
 {
 	int ret;
@@ -550,6 +644,10 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		goto out;
 
+	ret = cr_check_leaks(ctx);
+	if (ret < 0)
+		goto out;
+
 	ctx->crid = atomic_inc_return(&cr_ctx_count);
 
 	/* on success, return (unique) checkpoint identifier */
diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
index 8be6abe..04ce1a0 100644
--- a/checkpoint/ckpt_file.c
+++ b/checkpoint/ckpt_file.c
@@ -146,7 +146,8 @@ int cr_write_file(struct cr_ctx *ctx, struct file *file)
  * otherwise calls cr_write_file to dump the file pointer too.
  */
 static int
-cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int fd)
+cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int fd,
+		struct task_struct *t)
 {
 	struct cr_hdr h;
 	struct cr_hdr_fd_ent *hh;
@@ -236,7 +237,7 @@ int cr_write_fd_table(struct cr_ctx *ctx, struct task_struct *t)
 
 	cr_debug("nfds %d\n", nfds);
 	for (n = 0; n < nfds; n++) {
-		ret = cr_write_fd_ent(ctx, files, fdtable[n]);
+		ret = cr_write_fd_ent(ctx, files, fdtable[n], t);
 		if (ret < 0)
 			break;
 	}
diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
index 54b2674..834a78e 100644
--- a/checkpoint/ckpt_mem.c
+++ b/checkpoint/ckpt_mem.c
@@ -616,10 +616,12 @@ static enum cr_vma_type cr_shared_vma_type(struct vm_area_struct *vma, int old)
  * cr_write_vma - classify the vma and dump its contents
  * @ctx: checkpoint context
  * @vma: vma object
+ * @task: owning task
  *
  * (see vma subtypes in checkpoint_hdr.h)
  */
-static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
+static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma,
+			struct task_struct *task)
 {
 	struct cr_hdr h;
 	struct cr_hdr_vma *hh;
@@ -742,11 +744,19 @@ int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
 	struct cr_hdr_mm *hh;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
-	int objref, new;
+	int objref, new, exe_new;
+	int exefile_objref;
 	int ret;
 
 	mm = get_task_mm(t);
 
+	exe_new = cr_obj_add_ptr(ctx, mm->exe_file, &exefile_objref,
+				CR_OBJ_FILE, 0);
+	if (exe_new < 0) {
+		ret = exe_new;
+		goto mmput;
+	}
+
 	new = cr_obj_add_ptr(ctx, mm, &objref, CR_OBJ_MM, 0);
 	if (new < 0) {
 		ret = new;
@@ -764,6 +774,7 @@ int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
 	down_read(&mm->mmap_sem);
 
 	hh->objref = objref;
+	hh->exefile_objref = exefile_objref;
 
 	hh->start_code = mm->start_code;
 	hh->end_code = mm->end_code;
@@ -786,10 +797,17 @@ int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
 	if (ret < 0)
 		goto out;
 
+	if (exe_new) {
+		/* write out the exe_file */
+		ret = cr_write_file(ctx, mm->exe_file);
+		if (ret < 0)
+			goto out;
+	}
+
 	if (new) {
 		/* write the vma's */
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
-			ret = cr_write_vma(ctx, vma);
+			ret = cr_write_vma(ctx, vma, t);
 			if (ret < 0)
 				goto out;
 		}
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 2ffa098..c26a0d3 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -15,18 +15,7 @@
 #include <linux/ipc_namespace.h>
 #include <linux/checkpoint.h>
 
-struct cr_objref {
-	int objref;
-	void *ptr;
-	unsigned short type;
-	unsigned short flags;
-	struct hlist_node hash;
-};
-
-struct cr_objhash {
-	struct hlist_head *head;
-	int next_free_objref;
-};
+#include "objhash.h"
 
 #define CR_OBJHASH_NBITS  10
 #define CR_OBJHASH_TOTAL  (1UL << CR_OBJHASH_NBITS)
@@ -125,12 +114,13 @@ int cr_objhash_alloc(struct cr_ctx *ctx)
 
 	objhash->head = head;
 	objhash->next_free_objref = 1;
+	INIT_HLIST_HEAD(&objhash->all_nodes);
 
 	ctx->objhash = objhash;
 	return 0;
 }
 
-static struct cr_objref *cr_obj_find_by_ptr(struct cr_ctx *ctx, void *ptr)
+struct cr_objref *cr_obj_find_by_ptr(struct cr_ctx *ctx, void *ptr)
 {
 	struct hlist_head *h;
 	struct hlist_node *n;
@@ -184,6 +174,7 @@ static struct cr_objref *cr_obj_new(struct cr_ctx *ctx, void *ptr, int objref,
 	obj->ptr = ptr;
 	obj->type = type;
 	obj->flags = flags;
+	obj->users = 0;
 
 	ret = cr_obj_ref_grab(obj);
 	if (ret < 0) {
@@ -202,6 +193,7 @@ static struct cr_objref *cr_obj_new(struct cr_ctx *ctx, void *ptr, int objref,
 	}
 
 	hlist_add_head(&obj->hash, &ctx->objhash->head[i]);
+	hlist_add_head(&obj->next, &ctx->objhash->all_nodes);
 	return obj;
 }
 
@@ -241,6 +233,7 @@ int cr_obj_add_ptr(struct cr_ctx *ctx, void *ptr, int *objref,
 	} else if (obj->type != type)	/* sanity check */
 		return -EINVAL;
 	*objref = obj->objref;
+	obj->users++;
 	return ret;
 }
 
diff --git a/checkpoint/objhash.h b/checkpoint/objhash.h
new file mode 100644
index 0000000..cc56464
--- /dev/null
+++ b/checkpoint/objhash.h
@@ -0,0 +1,18 @@
+#include <linux/list.h>
+
+struct cr_objref {
+	int objref;
+	void *ptr;
+	unsigned short type;
+	unsigned short flags;
+	struct hlist_node hash;
+	unsigned long users;
+	struct hlist_node next;
+};
+
+struct cr_objhash {
+	struct hlist_head *head;
+	struct hlist_head all_nodes;
+	int next_free_objref;
+};
+
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 5293b9a..67db880 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -193,7 +193,7 @@ static int cr_read_head(struct cr_ctx *ctx)
 	    hh->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
 	    hh->patch != ((LINUX_VERSION_CODE) & 0xff))
 		goto out;
-	if (hh->flags & ~CR_CTX_CKPT)
+	if (hh->flags & ~(CR_CTX_CKPT|CHECKPOINT_VALID_FLAGS))
 		goto out;
 	if (hh->uts_release_len != sizeof(uts->release) ||
 	    hh->uts_version_len != sizeof(uts->version) ||
diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
index 9de770d..84a7255 100644
--- a/checkpoint/rstr_mem.c
+++ b/checkpoint/rstr_mem.c
@@ -19,6 +19,7 @@
 #include <linux/mm.h>
 #include <linux/err.h>
 #include <linux/syscalls.h>
+#include <linux/proc_fs.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -519,6 +520,7 @@ int cr_read_mm(struct cr_ctx *ctx)
 	struct mm_struct *mm;
 	unsigned int nr;
 	int ret;
+	struct file *exe_file;
 
 	hh = cr_hbuf_get(ctx, sizeof(*hh));
 	if (!hh)
@@ -580,6 +582,24 @@ int cr_read_mm(struct cr_ctx *ctx)
 	mm->arg_end = hh->arg_end;
 	mm->env_start = hh->env_start;
 	mm->env_end = hh->env_end;
+	exe_file = cr_obj_get_by_ref(ctx, hh->exefile_objref, CR_OBJ_FILE);
+	if (exe_file < 0) {
+		ret = -ENOENT;
+		up_write(&mm->mmap_sem);
+		goto out;
+	}
+	if (!exe_file) {
+		/* really it can't be the case that it NOT be NULL... */
+		int fd = cr_read_file(ctx, hh->exefile_objref);
+		if (fd < 0) {
+			ret = fd;
+			up_write(&mm->mmap_sem);
+			goto out;
+		}
+		exe_file = fget(fd);
+		sys_close(fd);
+	}
+	set_mm_exe_file(mm, exe_file);
 	up_write(&mm->mmap_sem);
 
 	/* FIX: need also mm->flags */
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 3dfb7d9..4757b11 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -20,6 +20,11 @@
 
 #include "checkpoint_mem.h"
 
+/* ckpt_unpriv_allowed - sysctl_controlled, do not allow
+ * checkpoint of a set of tasks which do not form a fully
+ * isolated container, if 0 */
+int ckpt_unpriv_allowed;
+
 /*
  * Helpers to write(read) from(to) kernel space to(from) the checkpoint
  * image file descriptor (similar to how a core-dump is performed).
@@ -270,10 +275,12 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
 	struct cr_ctx *ctx;
 	int ret;
 
-	/* no flags for now */
-	if (flags)
+	if (flags & ~CHECKPOINT_VALID_FLAGS)
 		return -EINVAL;
 
+	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
 	if (pid == 0)
 		pid = current->pid;
 	ctx = cr_ctx_alloc(fd, flags | CR_CTX_CKPT);
@@ -304,7 +311,10 @@ asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
 	pid_t pid;
 	int ret;
 
-	/* no flags for now */
+	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	/* no restart flags for now */
 	if (flags)
 		return -EINVAL;
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 82d2a40..175d727 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -33,7 +33,7 @@ struct cr_ctx {
 	unsigned long flags;
 	unsigned long oflags;	/* restart: old flags */
 
-	struct file *file;
+	struct file *file;	/* file to write image to */
 	int total;		/* total read/written */
 
 	void *hbuf;		/* temporary buffer for headers */
@@ -63,8 +63,12 @@ struct cr_ctx {
 };
 
 /* cr_ctx: flags */
-#define CR_CTX_CKPT	0x1
-#define CR_CTX_RSTR	0x2
+#define CR_CTX_CKPT		0x1
+#define CR_CTX_RSTR		0x2
+#define CHECKPOINT_SUBTREE	0x4
+
+#define CHECKPOINT_VALID_FLAGS CHECKPOINT_SUBTREE
+
 
 extern int cr_kwrite(struct cr_ctx *ctx, void *buf, int count);
 extern int cr_kread(struct cr_ctx *ctx, void *buf, int count);
@@ -96,6 +100,9 @@ extern int cr_obj_add_ptr(struct cr_ctx *ctx, void *ptr, int *objref,
 			  unsigned short type, unsigned short flags);
 extern int cr_obj_add_ref(struct cr_ctx *ctx, void *ptr, int objref,
 			  unsigned short type, unsigned short flags);
+extern void cr_obj_inc_by_ptr(struct cr_ctx *ctx, void *ptr);
+
+/* defined in checkpoint/ckpt_file.c */
 
 struct cr_hdr;
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 92b0336..c3c537e 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -162,11 +162,13 @@ struct cr_hdr_utsns {
 
 struct cr_hdr_mm {
 	__s32 objref;		/* identifier for shared objects */
+	__s32 exefile_objref;	/* objref for the exefile */
 	__u32 map_count;
 
 	__u64 start_code, end_code, start_data, end_data;
 	__u64 start_brk, brk, start_stack;
 	__u64 arg_start, arg_end, env_start, env_end;
+
 } __attribute__((aligned(8)));
 
 /* vma subtypes */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c5ef44f..1bb10b2 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -193,6 +193,10 @@ int sysctl_legacy_va_layout;
 extern int prove_locking;
 extern int lock_stat;
 
+#ifdef CONFIG_CHECKPOINT
+extern int ckpt_unpriv_allowed;
+#endif
+
 /* The default sysctl tables: */
 
 static struct ctl_table root_table[] = {
@@ -900,6 +904,19 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= &scan_unevictable_handler,
 	},
 #endif
+#ifdef CONFIG_CHECKPOINT
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "ckpt_unpriv_allowed",
+		.data		= &ckpt_unpriv_allowed,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+#endif
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
-- 
1.5.4.3
