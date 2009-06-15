From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] mktree: use clone_with_pid on s390
Date: Mon, 15 Jun 2009 12:13:37 -0500
Message-ID: <20090615171337.GA15152@us.ibm.com>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 mktree.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/mktree.c b/mktree.c
index db5a060..af18b57 100644
--- a/mktree.c
+++ b/mktree.c
@@ -1720,6 +1720,47 @@ static int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
 }
 #else
 
+#elif defined __s390__
+
+#ifndef __NR_clone_with_pids
+#define __NR_clone_with_pids	332
+#endif
+
+#define do_clone_with_pids(stack, flags, ptid, ctid, setp) ({ \
+	register unsigned long int __r2 asm ("2") = (unsigned long int)(stack);\
+	register unsigned long int __r3 asm ("3") = (unsigned long int)(flags);\
+	register unsigned long int __r4 asm ("4") = (unsigned long int)(ptid); \
+	register unsigned long int __r5 asm ("5") = (unsigned long int)(ctid); \
+	register unsigned long int __r6 asm ("6") = (unsigned long int)(NULL); \
+	register unsigned long int __r7 asm ("7") = (unsigned long int)(setp); \
+	register unsigned long int __result asm ("2"); \
+	__asm__ __volatile__( \
+		" lghi %%r1,332\n" \
+		" svc 0\n" \
+		: "=d" (__result) \
+		: "0" (__r2), "d" (__r3), \
+		  "d" (__r4), "d" (__r5), "d" (__r6), "d" (__r7) \
+		: "1", "cc", "memory" \
+	); \
+		__result; \
+	})
+
+int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
+			struct target_pid_set *target_pids, void *arg)
+{
+	long retval;
+	retval = do_clone_with_pids(child_stack, flags, NULL, NULL,
+			target_pids);
+
+	if (retval < 0) {
+		errno = -retval;
+		return -1;
+	} else if (retval == 0) {
+		return fn(arg);
+	} else
+		return retval;
+}
+
 #error mktree requires arch support for clone_with_pids() syscall
 
 /*
-- 
1.6.1.1
