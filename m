From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Fri, 8 May 2009 17:56:18 -0400
Message-ID: <20090508215618.GJ7293@redhat.com>
References: <20090506203228.GH8180@redhat.com> <20090506213453.GC4282@linux>
	<20090506215235.GJ8180@redhat.com> <20090507090450.GA4613@linux>
	<20090507141126.GA9463@redhat.com>
	<20090507144501.GB9463@redhat.com>
	<20090507153642.GC9463@redhat.com> <20090507221900.GA29774@linux>
	<20090508180951.GG7293@redhat.com> <20090508200458.GA3708@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090508200458.GA3708@linux>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 08, 2009 at 10:05:01PM +0200, Andrea Righi wrote:

[..]
> > Conclusion
> > ==========
> > It just reaffirms that with max BW control, we are not doing a fair job
> > of throttling hence no more hold the IO scheduler properties with-in
> > cgroup.
> > 
> > With proportional BW controller implemented at IO scheduler level, one
> > can do very tight integration with IO controller and hence retain 
> > IO scheduler behavior with-in cgroup.
> 
> It is worth to bug you I would say :). Results are interesting,
> definitely. I'll check if it's possible to merge part of the io-throttle
> max BW control in this controller and who knows if finally we'll be able
> to converge to a common proposal...

Great, Few thoughts though.

- What are your requirements? Do you strictly need max bw control or
  proportional BW control will satisfy your needs? Or you need both?

- With the current algorithm BFQ (modified WF2Q+), we should be able
  to do proportional BW division while maintaining the properties of
  IO scheduler with-in cgroup in hiearchical manner.
 
  I think it can be simply enhanced to do max bw control also. That is
  whenever a queue is selected for dispatch (from fairness point of view)
  also check the IO rate of that group and if IO rate exceeded, expire
  the queue immediately and fake as if queue consumed its time slice
  which will be equivalent to throttling.

  But in this simple scheme, I think throttling is still unfair with-in
  the class. What I mean is following.

  if an RT task and an BE task are in same cgroup and cgroup exceeds its
  max BW, RT task is next to be dispatched from fairness point of view and it
  will end being throttled. This is still fine because until RT task is
  finished, BE task will never get to run in that cgroup, so at some point
  of time, cgroup rate will come down and RT task will get the IO done
  meeting fairnesss and max bw constraints.

  But this simple scheme does not work with-in same class. Say prio 0
  and prio 7 BE class readers. Now we will end up throttling the guy who
  is scheduled to go next and there is no mechanism that prio0 and prio7
  tasks are throttled in proportionate manner.

  So, we shall have to come up with something better, I think Dhaval was
  implementing upper limit for cpu controller. May be PeterZ and Dhaval can
  give us some pointers how did they manage to implement both proportional
  and max bw control with the help of a single tree while maintaining the
  notion of prio with-in cgroup.

PeterZ/Dhaval  ^^^^^^^^

- We should be able to get rid of reader-writer issue even with above
  simple throttling mechanism for schedulers like deadline and AS, because at
  elevator we see it as a single queue (for both reads and writes) and we
  will throttle this queue. With-in queue dispatch are taken care by io
  scheduler. So as long as IO has been queued in the queue, scheduler
  will take care of giving advantage to readers even if throttling is
  taking place on the queue.

Why am I thinking loud? So that we know what are we trying to achieve at the
end of the day. So at this point of time what are the advantages/disadvantages
of doing max bw control along with proportional bw control?

Advantages
==========
- With a combined code base, total code should be less as compared to if
  both of them are implemented separately. 

- There can be few advantages in terms of maintaining the notion of IO
  scheduler with-in cgroup. (like RT tasks always goes first in presence
  of BE and IDLE task etc. But simple throttling scheme will not take
  care of fair throttling with-in class. We need a better algorithm to
  achive that goal).

- We probably will get rid of reader writer issue for single queue
  schedulers like deadline and AS. (Need to run tests and see).

Disadvantages
=============
- Implementation at IO scheduler/elevator layer does not cover higher
  level logical devices. So one can do max bw control only at leaf nodes
  where IO scheduler is running and not at intermediate logical nodes.
   
I personally think that proportional BW control will meet more people's
need as compared to max bw contorl. 

So far nobody has come up with a solution where a single proposal covers
all the cases without breaking things. So personally, I want to make
things work at least at IO scheduler level and cover as much ground as
possible without breaking things (hardware RAID, all the direct attached
devices etc) and then worry about higher level software devices.

Thoughts?

Thanks
Vivek
