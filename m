From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v4 1/2] cgroups: read-write lock CLONE_THREAD forking
	per threadgroup
Date: Wed, 4 Aug 2010 00:33:28 -0400
Message-ID: <20100804043328.GB11950@ghc17.ghc.andrew.cmu.edu>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100730235754.GB22644@ghc17.ghc.andrew.cmu.edu>
	<AANLkTikpNG2Y3S3AyxAbCkMynKu1u5yKPrw=bh+uy=9R@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikpNG2Y3S3AyxAbCkMynKu1u5yKPrw=bh+uy=9R-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Aug 03, 2010 at 08:44:01PM -0700, Paul Menage wrote:
>  On Fri, Jul 30, 2010 at 4:57 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> > +	 * The threadgroup_fork_lock prevents threads from forking with
> > +	 * CLONE_THREAD while held for writing. Use this for fork-sensitive
> > +	 * threadgroup-wide operations. It's taken for reading in fork.c in
> > +	 * copy_process().
> > +	 * Currently only needed write-side by cgroups.
> > +	 */
> > +	struct rw_semaphore threadgroup_fork_lock;
> > +#endif
> 
> I'm not sure how best to word this comment, but I'd prefer something like:
> 
> "The threadgroup_fork_lock is taken in read mode during a CLONE_THREAD
> fork operation; taking it in write mode prevents the owning
> threadgroup from adding any new threads and thus allows you to
> synchronize against the addition of unseen threads when performing
> threadgroup-wide operations. New-process forks (without CLONE_THREAD)
> are not affected."

That sounds good.

> As far as the #ifdef mess goes, it's true that some people don't have
> CONFIG_CGROUPS defined. I'd imagine that these are likely to be
> embedded systems with a fairly small number of processes and threads
> per process. Are there really any such platforms where the cost of a
> single extra rwsem per process is going to make a difference either in
> terms of memory or lock contention? I think you should consider making
> these additions unconditional.

That's certainly an option, but I think it would be clean enough to put
static inline functions just under the signal_struct definition.
Thoughts?

> 
> Paul
> 

-- Ben
