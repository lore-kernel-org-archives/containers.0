From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [BIG RFC] Filesystem-based checkpoint
Date: Tue, 28 Oct 2008 11:37:27 -0700
Message-ID: <1225219047.12673.182.camel@nimitz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-zs5UDPTEFJq3ozj4NEjI"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


--=-zs5UDPTEFJq3ozj4NEjI
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I hate the syscall.  It's a very un-Linux-y way of doing things.  There,
I said it.  Here's an alternative.  It still uses the syscall to
initiate things, but it uses debugfs to transport the data instead.
This is just a concept demonstration.  It doesn't actually work, and I
wouldn't be using debugfs in practice.

System calls in Linux are fast.  Doing lots of them is not a problem.
If it becomes one, we can always export a condensed version of this
format next to the expanded one, kinda like ftrace does.  Atomicity with
this approach is also not a problem.  The system call in this approach
doesn't return until the checkpoint is completely written out.

This lets userspace pick and choose what parts of the checkpoint it
cares about.  It enables us to do all the I/O from userspace: no
in-kernel sys_read/write().  I think this interface is much more
flexible than a plain syscall.

Want to do a fast checkpoint?  Fine, copy all data, use a lot of memory,
store it in-kernel.  Dump that out when the filesystem is accessed.
Destroy it when userspace asks.

Want to do a checkpoint with a small memory footprint?
10 write one struct
20 wait for userspace
30 goto 10

Userspace can loop like it is reading a pipe.  We could even track
per-checkpoint memory usage in the cr_ctx and stop writing when we go
over a certain memory threshold.

We can have two modes, internally.  Userspace never has to know what
which one we've chosen.  Say we have a word of data to output.  We can
either make a copy at sys_checkpoint() time and let the data continue to
be modified (let the task run).  Or, we can keep the task frozen and
generate data at debugfs read() time.  This means potentially zero
copying of data until userspace wants it.

The same goes for structures which might have complicated locking or
lifetime rules.  

This also shows how we might handle shared objects.

To use, just sys_checkpoint() as before, and look at /sys/kernel/debug/.
Use the crid you got back from the syscall to locate your checkpoint.
Write into the 'done' file when you want the sys_checkpoint() to return.

/sys/kernel/debug/checkpoint-1/
/sys/kernel/debug/checkpoint-1/done
/sys/kernel/debug/checkpoint-1/task-1141
/sys/kernel/debug/checkpoint-1/task-1141/fds
/sys/kernel/debug/checkpoint-1/task-1141/fds/1
/sys/kernel/debug/checkpoint-1/task-1141/fds/1/coe
/sys/kernel/debug/checkpoint-1/task-1141/fds/1/fd_nr
/sys/kernel/debug/checkpoint-1/task-1141/fds/1/fd
/sys/kernel/debug/checkpoint-1/task-1141/fds/0
/sys/kernel/debug/checkpoint-1/task-1141/fds/0/coe
/sys/kernel/debug/checkpoint-1/task-1141/fds/0/fd_nr
/sys/kernel/debug/checkpoint-1/task-1141/fds/0/fd
/sys/kernel/debug/checkpoint-1/files
/sys/kernel/debug/checkpoint-1/files/2
/sys/kernel/debug/checkpoint-1/files/2/f_version
/sys/kernel/debug/checkpoint-1/files/2/f_pos
/sys/kernel/debug/checkpoint-1/files/2/f_mode
/sys/kernel/debug/checkpoint-1/files/2/f_flags
/sys/kernel/debug/checkpoint-1/files/1
/sys/kernel/debug/checkpoint-1/files/1/target
/sys/kernel/debug/checkpoint-1/files/1/fd_type
/sys/kernel/debug/checkpoint-1/files/1/f_version
/sys/kernel/debug/checkpoint-1/files/1/f_pos
/sys/kernel/debug/checkpoint-1/files/1/f_mode
/sys/kernel/debug/checkpoint-1/files/1/f_flags

So, why not?

-- Dave

--=-zs5UDPTEFJq3ozj4NEjI
Content-Disposition: attachment; filename=debugfs-fun0.patch
Content-Type: text/x-patch; name=debugfs-fun0.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit


index 9c2d949..f4eb855 100644
DESC
debugfs-fun1
EDESC

