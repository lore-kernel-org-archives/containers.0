From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 37/38] C/R: checkpoint/restore opened files
Date: Fri, 22 May 2009 08:55:31 +0400
Message-ID: <1242968132-1044-37-git-send-email-adobriyan__6104.70006145096$1242971306$gmane$org@gmail.com>
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

File descriptor is dumped as formally an object, despite it can't be shared
by itself, only files_struct can.

Opening is done, veryfying that we opened right file, restoration of file
position and nothing more.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/kstate-image.h   |   16 +++
 include/linux/kstate.h         |    6 +
 kernel/kstate/cpt-sys.c        |    6 +
 kernel/kstate/kstate-context.c |    6 +
 kernel/kstate/kstate-file.c    |  201 ++++++++++++++++++++++++++++++++++++++++
 kernel/kstate/kstate-object.c  |    4 +
 kernel/kstate/kstate-task.c    |   54 +++++++++++
 7 files changed, 293 insertions(+), 0 deletions(-)

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 108bb2d..700fc62 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -54,6 +54,8 @@ struct kstate_image_header {
 #define KSTATE_OBJ_USER_STRUCT	14
 #define KSTATE_OBJ_USER_NS	15
 #define KSTATE_OBJ_PID		16
+#define KSTATE_OBJ_FILES_STRUCT	17
+#define KSTATE_OBJ_FD		18
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -77,6 +79,7 @@ struct kstate_image_task_struct {
 
 	kstate_ref_t	ref_mm;
 	kstate_ref_t	ref_nsproxy;
+	kstate_ref_t	ref_files;
 
 	kstate_ref_t	ref_real_cred;
 	kstate_ref_t	ref_cred;
@@ -318,4 +321,17 @@ struct kstate_image_pid {
 	__u32		level;
 	__u32		nr[1];
 } __packed;
+
+struct kstate_image_files_struct {
+	struct kstate_object_header hdr;
+} __packed;
+
+struct kstate_image_fd {
+	struct kstate_object_header hdr;
+
+	kstate_ref_t	ref_file;
+	__u32		fd;
+#define KSTATE_FD_FLAGS_CLOEXEC		(1 << 0)
+	__u32		fd_flags;
+} __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index 99a4345..2473381 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -23,6 +23,7 @@ struct kstate_object {
 enum kstate_context_obj_type {
 	KSTATE_CTX_CRED,
 	KSTATE_CTX_FILE,
+	KSTATE_CTX_FILES_STRUCT,
 	KSTATE_CTX_GROUP_INFO,
 #ifdef CONFIG_IPC_NS
 	KSTATE_CTX_IPC_NS,
@@ -149,6 +150,11 @@ int kstate_collect_all_pid(struct kstate_context *ctx);
 int kstate_dump_all_pid(struct kstate_context *ctx);
 int kstate_restore_pid(struct kstate_context *ctx, kstate_ref_t *ref);
 
+int kstate_collect_all_files_struct(struct kstate_context *ctx);
+int kstate_dump_all_files_struct(struct kstate_context *ctx);
+int kstate_restore_files_struct(struct kstate_context *ctx, kstate_ref_t *ref);
+int kstate_restore_fd(struct kstate_context *ctx, kstate_pos_t pos);
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index 119940d..05fc9d8 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -86,6 +86,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_files_struct(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_collect_all_file(ctx);
 	if (rv < 0)
 		return rv;
@@ -175,6 +178,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_file(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_files_struct(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index 9acb441..3e1589f 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -1,4 +1,5 @@
 /* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fdtable.h>
 #include <linux/file.h>
 #include <linux/ipc_namespace.h>
 #include <linux/list.h>
@@ -47,6 +48,11 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_FILES_STRUCT) {
+		put_files_struct((struct files_struct *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_GROUP_INFO) {
 		put_group_info((struct group_info *)obj->o_obj);
 		list_del(&obj->o_list);
diff --git a/kernel/kstate/kstate-file.c b/kernel/kstate/kstate-file.c
index f378be3..b11828b 100644
--- a/kernel/kstate/kstate-file.c
+++ b/kernel/kstate/kstate-file.c
@@ -58,6 +58,20 @@ int kstate_collect_all_file(struct kstate_context *ctx)
 	struct kstate_object *obj;
 	int rv;
 
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_FILES_STRUCT) {
+		struct files_struct *files = obj->o_obj;
+		struct file *file;
+		int fd;
+
+		for (fd = 0; fd < files->fdt->max_fds; fd++) {
+			file = fcheck_files(files, fd);
+			if (!file)
+				continue;
+			rv = collect_file(ctx, file);
+			if (rv < 0)
+				return rv;
+		}
+	}
 	for_each_kstate_object(ctx, obj, KSTATE_CTX_MM_STRUCT) {
 		struct mm_struct *mm = obj->o_obj;
 		struct vm_area_struct *vma;
@@ -232,3 +246,190 @@ out_free_image:
 	pr_debug("%s: return %d, ref {%llu, %u}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
 	return rv;
 }
+
+static int collect_files_struct(struct kstate_context *ctx, struct files_struct *files)
+{
+	int rv;
+
+	rv = kstate_collect_object(ctx, files, KSTATE_CTX_FILES_STRUCT);
+	pr_debug("collect files_struct %p: rv %d\n", files, rv);
+	return rv;
+}
+
+int kstate_collect_all_files_struct(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = collect_files_struct(ctx, tsk->files);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_FILES_STRUCT) {
+		struct files_struct *files = obj->o_obj;
+		unsigned int cnt = atomic_read(&files->count);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("files_struct %p has external references %lu:%u\n", files, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int dump_fd(struct kstate_context *ctx, struct files_struct *files, int fd, struct file *file)
+{
+	struct kstate_image_fd *i;
+	struct kstate_object *tmp;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_FD, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+	/*
+	 * fd doesn't get id because it can't be shared by itself,
+	 * only files_struct can. Assign some deterministic id.
+	 */
+	i->hdr.obj_id = 0;
+
+	tmp = find_kstate_obj_by_ptr(ctx, file, KSTATE_CTX_FILE);
+	i->ref_file = tmp->o_ref;
+	i->fd = fd;
+	i->fd_flags = 0;
+	if (FD_ISSET(fd, files->fdt->close_on_exec))
+		i->fd_flags |= KSTATE_FD_FLAGS_CLOEXEC;
+
+	rv = kstate_write(ctx, i, sizeof(*i));
+	kfree(i);
+	pr_debug("dump fd %d: rv %d, files_struct %p, file %p\n", fd, rv, files, file);
+	return rv;
+}
+
+static int dump_all_fd(struct kstate_context *ctx, struct files_struct *files)
+{
+	struct file *file;
+	int fd;
+	int rv;
+
+	for (fd = 0; fd < files->fdt->max_fds; fd++) {
+		file = fcheck_files(files, fd);
+		if (!file)
+			continue;
+		rv = dump_fd(ctx, files, fd, file);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int dump_files_struct(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct files_struct *files = obj->o_obj;
+	struct kstate_image_files_struct *i;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_FILES_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	kfree(i);
+	pr_debug("dump files_struct %p: ref {%llu, %u}, rv %d\n", files, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_files_struct(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_FILES_STRUCT) {
+		struct files_struct *files = obj->o_obj;
+
+		rv = dump_files_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+		rv = dump_all_fd(ctx, files);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_fd(struct kstate_context *ctx, kstate_pos_t pos)
+{
+	kstate_ref_t ref = { .pos = pos, .id = 0 };
+	struct kstate_image_fd *i;
+	struct file *file;
+	int fd;
+	unsigned int flags;
+	struct kstate_object *tmp;
+	int rv;
+
+	i = kstate_read_image(ctx, &ref, KSTATE_OBJ_FD, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	tmp = find_kstate_obj_by_ref(ctx, &i->ref_file, KSTATE_CTX_FILE);
+	if (!tmp) {
+		rv = kstate_restore_file(ctx, &i->ref_file);
+		if (rv < 0)
+			goto out_free_image;
+		tmp = find_kstate_obj_by_ref(ctx, &i->ref_file, KSTATE_CTX_FILE);
+	}
+	file = tmp->o_obj;
+
+	flags = 0;
+	if (i->fd_flags & KSTATE_FD_FLAGS_CLOEXEC)
+		flags |= O_CLOEXEC;
+	fd = alloc_fd(i->fd, flags);
+	if (fd != i->fd)
+		rv = (fd < 0) ? fd : -EINVAL;
+	else
+		rv = 0;
+	kfree(i);
+	if (rv < 0)
+		return rv;
+
+	get_file(file);
+	fd_install(fd, file);
+	return 0;
+
+out_free_image:
+	kfree(i);
+	return rv;
+}
+
+int kstate_restore_files_struct(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_files_struct *i;
+	struct files_struct *files;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_FILES_STRUCT, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	files = kmem_cache_zalloc(files_cachep, GFP_KERNEL);
+	if (!files) {
+		kfree(i);
+		return -ENOMEM;
+	}
+	atomic_set(&files->count, 1);
+	files->fdt = &files->fdtab;
+	files->fdt->max_fds = NR_OPEN_DEFAULT;
+	files->fdt->fd = files->fd_array;
+	files->fdt->close_on_exec = (fd_set *)&files->close_on_exec_init;
+	files->fdt->open_fds = (fd_set *)&files->open_fds_init;
+	spin_lock_init(&files->file_lock);
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, files, KSTATE_CTX_FILES_STRUCT, ref);
+	if (rv < 0)
+		kmem_cache_free(files_cachep, files);
+	pr_debug("restore files_struct %p: ref {%llu, %u}, rv %d\n", files, (unsigned long long)ref->pos, ref->id,  rv);
+	return rv;
+}
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index ab026f0..bc27985 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -1,4 +1,5 @@
 /* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fdtable.h>
 #include <linux/fs.h>
 #include <linux/ipc_namespace.h>
 #include <linux/mm_types.h>
@@ -42,6 +43,9 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_FILE:
 		get_file((struct file *)obj->o_obj);
 		break;
+	case KSTATE_CTX_FILES_STRUCT:
+		atomic_inc(&((struct files_struct *)obj->o_obj)->count);
+		break;
 	case KSTATE_CTX_GROUP_INFO:
 		get_group_info((struct group_info *)obj->o_obj);
 		break;
diff --git a/kernel/kstate/kstate-task.c b/kernel/kstate/kstate-task.c
index 4a3524e..101fcb8 100644
--- a/kernel/kstate/kstate-task.c
+++ b/kernel/kstate/kstate-task.c
@@ -1,4 +1,5 @@
 /* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fdtable.h>
 #include <linux/kthread.h>
 #include <linux/nsproxy.h>
 #include <linux/pid_namespace.h>
@@ -135,6 +136,9 @@ static int dump_task_struct(struct kstate_context *ctx, struct kstate_object *ob
 	tmp = find_kstate_obj_by_ptr(ctx, tsk->pids[PIDTYPE_SID].pid, KSTATE_CTX_PID);
 	i->ref_sid = tmp->o_ref;
 
+	tmp = find_kstate_obj_by_ptr(ctx, tsk->files, KSTATE_CTX_FILES_STRUCT);
+	i->ref_files = tmp->o_ref;
+
 	BUILD_BUG_ON(sizeof(i->comm) != sizeof(tsk->comm));
 	strlcpy((char *)i->comm, (const char *)tsk->comm, sizeof(i->comm));
 
@@ -351,6 +355,53 @@ static int restore_sid(struct kstate_context *ctx, kstate_ref_t *ref)
 	return 0;
 }
 
+static int restore_all_fd(struct kstate_context *ctx, kstate_pos_t pos)
+{
+	struct kstate_object_header hdr;
+	int rv;
+
+	while (1) {
+		rv = kstate_pread(ctx, &hdr, sizeof(hdr), pos);
+		if (rv < 0)
+			return rv;
+		if (hdr.obj_len < sizeof(hdr))
+			return -EINVAL;
+
+		if (hdr.obj_type == KSTATE_OBJ_FD) {
+			rv = kstate_restore_fd(ctx, pos);
+			if (rv < 0)
+				return rv;
+		} else
+			return 0;
+		pos += hdr.obj_len;
+	}
+}
+
+static int restore_files(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct files_struct *files;
+	struct kstate_object *tmp;
+	int restore_fd;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_FILES_STRUCT);
+	if (!tmp) {
+		rv = kstate_restore_files_struct(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_FILES_STRUCT);
+		restore_fd = 1;
+	} else
+		restore_fd = 0;
+	files = tmp->o_obj;
+
+	atomic_inc(&files->count);
+	reset_files_struct(files);
+	if (restore_fd)
+		return restore_all_fd(ctx, ref->pos + sizeof(struct kstate_image_files_struct));
+	return 0;
+}
+
 struct task_struct_restore_context {
 	struct kstate_context *ctx;
 	struct kstate_image_task_struct *i;
@@ -414,6 +465,9 @@ static int task_struct_restorer(void *_tsk_ctx)
 	rv = restore_sid(ctx, &i->ref_sid);
 	if (rv < 0)
 		goto out;
+	rv = restore_files(ctx, &i->ref_files);
+	if (rv < 0)
+		goto out;
 
 out:
 	tsk_ctx->rv = rv;
-- 
1.5.6.5
