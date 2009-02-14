From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
Date: Sun, 15 Feb 2009 00:50:28 +0100
Message-ID: <20090214235028.GE31861__24620.1486014344$1234655661$gmane$org@elte.hu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz>
	<20090213152836.0fbbfa7d.akpm@linux-foundation.org>
	<20090214230802.GE20477@elte.hu>
	<20090214153124.73132bf9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090214153124.73132bf9.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org


* Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> On Sun, 15 Feb 2009 00:08:02 +0100 Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org> wrote:
> 
> > 
> > * Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> > 
> > > Similar to the way in which perfectly correct and normal kernel
> > > sometimes has to be changed because it unexpectedly upsets the -rt
> > > patch.
> > 
> > Actually, regarding -rt, we try to keep that in two buckets:
> > 
> >  1) Normal kernel code works but is unclean or structured less
> >     than ideal. In this case we restructure the mainline code,
> >     but that change stands on its own four legs, without any
> >     -rt considerations.
> > 
> >  2) Normal kernel code that is clean - i.e. a change that only
> >     matters to -rt. In this case we dont touch the mainline code,
> >     nor do we bother mainline.
> > 
> > Do you know any specific example that falls outside of those categories?
> > 
> 
> It happens fairly regularly.  Problems with irqs-off regions, problems
> with preempt_disable() regions (came up just yesterday with a patch from
> Jeremy).

As Peter has stated it in that thread, throwing around preempt_disable()s
is considered anti-social regardless of any -rt concerns. (it's a bit like
how people were throwing around opaque lock_kernel()/unlock_kernel() pairs
a decade ago. It results in poorly documented locking semantics.)

> Plus some convert-to-sleeping-lock conversions over the years which
> weren't obviously needed in mainline.  Or which at least had -rt
> motivations.  But that's different.

Having -rt motivation is perfectly fine - many of the top features we
added in the past 2-3 years originated in the -rt tree. The question 
is, does a change improve the mainline code or not. If it does, the
motivation does not really matter.

I'll also note that recent VFS performance tests with spinning mutexes
have shown that they out-perform both spinlocks, old-semaphores and
old-mutexes. So conversion to sleeping locks might in fact grow a
"because it's not only easier to hack but also faster" dimension as well.

( I'm wondering whether those ext2/ext3 spinlocks that were a performance
  problem when converted to sleeping locks would perform better with
  spinning mutexes. )

	Ingo
