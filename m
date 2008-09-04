From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v3][PATCH 7/9] Infrastructure for shared objects
Date: Thu, 4 Sep 2008 04:05:22 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0809040404550.5982__29928.8444141441$1220516140$gmane$org@takamine.ncl.cs.columbia.edu>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0809040354440.460-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org


Infrastructure to handle objects that may be shared and referenced by
multiple tasks or other objects, e..g open files, memory address space
etc.

The state of shared objects is saved once. On the first encounter, the
state is dumped and the object is assigned a unique identifier and also
stored in a hash table (indexed by its physical kenrel address). From
then on the object will be found in the hash and only its identifier is
saved.

On restart the identifier is looked up in the hash table; if not found
then the state is read, the object is created, and added to the hash
table (this time indexed by its identifier). Otherwise, the object in
the hash table is used.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
  Documentation/checkpoint.txt |   44 +++++++++
  checkpoint/Makefile          |    2 +-
  checkpoint/objhash.c         |  205 ++++++++++++++++++++++++++++++++++++++++++
  checkpoint/sys.c             |    4 +
  include/linux/ckpt.h         |   18 ++++
  5 files changed, 272 insertions(+), 1 deletions(-)
  create mode 100644 checkpoint/objhash.c

diff --git a/Documentation/checkpoint.txt b/Documentation/checkpoint.txt
index 71930af..18725e6 100644
--- a/Documentation/checkpoint.txt
+++ b/Documentation/checkpoint.txt
@@ -163,6 +163,50 @@ cr_hdr + cr_hdr_task
  cr_hdr + cr_hdr_tail


+=== Shared resources (objects)
+
+Many resources used by tasks may be shared by more than one task (e.g.
+file descriptors, memory address space, etc), or even have multiple
+references from other resources (e.g. a single inode that represents
+two ends of a pipe).
+
+Clearly, the state of shared objects need only be saved once, even if
+they occur multiple times. We use a hash table (ctx->objhash) to keep
+track of shared objects in the following manner.
+
+On the first encounter, the state is dumped and the object is assigned
+a unique identifier and also stored in the hash table (indexed by its
+physical kenrel address). From then on the object will be found in the
+hash and only its identifier is saved.
+
+On restart the identifier is looked up in the hash table; if not found
+then the state is read, the object is created, and added to the hash
+table (this time indexed by its identifier). Otherwise, the object in
+the hash table is used.
+
+The interface for the hash table is the following:
+
+int cr_obj_get_by_ptr(struct cr_ctx *ctx, void *ptr, unsigned short type);
+  [checkpoint] find the unique identifier - object reference (objref)
+  - of the object that is pointer to by ptr (or 0 if not found).
+
+int cr_obj_add_ptr(struct cr_ctx *ctx, void *ptr, int *objref,
+		   unsigned short type, unsigned short flags);
+  [checkpoint] add the object pointed to by ptr to the hash table if
+  it isn't already there, and fill its unique identifier (objref); will
+  return 0 if already found in the has, or 1 otherwise.
+
+void *cr_obj_get_by_ref(struct cr_ctx *ctx, int objref, unsigned short type);
+  [restart] return the pointer to the object whose unique identifier
+  is equal to objref.
+
+int cr_obj_add_ref(struct cr_ctx *ctx, void *ptr, int objref,
+		   unsigned short type, unsigned short flags);
+  [restart] add the object with unique identifier objref, pointed to by
+  ptr to the hash table if it isn't already there; will return 0 if
+  already found in the has, or 1 otherwise.
+
+
  === Changelog

  [2008-Jul-29] v1:
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index ac35033..9843fb9 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,5 +2,5 @@
  # Makefile for linux checkpoint/restart.
  #

-obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o \
+obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o objhash.o \
  		ckpt_mem.o rstr_mem.o
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
new file mode 100644
index 0000000..442b08c
--- /dev/null
+++ b/checkpoint/objhash.c
@@ -0,0 +1,205 @@
+/*
+ *  Checkpoint-restart - object hash infrastructure to manage shared objects
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/file.h>
+#include <linux/hash.h>
+#include <linux/ckpt.h>
+
+struct cr_objref {
+	int objref;
+	void *ptr;
+	unsigned short type;
+	unsigned short flags;
+	struct hlist_node hash;
+};
+
+struct cr_objhash {
+	struct hlist_head *head;
+	int objref_index;
+};
+
+#define CR_OBJHASH_NBITS  10
+#define CR_OBJHASH_TOTAL  (1UL << CR_OBJHASH_NBITS - 1)
+
+static void cr_obj_ref_drop(struct cr_objref *obj)
+{
+	switch (obj->type) {
+	case CR_OBJ_FILE:
+		fput((struct file *) obj->ptr);
+		break;
+	default:
+		BUG();
+	}
+}
+
+static void cr_obj_ref_grab(struct cr_objref *obj)
+{
+	switch (obj->type) {
+	case CR_OBJ_FILE:
+		get_file((struct file *) obj->ptr);
+		break;
+	default:
+		BUG();
+	}
+}
+
+static void cr_objhash_clear(struct cr_objhash *objhash)
+{
+	struct hlist_head *h = objhash->head;
+	struct hlist_node *n, *t;
+	struct cr_objref *obj;
+	int i;
+
+	for (i = 0; i < CR_OBJHASH_TOTAL; i++) {
+		hlist_for_each_entry_safe(obj, n, t, &h[i], hash) {
+			cr_obj_ref_drop(obj);
+			kfree(obj);
+		}
+	}
+}
+
+void cr_objhash_free(struct cr_ctx *ctx)
+{
+	struct cr_objhash *objhash = ctx->objhash;
+
+	if (objhash) {
+		cr_objhash_clear(objhash);
+		kfree(objhash->head);
+		kfree(ctx->objhash);
+		ctx->objhash = NULL;
+	}
+}
+
+int cr_objhash_alloc(struct cr_ctx *ctx)
+{
+	struct cr_objhash *objhash;
+	struct hlist_head *head;
+
+	objhash = kzalloc(sizeof(*objhash), GFP_KERNEL);
+	if (!objhash)
+		return -ENOMEM;
+	head = kzalloc(CR_OBJHASH_TOTAL * sizeof(*head), GFP_KERNEL);
+	if (!head) {
+		kfree(objhash);
+		return -ENOMEM;
+	}
+
+	objhash->head = head;
+	objhash->objref_index = 1;
+
+	ctx->objhash = objhash;
+	return 0;
+}
+
+static struct cr_objref *cr_obj_find_by_ptr(struct cr_ctx *ctx, void *ptr)
+{
+	struct hlist_head *h;
+	struct hlist_node *n;
+	struct cr_objref *obj;
+
+	h = &ctx->objhash->head[hash_ptr(ptr, CR_OBJHASH_NBITS)];
+	hlist_for_each_entry(obj, n, h, hash)
+		if (obj->ptr == ptr)
+			return obj;
+	return NULL;
+}
+
+static struct cr_objref *cr_obj_find_by_objref(struct cr_ctx *ctx, int objref)
+{
+	struct hlist_head *h;
+	struct hlist_node *n;
+	struct cr_objref *obj;
+
+	h = &ctx->objhash->head[hash_ptr((void *) objref, CR_OBJHASH_NBITS)];
+	hlist_for_each_entry(obj, n, h, hash)
+		if (obj->objref == objref)
+			return obj;
+	return NULL;
+}
+
+static struct cr_objref *cr_obj_new(struct cr_ctx *ctx, void *ptr, int objref,
+				    unsigned short type, unsigned short flags)
+{
+	struct cr_objref *obj;
+
+	obj = kmalloc(sizeof(*obj), GFP_KERNEL);
+	if (obj) {
+		int i;
+
+		obj->ptr = ptr;
+		obj->type = type;
+		obj->flags = flags;
+
+		if (objref) {
+			/* use 'objref' to index (restart) */
+			obj->objref = objref;
+			i = hash_ptr((void *) objref, CR_OBJHASH_NBITS);
+		} else {
+			/* use 'ptr' to index, assign objref (checkpoint) */
+			obj->objref = ctx->objhash->objref_index++;;
+			i = hash_ptr(ptr, CR_OBJHASH_NBITS);
+		}
+
+		hlist_add_head(&obj->hash, &ctx->objhash->head[i]);
+		cr_obj_ref_grab(obj);
+	}
+	return obj;
+}
+
+int cr_obj_add_ptr(struct cr_ctx *ctx, void *ptr, int *objref,
+		   unsigned short type, unsigned short flags)
+{
+	struct cr_objref *obj;
+	int ret = 0;
+
+	obj = cr_obj_find_by_ptr(ctx, ptr);
+	if (!obj) {
+		obj = cr_obj_new(ctx, ptr, 0, type, flags);
+		if (!obj)
+			return -ENOMEM;
+		else
+			ret = 1;
+	} else if (obj->type != type)	/* sanity check */
+		return -EINVAL;
+	*objref = obj->objref;
+	return ret;
+}
+
+int cr_obj_add_ref(struct cr_ctx *ctx, void *ptr, int objref,
+		   unsigned short type, unsigned short flags)
+{
+	struct cr_objref *obj;
+
+	obj = cr_obj_new(ctx, ptr, objref, type, flags);
+	return (obj ? 0 : -ENOMEM);
+}
+
+int cr_obj_get_by_ptr(struct cr_ctx *ctx, void *ptr, unsigned short type)
+{
+	struct cr_objref *obj;
+
+	obj = cr_obj_find_by_ptr(ctx, ptr);
+	if (obj)
+		return (obj->type == type ? obj->objref : -EINVAL);
+	else
+		return -ESRCH;
+}
+
+void *cr_obj_get_by_ref(struct cr_ctx *ctx, int objref, unsigned short type)
+{
+	struct cr_objref *obj;
+
+	obj = cr_obj_find_by_objref(ctx, objref);
+	if (obj)
+		return (obj->type == type ? obj->ptr : ERR_PTR(-EINVAL));
+	else
+		return NULL;
+}
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 263fb8a..1857010 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -130,6 +130,7 @@ void cr_ctx_free(struct cr_ctx *ctx)
  	free_pages((unsigned long) ctx->hbuf, CR_HBUF_ORDER);

  	cr_pgarr_free(ctx);
