From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Fri, 24 Apr 2009 10:44:22 +0530
Message-ID: <20090424051422.GA6867__29221.3030661971$1240550290$gmane$org@balbir.in.ibm.com>
References: <20090421181429.GO19637@balbir.in.ibm.com>
	<20090421191401.GF15541@mit.edu> <20090421204905.GA5573@linux>
	<20090422093349.1ee9ae82.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422102153.9aec17b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422102239.GA1935@linux>
	<20090423090535.ec419269.kamezawa.hiroyu@jp.fujitsu.com>
	<20090423012254.GZ15541@mit.edu>
	<20090423115419.c493266a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090423043547.GB2723@mit.edu>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090423043547.GB2723-3s7WtUTddSA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, randy.dunlap@o
List-Id: containers.vger.kernel.org

* Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org> [2009-04-23 00:35:48]:

> On Thu, Apr 23, 2009 at 11:54:19AM +0900, KAMEZAWA Hiroyuki wrote:
> > > How much testing has been done in terms of whether the I/O throttling
> > > actually works?  Not just, "the kernel doesn't crash", but that where
> > > you have one process generating a large amount of I/O load, in various
> > > different ways, and whether the right things happens?  If so, how has
> > > this been measured?
> > 
> > I/O control people should prove it. And they do, I think.
> > 
> 
> Well, with all due respect, the fact that they only tested removing
> the ext3 patch to fs/jbd2/commit.c, and discovered it had no effect,
> only after I asked some questions about how it could possibly work
> from a theoretical basis, makes me wonder exactly how much testing has
> actually been done to date.  Which is why I asked the question....
>

The IO controller patches (now 3 in total) are undergoing review and
comparison. I had suggested we setup a wiki to track requirements and
design. I'll try to get that setup.
 
> > > I'm really concerned that given some of the ways that I/O will "leak"
> > > out --- the via pdflush, swap writeout, etc., that without the rest of
> > > the pieces in place, I/O throttling by itself might not prove to be
> > > very effective.  Sure, if the workload is only doing direct I/O, life
> > > is pretty easy and it shouldn't be hard to throttle the cgroup.
> > 
> > It's just a problem of "what we do and what we don't, now".
> > Andrea, Vivek, could you clarify ? As other project, I/O controller
> > will not be 100% at first implementation.
> 
> Yeah, but if the design hasn't been fully validated, maybe the
> implementation isn't ready for merging yet.  I only came across these
> patch series because of the ext3 patch, and when I started looking at
> it just from a high level point of view, I'm concerned about the
> design gaps and exactly how much high level thinking has gone into the
> patches.  This isn't a NACK per se, because I haven't spent the time
> to look at this code very closely (nor do I have the time).
> 
> Consider this more of a yellow flag being thrown on the field, in the
> hopes that the block layer and VM experts will take a much closer
> review of these patches.  I have a vague sense of disquiet that the
> container patches are touching a very large number of subsystems
> across the kernels, and it's not clear to me the maintainers of all of
> the subsystems have been paying very close attention and doing a
> proper high-level review of the design.
> 
> Simply on the strength of a very cursory reivew and asking a few
> questions, it seems to me that the I/O controller was implemented,
> apparently without even thinking about the write throttling problems,
> and this just making me.... very, very, nervous.  
> 
> I hope someone like akpm is paying very close attention and auditing
> these patches both from an low-level patch cleanliness point of view
> as well as a high-level design review.  Or at least that *someone* is
> doing so and can perhaps document how all of these knobs interact.
> After all, if they are going to be separate, and someone turns the I/O
> throttling knob without bothering to turn the write throttling knob
> --- what's going to happen?  An OOM?  That's not going to be very safe
> or friendly for the sysadmin who plans to be configuring the system.
> 
> Maybe this high level design considerations is happening, and I just
> haven't have seen it.  I sure hope so.

My understanding is that, it will happen and the patches are
undergoing several iterations, some of them being design iterations.
May be a larger RFC with requirements might help grab more attention.

-- 
	Balbir
