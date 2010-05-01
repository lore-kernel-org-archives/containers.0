From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 058/100] c/r: (s390): expose a constant for the number of
	words (CRs)
Date: Sat,  1 May 2010 10:15:40 -0400
Message-ID: <1272723382-19470-59-git-send-email-orenl__1644.72498368031$1272727898$gmane$org@cs.columbia.edu>
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
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

We need to use this value in the checkpoint/restart code and would like to
have a constant instead of a magic '3'.

Changelog:
    Jan 20:
            . Define s390x sys_restart wrapper
    Mar 30:
            . Add CHECKPOINT_SUPPORT in Kconfig (Nathan Lynch)
    Mar 03:
            . Picked up additional use of magic '3' in ptrace.h

Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/Kconfig          |    4 ++++
 arch/s390/kernel/process.c |    8 ++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 0d8cd9b..b358e63 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -49,6 +49,10 @@ config GENERIC_TIME_VSYSCALL
 config GENERIC_CLOCKEVENTS
 	def_bool y
 
+config CHECKPOINT_SUPPORT
+	bool
+	default y if 64BIT
+
 config GENERIC_BUG
 	bool
 	depends on BUG
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 799cbb0..15f5719 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -240,6 +240,14 @@ SYSCALL_DEFINE4(clone, unsigned long, newsp, unsigned long, clone_flags,
 		       parent_tidptr, child_tidptr);
 }
 
+#ifdef CONFIG_CHECKPOINT
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
1.6.3.3
