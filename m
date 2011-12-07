From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH UPDATED 03/10] threadgroup: extend threadgroup_lock() to
	cover exit and exec
Date: Wed, 7 Dec 2011 16:30:54 +0100
Message-ID: <20111207153046.GC13252__38121.8741917566$1323272076$gmane$org@somewhere.redhat.com>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-4-git-send-email-tj@kernel.org>
	<20111124225054.GA14828@google.com>
	<20111125140136.GC23307@somewhere.redhat.com>
	<20111127193001.GC4266@google.com>
	<20111202162753.GA19752@somewhere.redhat.com>
	<20111205184315.GJ627@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111205184315.GJ627-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Dec 05, 2011 at 10:43:15AM -0800, Tejun Heo wrote:
> Hello, Frederic.
> 
> On Fri, Dec 02, 2011 at 05:28:03PM +0100, Frederic Weisbecker wrote:
> > But I don't think it's very useful to protect against irq_exit_thread(),
> > what happens there is purely of internal irq interest.
> > 
> > Then right after, PF_EXITING is set before any interesting change.
> > Isn't it possible to simply lock this flag setting? IIRC, as soon
> > as the PF_EXITING flag is set, you ignore the task for attachment.
> 
> I think that's technically possible but it does introduce another
> class of tasks - the dying ones.  e.g. If a task has PF_EXITING set
> and the containing process is migrating, we'll have to migrate all
> tasks but the dying one and cgroup ->exit callbacks can be called on
> the lonely task after the migration is complete.  It's kinda messy and
> if someone makes a wrong assumption there, the bug is gonna be even
> more difficult to reproduce / track down than now.  Yes, smaller scope
> locking is nicer but I would like to avoid api weirdities like that.

I don't understand what you mean. On your patches, you only process tasks
that don't have PF_EXITING, ie: you don't include these in the flex array
on cgroup_attach_proc(). So that still applies in my proposal.

From the exit path we would have:

	exit_signal() {
		lock_threadgroup_change(task);
		task->flags |= PF_EXITING;
		lock_threadgroup(task);
	}

	exit all the rest: mm, etc...

Then from cgroup_attach_proc():

	lock_threadgroup(task);
	for_each_thread(task) {
		if (!(task->flags & PF_EXITING))
			include in flex array
	}

Am I forgetting something?
