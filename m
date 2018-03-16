From: Christian Brauner <christian.brauner-cl+VPiYnx/1AfugRpC6u6w@public.gmane.org>
Subject: Re: [RFC 0/3] seccomp trap to userspace
Date: Fri, 16 Mar 2018 15:47:51 +0100
Message-ID: <20180316144751.GA3304@mailbox.org>
References: <20180204104946.25559-1-tycho@tycho.ws>
	<20180315160924.GA12744@gmail.com>
	<CALCETrVnvbZLx5v=DMu2N1JtR+ys507X5CYBi-qQnus3VMQdwg@mail.gmail.com>
	<20180315170509.GA32766@mail.hallyn.com>
	<CALCETrXPcCNbpFJhXktkVS9gOPpmnU_bbY6Z8RrsBarq0dP4Lg@mail.gmail.com>
	<20180315173524.k7vwnvnhomg2j5yv@smitten>
	<CALCETrWH7HbY2gS6O_cYKfp9QqqWBWVcHb++GaP3uUiSO9oo6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrWH7HbY2gS6O_cYKfp9QqqWBWVcHb++GaP3uUiSO9oo6g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Fri, Mar 16, 2018 at 12:46:55AM +0000, Andy Lutomirski wrote:
> On Thu, Mar 15, 2018 at 5:35 PM, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org> wrote:
> > Hi Andy,
> >
> > On Thu, Mar 15, 2018 at 05:11:32PM +0000, Andy Lutomirski wrote:
> >> On Thu, Mar 15, 2018 at 5:05 PM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> >> > Hm, synchronously - that brings to mind a thought...  I should re-look at
> >> > Tycho's patches first, but, if I'm in a container, start some syscall that
> >> > gets trapped to userspace, then I hit ctrl-c.  I'd like to be able to have
> >> > the handler be interrupted and have it return -EINTR.  Is that going to
> >> > be possible with the synchronous approach?
> >>
> >> I think so, but it should be possible with the classic async approach
> >> too.  The main issue is the difference between a classic filter like
> >> this (pseudocode):
> >>
> >> if (nr == SYS_mount) return TRAP_TO_USERSPACE;
> >>
> >> and the eBPF variant:
> >>
> >> if (nr == SYS_mount) trap_to_userspace();
> >
> > Sargun started a private design discussion thread that I don't think
> > you were on, but Alexei said something to the effect of "eBPF programs
> > will never wait on userspace", so I'm not sure we can do something
> > like this in an eBPF program. I'm cc-ing him here again to confirm,
> > but I doubt things have changed.
> >
> >> I admit that it's still not 100% clear to me that the latter is
> >> genuinely more useful than the former.
> >>
> >> The case where I think the synchronous function call is a huge win is this one:
> >>
> >> if (nr  == SYS_mount) {
> >>   log("Someone called mount with args %lx\n", ...);
> >>   return RET_KILL;
> >> }
> >>
> >> The idea being that the log message wouldn't show up in the kernel log
> >> -- it would get sent to the listener socket belonging to whoever
> >> created the filter, and that process could then go and log it
> >> properly.  This would work perfectly in containers and in totally
> >> unprivileged applications like Chromium.
> >
> > The current implementation can't do exactly this, but you could do:
> >
> > if (nr == SYS_mount) {
> >     log(...);
> >     kill(pid, SIGKILL);
> > }
> >
> > from the handler instead.
> >
> > I guess Serge is asking a slightly different question: what if the
> > task gets e.g. SIGINT from the user doing a ^C or SIGALARM or
> > something, we should probably send the handler some sort of message or
> > interrupt to let it know that the syscall was cancelled. Right now the
> > current set doesn't behave that way, and the handler will just
> > continue on its merry way and get an EINVAL when it tries to respond
> > with the cancelled cookie.
> 
> Hmm, I think we have to be very careful to avoid nasty races.  I think
> the correct approach is to notice the signal and send a message to the
> listener that a signal is pending but to take no additional action.
> If the handler ends up completing the syscall with a successful
> return, we don't want to replace it with -EINTR.  IOW the code looks
> kind of like:
> 
> send_to_listener("hey I got a signal");
> wait_ret = wait_interruptible for the listener to reply;
> if (wait_ret == -EINTR) {

Hm, so from the pseudo-code it looks like: The handler would inform the
listener that it received a signal (either from the syscall requester or
from somewhere else) and then wait for the listener to reply to that
message.  This would allow the listener to decide what action it wants
the handler to take based on the signal, i.e. either cancel the request
or retry?  The comment makes it sound like that the handler doesn't
really wait on the listener when it receives a signal it simply moves
on.
So no "taking no additional action" here means not have the handler
decide to abort but the listener?

Sorry if I'm being dense.

Christian

>   send_to_listener("hey there's a signal");
>   wait_ret = wait_killable for the listener to reply to the original request;
> }
> 
> if (wait_ret == -EINTR) {
>   /* hmm, this next line might not actually be necessary, but it's
> harmless and possibly useful */
>   send_to_listener("hey we're going away");
>   /* and stop waiting */
> }
> 
> ... actually handle the result.
> 
> --Andy
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
