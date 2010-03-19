From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [C/R v20][PATCH 66/96] c/r: restore file->f_cred
Date: Thu, 18 Mar 2010 20:59:57 -0400
Message-ID: <1268960401-16680-14-git-send-email-orenl__38248.5784627081$1268961104$gmane$org@cs.columbia.edu>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268960401-16680-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Restore a file's f_cred.  This is set to the cred of the task doing
the open, so often it will be the same as that of the restarted task.

Changelog[v1]:
  - [Nathan Lynch] discard const from struct cred * where appropriate

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/files.c             |   18 ++++++++++++++++--
 include/linux/checkpoint_hdr.h |    2 +-
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 62feadd..63a611f 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -148,15 +148,21 @@ static int scan_fds(struct files_struct *files, int **fdtable)
 int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 			   struct ckpt_hdr_file *h)
 {
+	struct cred *f_cred = (struct cred *) file->f_cred;
+
 	h->f_flags = file->f_flags;
 	h->f_mode = file->f_mode;
 	h->f_pos = file->f_pos;
 	h->f_version = file->f_version;
 
+	h->f_credref = checkpoint_obj(ctx, f_cred, CKPT_OBJ_CRED);
+	if (h->f_credref < 0)
+		return h->f_credref;
+
 	ckpt_debug("file %s credref %d", file->f_dentry->d_name.name,
 		h->f_credref);
 
-	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
+	/* FIX: need also file->f_owner, etc */
 
 	return 0;
 }
@@ -522,8 +528,16 @@ int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 	fmode_t new_mode = file->f_mode;
 	fmode_t saved_mode = (__force fmode_t) h->f_mode;
 	int ret;
+	struct cred *cred;
+
+	/* FIX: need to restore owner etc */
 
-	/* FIX: need to restore uid, gid, owner etc */
+	/* restore the cred */
+	cred = ckpt_obj_fetch(ctx, h->f_credref, CKPT_OBJ_CRED);
+	if (IS_ERR(cred))
+		return PTR_ERR(cred);
+	put_cred(file->f_cred);
+	file->f_cred = get_cred(cred);
 
 	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
 	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index cbccc81..729be96 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -432,7 +432,7 @@ struct ckpt_hdr_file {
 	__u32 f_type;
 	__u32 f_mode;
 	__u32 f_flags;
-	__u32 _padding;
+	__s32 f_credref;
 	__u64 f_pos;
 	__u64 f_version;
 } __attribute__((aligned(8)));
-- 
1.6.3.3
