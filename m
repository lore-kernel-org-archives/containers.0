From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 9/9] cr: ipc: reset kern_ipc_perms
Date: Fri, 29 May 2009 17:34:04 -0500
Message-ID: <20090529223404.GI14602@us.ibm.com>
References: <20090529223229.GA14536@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090529223229.GA14536@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morgan <morgan@kernel.org>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Reset the checkpointed uid and gid info on ipc objects.

Right now, we return -EPERM if the user calling sys_restart() isn't
allowed to create an object with the checkpointed uid.  We may prefer
to simply use the caller's uid in that case - but that could lead to
subtle userspace bugs?  Unsure, so going for the stricter behavior.

TODO: restore kern_ipc_perms->security.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
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

