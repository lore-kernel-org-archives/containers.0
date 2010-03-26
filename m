From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Fri, 26 Mar 2010 05:46:19 -0700
Message-ID: <20100326124619.GC3345__45321.8790506527$1269607770$gmane$org@count0.beaverton.ibm.com>
References: <20100321195044.GA23757@megiteam.pl>
	<20100323212834.GH20796@count0.beaverton.ibm.com>
	<20100325213356.GB20541@megiteam.pl>
	<20100326111131.GA8604@redhat.com>
	<20100326113201.GB17113@megiteam.pl>
	<20100326120028.GA11311@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100326120028.GA11311-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 26, 2010 at 01:00:28PM +0100, Oleg Nesterov wrote:
> On 03/26, Grzegorz Nosek wrote:
> >
> > On Fri, Mar 26, 2010 at 12:11:31PM +0100, Oleg Nesterov wrote:
> > > Yes, this is broken. More precisely, this wasn't even supposed to work.
> > >
> > > Even stracing of the sub-init itself (or global init btw) has problems,
> > > the straced init is not protected from unwanted signals.
> >
> > Is this impossible/very hard to do cleanly? I understand that container's
> > init becomes vulnerable to signals sent from root-owned processes in the
> > container. If so, the impact of this issue should be quite limited, no?
> 
> Yes, probably we can ignore this.
> 
> > > Yes. First of all, tracehook_report_clone_complete() reports the wrong pid nr,
> > > as it seen inside the init's namespace. This is easy to fix, but I doubt this
> > > can help. IIRC strace doesn't use PTRACE_GETEVENTMSG at all, it looks at eax
> > > after syscall.
> > >
> > > which patch?
> >
> > The patch below posted by Matt. AIUI, it fixes the
> > tracehook_report_clone_complete() part, which results in an observable
> > change in strace's behaviour (not that it makes strace work, though).
> 
> I guess it doesn't work because we need to fix strace, see "strace doesn't
> use PTRACE_GETEVENTMSG" above.
> 
> > Anyway, are there any remaining issues on the kernel side or does strace
> > have to be taught about pid namespaces?
> 
> At first glance, I don't see other problems, except sometimes the reported
> pid is wrong (like in do_fork). 
> 
> > +               ptrace_pid_vnr = nr;
> > +               if (unlikely(p->parent != p->real_parent)) {
> > +                       rcu_read_lock();
> > +                       ptrace_pid_vnr = task_pid_nr_ns(p, p->parent->nsproxy->pid_ns);
> 
> Yes, this is what I meant.
> 
> But we should not do this in do_fork().

I'm puzzled. If not here, where should we do this? Or are you saying
ptrace should take a reference to the pid, store it, and get the vnr during
PTRACE_GETEVENTMSG? (drop the reference at detach or when a new pid reference
comes in..)

> But once again. This change fixes the value in "tracee->ptrace_message == newpid",
> but a quick grep shows that strace-4.5.19 doesn't use PTRACE_GETEVENTMSG at all.

You are correct. However strace and gdb aren't necessarily the only users
of ptrace so wouldn't it still be good to fix this?

Cheers,
	-Matt Helsley
