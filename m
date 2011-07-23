From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Sat, 23 Jul 2011 07:10:05 +0200
Message-ID: <20110723051005.GE21089@mtj.dyndns.org>
References: <4E204466.8010204@parallels.com>
	<20110723002558.GE16940@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110723002558.GE16940-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Fri, Jul 22, 2011 at 05:25:58PM -0700, Matt Helsley wrote:
> Finally, I think there's substantial room here for quiet and subtle
> races to corrupt checkpoint images. If we add /proc interfaces only to
> find they're racy will we need to add yet more /proc interfaces to
> maintain backward compatibility yet fix the races? To get the locking
> that ensures a consistent subset of information with this /proc-based
> approach I think we'll frequently need to change the contents of
> existing /proc files.

The target processes need to be frozen to remove race conditions (be
it SIGSOTP, cgroup freeze or PTRACE trap).  If there are exceptions in
the boundaries between frozen domain and the rest of the system,
they'll need to be dealt with and those need to be dealt with whether
the thing is in kernel or not.

> Imagine trusting the output of top to exactly represent the state of
> your system's cpu usage. That's the sort of thing a piecemeal /proc
> interface gets us. You're asking us to trust that frequent checkpoints
> (say once every five minutes) of large, multiprocess, month-long
> program runs won't quietly get corrupted and will leave plenty of
> performance to not interfere with the throughput of the work.

This is rather bogus.  If you freeze the processes, most of the
information in /proc (the ones which would show up in top anyway)
doesn't change.  What race condition?

> A kernel syscall interface has a better chance of allowing us to fix
> races without changing the interface. We've fixed a few races with
> Oren's tree and none of them required us to change the output format.

Sure, that was completely embedded in the kernel and things can be
implemented and fixed with much less consideration.  I can see how
that would be easier for the specific use case, but that EXACTLY is
why it can't go upstream.  I just can't see it happening and think it
would be far more productive spending the time and energy looking for
and implementing solutions which actually can go mainline.  If you
don't care about mainlining, that's great too, but then there's no
point in talking about it either.

Thanks.

-- 
tejun