+	cr_objhash_free(ctx);

  	kfree(ctx);
  }
@@ -156,6 +157,9 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
  	if (!cr_pgarr_alloc(ctx, &ctx->pgarr))
  		goto nomem;

+	if (cr_objhash_alloc(ctx) < 0)
+		goto nomem;
+
  	ctx->pid = pid;
  	ctx->flags = flags;

diff --git a/include/linux/ckpt.h b/include/linux/ckpt.h
index 83c61a4..e8be58c 100644
--- a/include/linux/ckpt.h
+++ b/include/linux/ckpt.h
@@ -28,6 +28,8 @@ struct cr_ctx {
  	void *hbuf;		/* temporary buffer for headers */
  	int hpos;		/* position in headers buffer */

+	struct cr_objhash *objhash;	/* hash for shared objects */
+
  	struct cr_pgarr *pgarr;	/* page array for dumping VMA contents */
  	struct cr_pgarr *pgcur;	/* current position in page array */

@@ -50,6 +52,22 @@ int cr_kread(struct cr_ctx *ctx, void *buf, int count);
  void *cr_hbuf_get(struct cr_ctx *ctx, int n);
  void cr_hbuf_put(struct cr_ctx *ctx, int n);

+/* shared objects handling */
+
+enum {
+	CR_OBJ_FILE = 1,
+	CR_OBJ_MAX
+};
+
+void cr_objhash_free(struct cr_ctx *ctx);
+int cr_objhash_alloc(struct cr_ctx *ctx);
+void *cr_obj_get_by_ref(struct cr_ctx *ctx, int objref, unsigned short type);
+int cr_obj_get_by_ptr(struct cr_ctx *ctx, void *ptr, unsigned short type);
+int cr_obj_add_ptr(struct cr_ctx *ctx, void *ptr, int *objref,
+		   unsigned short type, unsigned short flags);
+int cr_obj_add_ref(struct cr_ctx *ctx, void *ptr, int objref,
+		   unsigned short type, unsigned short flags);
+
  struct cr_hdr;

  int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf);
-- 
1.5.4.3
