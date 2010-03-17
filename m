From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [C/R v20][PATCH 72/96] Expose may_setuid() in user.h and add
	may_setgid() (v2)
Date: Wed, 17 Mar 2010 12:09:00 -0400
Message-ID: <1268842164-5590-73-git-send-email-orenl__42715.7360747971$1268850577$gmane$org@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-37-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-38-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-39-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-40-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-41-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-42-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-43-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-44-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-45-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-46-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-47-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-48-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-49-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-50-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-51-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-52-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-53-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-54-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-55-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-56-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-57-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-58-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-59-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-60-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-61-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-62-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-63-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-64-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-65-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-66-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-67-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-68-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-69-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-70-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-71-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-72-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268842164-5590-72-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
index 15f762c..8ddafea 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -604,7 +604,7 @@ int checkpoint_user(struct ckpt_ctx *ctx, void *ptr)
 	return do_checkpoint_user(ctx, (struct user_struct *) ptr);
 }
 
-static int may_setuid(struct user_namespace *ns, uid_t uid)
+int may_setuid(struct user_namespace *ns, uid_t uid)
 {
 	/*
 	 * this next check will one day become
@@ -631,6 +631,17 @@ static int may_setuid(struct user_namespace *ns, uid_t uid)
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
