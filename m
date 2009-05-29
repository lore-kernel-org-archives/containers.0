From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 7/9] cr: restore file->f_cred
Date: Fri, 29 May 2009 17:33:45 -0500
Message-ID: <20090529223345.GG14602@us.ibm.com>
References: <20090529223229.GA14536@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090529223229.GA14536-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Restore a file's f_cred.  This is set to the cred of the task doing
the open, so often it will be the same as that of the restarted task.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c             |   16 ++++++++++++++--
 include/linux/checkpoint_hdr.h |    2 +-
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index b264e40..cc813ed 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -154,7 +154,11 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 	h->f_pos = file->f_pos;
 	h->f_version = file->f_version;
 
-	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
+	h->f_credref = checkpoint_obj(ctx, file->f_cred, CKPT_OBJ_CRED);
+	if (h->f_credref < 0)
+		return h->f_credref;
+
+	/* FIX: need also file->f_owner, etc */
 
 	return 0;
 }
@@ -377,8 +381,16 @@ int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 			struct ckpt_hdr_file *h)
 {
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
index e38867e..7f4972b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -296,7 +296,7 @@ struct ckpt_hdr_file {
 	__u32 f_type;
 	__u32 f_mode;
 	__u32 f_flags;
-	__u32 _padding;
+	__s32 f_credref;
 	__u64 f_pos;
 	__u64 f_version;
 } __attribute__((aligned(8)));
-- 
1.6.1
