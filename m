From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: Re: [RFC 0/3] seccomp trap to userspace
Date: Thu, 15 Mar 2018 11:35:24 -0600
Message-ID: <20180315173524.k7vwnvnhomg2j5yv__40623.0827131823$1521135211$gmane$org@smitten>
References: <20180204104946.25559-1-tycho@tycho.ws>
	<20180315160924.GA12744@gmail.com>
	<CALCETrVnvbZLx5v=DMu2N1JtR+ys507X5CYBi-qQnus3VMQdwg@mail.gmail.com>
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
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Christian Brauner <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Andy,

On Thu, Mar 15, 2018 at 05:11:32PM +0000, Andy Lutomirski wrote:
> On Thu, Mar 15, 2018 at 5:05 PM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
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

Sargun started a private design discussion thread that I don't think
you were on, but Alexei said something to the effect of "eBPF programs
will never wait on userspace", so I'm not sure we can do something
like this in an eBPF program. I'm cc-ing him here again to confirm,
but I doubt things have changed.

> I admit that it's still not 100% clear to me that the latter is
> genuinely more useful than the former.
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

The current implementation can't do exactly this, but you could do:

if (nr == SYS_mount) {
    log(...);
    kill(pid, SIGKILL);
}

from the handler instead.

I guess Serge is asking a slightly different question: what if the
task gets e.g. SIGINT from the user doing a ^C or SIGALARM or
something, we should probably send the handler some sort of message or
interrupt to let it know that the syscall was cancelled. Right now the
current set doesn't behave that way, and the handler will just
continue on its merry way and get an EINVAL when it tries to respond
with the cancelled cookie.

Anyway, I think these last two points can be addressed with the
approach from this series. The notification to the handler about a
cancelled syscall might be slightly awkward, but I'll take a look.

Cheers,

Tycho
