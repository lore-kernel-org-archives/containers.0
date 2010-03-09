From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH linux-cr] always restore msg_msg label
Date: Tue, 9 Mar 2010 00:13:01 -0600
Message-ID: <20100309061301.GA21905@us.ibm.com>
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

Hi Oren,

In comparing your ckpt-v19-dev-serge branch to my local one I
noticed this patch was missing, then realized I hadn't sent it
separately, but only inline with a response to Nathan.

Please do apply.

Without this patch, selinux labels will not be restored on msg_msg's in
message queues (because we didn't send the restored msg_msg through
msgsnd), and the restored task won't have the permission to receive the
messages.

As I mentioned in that thread, simply re-routing the restored
msg_msg through msgsnd doesn't really suffice because the msg_msg
label is calculated as a product of the msgq and sending task
labels, and the latter may have already changed.

thanks,
-serge

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 security/security.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/security/security.c b/security/security.c
index 28db976..2b147cf 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1524,7 +1524,9 @@ int security_restore_obj(struct ckpt_ctx *ctx, void *v, int sectype,
 
 	/* return if caller didn't want to restore checkpointed labels */
 	if (!(ctx->uflags & RESTART_KEEP_LSM))
-		return 0;
+		/* though msg_msg label must always be restored */
+		if (sectype != CKPT_SECURITY_MSG_MSG)
+			return 0;
 
 	l = ckpt_obj_fetch(ctx, secref, CKPT_OBJ_SECURITY);
 	if (IS_ERR(l))
-- 
1.6.0.6
