From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Forbid invocation of kexec_load() outside initial PID
	namespace
Date: Fri,  3 Aug 2012 11:53:04 +0100
Message-ID: <1343991184-3619-1-git-send-email-berrange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

The following commit

    commit cf3f89214ef6a33fad60856bc5ffd7bb2fc4709b
    Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
    Date:   Wed Mar 28 14:42:51 2012 -0700

    pidns: add reboot_pid_ns() to handle the reboot syscall

introduced custom handling of the reboot() syscall when invoked
from a non-initial PID namespace. The intent was that a process
in a container can be allowed to keep CAP_SYS_BOOT and execute
reboot() to shutdown/reboot just their private container, rather
than the host.

Unfortunately the kexec_load() syscall also relies on the
CAP_SYS_BOOT capability. So by allowing a container to keep
this capability to safely invoke reboot(), they mistakenly
also gain the ability to use kexec_load(). The solution is
to make kexec_load() return -EPERM if invoked from a PID
namespace that is not the initial namespace

Signed-off-by: Daniel P. Berrange <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 kernel/kexec.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel/kexec.c b/kernel/kexec.c
index 0668d58..b152bde 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -947,6 +947,11 @@ SYSCALL_DEFINE4(kexec_load, unsigned long, entry, unsigned long, nr_segments,
 	if (!capable(CAP_SYS_BOOT))
 		return -EPERM;
 
+	/* Processes in containers must not be allowed to load a new
+	 * kernel, even if they have CAP_SYS_BOOT */
+	if (task_active_pid_ns(current) != &init_pid_ns)
+		return -EPERM;
+
 	/*
 	 * Verify we have a legal set of flags
 	 * This leaves us room for future extensions.
-- 
1.7.11.2
