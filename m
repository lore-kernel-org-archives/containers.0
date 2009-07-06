From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] mktree: s390: don't hard-code clone-with-pids syscall
Date: Mon, 6 Jul 2009 17:27:03 -0500
Message-ID: <20090706222703.GA730@us.ibm.com>
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

Use __NR_clone_with_pids (from asm/unistd.h) as an immediate
value instead.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 mktree.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mktree.c b/mktree.c
index 76a71ac..0782068 100644
--- a/mktree.c
+++ b/mktree.c
@@ -1829,11 +1829,12 @@ static int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
 	register unsigned long int __r7 asm ("7") = (unsigned long int)(setp); \
 	register unsigned long int __result asm ("2"); \
 	__asm__ __volatile__( \
-		" lghi %%r1,332\n" \
+		" lghi %%r1,%7\n" \
 		" svc 0\n" \
 		: "=d" (__result) \
 		: "0" (__r2), "d" (__r3), \
-		  "d" (__r4), "d" (__r5), "d" (__r6), "d" (__r7) \
+		  "d" (__r4), "d" (__r5), "d" (__r6), "d" (__r7), \
+		  "i" (__NR_clone_with_pids) \
 		: "1", "cc", "memory" \
 	); \
 		__result; \
-- 
1.6.1.1
