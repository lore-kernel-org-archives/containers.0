From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: credentials: fix some refcounting
Date: Thu, 14 May 2009 17:32:47 -0500
Message-ID: <20090514223247.GA13378@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Creds and user namespaces both need one more ref taken.
A new user_ns needs a ref to remain pinned by its root user.
current_user_ns needs an extra ref bc objhash drops two on
restart.
cred needs a ref for the real credentials because commit_creds
eats one ref.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/process.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index 5047944..74872ba 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -601,7 +601,8 @@ static struct user_namespace *restore_read_userns(struct ckpt_ctx *ctx)
 		return ERR_PTR(PTR_ERR(h));
 	if (h->flags & CKPT_USERNS_INIT) {
 		ckpt_hdr_put(ctx, h);
-		return current_user_ns();
+		/* grab an extra ref bc objhash will drop an extra */
+		return get_user_ns(current_user_ns());
 	}
 	creator = ckpt_obj_fetch(ctx, h->creator_ref, CKPT_OBJ_USER);
 	ckpt_hdr_put(ctx, h);
@@ -616,6 +617,10 @@ static struct user_namespace *restore_read_userns(struct ckpt_ctx *ctx)
 	/* new_user_ns() doesn't bump creator's refcount */
 	get_uid(creator);
 
+	/* objhash will drop new_ns refcount, but new_root
+	 * should hold a ref */
+	get_user_ns(ns);
+
 	return ns;
 }
 
@@ -1088,6 +1093,10 @@ static int restore_creds(struct ckpt_ctx *ctx, struct cred *rcred,
 	int ret;
 	const struct cred *old;
 
+	/* commit_creds will take one ref for the eff creds, but
+	 * expects us to hold a ref for the obj creds, so take a
+	 * ref here */
+	get_cred(rcred);
 	ret = commit_creds(rcred);
 	if (ret)
 		return ret;
-- 
1.6.1
