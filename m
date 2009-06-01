From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 8/8] cr: restore file->f_cred
Date: Mon, 1 Jun 2009 17:22:39 -0500
Message-ID: <20090601222239.GH29460@us.ibm.com>
References: <20090601222119.GB29164@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090601222119.GB29164@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org

Restore a file's f_cred.  This is set to the cred of the task doing
the open, so often it will be the same as that of the restarted task.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
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
index da9e44b..06635ba 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -304,7 +304,7 @@ struct ckpt_hdr_file {
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

