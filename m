From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
Date: Fri, 13 Feb 2009 11:20:36 +0100
Message-ID: <20090213102036.GA4608__16581.175910733$1234520585$gmane$org@elte.hu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<20090212091721.GB1888@elte.hu> <1234462283.30155.173.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1234462283.30155.173.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org
List-Id: containers.vger.kernel.org


* Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> > What is it good for right now, and what are the known weaknesses and
> > quirks you can think of. Declaring them upfront is a bonus - not talking
> > about them and us discovering them later at the patch integration stage
> > is a sure receipe for upstream grumpiness.
> 
> That's a fair enough point, and I do agree with you on it.
> 
> Right now, it is good for very little.  An app has to basically be
> either specifically designed to work, or be pretty puny in its
> capabilities.  Any fds that are open can only be restored if a simple
> open();lseek(); would have been sufficient to get it back into a good
> state.  The process must be single-threaded.  Shared memory, hugetlbfs,
> VM_NONLINEAR are not supported.  

That is OK as a starting point, as long as:

> > For example, one of the critical corner points: can an app programmatically 
> > determine whether it can support checkpoint/restart safely? Are there 
> > warnings/signals/helpers in place that make it a well-defined space, and
> > make the implementation of missing features directly actionable?
> > 
> > ( instead of: 'silent breakage' and a wishy-washy boundary between the
> >   working and non-working space. Without clear boundaries there's no
> >   clear dynamics that extends the 'working' space beyond the demo stage. )
> 
> Patch 12/14 is supposed to address this *concept*.  But, it hasn't been
> carried through so that it currently works.  My expectation was that we
> would go through and add things over time.  I'll go make sure I push it
> to the point that it actually works for at least the simple test
> programs that we have.
> 
> What I will probably do is something BKL-style.  Basically put a "this
> can't be checkpointed" marker over most everything I can think of and
> selectively remove it as we add features.  

An app really has to know whether it can reliably checkpoint+restart.

Otherwise it wont ever get past the toy stage and people will waste a
lot of time if their designed-for-checkpoints app accidentally runs
into some kernel feature or other side-effect that is not supported.

I personally wouldnt mind to sprinkle the kernel with markers, as long
as you can make it really cheap even with CONFIG_CHECKPOINT_RESTART=y.

Btw., i dont think it's all that much work, nor is it really intrusive:
have you thought of reusing all the existing security callbacks? You'd
have instant coverage of basically every system call and kernel
functionality that matters, and you could have a finegrained set of
policies.

The only drawback is that you have to enable CONFIG_SECURITY for it,
but in practice most distros enable that, so the callback overhead is
already there - you just have to enable it. (Also, some care has to
be taken to properly stack it to existing LSM modules, but that is
solvable too.)

Sidenote: CONFIG_CHECKPOINT_RESTART is IMO an uncomfortably long name,
i'd suggest to rename it to CONFIG_CHECKPOINTS or so. [the concept of a
checkpoint is good enough to mention - if there's a checkpoint then a
restart is logically implied.]

	Ingo
