From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Tue, 6 Apr 2010 06:53:45 -0700
Message-ID: <20100406135345.GC3345__2460.18922557614$1270562100$gmane$org@count0.beaverton.ibm.com>
References: <20100321195044.GA23757@megiteam.pl>
	<20100323212834.GH20796@count0.beaverton.ibm.com>
	<20100325213356.GB20541@megiteam.pl>
	<20100326111131.GA8604@redhat.com>
	<20100326115357.GA3345@count0.beaverton.ibm.com>
	<20100326124522.GD17113@megiteam.pl>
	<20100326134709.GB15790@redhat.com>
	<20100406034443.8B40ED477@magilla.sf.frob.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100406034443.8B40ED477-nL1rrgvulkc2UH6IwYuUx0EOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Biederman Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org


On Mon, Apr 05, 2010 at 08:44:43PM -0700, Roland McGrath wrote:
> (I've been away for a couple of weeks.)
> I concur with the things Oleg's said in this thread.
> 
> As to what's "correct" for the kernel in theory, it would certainly make
> sense to clean up the ptrace cases to use the tracer (parent) pid_ns when
> reporting any PID as such.  The wait and SIGCHLD code already does this, so
> that would be consistent.  Off hand I don't see anything other than
> tracehook_report_clone{,_complete}() that sees the wrong value now.

Yup.

> Fixing that requires a bit of hair.  The simple and clean approach is to
> just have the tracehook calls (i.e. ptrace layer) extract the PID from the
> task_struct using the desired pid_ns.  The trouble there is that the

It's also possible to take an extra reference to the struct pid and pass
that to the tracehook. That and the pid_ns of the tracer receiving the pid
is all we'll ever need inside the tracehook layer. The only advantage, I
think, is we wouldn't pin the task struct while holding the pid reference.

> tracehook_report_clone_complete() call is made when that task_struct is no
> longer guaranteed to be valid.  The contrary approach of extracting the
> appropriate value for the tracer earlier breaks the clean layering because
> the fork.c code really should not know at all that ->parent->nsproxy is the
> place to look for what values to pass to tracehook calls.  I guess the
> simple and clean fix is to get_task_struct() before wake_up_new_task()
> and put_task_struct() after tracehook_report_clone_complete().  That does
> add some gratuitous atomic incr/decr overhead, though.

Also true.

Of course my suggestion of holding the pid reference won't avoid adding
atomic ops -- just changes which refcount they work on.

> 
> None of this has much of anything to do with strace, of course.  As I've
> said, I don't see anything other than the PTRACE_GETEVENTMSG value for
> PTRACE_EVENT_{CLONE,FORK,VFORK} reports that is wrong in the kernel.  As
> Oleg said, strace doesn't use that at all.  (This is not the place to
> discuss the details of strace further.)

Also, looking at proposed changes (utrace and Eric Biederman's setns())
storing a pid nr rather than a reference to a task struct or struct pid
probably won't be correct.

In the case of Eric Biederman's setns(), if capable of changing pid namespace,
we could have:

	Traced				Tracer
	fork()
					... (an arbitrary amount of time passes)
					setns()
					ptrace(GETEVENTMSG)

At which point returning a static pid number held in the message field
produces the wrong pid. Also, if utrace allows multiple tracers and they each
exist in a different namespace then storing a pid nr isn't going to work.

So my hunch is, in the long run, we'll need to hold a reference there and
drop it when the last tracer detaches or the next event would have
overwritten the "message". The amount of time it would need to be held
suggests to me that we should refer to a struct pid and not a task struct
if possible.

Cheers,
	-Matt Helsley
