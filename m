From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: performance drop after using blkcg
Date: Tue, 11 Dec 2012 10:37:25 -0500
Message-ID: <20121211153725.GD5580__38682.5745496482$1355240274$gmane$org@redhat.com>
References: <CAFVn34SxqAJe_4P-WT8MOiG-kmKKD7ge96zoHXQuGqHWPgAt+A@mail.gmail.com>
	<20121211142518.GA5580@redhat.com>
	<20121211142742.GE7084@htj.dyndns.org>
	<20121211144336.GB5580@redhat.com>
	<20121211144718.GF7084@htj.dyndns.org>
	<20121211150234.GC5580@redhat.com>
	<20121211151412.GG7084@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121211151412.GG7084-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

On Tue, Dec 11, 2012 at 07:14:12AM -0800, Tejun Heo wrote:
> Hello, Vivek.
> 
> On Tue, Dec 11, 2012 at 10:02:34AM -0500, Vivek Goyal wrote:
> > cfq_group_served() {
> >         if (iops_mode(cfqd))
> >                 charge = cfqq->slice_dispatch;
> > 	cfqg->vdisktime += cfq_scale_slice(charge, cfqg);
> > }
> > 
> > Isn't it effectively IOPS scheduling. One should get IOPS rate in proportion to
> > their weight (as long as they can throw enough traffic at device to keep
> > it busy). If not, can you please give more details about your proposal.
> 
> The problem is that we lose a lot of isolation w/o idling between
> queues or groups.  This is because we switch between slices and while
> a slice is in progress only ios belongint to that slice can be issued.
> ie. higher priority cfqgs / cfqqs, after dispatching the ios they have
> ready, lose their slice immmediately.  Lower priority slice takes over
> and when hgiher priority ones get ready, they have to wait for the
> lower priority one before submitting the new IOs.  In many cases, they
> end up not being able to generate IOs any faster than the ones in
> lower priority cfqqs/cfqgs.
> 
> This is becase we switch slices rather than iops.

I am not sure how any of the above problems will go away if we start
scheduling iops. 

>  We can make cfq
> essentially switch iops by implementing very aggressive preemption but
> I really don't see much point in that.

Yes, this should be easily doable. Once a queue/group is being removed
and is losing its share, just keep track of last vdisktime. When more IO
comes in this group and current group is preempted (if its vdisktime is
greater than one being queued). And new group is probably queued at
the front.

I have experimented with schemes like that but did not see any very
promising resutls. Assume device supports queue depth of 128, and there
is one dependent reader and one writer. If reader goes away and comes
back and preempts low priority writer, in that small time window writer
has dispatched enough requests to introduce read delays. So preemption
helps only so much. I am curious to know how iops based scheduler solve
these issues.  

Only way to provide effective isolation seemed to be idling and the
moment we idle we kill the performance. It does not matter whether we
are scheduling time or iops.

>  cfq is way too heavy and
> ill-suited for high speed non-rot devices which are becoming more and
> more consistent in terms of iops they can handle.
> 
> I think we need something better suited for the maturing non-rot
> devices.  They're becoming very different from what cfq was built for
> and we really shouldn't be maintaining several rb trees which need
> full synchronization for each IO.  We're doing way too much and it
> just isn't scalable.

I am fine with doing things differently in a different scheduler. But 
what I am aruging here is that atleast with CFQ we should be able to
experiment and figure out what works.  In CFQ all the code is there and
if this iops based scheduling has merit, one should be able to quickly
experiment and demonstrate how would one do things differently.

To me I have not been able to understand yet that what is iops based
scheduling doing differently. Will we idle there or not. If we idle
we again have performance problems.

So doing things out of CFQ is fine. I am only after understanding the
technical idea which will solve the problem of provinding isolation
as well as fairness without losing throughput. And I have not been
able to get a hang of it yet.

Thanks
Vivek
