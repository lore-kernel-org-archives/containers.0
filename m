From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH][V4] Add reboot_pid_ns to handle the reboot syscall
Date: Thu, 15 Dec 2011 14:00:28 -0800
Message-ID: <20111215140028.e1b8a6a7.akpm@linux-foundation.org>
References: <1323649064-7960-1-git-send-email-daniel.lezcano@free.fr>
	<1323649064-7960-2-git-send-email-daniel.lezcano@free.fr>
	<20111213162242.1ab3cb1a.akpm@linux-foundation.org>
	<20111214191739.GA14693@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111214191739.GA14693-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 14 Dec 2011 20:17:39 +0100
Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> > It would be
> > better to do
> >
> > #ifdef CONFIG_PID_NS
> > extern void pidns_handle_reboot(int cmd);
> > #else
> > static inline void pidns_handle_reboot(int cmd)
> > {
> > }
> > #endif
> 
> Can't resist.
> 
> Why the kernel always prefers to do it this way, adding the ugly
> do-nothing inlines?
> 
> Isn't it better to simply call pidns_handle_reboot(cmd) under
> CONFIG_PID_NS in sys_reboot() ?
> 
> 	#ifdef CONFIG_PID_NS
> 	if (task_active_pid_ns(current) != &init_pid_ns)
> 		return reboot_pid_ns(cmd);
> 	#endif

Imagine what the code would look like if we took all the existing empty
inline stubs and replaced them with #if/#else/#endif.
