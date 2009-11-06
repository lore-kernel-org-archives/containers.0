From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 5/7] kernel/cred.c: ckpt_err at restart
Date: Thu,  5 Nov 2009 18:00:17 -0600
Message-ID: <1257465619-1777-6-git-send-email-serue@us.ibm.com>
References: <1257465619-1777-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257465619-1777-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/cred.c |   46 ++++++++++++++++++++++++++++++++++++----------
 1 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/kernel/cred.c b/kernel/cred.c
index 62d28a4..c941078 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -764,32 +764,46 @@ static struct cred *do_restore_cred(struct ckpt_ctx *ctx)
 	int i;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CRED);
-	if (IS_ERR(h))
+	if (IS_ERR(h)) {
+		ckpt_err(ctx, ret, "reading cred entry\n");
 		return ERR_PTR(PTR_ERR(h));
+	}
 
 	cred = prepare_creds();
-	if (!cred)
+	if (!cred) {
+		ckpt_err(ctx, ret, "prepare_creds()\n");
 		goto error;
+	}
 
 
 	/* Do we care if the target user and target group were compatible?
 	 * Probably.  But then, we can't do any setuid without CAP_SETUID,
 	 * so we must have been privileged to abuse it... */
 	groupinfo = ckpt_obj_fetch(ctx, h->groupinfo_ref, CKPT_OBJ_GROUPINFO);
-	if (IS_ERR(groupinfo))
+	if (IS_ERR(groupinfo)) {
+		ret = PTR_ERR(groupinfo);
+		ckpt_err(ctx, ret, "%(O)fetching group\n", h->groupinfo_ref);
 		goto err_putcred;
+	}
 	user = ckpt_obj_fetch(ctx, h->user_ref, CKPT_OBJ_USER);
-	if (IS_ERR(user))
+	if (IS_ERR(user)) {
+		ret = PTR_ERR(user);
+		ckpt_err(ctx, ret, "%(O)fetching user\n", h->user_ref);
 		goto err_putcred;
+	}
 
 	/*
 	 * TODO: this check should  go into the common helper in
 	 * kernel/sys.c, and should account for user namespaces
 	 */
+	ret = -EPERM;
 	if (!capable(CAP_SETGID))
 		for (i = 0; i < groupinfo->ngroups; i++) {
-			if (!in_egroup_p(GROUP_AT(groupinfo, i)))
+			gid_t g = GROUP_AT(groupinfo, i);
+			if (!in_egroup_p(g)) {
+				ckpt_err(ctx, ret, "group %d\n", g);
 				goto err_putcred;
+			}
 		}
 	ret = set_groups(cred, groupinfo);
 	if (ret < 0)
@@ -797,20 +811,32 @@ static struct cred *do_restore_cred(struct ckpt_ctx *ctx)
 	free_uid(cred->user);
 	cred->user = get_uid(user);
 	ret = cred_setresuid(cred, h->uid, h->euid, h->suid);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "setting uid %d euid %d suid %d\n",
+			 h->uid, h->euid, h->suid);
 		goto err_putcred;
+	}
 	ret = cred_setfsuid(cred, h->fsuid, &olduid);
-	if (olduid != h->fsuid && ret < 0)
+	if (olduid != h->fsuid && ret < 0) {
+		ckpt_err(ctx, ret, "setting fs uid %d\n", h->fsuid);
 		goto err_putcred;
+	}
 	ret = cred_setresgid(cred, h->gid, h->egid, h->sgid);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "setting gid %d egid %d sgid %d\n",
+			 h->gid, h->egid, h->sgid);
 		goto err_putcred;
+	}
 	ret = cred_setfsgid(cred, h->fsgid, &oldgid);
-	if (oldgid != h->fsgid && ret < 0)
+	if (oldgid != h->fsgid && ret < 0) {
+		ckpt_err(ctx, ret, "setting fs gid %d\n", h->fsgid);
 		goto err_putcred;
+	}
 	ret = restore_capabilities(&h->cap_s, cred);
-	if (ret)
+	if (ret) {
+		ckpt_err(ctx, ret, "restoring capabilities\n");
 		goto err_putcred;
+	}
 
 	ckpt_hdr_put(ctx, h);
 	return cred;
-- 
1.6.1
