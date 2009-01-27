From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC cr-pipe-v13][PATCH 1/3] A new file type (CR_FD_OBJREF) for a
	file descriptor already setup
Date: Tue, 27 Jan 2009 16:23:13 -0500
Message-ID: <1233091395-24582-3-git-send-email-orenl@cs.columbia.edu>
References: <1233091395-24582-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1233091395-24582-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

While file pointers are shared objects, they may share an underlying
object themselves. For instance, file pointers of both ends of a pipe
that share the same pipe inode. In this case, the shared entity to
handle is the inode that is shared among two file pointers (e.g read-
and write- ends). In this sort of "nested sharing" we need only save
the underlying object once (upon first encounter) on checkpoint, and
restore it only once during restart.

To checkpoint a file descriptor of this sort, we first lookup the
inode in the hash table:

If not found, it is the first encounter of this inode. Here, Besides
the file descriptor data, we also (a) register the inode in the hash
and save the corresponding 'objref' of this inode in '->fd_objref' of
the file descriptor. We then also (b) save the inode data, as per the
inode type (this is not implemented in this patch, as it depends on
the object). The file descriptor type will indicate the type of that
object (e.g. for a pipe, when supported, CR_FD_PIPE).

If found, it is the second encounter of this inode, e.g. in the case
of a pipe, as we hit the other end of the same pipe. At this point we
need only record the reference ('objref') to the inode that we had
saved before, and the file descriptor type is changed to CR_FD_OBJREF.

The logic during restart is similar: the '->fd_objref' is looked up in
the hash table. Unlike checkpoint, during restart the object that is
placed (and sought) in the hash table is the _file_ pointer, rather
than the _inode_.

If not found, it is the first encounter of this inode. Therefore we
(a) restore the inode data. Specifically, we construct a matching
object and end up with multiple file pointers (e.g. if the object is a
pipe, we will have both read- and write- ends). One of those is used
for the file descriptor in question; the other(s) will be deposited in
the hash table, to be retrieved and used later on. We also (b) register
the newly created inode in the hash table using the given 'objref'.

If found, then we can skip the setup of the underlying object that
is represented by the inode.

The type CR_FD_OBJREF indicates, on restart, that the corresponding
file descriptor is already setup and registered in the hash under the
'->fd_objref' that it had been assigned.

The next two patches use CR_FD_OBJREF to implement support for pipes.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/ckpt_file.c         |   52 ++++++++++++++++++------
 checkpoint/objhash.c           |   30 +++++++++++---
 checkpoint/rstr_file.c         |   85 +++++++++++++++++++++++++++++++---------
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |    9 +++-
 5 files changed, 135 insertions(+), 42 deletions(-)

diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
index e3097ac..f5263f2 100644
--- a/checkpoint/ckpt_file.c
+++ b/checkpoint/ckpt_file.c
@@ -72,13 +72,31 @@ int cr_scan_fds(struct files_struct *files, int **fdtable)
 	return n;
 }
 
