From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Fri, 26 Mar 2010 14:34:39 +0100
Message-ID: <20100326133439.GA15790__30867.3300584362$1269610720$gmane$org@redhat.com>
References: <20100321195044.GA23757@megiteam.pl>
	<20100323212834.GH20796@count0.beaverton.ibm.com>
	<20100325213356.GB20541@megiteam.pl>
	<20100326111131.GA8604@redhat.com>
	<20100326113201.GB17113@megiteam.pl>
	<20100326120028.GA11311@redhat.com>
	<20100326124619.GC3345@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100326124619.GC3345-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/26, Matt Helsley wrote:
>
> On Fri, Mar 26, 2010 at 01:00:28PM +0100, Oleg Nesterov wrote:
> > 
> > > +               ptrace_pid_vnr = nr;
> > > +               if (unlikely(p->parent != p->real_parent)) {
> > > +                       rcu_read_lock();
> > > +                       ptrace_pid_vnr = task_pid_nr_ns(p, p->parent->nsproxy->pid_ns);
> > 
> > Yes, this is what I meant.
> > 
> > But we should not do this in do_fork().
> 
> I'm puzzled. If not here, where should we do this? Or are you saying
> ptrace should take a reference to the pid,

Ah, no, sorry.

I meant tracehook_report_clone_complete should do this under "if (trace)".
And we need a helper to get the right pid, it could be used
by do_notify_parent() too, and (probably) we need more changes like this.

> > But once again. This change fixes the value in "tracee->ptrace_message == newpid",
> > but a quick grep shows that strace-4.5.19 doesn't use PTRACE_GETEVENTMSG at all.
>
> You are correct. However strace and gdb aren't necessarily the only users
> of ptrace so wouldn't it still be good to fix this?

Yes, agreed.

Oh. The only problem is utrace patches in -mm. I mean the possible textual
conflicts...

Oleg.
