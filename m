From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 069/100] Expose may_setuid() in user.h and add
	may_setgid() (v2)
Date: Sat,  1 May 2010 10:15:51 -0400
Message-ID: <1272723382-19470-70-git-send-email-orenl__32244.9143663563$1272728548$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Make these helpers available to others.

Changes in v2:
 - Avoid checking the groupinfo in ctx->realcred against the current in
   may_setgid()

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/user.h |    9 +++++++++
 kernel/user.c        |   13 ++++++++++++-
 2 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/include/linux/user.h b/include/linux/user.h
index 68daf84..c231e9c 100644
--- a/include/linux/user.h
+++ b/include/linux/user.h
@@ -1 +1,10 @@
+#ifndef _LINUX_USER_H
+#define _LINUX_USER_H
+
 #include <asm/user.h>
+#include <linux/sched.h>
+
+extern int may_setuid(struct user_namespace *ns, uid_t uid);
+extern int may_setgid(gid_t gid);
+
+#endif
diff --git a/kernel/user.c b/kernel/user.c
index 4d1fda6..c546fee 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -279,7 +279,7 @@ static int checkpoint_user(struct ckpt_ctx *ctx, void *ptr)
 	return do_checkpoint_user(ctx, (struct user_struct *) ptr);
 }
 
-static int may_setuid(struct user_namespace *ns, uid_t uid)
+int may_setuid(struct user_namespace *ns, uid_t uid)
 {
 	/*
 	 * this next check will one day become
@@ -306,6 +306,17 @@ static int may_setuid(struct user_namespace *ns, uid_t uid)
 	return 0;
 }
 
+int may_setgid(gid_t gid)
+{
+	if (capable(CAP_SETGID))
+		return 1;
+
+	if (in_egroup_p(gid))
+		return 1;
+
+	return 0;
+}
+
 static struct user_struct *do_restore_user(struct ckpt_ctx *ctx)
 {
 	struct user_struct *u;
-- 
1.6.3.3
