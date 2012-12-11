From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: performance drop after using blkcg
Date: Tue, 11 Dec 2012 11:18:20 -0500
Message-ID: <20121211161820.GE5580__15988.637720193$1355242732$gmane$org@redhat.com>
References: <CAFVn34SxqAJe_4P-WT8MOiG-kmKKD7ge96zoHXQuGqHWPgAt+A@mail.gmail.com>
	<20121211142518.GA5580@redhat.com>
	<20121211142742.GE7084@htj.dyndns.org>
	<20121211144336.GB5580@redhat.com>
	<20121211144718.GF7084@htj.dyndns.org>
	<20121211150234.GC5580@redhat.com>
	<20121211151412.GG7084@htj.dyndns.org>
	<20121211153725.GD5580@redhat.com>
	<20121211160137.GJ7084@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121211160137.GJ7084-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Zhao Shuai <zhaoshuai-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Dec 11, 2012 at 08:01:37AM -0800, Tejun Heo wrote:

[..]
> > Only way to provide effective isolation seemed to be idling and the
> > moment we idle we kill the performance. It does not matter whether we
> > are scheduling time or iops.
> 
> If the completion latency of IOs fluctuates heavily depend on queue
> depth, queue depth would need to be throttled so that lower priority
> queue can't overwhelm the device queue while prospect higher priority
> accessors exist.  Another aspect is that devices are getting a lot
> more consistent in terms of latency.
> 
> While idling would also solve isolation issue with unordered deep
> device queue, it really is a solution for a rotational device with
> large seek penalty as the time lost while idling can often/somtimes
> made up by the save from lower seeks.  For non-rot devices with deep
> queue, the right thing to do would be controlling queue depth or
> propagate priority to the device queue (from what I hear, people are
> working on it. dunno how well it would turn out tho).

- Controlling device queue should bring down throughput too as it
  should bring down level of parallelism at device level. Also asking
  user to tune device queue depth seems bad interface. How would a
  user know what's the right queue depth. May be software can try to
  be intelligent about it and if IO latencies cross a threshold then
  try to decrese queue depth. (We do things like that in CFQ).

- Passing prio to device sounds something new and promising. If they
  can do a good job at it, why not. I think at minimum they need to
  make sure READs are prioritized over writes by default. And may
  be provide a way to signal important writes which need to go to
  the disk now.

  If READs are prioritized in device, then it takes care of one very
  important use case. Then we just have to worry about other case of
  fairness between different readers or fairness between different
  writers and there we do not idle and try our best to give fair share.
  In case group is not backlogged, it is bound to loose some share.

> 
> > >  cfq is way too heavy and
> > > ill-suited for high speed non-rot devices which are becoming more and
> > > more consistent in terms of iops they can handle.
> > > 
> > > I think we need something better suited for the maturing non-rot
> > > devices.  They're becoming very different from what cfq was built for
> > > and we really shouldn't be maintaining several rb trees which need
> > > full synchronization for each IO.  We're doing way too much and it
> > > just isn't scalable.
> > 
> > I am fine with doing things differently in a different scheduler. But 
> > what I am aruging here is that atleast with CFQ we should be able to
> > experiment and figure out what works.  In CFQ all the code is there and
> > if this iops based scheduling has merit, one should be able to quickly
> > experiment and demonstrate how would one do things differently.
> > 
> > To me I have not been able to understand yet that what is iops based
> > scheduling doing differently. Will we idle there or not. If we idle
> > we again have performance problems.
> 
> When the device can do tens of thousands ios per sec, I don't think it
> makes much sense to idle the device.  You just lose too much.

Agreed. idling starts showing soon on fast SATA rotational devices itself
so idling on faster devices will lead to bad results on most of the
workloads.

> 
> > So doing things out of CFQ is fine. I am only after understanding the
> > technical idea which will solve the problem of provinding isolation
> > as well as fairness without losing throughput. And I have not been
> > able to get a hang of it yet.
> 
> I think it already has some aspect of it.  It has the half-iops mode
> for a reason, right?  It just is very inefficient and way more complex
> than it needs to be.

I introduced this iops_mode() in an attempt to try to provide fair disk
share in terms of iops instead of disk slices. It might not be most
efficient one but atleast it can provide answers whether it is something
useful or not and for what workload and devices this iops based scheduling
is useful. 

So if somebody wants to experiment, just tweak the code a bit to allow
preemption when a queue which lost share gets backlogged and you
practially have a prototype of iops based group scheduling.

Thanks
Vivek
