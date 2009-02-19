From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/7][v8] SI_USER: Masquerade si_pid when crossing pid
	ns boundary
Date: Thu, 19 Feb 2009 23:31:37 +0100
Message-ID: <20090219223137.GA10378@redhat.com>
References: <20090219030207.GA18783@us.ibm.com>
	<20090219030743.GG18990@us.ibm.com>
	<m1y6w21k6d.fsf@fess.ebiederm.org>
	<20090219185159.GA374@redhat.com>
	<m1fxiayss9.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1fxiayss9.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 02/19, Eric W. Biederman wrote:
>
> Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> >
> > SI_FROMUSER() == T, unless we have more (hopefully not) in-kernel
> > users which send SI_FROMUSER() signals, .si_pid must be valid?
>
> So the argument is that while things such as force_sig_info(SIGSEGV)
> don't have a si_pid we don't care because from_ancestor_ns  == 0.
>
> Interesting.  Then I don't know if we have any kernel senders
> that cross the namespace boundaries.
>
> That said I still object to this code.
>
> sys_kill(-pgrp, SIGUSR1)
>   kill_something_info(SIGUSR1, &info, 0)
>     __kill_pgrp_info(SIGUSR1, &info task_pgrp(current))
>       group_send_sig_info(SIGUSR1, &info, tsk)
>         __group_send_sig_info(SIGUSR1, &info, tsk)
>           send_signal(SIGUSR1, &info, tsk, 1)
>             __send_signal(SIGUSR1, &info, tsk, 1)
>
>
> Process groups and sessions can have processes in multiple pid
> namespaces, which is very useful for not messing up your controlling
> terminal.
>
> In which case sys_kill cannot possibly set the si_pid value correct
> and from_ancestor_ns is not enough either.

(I know, I shouldn't reply today because I am already sleeping ;)

Why? send_signal() should calculate the correct value of
from_parent and pass it to __send_signal(). If it is true, then
we clear .si_pid in the copied siginfo (which was already queued).
We don't mangle the original siginfo.

This happens for each process we send the signal.

Or I misunderstood you?

Oleg.
