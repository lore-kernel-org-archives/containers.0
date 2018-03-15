From: Christian Brauner <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [RFC 0/3] seccomp trap to userspace
Date: Thu, 15 Mar 2018 18:25:59 +0100
Message-ID: <20180315172558.GA28108@gmail.com>
References: <CALCETrVnvbZLx5v=DMu2N1JtR+ys507X5CYBi-qQnus3VMQdwg@mail.gmail.com>
	<20180315170509.GA32766@mail.hallyn.com>
	<CALCETrXPcCNbpFJhXktkVS9gOPpmnU_bbY6Z8RrsBarq0dP4Lg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrXPcCNbpFJhXktkVS9gOPpmnU_bbY6Z8RrsBarq0dP4Lg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 15, 2018 at 05:11:32PM +0000, Andy Lutomirski wrote:
> On Thu, Mar 15, 2018 at 5:05 PM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> > Quoting Andy Lutomirski (luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> >> On Thu, Mar 15, 2018 at 4:09 PM, Christian Brauner
> >> <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> >> > On Sun, Feb 04, 2018 at 11:49:43AM +0100, Tycho Andersen wrote:
> >> >> Several months ago at Linux Plumber's, we had a discussion about adding a
> >> >> feature to seccomp which would allow seccomp to trigger a notification for some
> >> >> other process. Here's a draft of that feature.
> >> >>
> >> >> Patch 1 contains the bulk of it, patches 2 & 3 offer an alternative way to
> >> >> acquire the fd that receives notifications via ptrace (the method in patch 1
> >> >> poses some problems). Other suggestions for how to acquire one of these fds
> >> >> would be welcome.
> >> >>
> >> >> Take a close look at the synchronization. I think I've got it right, but I
> >> >> probably don't :)
> >> >>
> >> >> Thanks!
> >> >>
> >> >> Tycho Andersen (3):
> >> >>   seccomp: add a return code to trap to userspace
> >> >>   seccomp: hoist out filter resolving logic
> >> >>   seccomp: add a way to get a listener fd from ptrace
> >> >>
> >> >>  arch/Kconfig                                  |   7 +
> >> >>  include/linux/seccomp.h                       |  14 +-
> >> >>  include/uapi/linux/ptrace.h                   |   1 +
> >> >>  include/uapi/linux/seccomp.h                  |  18 +-
> >> >>  kernel/ptrace.c                               |   4 +
> >> >>  kernel/seccomp.c                              | 467 ++++++++++++++++++++++++--
> >> >>  tools/testing/selftests/seccomp/seccomp_bpf.c | 180 +++++++++-
> >> >>  7 files changed, 653 insertions(+), 38 deletions(-)
> >> >
> >> > Hey,
> >> >
> >> > So, I've been following the discussion silently in the background and I
> >> > see that it got sidetracked into seccomp + ebpf. While I can see that
> >> > there is value in adding epbf support to seccomp I'd really like to see
> >> > this decoupled from this patchset. Afaict, this patchset would just work
> >> > fine without the ebpf portion (but I might be just have missed the
> >> > point). So if possible I would like to see a second version of this with
> >> > the comments accounted for and - if possible - have this up for merging
> >> > independent of the ebpf patchset that's floating around.
> >> >
> >>
> >> The issue is that it might be (and, then again, might not be) nicer to
> >> to *synchronously* call out to the monitor in the filter.  eBPF can do
> >> that very cleanly, whereas classic BPF can't.
> >
> > Hm, synchronously - that brings to mind a thought...  I should re-look at
> > Tycho's patches first, but, if I'm in a container, start some syscall that
> > gets trapped to userspace, then I hit ctrl-c.  I'd like to be able to have
> > the handler be interrupted and have it return -EINTR.  Is that going to
> > be possible with the synchronous approach?
> 
> I think so, but it should be possible with the classic async approach
> too.  The main issue is the difference between a classic filter like
> this (pseudocode):
> 
> if (nr == SYS_mount) return TRAP_TO_USERSPACE;
> 
> and the eBPF variant:
> 
> if (nr == SYS_mount) trap_to_userspace();
> 
> I admit that it's still not 100% clear to me that the latter is
> genuinely more useful than the former.

We've just discussed this on irc and the fact that most problems can be
addressed by interfaces we already have makes it questionable what ebpf
brings to the game here. Especially since the discussion gave the
impression that if ebpf ever makes it to seccomp it will basically be
because it allows a nice implementation of the trap to userspace. If
it's even unclear whether it is really the better choice for this task
then we could consider to no try and make this patchset use it. (I
probably sound way more polemic than I intend to.)

> 
> The case where I think the synchronous function call is a huge win is this one:
> 
> if (nr  == SYS_mount) {
>   log("Someone called mount with args %lx\n", ...);
>   return RET_KILL;
> }
> 
> The idea being that the log message wouldn't show up in the kernel log
> -- it would get sent to the listener socket belonging to whoever
> created the filter, and that process could then go and log it
> properly.  This would work perfectly in containers and in totally
> unprivileged applications like Chromium.

Hm, that is a decent point but that's also a non-essential feature. I
also wonder if there's any reason to not simply extend it to use ebpf
later if seccomp every uses it?

Christian
