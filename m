From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Thu, 23 Apr 2009 11:44:24 +0200
Message-ID: <20090423094423.GA9756__10857.7231331312$1240480123$gmane$org@linux>
References: <20090421181429.GO19637@balbir.in.ibm.com>
	<20090421191401.GF15541@mit.edu> <20090421204905.GA5573@linux>
	<20090422093349.1ee9ae82.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422102153.9aec17b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422102239.GA1935@linux>
	<20090423090535.ec419269.kamezawa.hiroyu@jp.fujitsu.com>
	<20090423012254.GZ15541@mit.edu>
	<20090423115419.c493266a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090423043547.GB2723@mit.edu>
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
To: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Gui-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 23, 2009 at 12:35:48AM -0400, Theodore Tso wrote:
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

This is true in part. Actually io-throttle v12 has been largely tested,
also in production environments (Matt and David in cc can confirm
this) with quite interesting results.

I tested the previous versions usually with many parallel iozone, dd,
using many different configurations.

In v12 writeback IO is not actually limited, what io-throttle did was to
account and limit reads and direct IO in submit_bio() and limit and
account page cache writes in balance_dirty_pages_ratelimited_nr().

This seems to work quite well for the cases when we want avoid that a
single cgroup eats all the IO BW, but in this way in presence of a large
write stream we periodically have bunches of writeback IO that can
disrupt the other cgroups' BW requirements, from the QoS perspective.

The point is that in the new versions (v13 and v14) I merged the
bio-cgroup stuff to track and opportunely handle writeback IO in a
"smoother" way, actually changing some core components of the
io-throttle controller.

And this means it surely needs additional testing before merging in the
mainline.

I'll reproduce all the tests and publish the results ASAP using the new
implementation. I was just waiting to reach a stable point in the
implementation decisions before doing that.

> 
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

And the ext3 patch BTW was just an experimental test, that has been
useful at the end, because now I have the attention and some feedbacks
also from the fs experts... :)

Anyway, as said above and at least for io-throttle it is not a totally
first implementation. It's a quite old and tested cgroup subsystem, but
some core components have been redesigned. For this reason it surely
needs more testing, and we're still discussing some implementation
details. I'd say the basic interface is stable and as Kamezawa said we
just need to decide what we do, what we don't, which problems the IO
controller should address and which should be considered by other cgroup
subsystems (like the dirty ratio issue).

> 
> Consider this more of a yellow flag being thrown on the field, in the
> hopes that the block layer and VM experts will take a much closer
> review of these patches.  I have a vague sense of disquiet that the
> container patches are touching a very large number of subsystems
> across the kernels, and it's not clear to me the maintainers of all of
> the subsystems have been paying very close attention and doing a
> proper high-level review of the design.

Agreed that IO controller touches a lot of critical kernel components. A
feedback from VM and block layer experts would be really welcome.

> 
> Simply on the strength of a very cursory reivew and asking a few
> questions, it seems to me that the I/O controller was implemented,
> apparently without even thinking about the write throttling problems,
> and this just making me.... very, very, nervous.  

Actually we discussed a lot about write throttling problems. At least I
addressed the problem since io-throttle RFC v2 (posted in Jun 2008).

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

In a previous discussion (http://lkml.org/lkml/2008/11/4/565) we decided
to split the problems: the decision was that IO controller should
consider only IO requests and the memory controller should take care of
the OOM / dirty pages problems. Distinct memcg dirty_ratio seemed to be
a good start. Anyway, I think we're not so far from having an acceptable
solution, also looking at the recent thoughts and discussions in this
thread. For the implementation part, as pointed by Kamezawa per bdi /
task dirty ratio is a very similar problem. Probably we can simply
replicate the same concepts per cgroup.

-Andrea
