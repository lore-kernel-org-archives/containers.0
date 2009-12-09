From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] c/r: [x86_32] sys_restore to use ptregs prototype
Date: Wed, 9 Dec 2009 11:02:05 -0600
Message-ID: <20091209170205.GA21507@us.ibm.com>
References: <1260131469-2917-1-git-send-email-orenl@cs.columbia.edu>
	<1260131469-2917-2-git-send-email-orenl@cs.columbia.edu>
	<4B1C357C.2090003@cs.columbia.edu>
	<1260219307.7151.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1260219307.7151.3.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Here I guess is the s390 version.  If we need the pt_regs later, we
can get it using get_pt_regs(current) as the clone wrapper right
above it does.

Subject: [PATCH 1/1] define s390x sys_restart wrapper

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/kernel/process.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 0a59317..087f52c 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -241,6 +241,15 @@ SYSCALL_DEFINE4(clone, unsigned long, newsp, unsigned long, clone_flags,
 		       parent_tidptr, child_tidptr);
 }
 
+#ifdef CONFIG_CHECKPOINT
+extern long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd);
+SYSCALL_DEFINE4(restart, pid_t, pid, int, fd, unsigned long, flags,
+		int, logfd)
+{
+	return do_sys_restart(pid, fd, flags, logfd);
+}
+#endif
+
 SYSCALL_DEFINE4(eclone, unsigned int, flags_low, struct clone_args __user *,
 		uca, int, args_size, pid_t __user *, pids)
 {
-- 
1.6.1
