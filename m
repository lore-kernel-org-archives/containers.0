From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: use a new capability to authorize c/r
Date: Tue, 12 May 2009 10:07:13 -0500
Message-ID: <20090512150713.GA32064@us.ibm.com>
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
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Alexey,

do you object to this patch?  The idea is to not give away any
privilege not otherwise needed.

thanks,
-serge

From b929e0b1c1a27e328ad04e8e651ddd5ec0496ccc Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 12 May 2009 10:53:14 -0400
Subject: [PATCH 1/1] cr: use a new capability to authorize c/r

We're currently using CAP_SYS_ADMIN to allow sys_checkpoint() and
sys_restart().  It makes no sense to lump it in with all the other
things CAP_SYS_ADMIN implies.

Define CAP_CHECKPOINT_RESTART and use that instead.

Note that CAP_SYS_ADMIN will still be necessary for unsharing
namespaces, CAP_SETUID  and CAP_SETGID for setting ids, etc.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/sys.c           |    4 ++--
 include/linux/capability.h |    4 +++-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 255ebc1..5552478 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -281,7 +281,7 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
 	if (flags & ~CKPT_USER_FLAGS)
 		return -EINVAL;
 
-	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
+	if (!ckpt_unpriv_allowed && !capable(CAP_CHECKPOINT_RESTART))
 		return -EPERM;
 
 	if (pid == 0)
@@ -318,7 +318,7 @@ asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
 	if (flags)
 		return -EINVAL;
 
-	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
+	if (!ckpt_unpriv_allowed && !capable(CAP_CHECKPOINT_RESTART))
 		return -EPERM;
 
 	/* FIXME: for now, we use 'crid' as a pid */
diff --git a/include/linux/capability.h b/include/linux/capability.h
index 572b5a0..a593391 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -357,7 +357,9 @@ struct cpu_vfs_cap_data {
 
 #define CAP_MAC_ADMIN        33
 
-#define CAP_LAST_CAP         CAP_MAC_ADMIN
+#define CAP_CHECKPOINT_RESTART      34
+
+#define CAP_LAST_CAP         CAP_CHECKPOINT_RESTART
 
 #define cap_valid(x) ((x) >= 0 && (x) <= CAP_LAST_CAP)
 
-- 
1.6.1
