From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 1/1][V5] Add reboot_pid_ns to handle the reboot syscall
Date: Thu, 2 Feb 2012 16:10:18 -0800
Message-ID: <20120202161018.e3c62965.akpm@linux-foundation.org>
References: <1325754410-32600-1-git-send-email-daniel.lezcano@free.fr>
	<1325754410-32600-2-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1325754410-32600-2-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu,  5 Jan 2012 10:06:50 +0100
Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:

> In the case of a child pid namespace, rebooting the system does not
> really makes sense. When the pid namespace is used in conjunction
> with the other namespaces in order to create a linux container, the
> reboot syscall leads to some problems.
> 
> A container can reboot the host. That can be fixed by dropping
> the sys_reboot capability but we are unable to correctly to poweroff/
> halt/reboot a container and the container stays stuck at the shutdown
> time with the container's init process waiting indefinitively.
> 
> After several attempts, no solution from userspace was found to reliabily
> handle the shutdown from a container.
> 
> This patch propose to make the init process of the child pid namespace to
> exit with a signal status set to : SIGINT if the child pid namespace called
> "halt/poweroff" and SIGHUP if the child pid namespace called "reboot".
> When the reboot syscall is called and we are not in the initial
> pid namespace, we kill the pid namespace for "HALT", "POWEROFF", "RESTART",
> and "RESTART2". Otherwise we return EINVAL.
> 
> Returning EINVAL is also an easy way to check if this feature is supported
> by the kernel when invoking another 'reboot' option like CAD.
> 
> By this way the parent process of the child pid namespace knows if
> it rebooted or not and can take the right decision.

Looks OK, although the comments need help.  Is the below still true?

Do you think it would be feasible to put your testcase into
tools/testing/selftests?  I'm thinking "no", because running the test
needs elevated permissions and might reboot the user's machine(!).


--- a/include/linux/pid_namespace.h~pidns-add-reboot_pid_ns-to-handle-the-reboot-syscall-fix
+++ a/include/linux/pid_namespace.h
@@ -32,7 +32,7 @@ struct pid_namespace {
 #endif
 	gid_t pid_gid;
 	int hide_pid;
-	int reboot;
+	int reboot;	/* group exit code if this pidns was rebooted */
 };
 
 extern struct pid_namespace init_pid_ns;
--- a/kernel/sys.c~pidns-add-reboot_pid_ns-to-handle-the-reboot-syscall-fix
+++ a/kernel/sys.c
@@ -444,9 +444,10 @@ SYSCALL_DEFINE4(reboot, int, magic1, int
 	                magic2 != LINUX_REBOOT_MAGIC2C))
 		return -EINVAL;
 
-	/* In case the pid namespaces are enabled, the current task is in a
-	 * child pid_namespace and the command is handled by 'reboot_pid_ns',
-	 * this one will invoke 'do_exit'.
+	/*
+	 * If pid namespaces are enabled and the current task is in a child
+	 * pid_namespace, the command is handled by reboot_pid_ns() which will
+	 * call do_exit().
 	 */
 	ret = reboot_pid_ns(task_active_pid_ns(current), cmd);
 	if (ret)

> --- a/include/linux/pid_namespace.h
> +++ b/include/linux/pid_namespace.h
> @@ -32,6 +32,7 @@ struct pid_namespace {
>  #endif
>  	gid_t pid_gid;
>  	int hide_pid;
> +	int reboot;
>  };

This was particuarly distressing.  The field was poorly named and other
people forgotting to document their data structures doesn't mean that
we should continue to do this!
