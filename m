From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][V4] Add reboot_pid_ns to handle the reboot syscall
Date: Wed, 14 Dec 2011 20:17:39 +0100
Message-ID: <20111214191739.GA14693@redhat.com>
References: <1323649064-7960-1-git-send-email-daniel.lezcano@free.fr>
	<1323649064-7960-2-git-send-email-daniel.lezcano@free.fr>
	<20111213162242.1ab3cb1a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111213162242.1ab3cb1a.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/13, Andrew Morton wrote:
>
> > --- a/kernel/sys.c
> > +++ b/kernel/sys.c
> > @@ -444,6 +444,9 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
> >  	                magic2 != LINUX_REBOOT_MAGIC2C))
> >  		return -EINVAL;
> >
> > +	if (task_active_pid_ns(current) != &init_pid_ns)
> > +		return reboot_pid_ns(task_active_pid_ns(current), cmd);
> > +
> >  	/* Instead of trying to make the power_off code look like
> > 	 * halt when pm_power_off is not set do it the easy way.
> > 	 */
>
> I'll repeat my cruelly-ignored review comment for v3:
>
> This adds a bunch of useless code if CONFIG_PID_NS=n.

Agreed.

> It would be
> better to do
>
> #ifdef CONFIG_PID_NS
> extern void pidns_handle_reboot(int cmd);
> #else
> static inline void pidns_handle_reboot(int cmd)
> {
> }
> #endif

Can't resist.

Why the kernel always prefers to do it this way, adding the ugly
do-nothing inlines?

Isn't it better to simply call pidns_handle_reboot(cmd) under
CONFIG_PID_NS in sys_reboot() ?

	#ifdef CONFIG_PID_NS
	if (task_active_pid_ns(current) != &init_pid_ns)
		return reboot_pid_ns(cmd);
	#endif

This way, if you look at sys_reboot() you can immediately see what
happens, no need to inspect the !CONFIG_PID_NS definition. Plus this
doesn't add the "unnecesary" entry into tag file.

OK, </flame> ;)

Otherwise,

Reviewed-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
