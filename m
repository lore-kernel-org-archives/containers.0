From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH UPDATED 03/10] threadgroup: extend threadgroup_lock() to
	cover exit and exec
Date: Fri, 2 Dec 2011 17:28:03 +0100
Message-ID: <20111202162753.GA19752__27475.731218192$1322843304$gmane$org@somewhere.redhat.com>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-4-git-send-email-tj@kernel.org>
	<20111124225054.GA14828@google.com>
	<20111125140136.GC23307@somewhere.redhat.com>
	<20111127193001.GC4266@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111127193001.GC4266-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

On Sun, Nov 27, 2011 at 11:30:01AM -0800, Tejun Heo wrote:
> Hello, Frederic.
> 
> On Fri, Nov 25, 2011 at 03:01:39PM +0100, Frederic Weisbecker wrote:
> > > +	/*
> > > +	 * @tsk's threadgroup is going through changes - lock out users
> > > +	 * which expect stable threadgroup.  Do this before actually
> > > +	 * starting tearing down @tsk so that locked threadgroup has either
> > > +	 * alive or dead tasks, not something inbetween.
> > > +	 */
> > > +	threadgroup_change_begin(tsk);
> > > +
> > 
> > I still wonder why there is a so big coverage of this lock. I mean
> > why is it called right before exit_irq_thread() and released so late.
> > All we want is to lock cgroup_exit() I think, after which tasks can't be
> > migrated.
> 
> That way, cgroup plugins never see tasks in the process of
> deconstruction.  Its ->mm, ->sighand, ->signal and so on either don't
> exist or continue to exist across all cgroup callbacks.  It's simpler
> and safer (especially as bugs in this area would only be visible when
> migration and exit race), and if we're gonna synchronize exit path at
> all, there isn't anything to lose by excluding the whole thing.

Fine.

But I don't think it's very useful to protect against irq_exit_thread(),
what happens there is purely of internal irq interest.

Then right after, PF_EXITING is set before any interesting change.
Isn't it possible to simply lock this flag setting? IIRC, as soon
as the PF_EXITING flag is set, you ignore the task for attachment.