+/* cr_write_fd_file - for regular files, directories, symbolic links */
+static int cr_write_fd_file(struct cr_ctx *ctx, struct file *file, int parent)
+{
+	return cr_write_fname(ctx, &file->f_path, &ctx->fs_mnt);
+}
+
+/* cr_inode_to_fdtype - determine the fd type given an inode */
+static inline enum fd_type cr_inode_to_fdtype(struct inode *inode)
+{
+	switch (inode->i_mode & S_IFMT) {
+	case S_IFREG:
+		return CR_FD_FILE;
+	case S_IFDIR:
+		return CR_FD_DIR;
+	}
+	/* file type unsupported */
+	return -EBADF;
+}
+
 /* cr_write_fd_data - dump the state of a given file pointer */
 static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
 {
 	struct cr_hdr h;
 	struct cr_hdr_fd_data *hh = cr_hbuf_get(ctx, sizeof(*hh));
-	struct dentry *dent = file->f_dentry;
-	struct inode *inode = dent->d_inode;
+	struct inode *inode = file->f_dentry->d_inode;
 	enum fd_type fd_type;
 	int ret;
 
@@ -92,27 +110,35 @@ static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
 	hh->f_version = file->f_version;
 	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
 
-	switch (inode->i_mode & S_IFMT) {
-	case S_IFREG:
-		fd_type = CR_FD_FILE;
-		break;
-	case S_IFDIR:
-		fd_type = CR_FD_DIR;
-		break;
-	default:
+	fd_type = cr_inode_to_fdtype(inode);
+	if (fd_type < 0) {
 		cr_hbuf_put(ctx, sizeof(*hh));
-		return -EBADF;
+		return fd_type;
 	}
 
-	/* FIX: check if the file/dir/link is unlinked */
 	hh->fd_type = fd_type;
+	hh->fd_objref = 0;
+
+	/* FIX: check if the inode is unlinked */
 
 	ret = cr_write_obj(ctx, &h, hh);
 	cr_hbuf_put(ctx, sizeof(*hh));
 	if (ret < 0)
 		return ret;
 
-	return cr_write_fname(ctx, &file->f_path, &ctx->fs_mnt);
+	switch (fd_type) {
+	case CR_FD_OBJREF:
+		/* nothing to do */
+		break;
+	case CR_FD_FILE:
+	case CR_FD_DIR:
+		ret = cr_write_fd_file(ctx, file, parent);
+		break;
+	default:
+		BUG();
+	}
+
+	return ret;
 }
 
 /**
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index ee31b38..01fd2dc 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -35,20 +35,31 @@ static void cr_obj_ref_drop(struct cr_objref *obj)
 	case CR_OBJ_FILE:
 		fput((struct file *) obj->ptr);
 		break;
+	case CR_OBJ_INODE:
+		iput((struct inode *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
 }
 
-static void cr_obj_ref_grab(struct cr_objref *obj)
+static int cr_obj_ref_grab(struct cr_objref *obj)
 {
+	int ret = 0;
+
 	switch (obj->type) {
 	case CR_OBJ_FILE:
 		get_file((struct file *) obj->ptr);
 		break;
+	case CR_OBJ_INODE:
+		if (!igrab((struct inode *) obj->ptr))
+			ret = -EBADF;
+		break;
 	default:
 		BUG();
 	}
+
+	return ret;
 }
 
 static void cr_objhash_clear(struct cr_objhash *objhash)
@@ -144,16 +155,22 @@ static struct cr_objref *cr_obj_new(struct cr_ctx *ctx, void *ptr, int objref,
 				    unsigned short type, unsigned short flags)
 {
 	struct cr_objref *obj;
-	int i;
+	int i, ret;
 
 	obj = kmalloc(sizeof(*obj), GFP_KERNEL);
 	if (!obj)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 
 	obj->ptr = ptr;
 	obj->type = type;
 	obj->flags = flags;
 
+	ret = cr_obj_ref_grab(obj);
+	if (ret < 0) {
+		kfree(obj);
+		return ERR_PTR(ret);
+	}
+
 	if (objref) {
 		/* use @objref to index (restart) */
 		obj->objref = objref;
@@ -165,7 +182,6 @@ static struct cr_objref *cr_obj_new(struct cr_ctx *ctx, void *ptr, int objref,
 	}
 
 	hlist_add_head(&obj->hash, &ctx->objhash->head[i]);
-	cr_obj_ref_grab(obj);
 	return obj;
 }
 
