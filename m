From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Thu, 23 Apr 2009 11:54:19 +0900
Message-ID: <20090423115419.c493266a.kamezawa.hiroyu__11913.267200771$1240455520$gmane$org@jp.fujitsu.com>
References: <20090421163537.GI19186@mit.edu>
	<20090421172317.GM19637@balbir.in.ibm.com>
	<20090421174620.GD15541@mit.edu>
	<20090421181429.GO19637@balbir.in.ibm.com>
	<20090421191401.GF15541@mit.edu> <20090421204905.GA5573@linux>
	<20090422093349.1ee9ae82.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422102153.9aec17b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422102239.GA1935@linux>
	<20090423090535.ec419269.kamezawa.hiroyu@jp.fujitsu.com>
	<20090423012254.GZ15541@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090423012254.GZ15541-3s7WtUTddSA@public.gmane.org>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, Carl-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Gui-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 22 Apr 2009 21:22:54 -0400
Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org> wrote:

> On Thu, Apr 23, 2009 at 09:05:35AM +0900, KAMEZAWA Hiroyuki wrote:
> > So, current status is.
> > 
> >   A. memcg should support dirty_ratio for its own memory reclaim.
> >      in plan.
> > 
> >   B. another cgroup can be implemnted to support cgroup_dirty_limit().
> >      But relationship with "A" should be discussed.
> >      no plan yet.
> > 
> >   C. I/O cgroup and bufferred I/O tracking system.
> >      Now under patch review.
> > 
> > And this I/O throttle is mainly for "C" discussion. 
> 
> How much testing has been done in terms of whether the I/O throttling
> actually works?  Not just, "the kernel doesn't crash", but that where
> you have one process generating a large amount of I/O load, in various
> different ways, and whether the right things happens?  If so, how has
> this been measured?

I/O control people should prove it. And they do, I think.

> 
> I'm really concerned that given some of the ways that I/O will "leak"
> out --- the via pdflush, swap writeout, etc., that without the rest of
> the pieces in place, I/O throttling by itself might not prove to be
> very effective.  Sure, if the workload is only doing direct I/O, life
> is pretty easy and it shouldn't be hard to throttle the cgroup.
> 
It's just a problem of "what we do and what we don't, now".
Andrea, Vivek, could you clarify ? As other project, I/O controller will not be
100% at first implementation. 

> But in the case where there is bufferred I/O, without write
> throttling, it's hard to see how well the I/O controller will work in
> practice.  In fact, I wouldn't be that surprised if it's possible to
> trigger the OOM killer.......
> 

yes, then, memcg should have dirty_ratio handler. And, we may have to
implement dirty-ratio controller.  So, please don't merge memcg discussion
and I/O BW throttoling. It's related to each other but different problem.

Thanks,
-Kame
