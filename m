From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [patch 1/1][RFC] do not sys_reboot when not in init_pid_ns
Date: Mon, 03 Nov 2008 10:59:15 -0800
Message-ID: <1225738755.12673.455.camel@nimitz>
References: <490CEDA0.6020800@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <490CEDA0.6020800-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, 2008-11-02 at 01:00 +0100, Daniel Lezcano wrote:
> +++ net-next-2.6/kernel/sys.c
> @@ -355,6 +355,9 @@ asmlinkage long sys_reboot(int magic1, i
>         if (!capable(CAP_SYS_BOOT))
>                 return -EPERM;
> 
> +       if (current->nsproxy->pid_ns != &init_pid_ns)
> +               return 0;
> +
>         /* For safety, we require "magic" arguments. */
>         if (magic1 != LINUX_REBOOT_MAGIC1 ||
>             (magic2 != LINUX_REBOOT_MAGIC2 &&

One problem I have with this is that it specifically defines being "in a
container" as being in a pid_ns other than the init_pid_ns.  If we're
going to go down this road, it should be at *least*:

int in_a_container(void)
{
	return current->nsproxy->pid_ns != &init_pid_ns;
}

But, this also sucks because we don't want to be introducing new code
paths all over the kernel for the "container" case.  What we'll end up
with little craplets like this spread all over:

	if (in_a_container()) {
		/* don't ever test this code path */
	}

:)

So I think we should avoid what you're trying to do here like the
plague.

-- Dave