---

 linux-2.6.git-dave/arch/x86/mm/checkpoint.c       |   28 +++++++++++++
 linux-2.6.git-dave/checkpoint/checkpoint.c        |   21 ++++++++++
 linux-2.6.git-dave/checkpoint/ckpt_file.c         |   13 ------
 linux-2.6.git-dave/checkpoint/sys.c               |   45 +++++++++++++++++++++-
 linux-2.6.git-dave/include/linux/checkpoint.h     |    8 +++
 linux-2.6.git-dave/include/linux/checkpoint_hdr.h |   14 ++++--
 6 files changed, 110 insertions(+), 19 deletions(-)

diff -puN arch/x86/mm/checkpoint.c~debugfs-fun0 arch/x86/mm/checkpoint.c
--- linux-2.6.git/arch/x86/mm/checkpoint.c~debugfs-fun0	2008-10-23 10:27:13.000000000 -0700
+++ linux-2.6.git-dave/arch/x86/mm/checkpoint.c	2008-10-23 10:27:13.000000000 -0700
@@ -11,9 +11,32 @@
 #include <asm/desc.h>
 #include <asm/i387.h>
 
+#include <linux/debugfs.h>
+
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+struct dentry *blobhelp(const char *name, mode_t mode,
+			struct dentry *parent, void *blob, int size)
+{
+	struct debugfs_blob_wrapper *wrap = kmalloc(sizeof(*wrap), GFP_KERNEL);
+	wrap->data = kmalloc(size, GFP_KERNEL);
+	memcpy(wrap->data, blob, size);
+	wrap->size = size;
+	return debugfs_create_blob(name, mode, parent, wrap);
+}
+
+char *tdir(u32 pid)
+{
+	char *buf;
+	// 7 for 'thread-'
+	// 10 for 32-bit int
+	// 1 for \0
+	buf = kmalloc(18, GFP_KERNEL);
+	sprintf(buf, "thread-%d", pid);
+	return buf;
+}
+
 /* dump the thread_struct of a given task */
 int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
 {
@@ -23,10 +46,12 @@ int cr_write_thread(struct cr_ctx *ctx, 
 	struct desc_struct *desc;
 	int ntls = 0;
 	int n, ret;
+	struct dentry *dir;
 
 	h.type = CR_HDR_THREAD;
 	h.len = sizeof(*hh);
 	h.parent = task_pid_vnr(t);
+	dir = debugfs_create_dir(tdir(h.parent), ctx->debugfs_dir);
 
 	thread = &t->thread;
 
@@ -40,6 +65,8 @@ int cr_write_thread(struct cr_ctx *ctx, 
 	hh->gdt_entry_tls_entries = GDT_ENTRY_TLS_ENTRIES;
 	hh->sizeof_tls_array = sizeof(thread->tls_array);
 	hh->ntls = ntls;
+	debugfs_create_u16("ntls", 0444, dir, &hh->ntls);
+	debugfs_create_u16("gdt_entry_tls_entries", 0444, dir, &hh->gdt_entry_tls_entries);
 
 	ret = cr_write_obj(ctx, &h, hh);
 	cr_hbuf_put(ctx, sizeof(*hh));
@@ -48,6 +75,7 @@ int cr_write_thread(struct cr_ctx *ctx, 
 
 	/* for simplicity dump the entire array, cherry-pick upon restart */
 	ret = cr_kwrite(ctx, thread->tls_array, sizeof(thread->tls_array));
+	blobhelp("tls_array", 0444, dir, thread->tls_array, sizeof(thread->tls_array));
 
 	cr_debug("ntls %d\n", ntls);
 
diff -puN checkpoint/sys.c~debugfs-fun0 checkpoint/sys.c
--- linux-2.6.git/checkpoint/sys.c~debugfs-fun0	2008-10-23 10:27:13.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/sys.c	2008-10-28 11:18:04.000000000 -0700
@@ -8,6 +8,7 @@
  *  distribution for more details.
  */
 
+#include <linux/debugfs.h>
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
 #include <linux/ptrace.h>
@@ -147,7 +148,7 @@ void *cr_hbuf_get(struct cr_ctx *ctx, in
 void cr_hbuf_put(struct cr_ctx *ctx, int n)
 {
 	BUG_ON(ctx->hpos < n);
-	ctx->hpos -= n;
+	//ctx->hpos -= n;
 }
 
 /*
@@ -217,11 +218,12 @@ static void cr_ctx_free(struct cr_ctx *c
 	if (ctx->file)
 		fput(ctx->file);
 
-	kfree(ctx->hbuf);
+	//kfree(ctx->hbuf);
 
 	if (ctx->vfsroot)
 		path_put(ctx->vfsroot);
 
+	return;
 	cr_pgarr_free(ctx);
 	cr_objhash_free(ctx);
 
@@ -269,6 +271,12 @@ static struct cr_ctx *cr_ctx_alloc(pid_t
 
 	ctx->crid = atomic_inc_return(&cr_ctx_count);
 
+	{
+		char buf[32];
+		sprintf(&buf[0], "checkpoint-%d", ctx->crid);
+		ctx->debugfs_dir = debugfs_create_dir(&buf[0], NULL);
+		ctx->fd_dir = debugfs_create_dir("files", ctx->debugfs_dir);
+	}
 	return ctx;
 
  err:
@@ -276,6 +284,30 @@ static struct cr_ctx *cr_ctx_alloc(pid_t
 	return ERR_PTR(err);
 }
 
+/*
+ * Copied from debugfs, needs cleanup
+ */
+static int default_open(struct inode *inode, struct file *file)
+{
+	if (inode->i_private)
+		file->private_data = inode->i_private;
+
+	return 0;
+}
+
+static ssize_t cr_debugfs_done(struct file *file, const char __user *user_buf,
+		                               size_t count, loff_t *ppos)
+{
+	struct cr_ctx *ctx = file->private_data;
+	mutex_unlock(&ctx->mutex_done);
+	return count;
+}
+
+static const struct file_operations debugfs_done_fops = {
+	.write = cr_debugfs_done,
+	.open =	 default_open,
+};
+
 /**
  * sys_checkpoint - checkpoint a container
  * @pid: pid of the container init(1) process
@@ -303,6 +335,14 @@ asmlinkage long sys_checkpoint(pid_t pid
 	if (!ret)
 		ret = ctx->crid;
 
+	/*
+	 * Wait for userspace to consume the image
+	 */
+	mutex_init(&ctx->mutex_done);
+	debugfs_create_file("done", 0200, ctx->debugfs_dir,
+				ctx, &debugfs_done_fops);
+	mutex_lock(&ctx->mutex_done);
+	mutex_lock(&ctx->mutex_done);
 	cr_ctx_free(ctx);
 	return ret;
 }
@@ -334,3 +374,4 @@ asmlinkage long sys_restart(int crid, in
 	cr_ctx_free(ctx);
 	return ret;
 }
+
diff -puN include/linux/checkpoint.h~debugfs-fun0 include/linux/checkpoint.h
--- linux-2.6.git/include/linux/checkpoint.h~debugfs-fun0	2008-10-23 10:27:13.000000000 -0700
+++ linux-2.6.git-dave/include/linux/checkpoint.h	2008-10-28 10:57:39.000000000 -0700
@@ -36,6 +36,11 @@ struct cr_ctx {
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 
 	struct path *vfsroot;	/* container root (FIXME) */
+
+	struct mutex mutex_done;
+	struct dentry *debugfs_dir;
+	struct dentry *fd_dir;
+	struct dentry *current_task_dir;
 };
 
 /* cr_ctx: flags */
@@ -73,7 +78,8 @@ struct cr_hdr;
 extern int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf);
 extern int cr_write_string(struct cr_ctx *ctx, char *str, int len);
 extern int cr_write_fname(struct cr_ctx *ctx,
-			  struct path *path, struct path *root);
+			  struct path *path, struct path *root,
+			  struct dentry *debugfs_dir);
 
 extern int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
 extern int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
diff -puN include/linux/checkpoint_hdr.h~debugfs-fun0 include/linux/checkpoint_hdr.h
--- linux-2.6.git/include/linux/checkpoint_hdr.h~debugfs-fun0	2008-10-23 10:27:13.000000000 -0700
+++ linux-2.6.git-dave/include/linux/checkpoint_hdr.h	2008-10-23 10:27:13.000000000 -0700
@@ -22,10 +22,16 @@
 
 /* records: generic header */
 
+typedef int (cr_hdr_op)(struct cr_ctx *ctx, struct cr_hdr *cr_hdr, void *private);
+
 struct cr_hdr {
 	__s16 type;
 	__s16 len;
 	__u32 parent;
+
+	void *data;
+	cr_hdr_op *cr_op;
+	void *buf; /* of length len ^^ */
 };
 
 /* header types */
@@ -34,20 +40,20 @@ enum {
 	CR_HDR_STRING,
 	CR_HDR_FNAME,
 
-	CR_HDR_TASK = 101,
+	CR_HDR_TASK,
 	CR_HDR_THREAD,
 	CR_HDR_CPU,
 
-	CR_HDR_MM = 201,
+	CR_HDR_MM,
 	CR_HDR_VMA,
 	CR_HDR_PGARR,
 	CR_HDR_MM_CONTEXT,
 
-	CR_HDR_FILES = 301,
+	CR_HDR_FILES,
 	CR_HDR_FD_ENT,
 	CR_HDR_FD_DATA,
 
-	CR_HDR_TAIL = 5001
+	CR_HDR_TAIL
 };
 
 struct cr_hdr_head {
diff -puN security/Makefile~debugfs-fun0 security/Makefile
diff -puN checkpoint/checkpoint.c~debugfs-fun0 checkpoint/checkpoint.c
--- linux-2.6.git/checkpoint/checkpoint.c~debugfs-fun0	2008-10-28 11:18:04.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/checkpoint.c	2008-10-28 11:18:04.000000000 -0700
@@ -191,6 +191,26 @@ static int cr_write_task_struct(struct c
 	return cr_write_string(ctx, t->comm, TASK_COMM_LEN);
 }
 
+int cr_create_task_dir(struct cr_ctx *ctx, struct task_struct *t)
+{
+	char buf[22];
+	// 11 for 'thread--fds'
+	// 10 for 32-bit int
+	// 1 for \0
+	sprintf(buf, "task-%d", task_pid_vnr(t));
+
+	/*
+	 * This is not very nice to hide in here, so
+	 * eventually just pass this around or make
+	 * a cr-specific on-stack structure just for
+	 * tasks.
+	 */
+	ctx->current_task_dir =
+		debugfs_create_dir(&buf[0], ctx->debugfs_dir);
+
+	return 0;
+}
+
 /* dump the entire state of a given task */
 static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 {
@@ -203,6 +223,7 @@ static int cr_write_task(struct cr_ctx *
 		return -EAGAIN;
 	}
 
+	cr_create_task_dir(ctx, t);
 	ret = cr_write_task_struct(ctx, t);
 	cr_debug("task_struct: ret %d\n", ret);
 	if (ret < 0)
diff -puN checkpoint/ckpt_file.c~debugfs-fun0 checkpoint/ckpt_file.c
--- linux-2.6.git/checkpoint/ckpt_file.c~debugfs-fun0	2008-10-28 11:18:04.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/ckpt_file.c	2008-10-28 11:18:04.000000000 -0700
@@ -216,17 +216,6 @@ out:
 	return ret;
 }
 
-static char *tfddir(u32 pid)
-{
-	char *buf;
-	// 11 for 'thread--fds'
-	// 10 for 32-bit int
-	// 1 for \0
-	buf = kmalloc(22, GFP_KERNEL);
-	sprintf(buf, "thread-%d-fds", pid);
-	return buf;
-}
-
 int cr_write_files(struct cr_ctx *ctx, struct task_struct *t)
 {
 	struct cr_hdr h;
@@ -239,7 +228,7 @@ int cr_write_files(struct cr_ctx *ctx, s
 	h.type = CR_HDR_FILES;
 	h.len = sizeof(*hh);
 	h.parent = task_pid_vnr(t);
-	dir = debugfs_create_dir(tfddir(h.parent), ctx->debugfs_dir);
+	dir = debugfs_create_dir("fds", ctx->current_task_dir);
 
 	files = get_files_struct(t);
 
_

--=-zs5UDPTEFJq3ozj4NEjI
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--=-zs5UDPTEFJq3ozj4NEjI--
