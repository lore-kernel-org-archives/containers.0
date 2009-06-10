From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/10] cr: ipc: reset kern_ipc_perms
Date: Tue, 9 Jun 2009 20:45:06 -0500
Message-ID: <20090610014506.GD5658@us.ibm.com>
References: <20090610014412.GA5628@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090610014412.GA5628-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Reset the checkpointed uid and gid info on ipc objects.

Right now, we return -EPERM if the user calling sys_restart() isn't
allowed to create an object with the checkpointed uid.  We may prefer
to simply use the caller's uid in that case - but that could lead to
subtle userspace bugs?  Unsure, so going for the stricter behavior.

TODO: restore kern_ipc_perms->security.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/checkpoint.c |   33 +++++++++++++++++++++++++++++++--
 1 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index f621226..bc77743 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -119,6 +119,26 @@ int checkpoint_ipc_ns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns)
  * Restart
  */
 
+/*
+ * check whether current task may create ipc object with
+ * checkpointed uids and gids.
+ * Return 1 if ok, 0 if not.
+ */
+static int validate_created_perms(struct ckpt_hdr_ipc_perms *h)
+{
+	const struct cred *cred = current_cred();
+	uid_t uid = cred->uid, euid = cred->euid;
+
+	/* actually I don't know - is CAP_IPC_OWNER the right one? */
+	if (((h->uid != uid && h->uid == euid) ||
+			(h->cuid != uid && h->cuid != euid) ||
+			!in_group_p(h->cgid) ||
+			!in_group_p(h->gid)) &&
+			!capable(CAP_IPC_OWNER))
+		return 0;
+	return 1;
+}
+
 int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 			   struct kern_ipc_perm *perm)
 {
@@ -139,14 +159,23 @@ int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 
 	perm->id = h->id;
 	perm->key = h->key;
-#if 0 /* FIX: requires security checks */
+
+	if (!validate_created_perms(h))
+		return -EPERM;
 	perm->uid = h->uid;
 	perm->gid = h->gid;
 	perm->cuid = h->cuid;
 	perm->cgid = h->cgid;
-#endif
 	perm->mode = h->mode;
 	perm->seq = h->seq;
+	/*
+	 * Todo: restore perm->security.
+	 * At the moment it gets set by security_x_alloc() called through
+	 * ipcget()->ipcget_public()->ops-.getnew (->nequeue for instance)
+	 * We will want to ask the LSM to consider resetting the
+	 * checkpointed ->security, based on current_security(),
+	 * the checkpointed ->security, and the checkpoint file context.
+	 */
 
 	return 0;
 }
-- 
1.6.1
