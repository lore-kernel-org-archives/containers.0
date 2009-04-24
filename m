From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Fri, 24 Apr 2009 09:26:09 +0900
Message-ID: <20090424092609.aa1da56a.kamezawa.hiroyu__2248.96887452832$1240533030$gmane$org@jp.fujitsu.com>
References: <20090421204905.GA5573@linux>
	<20090422093349.1ee9ae82.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422102153.9aec17b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422102239.GA1935@linux>
	<20090423090535.ec419269.kamezawa.hiroyu@jp.fujitsu.com>
	<20090423012254.GZ15541@mit.edu>
	<20090423115419.c493266a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090423043547.GB2723@mit.edu> <20090423094423.GA9756@linux>
	<20090423121745.GC2723@mit.edu> <20090423211300.GA20176@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090423211300.GA20176@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Jens-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Gui-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 23 Apr 2009 23:13:04 +0200
Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Thu, Apr 23, 2009 at 08:17:45AM -0400, Theodore Tso wrote:
> > On Thu, Apr 23, 2009 at 11:44:24AM +0200, Andrea Righi wrote:
> > > This is true in part. Actually io-throttle v12 has been largely tested,
> > > also in production environments (Matt and David in cc can confirm
> > > this) with quite interesting results.
> > > 
> > > I tested the previous versions usually with many parallel iozone, dd,
> > > using many different configurations.
> > > 
> > > In v12 writeback IO is not actually limited, what io-throttle did was to
> > > account and limit reads and direct IO in submit_bio() and limit and
> > > account page cache writes in balance_dirty_pages_ratelimited_nr().
> > 
> > Did the testing include what happened if the system was also
> > simultaneously under memory pressure?  What you might find happening
> > then is that the cgroups which have lots of dirty pages, which are not
> > getting written out, have their memory usage "protected", while
> > cgroups that have lots of clean pages have more of their pages
> > (unfairly) evicted from memory.  The worst case, of course, would be
> > if the memory pressure is coming from an uncapped cgroup.
> 
> This is an interesting case that should be considered of course. The
> tests I did were mainly focused in distinct environment where each
> cgroup writes its own files and dirties its own memory. I'll add this
> case to the next tests I'll do with io-throttle.
> 
> But it's a general problem IMHO and doesn't depend only on the presence
> of an IO controller. The same issue can happen if a cgroup reads a file
> from a slow device and another cgroup writes to all the pages of the
> other cgroup.
> 
> Maybe this kind of cgroup unfairness should be addressed by the memory
> controller, the IO controller should be just like another slow device in
> this particular case.
> 
"soft limit"...for selecting victim at memory shortage is under development.


> >    
> > So that's basically the same worry I have; which is we're looking at
> > things at a too-low-level basis, and not at the big picture.
> > 
> > There wasn't discussion about the I/O controller on this thread at
> > all, at least as far as I could find; nor that splitting the problem
> > was the right way to solve the problem.  Maybe somewhere there was a
> > call for someone to step back and take a look at the "big picture"
> > (what I've been calling the high level design), but I didn't see it in
> > the thread.
> > 
> > It would seem to be much simpler if there was a single tuning knob for
> > the I/O controller and for dirty page writeback --- after all, why
> > *else* would you be trying to control the rate at which pages get
> > dirty?  And if you have a cgroup which sometimes does a lot of writes
> 
> Actually we do already control the rate at which dirty pages are
> generated. In balance_dirty_pages() we add a congestion_wait() when the
> bdi is congested.
> 
> We do that when we write to a slow device for example. Slow because it
> is intrinsically slow or because it is limited by some IO controlling
> rules.
> 
> It is a very similar issue IMHO.
> 
I think so, too.

> > via direct I/O, and sometimes does a lot of writes through the page
> > cache, and sometimes does *both*, it would seem to me that if you want
> > to be able to smoothly limit the amount of I/O it does, you would want
> > to account and charge for direct I/O and page cache I/O under the same
> > "bucket".   Is that what the user would want?   
> > 
> > Suppose you only have 200 MB/sec worth of disk bandwidth, and you
> > parcel it out in 50 MB/sec chunks to 4 cgroups.  But you also parcel
> > out 50MB/sec of dirty writepages quota to each of the 4 cgroups. 

50MB/sec of diry writepages sounds strange. It's just "50MB of dirty pages limit".
not 50MB/sec if we use a logic like dirty_ratio.


> > Now suppose one of the cgroups, which was normally doing not much of
> > anything, suddenly starts doing a database backup which does 50 MB/sec
> > of direct I/O reading from the database file, and 50 MB/sec dirtying
> > pages in the page cache as it writes the backup file.  Suddenly that
> > one cgroup is using half of the system's I/O bandwidth!
> 
Hmm ? buffered I/O tracking can't be a help ? Of course, I/O controller 
should chase this. And dirty_ratio is not 50MB/sec but 50MB. Then,
read will get slow down very soon if read/write is done by 1 thread.
(I'm not sure if there are 2 threads, one only read and another only write.)

BTW, read B/W and write B/W can be handled under a limit ?


> Agreed. The bucket should be the same. The dirty memory should be
> probably limited only in terms of "space" for this case instead of BW.
> 
> And we should guarantee that a cgroup doesn't fill unfairly the memory
> with dirty pages (system-wide or in other cgroups).
> 
> > 
> > And before you say this is "correct" from a definitional point of
> > view, is it "correct" from what a system administrator would want to
> > control?  Is it the right __feature__?  If you just say, well, we
> > defined the problem that way, and we're doing things the way we
> > defined it, that's a case of garbage in, garbage out.  You also have
> > to ask the question, "did we define the _problem_ in the right way?"
> > What does the user of this feature really want to do?  
> > 
> > It would seem to me that the system administrator would want a single
> > knob, saying "I don't know or care how the processes in a cgroup does
> > its I/O; I just want to limit things so that the cgroup can only hog
> > 25% of the I/O bandwidth."
> 
> Agreed.
> 
Agreed. It will be the best.

> > 
> > And note this is completely separate from the question of what happens
> > if you throttle I/O in the page cache writeback loop, and you end up
> > with an imbalance in the clean/dirty ratios of the cgroups. 
dirty_ratio for memcg is in plan. just delayed.

> > And
> > looking at this thread, life gets even *more* amusing on NUMA machines
> > if you do this; what if you end up starving a cpuset as a result of
> > this I/O balancing decision, so a particular cpuset doesn't have
> > enough memory?  That's when you'll *definitely* start having OOM
> > problems.
> > 
cpuset users shouldn't use I/O limiting, in general.
Or I/O cotroller should have a switch as "toggle I/O limit if I/O is from
kswapd/vmscan.c". (Or categorize it to kernel I/O.)


> Honestly, I've never considered the cgroups "interactions" and the
> unfair distribution of dirty pages among cgroups, for example, as
> correctly pointed out by Ted.
> 

If we really want that, scheduler-cgroup should be considered, too.

Considering optimisically, 99% of cgroup users will use "container" and
all resource control cgroup will be set up at once. Then, user-land
container tools can tell users the container has good balance(of cpu,memory,I/O, etc)
or not.

_interactions_ is important. But cgroup is desined to have many independent subsystems
because it's considered as generic infrastructure.
I didn't read the cgroup design discussion but it's strange to say  "we need
balance under subsystem in the kernel" _now_.

A container, the user interface of cgroups which most people think of, should
know that. If we can't do in user land, we should find a way to _ineractions_ in
the kernel, of course.

Thanks,
-Kame
