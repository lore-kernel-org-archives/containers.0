From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 22/30] cr: deal with opened files
Date: Fri, 10 Apr 2009 06:38:53 +0400
Message-ID: <20090410023853.GW27788__34638.2302734584$1239331992$gmane$org@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

C/R tsk->files and opened files!
fd should have struct file::checkpoint ;-)

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/cr.h  |   16 +++
 kernel/cr/cpt-sys.c |    6 +
 kernel/cr/cr-file.c |  249 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr-task.c |    5 +
 kernel/cr/cr.h      |    4 
 5 files changed, 280 insertions(+)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -39,6 +39,8 @@ struct cr_object_header {
 #define CR_OBJ_UTS_NS		8
 #define CR_OBJ_PID_NS		9
 #define CR_OBJ_PID		10
+#define CR_OBJ_FILES_STRUCT	11
+#define CR_OBJ_FD		12
 	__u32	cr_type;	/* object type */
 	__u32	cr_len;		/* object length in bytes including header */
 } __packed;
@@ -59,6 +61,7 @@ struct cr_image_task_struct {
 	cr_pos_t	cr_pos_real_parent;
 	cr_pos_t	cr_pos_mm;
 	cr_pos_t	cr_pos_pids[3];
+	cr_pos_t	cr_pos_files;
 	cr_pos_t	cr_pos_nsproxy;
 
 	__u8		cr_comm[16];
@@ -228,6 +231,10 @@ struct cr_image_vma_content {
 	/* __u8 cr_data[cr_nr_pages * cr_page_size]; */
 } __packed;
 
+struct cr_image_files_struct {
+	struct cr_object_header cr_hdr;
+} __packed;
+
 struct cr_image_file {
 	struct cr_object_header cr_hdr;
 
@@ -245,6 +252,15 @@ struct cr_image_file {
 	/* __u8	cr_name[cr_name_len] */
 } __packed;
 
+struct cr_image_fd {
+	struct cr_object_header cr_hdr;
+
+	cr_pos_t	cr_pos_file;
+	__u32		cr_fd;
+#define CR_FD_FLAGS_CLOEXEC	(1 << 0)
+	__u32		cr_fd_flags;
+} __packed;
+
 struct cr_image_pid {
 	struct cr_object_header cr_hdr;
 
--- a/kernel/cr/cpt-sys.c
+++ b/kernel/cr/cpt-sys.c
@@ -77,6 +77,9 @@ static int cr_collect(struct cr_context *ctx)
 	rv = cr_collect_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_collect_all_files_struct(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_collect_all_file(ctx);
 	if (rv < 0)
 		return rv;
@@ -125,6 +128,9 @@ static int cr_dump(struct cr_context *ctx)
 	rv = cr_dump_all_file(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_dump_all_files_struct(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_dump_all_uts_ns(ctx);
 	if (rv < 0)
 		return rv;
--- a/kernel/cr/cr-file.c
+++ b/kernel/cr/cr-file.c
@@ -64,6 +64,20 @@ int cr_collect_all_file(struct cr_context *ctx)
 	struct cr_object *obj;
 	int rv;
 
+	for_each_cr_object(ctx, obj, CR_CTX_FILES_STRUCT) {
+		struct files_struct *files = obj->o_obj;
+		struct file *file;
+		int fd;
+
+		for (fd = 0; fd < files->fdt->max_fds; fd++) {
+			file = fcheck_files(files, fd);
+			if (!file)
+				continue;
+			rv = cr_collect_file(ctx, file);
+			if (rv < 0)
+				return rv;
+		}
+	}
 	for_each_cr_object(ctx, obj, CR_CTX_MM_STRUCT) {
 		struct mm_struct *mm = obj->o_obj;
 		struct vm_area_struct *vma;
@@ -229,3 +243,238 @@ int cr_restore_file(struct cr_context *ctx, loff_t pos)
 	kfree(i);
 	return 0;
 }
+
+static int cr_restore_fd(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_fd *i;
+	struct file *file;
+	int fd;
+	unsigned int flags;
+	struct cr_object *tmp;
+	int rv;
+
+	i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (!i)
+		return -ENOMEM;
+	rv = cr_pread(ctx, i, sizeof(*i), pos);
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+	if (i->cr_hdr.cr_type != CR_OBJ_FD) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	tmp = cr_find_obj_by_pos(ctx, i->cr_pos_file, CR_CTX_FILE);
+	if (!tmp) {
+		rv = cr_restore_file(ctx, i->cr_pos_file);
+		if (rv < 0) {
+			kfree(i);
+			return rv;
+		}
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_file, CR_CTX_FILE);
+	}
+	file = tmp->o_obj;
+
+	flags = 0;
+	if (i->cr_fd_flags & CR_FD_FLAGS_CLOEXEC)
+		flags |= O_CLOEXEC;
+	fd = alloc_fd(i->cr_fd, flags);
+	if (fd != i->cr_fd)
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
+}
+
+static int cr_restore_all_fd(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_object_header cr_hdr;
+	int rv;
+
+	while (1) {
+		rv = cr_pread(ctx, &cr_hdr, sizeof(cr_hdr), pos);
+		if (rv < 0)
+			return rv;
+		if (cr_hdr.cr_type == CR_OBJ_FD) {
+			rv = cr_restore_fd(ctx, pos);
+			if (rv < 0)
+				return rv;
+		} else
+			return 0;
+		pos += cr_hdr.cr_len;
+	}
+}
+
+static int cr_collect_files_struct(struct cr_context *ctx, struct files_struct *files)
+{
+	int rv;
+
+	rv = cr_collect_object(ctx, files, CR_CTX_FILES_STRUCT);
+	printk("collect files_struct %p: rv %d\n", files, rv);
+	return rv;
+}
+
+int cr_collect_all_files_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = cr_collect_files_struct(ctx, tsk->files);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_FILES_STRUCT) {
+		struct files_struct *files = obj->o_obj;
+		unsigned int cnt = atomic_read(&files->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: files_struct %p has external references %lu:%u\n", __func__, files, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_fd(struct cr_context *ctx, struct files_struct *files, int fd, struct file *file)
+{
+	struct cr_image_fd *i;
+	struct cr_object *tmp;
+	int rv;
+
+	printk("dump fd %d, files_struct = %p, file = %p\n", fd, files, file);
+
+	i = cr_prepare_image(CR_OBJ_FD, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	tmp = cr_find_obj_by_ptr(ctx, file, CR_CTX_FILE);
+	i->cr_pos_file = tmp->o_pos;
+	i->cr_fd = fd;
+	i->cr_fd_flags = 0;
+	if (FD_ISSET(fd, files->fdt->close_on_exec))
+		i->cr_fd_flags |= CR_FD_FLAGS_CLOEXEC;
+
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+static int cr_dump_files_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct files_struct *files = obj->o_obj;
+	struct cr_image_files_struct *i;
+	int fd;
+	int rv;
+
+	printk("dump files_struct %p\n", files);
+
+	i = cr_prepare_image(CR_OBJ_FILES_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	if (rv < 0)
+		return rv;
+
+	for (fd = 0; fd < files->fdt->max_fds; fd++) {
+		struct file *file;
+
+		file = fcheck_files(files, fd);
+		if (file) {
+			rv = cr_dump_fd(ctx, files, fd, file);
+			if (rv < 0)
+				return rv;
+		}
+	}
+	return 0;
+}
+
+int cr_dump_all_files_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_FILES_STRUCT) {
+		rv = cr_dump_files_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int __cr_restore_files_struct(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_files_struct *i;
+	struct files_struct *files;
+	struct cr_object *obj;
+	int rv;
+
+	i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (!i)
+		return -ENOMEM;
+	rv = cr_pread(ctx, i, sizeof(*i), pos);
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+	if (i->cr_hdr.cr_type != CR_OBJ_FILES_STRUCT) {
+		kfree(i);
+		return -EINVAL;
+	}
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
+	obj = cr_object_create(files);
+	if (!obj) {
+		kmem_cache_free(files_cachep, files);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_FILES_STRUCT]);
+	printk("restore files_struct %p, pos %lld\n", files, (long long)pos);
+	return 0;
+}
+
+int cr_restore_files_struct(struct cr_context *ctx, loff_t pos)
+{
+	struct files_struct *files;
+	struct cr_object *tmp;
+	int rv;
+
+	tmp = cr_find_obj_by_pos(ctx, pos, CR_CTX_FILES_STRUCT);
+	if (!tmp) {
+		rv = __cr_restore_files_struct(ctx, pos);
+		if (rv < 0)
+			return rv;
+		tmp = cr_find_obj_by_pos(ctx, pos, CR_CTX_FILES_STRUCT);
+	}
+	files = tmp->o_obj;
+	atomic_inc(&files->count);
+	reset_files_struct(files);
+	return cr_restore_all_fd(ctx, pos + sizeof(struct cr_image_files_struct));
+}
--- a/kernel/cr/cr-task.c
+++ b/kernel/cr/cr-task.c
@@ -127,6 +127,8 @@ static int cr_dump_task_struct(struct cr_context *ctx, struct cr_object *obj)
 		i->cr_pos_pids[2] = tmp->o_pos;
 	else
 		i->cr_pos_pids[2] = CR_POS_UNDEF;
+	tmp = cr_find_obj_by_ptr(ctx, tsk->files, CR_CTX_FILES_STRUCT);
+	i->cr_pos_files = tmp->o_pos;
 
 	BUILD_BUG_ON(TASK_COMM_LEN != 16);
 	strlcpy((char *)i->cr_comm, (const char *)tsk->comm, sizeof(i->cr_comm));
@@ -186,6 +188,9 @@ static int task_struct_restorer(void *_tsk_ctx)
 	rv = cr_restore_nsproxy(ctx, i->cr_pos_nsproxy);
 	if (rv < 0)
 		goto out;
+	rv = cr_restore_files_struct(ctx, i->cr_pos_files);
+	if (rv < 0)
+		return rv;
 	rv = cr_restore_pid(ctx, i);
 	if (rv < 0)
 		goto out;
--- a/kernel/cr/cr.h
+++ b/kernel/cr/cr.h
@@ -23,6 +23,7 @@ struct cr_object {
 /* Not visible to userspace! */
 enum cr_context_obj_type {
 	CR_CTX_FILE,
+	CR_CTX_FILES_STRUCT,
 	CR_CTX_MM_STRUCT,
 	CR_CTX_NSPROXY,
 	CR_CTX_PID,
@@ -70,6 +71,7 @@ static inline void __user *cr_restore_ptr(__u64 ptr)
 	return (void __user *)(unsigned long)ptr;
 }
 
+int cr_collect_all_files_struct(struct cr_context *ctx);
 int cr_collect_all_file(struct cr_context *ctx);
 int cr_collect_all_mm_struct(struct cr_context *ctx);
 int cr_collect_all_nsproxy(struct cr_context *ctx);
@@ -78,6 +80,7 @@ int cr_collect_all_pid(struct cr_context *ctx);
 int cr_collect_all_task_struct(struct cr_context *ctx);
 int cr_collect_all_uts_ns(struct cr_context *ctx);
 
+int cr_dump_all_files_struct(struct cr_context *ctx);
 int cr_dump_all_file(struct cr_context *ctx);
 int cr_dump_all_mm_struct(struct cr_context *ctx);
 int cr_dump_all_nsproxy(struct cr_context *ctx);
@@ -86,6 +89,7 @@ int cr_dump_all_pid(struct cr_context *ctx);
 int cr_dump_all_task_struct(struct cr_context *ctx);
 int cr_dump_all_uts_ns(struct cr_context *ctx);
 
+int cr_restore_files_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_file(struct cr_context *ctx, loff_t pos);
 int cr_restore_mm_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_nsproxy(struct cr_context *ctx, loff_t pos);