@@ -198,8 +214,8 @@ int cr_obj_add_ptr(struct cr_ctx *ctx, void *ptr, int *objref,
 	obj = cr_obj_find_by_ptr(ctx, ptr);
 	if (!obj) {
 		obj = cr_obj_new(ctx, ptr, 0, type, flags);
-		if (!obj)
-			return -ENOMEM;
+		if (IS_ERR(obj))
+			return PTR_ERR(obj);
 		else
 			ret = 1;
 	} else if (obj->type != type)	/* sanity check */
@@ -229,7 +245,7 @@ int cr_obj_add_ref(struct cr_ctx *ctx, void *ptr, int objref,
 	struct cr_objref *obj;
 
 	obj = cr_obj_new(ctx, ptr, objref, type, flags);
-	return obj ? 0 : -ENOMEM;
+	return IS_ERR(obj) ? PTR_ERR(obj) : 0;
 }
 
 /**
diff --git a/checkpoint/rstr_file.c b/checkpoint/rstr_file.c
index f44b081..e3b684e 100644
--- a/checkpoint/rstr_file.c
+++ b/checkpoint/rstr_file.c
@@ -65,6 +65,55 @@ static int cr_attach_get_file(struct file *file)
 	return fd;
 }
 
+/**
+ * cr_obj_add_file - register a file pointer of a given fd in hash table
+ * @ctx: checkpoint context
+ * @fd: file descriptor
+ * @objref: objrect reference
+ *
+ * Return the file pointer (will be safely referenced in the hash table)
+ */
+static struct file *cr_obj_add_file(struct cr_ctx *ctx, int fd, int objref)
+{
+	struct file *file;
+	int ret;
+
+	file = fget(fd);
+	if (!file)
+		return ERR_PTR(-EBADF);
+	ret = cr_obj_add_ref(ctx, file, objref, CR_OBJ_FILE, 0);
+	fput(file);
+	return (ret < 0 ? ERR_PTR(ret) : file);
+}
+
+/* return a new fd associated with a the file referenced by @hh->objref */
+static int
+cr_read_fd_objref(struct cr_ctx *ctx, struct cr_hdr_fd_data *hh, int rparent)
+{
+	struct file *file;
+
+	file = cr_obj_get_by_ref(ctx, hh->fd_objref, CR_OBJ_FILE);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+	return cr_attach_get_file(file);
+}
+
+/* return a new fd associated with a new open file/directory */
+static
+int cr_read_fd_file(struct cr_ctx *ctx, struct cr_hdr_fd_data *hh, int rparent)
+{
+	struct file *file;
+	int fd;
+
+	file = cr_read_open_fname(ctx, hh->f_flags, hh->f_mode);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+	fd = cr_attach_file(file);
+	if (fd < 0)
+		filp_close(file, NULL);
+	return fd;
+}
+
 #define CR_SETFL_MASK (O_APPEND|O_NONBLOCK|O_NDELAY|FASYNC|O_DIRECT|O_NOATIME)
 
 /* cr_read_fd_data - restore the state of a given file pointer */
@@ -74,7 +123,7 @@ cr_read_fd_data(struct cr_ctx *ctx, struct files_struct *files, int rparent)
 	struct cr_hdr_fd_data *hh = cr_hbuf_get(ctx, sizeof(*hh));
 	struct file *file;
 	int parent, ret;
-	int fd = 0;	/* pacify gcc warning */
+	int fd;
 
 	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_FD_DATA);
 	pr_debug("rparent %d parent %d flags %#x mode %#x how %d\n",
@@ -88,47 +137,45 @@ cr_read_fd_data(struct cr_ctx *ctx, struct files_struct *files, int rparent)
 
 	if (parent != rparent)
 		goto out;
+	if (hh->fd_objref < 0)
+		goto out;
 
 	/* FIX: more sanity checks on f_flags, f_mode etc */
 
 	switch (hh->fd_type) {
 	case CR_FD_FILE:
 	case CR_FD_DIR:
-		file = cr_read_open_fname(ctx, hh->f_flags, hh->f_mode);
+		fd = cr_read_fd_file(ctx, hh, rparent);
+		break;
+	case CR_FD_OBJREF:
+		fd = cr_read_fd_objref(ctx, hh, rparent);
 		break;
 	default:
 		goto out;
 	}
 
-	if (IS_ERR(file)) {
-		ret = PTR_ERR(file);
+	if (fd < 0) {
+		ret = fd;
 		goto out;
 	}
 
 	/* FIX: need to restore uid, gid, owner etc */
 
-	/* adding <objref,file> to the hash will keep a reference to it */
-	ret = cr_obj_add_ref(ctx, file, parent, CR_OBJ_FILE, 0);
-	if (ret < 0) {
-		filp_close(file, NULL);
-		goto out;
-	}
-
-	fd = cr_attach_file(file);	/* no need to cleanup 'file' below */
-	if (fd < 0) {
-		ret = fd;
-		filp_close(file, NULL);
+	/* register new <objref, file> tuple in hash table */
+	file = cr_obj_add_file(ctx, fd, rparent);
+	if (IS_ERR(file)) {
+		ret = PTR_ERR(file);
 		goto out;
 	}
 
-	ret = sys_fcntl(fd, F_SETFL, hh->f_flags & CR_SETFL_MASK);
-	if (ret < 0)
-		goto out;
 	ret = vfs_llseek(file, hh->f_pos, SEEK_SET);
 	if (ret == -ESPIPE)	/* ignore error on non-seekable files */
 		ret = 0;
 
-	ret = 0;
+	if (ret < 0)
+		goto out;
+
+	ret = sys_fcntl(fd, F_SETFL, hh->f_flags & CR_SETFL_MASK);
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret < 0 ? ret : fd;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 217cf6e..bf89c0f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -75,6 +75,7 @@ extern void cr_ctx_put(struct cr_ctx *ctx);
 
 enum {
 	CR_OBJ_FILE = 1,
+	CR_OBJ_INODE,
 	CR_OBJ_MAX
 };
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 6dc739f..aba99f4 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -144,13 +144,16 @@ struct cr_hdr_fd_ent {
 
 /* fd types */
 enum  fd_type {
-	CR_FD_FILE = 1,
+	CR_FD_OBJREF = 1,
+	CR_FD_FILE,
 	CR_FD_DIR,
 };
 
 struct cr_hdr_fd_data {
-	__u16 fd_type;
-	__u16 f_mode;
+	__u32 fd_type;
+	__u32 fd_objref;
+
+	__u32 f_mode;
 	__u32 f_flags;
 	__u64 f_pos;
 	__u64 f_version;
-- 
1.5.4.3
