From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC v2][PATCH 6/9] Simplify filename handling for now
Date: Wed, 20 Aug 2008 12:26:04 -0700
Message-ID: <20080820192604.79777FBA__34570.6965345473$1219260603$gmane$org@nimitz>
References: <20080820192557.98788FAB@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080820192557.98788FAB@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


The filename handling is a bit clunky, as one of the reviewers
noted.  It can allocate memory in one of two places and that
makes things look a bit weird.

We don't *really* need the filename sitting around in its own
buffer, so let's just combine the writing and the filename
generation.

It moves the order in which the things in the VMA are done,
but it doens't change the order in which they are written
to the checkpoint file.

Note how much code this removes.

---

 oren-cr.git-dave/checkpoint/checkpoint.c |   48 ++++++++++++-------------------
 oren-cr.git-dave/checkpoint/ckpt.h       |    1 
 oren-cr.git-dave/checkpoint/ckpt_mem.c   |   36 ++++++-----------------
 3 files changed, 30 insertions(+), 55 deletions(-)

diff -puN checkpoint/checkpoint.c~0007-fixup-filename-handling checkpoint/checkpoint.c
--- oren-cr.git/checkpoint/checkpoint.c~0007-fixup-filename-handling	2008-08-20 12:12:50.000000000 -0700
+++ oren-cr.git-dave/checkpoint/checkpoint.c	2008-08-20 12:12:50.000000000 -0700
@@ -23,43 +23,33 @@
 #include "ckpt_arch.h"
 
 /**
- * cr_get_fname - return pathname of a given file
- * @file: file pointer
- * @buf: buffer for pathname
- * @n: buffer length (in) and pathname length (out)
- *
- * if the buffer provivded by the caller is too small, allocate a new
- * buffer; caller should call cr_put_pathname() for cleanup
+ * cr_write_fname - write a string record for a filename
+ * @ctx: checkpoint context
+ * @path: path name to write
+ * @root: root from which to find the path
  */
-char *cr_get_fname(struct path *path, struct path *root, char *buf, int *n)
+int cr_write_fname(struct cr_ctx *ctx, struct path *path, struct path *root)
 {
+	char *fname_buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	char *fname;
+	int ret;
+	int len;
 
-	fname = __d_path(path, root, buf, *n);
+	if (!fname_buf)
+		return -ENOMEM;
 
-	if (IS_ERR(fname) && PTR_ERR(fname) == -ENAMETOOLONG) {
-		 if (!(buf = (char *) __get_free_pages(GFP_KERNEL, 0)))
-			 return ERR_PTR(-ENOMEM);
-		fname = __d_path(path, root, buf, PAGE_SIZE);
-		if (IS_ERR(fname))
-			free_pages((unsigned long) buf, 0);
+	fname = __d_path(path, root, fname_buf, PAGE_SIZE);
+	if (IS_ERR(fname)) {
+		ret = PTR_ERR(fname);
+		goto out_free;
 	}
-	if (!IS_ERR(fname))
-		*n = (buf + *n - fname);
 
-	return fname;
-}
+	len = PAGE_SIZE + fname_buf - fname;
+	ret = cr_write_str(ctx, fname, len);
 
-/**
- * cr_put_fname - (possibly) cleanup pathname buffer
- * @buf: original buffer that was given to cr_get_pathname()
- * @fname: resulting pathname from cr_get_pathname()
- * @n: length of original buffer
- */
-void cr_put_fname(char *buf, char *fname, int n)
-{
-	if (fname && (fname < buf || fname >= buf + n))
-		free_pages((unsigned long) buf, 0);
+out_free:
+	kfree(fname_buf);
+	return ret;
 }
 
 /**
diff -puN checkpoint/ckpt.h~0007-fixup-filename-handling checkpoint/ckpt.h
--- oren-cr.git/checkpoint/ckpt.h~0007-fixup-filename-handling	2008-08-20 12:12:50.000000000 -0700
+++ oren-cr.git-dave/checkpoint/ckpt.h	2008-08-20 12:12:50.000000000 -0700
@@ -48,6 +48,7 @@ struct cr_ctx {
 
 extern void cr_put_fname(char *buf, char *fname, int n);
 extern char *cr_get_fname(struct path *path, struct path *root, char *buf, int *n);
+extern int cr_write_fname(struct cr_ctx *ctx, struct path *path, struct path *root);
 
 extern int cr_uwrite(struct cr_ctx *ctx, void *buf, int count);
 extern int cr_kwrite(struct cr_ctx *ctx, void *buf, int count);
diff -puN checkpoint/ckpt_mem.c~0007-fixup-filename-handling checkpoint/ckpt_mem.c
--- oren-cr.git/checkpoint/ckpt_mem.c~0007-fixup-filename-handling	2008-08-20 12:12:50.000000000 -0700
+++ oren-cr.git-dave/checkpoint/ckpt_mem.c	2008-08-20 12:12:50.000000000 -0700
@@ -262,8 +262,7 @@ static int cr_write_vma(struct cr_ctx *c
 {
 	struct cr_hdr h;
 	struct cr_hdr_vma *hh = ctx->tbuf;
-	char *fname = NULL;
-	int how, nr, ret;
+	int nr, ret;
 
 	h.type = CR_HDR_VMA;
 	h.len = sizeof(*hh);
@@ -280,23 +279,10 @@ static int cr_write_vma(struct cr_ctx *c
 		return -ETXTBSY;
 	}
 
-	/* by default assume anon memory */
-	how = CR_VMA_ANON;
-
-	/* if there is a backing file, assume private-mapped */
-	/* (NEED: check if the file is unlinked) */
-	if (vma->vm_file) {
-		nr = PAGE_SIZE;
-		fname = cr_get_fname(&vma->vm_file->f_path,
-				     ctx->vfsroot, ctx->tbuf, &nr);
-		if (IS_ERR(fname))
-			return PTR_ERR(fname);
-		hh->namelen = nr;
-		how = CR_VMA_FILE;
-	} else
-		hh->namelen = 0;
-
-	hh->how = how;
+	hh->how = CR_VMA_ANON;
+	hh->namelen = 0;
+	if (vma->vm_file)
+		hh->how = CR_VMA_FILE;
 
 	/*
 	 * it seems redundant now, but we do it in 3 steps for because:
@@ -310,18 +296,16 @@ static int cr_write_vma(struct cr_ctx *c
 	 * pages to dump, and make those pages COW. keep the list of pages
 	 * (and a reference to each page) on the checkpoint ctx */
 	nr = cr_vma_scan_pages(ctx, vma);
-	if (nr < 0) {
-		cr_put_fname(ctx->tbuf, fname, PAGE_SIZE);
+	if (nr < 0)
 		return nr;
-	}
 
 	hh->npages = nr;
 	ret = cr_write_obj(ctx, &h, hh);
 
-	if (!ret && hh->namelen)
-		ret = cr_write_str(ctx, fname, hh->namelen);
-
-	cr_put_fname(ctx->tbuf, fname, PAGE_SIZE);
+	/* if there is a backing file, assume private-mapped */
+	/* (NEED: check if the file is unlinked) */
+	if (hh->how == CR_VMA_FILE)
+		ret = cr_write_fname(ctx, &vma->vm_file->f_path, ctx->vfsroot);
 
 	if (ret < 0)
 		return ret;
_
