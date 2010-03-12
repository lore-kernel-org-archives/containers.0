From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH linux-cr urgent] lsm: fix unlabeled restore case.
Date: Fri, 12 Mar 2010 14:47:06 -0600
Message-ID: <20100312204706.GA408@us.ibm.com>
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

If an object is being restored which was checkpointed without an
LSM label, then we should return 0 BEFORE we try to ckpt_obj_fetch
a -1 objref (and obviously return error).

This makes the msg cr_tests ipc testcase fail if, for instance,
CONFIG_SECURITY=y but no LSM is active.

IMO this definately should be in the tree that gets sent out...

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 security/security.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/security/security.c b/security/security.c
index 2b147cf..4b3f932 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1528,14 +1528,14 @@ int security_restore_obj(struct ckpt_ctx *ctx, void *v, int sectype,
 		if (sectype != CKPT_SECURITY_MSG_MSG)
 			return 0;
 
-	l = ckpt_obj_fetch(ctx, secref, CKPT_OBJ_SECURITY);
-	if (IS_ERR(l))
-		return PTR_ERR(l);
-
 	/* return if checkpointed label was "Not Applicable" */
 	if (secref == SECURITY_CTX_NONE)
 		return 0;
 
+	l = ckpt_obj_fetch(ctx, secref, CKPT_OBJ_SECURITY);
+	if (IS_ERR(l))
+		return PTR_ERR(l);
+
 	/* Ask the LSM to apply a void*security to the object
 	 * based on the checkpointed context string */
 	switch (sectype) {
-- 
1.6.1
