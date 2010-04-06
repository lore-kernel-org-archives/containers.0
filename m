From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Tue, 6 Apr 2010 08:29:36 -0700
Message-ID: <20100406152936.GD3345__5062.98664627156$1270567869$gmane$org@count0.beaverton.ibm.com>
References: <20100321195044.GA23757@megiteam.pl>
	<20100323212834.GH20796@count0.beaverton.ibm.com>
	<20100325213356.GB20541@megiteam.pl>
	<20100326111131.GA8604@redhat.com>
	<20100326115357.GA3345@count0.beaverton.ibm.com>
	<20100326124522.GD17113@megiteam.pl>
	<20100326134709.GB15790@redhat.com>
	<20100406034443.8B40ED477@magilla.sf.frob.com>
	<20100406135345.GC3345@count0.beaverton.ibm.com>
	<m1vdc48vhy.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1vdc48vhy.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Apr 06, 2010 at 08:13:13AM -0700, Eric W. Biederman wrote:
> Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > On Mon, Apr 05, 2010 at 08:44:43PM -0700, Roland McGrath wrote:

<snip>

> >> None of this has much of anything to do with strace, of course.  As I've
> >> said, I don't see anything other than the PTRACE_GETEVENTMSG value for
> >> PTRACE_EVENT_{CLONE,FORK,VFORK} reports that is wrong in the kernel.  As
> >> Oleg said, strace doesn't use that at all.  (This is not the place to
> >> discuss the details of strace further.)
> >
> > Also, looking at proposed changes (utrace and Eric Biederman's setns())
> > storing a pid nr rather than a reference to a task struct or struct pid
> > probably won't be correct.
> 
> My setns work has demonstrated that even for entering a namespace we
> never ever need to change the struct pid of a task.  setns has no other
> bearing on this problem then to say there is no foreseeable reason to
> change the rules.
> 
> > In the case of Eric Biederman's setns(), if capable of changing pid namespace,
> > we could have:
> >
> > 	Traced				Tracer
> > 	fork()
> > 					... (an arbitrary amount of time passes)
> > 					setns()
> > 					ptrace(GETEVENTMSG)
> 
> Forget that.  The pid namespace was architected so that we can ptrace a process
> in another pid namespace.
> 
> > At which point returning a static pid number held in the message field
> > produces the wrong pid.
> 
> No.  A processes always sees pids from the context of it's original pid
> namespace.  All setns does is affect which pid namespace children will
> be native in.

OK, good. So we can resolve the tasks/struct pids within the tracehook
and be done with it. Thanks Eric!

Cheers,
	-Matt Helsley
