From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IOPS based scheduler (Was: Re: [PATCH 18/21] blkcg: move
	blkio_group_conf->weight to cfq)
Date: Tue, 3 Apr 2012 12:50:00 -0400
Message-ID: <20120403164959.GJ5913__37032.1989096285$1333471815$gmane$org@redhat.com>
References: <1332975091-10950-19-git-send-email-tj@kernel.org>
	<4F7A1C8B.3010402@tao.ma>
	<20120402214938.GA19634@dhcp-172-17-108-109.mtv.corp.google.com>
	<4F7A2217.2030201@tao.ma>
	<20120402221702.GA21017@dhcp-172-17-108-109.mtv.corp.google.com>
	<4F7A261A.9000200@tao.ma> <20120402222504.GA2672@redhat.com>
	<4F7A2B21.5000907@tao.ma> <20120403153736.GI5913@redhat.com>
	<4F7B2708.6080504@tao.ma>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F7B2708.6080504-d1IQDZat3X0@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tao Ma <tm-d1IQDZat3X0@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shaohua Li <shli-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 04, 2012 at 12:36:24AM +0800, Tao Ma wrote:

[..]
> > - Can't we just set the slice_idle=0 and "quantum" to some high value
> >   say "64" or "128" and achieve similar results to iops based scheduler?
> yes, I should say cfq with slice_idle = 0 works well in most cases. But
> if it comes to blkcg with ssd, it is really a disaster. You know, cfq
> has to choose between different cgroups, so even if you choose 1ms as
> the service time for each cgroup(actually in my test, only >2ms can work
> reliably). the latency for some requests(which have been sent by the
> user while not submitting to the driver) is really too much for the
> application. I don't think there is a way to resolve it in cfq.

Ok, so now you are saying that CFQ as such is not a problem but blkcg
logic in CFQ is an issue.

What's the issue there? I think the issue there also is group idling.
If you set group_idle=0, that idling will be cut down and switching
between groups will be fast. That's a different thing that in the
process you will most likely lose service differentiation also for
most of the workloads.

> 
> > 
> > In theory, above will cut down on idling and try to provide fairness in
> > terms of time. I thought fairness in terms of time is most fair. The
> > most common problem is measurement of time is not attributable to
> > individual queue in an NCQ hardware. I guess that throws time measurement
> > of out the window until and unless we have a better algorithm to measure
> > time in NCQ environment.
> > 
> > I guess then we can just replace time with number of requests dispatched
> > from a process queue. Allow it to dispatch requests for some time and
> > then schedule it out and put it back on service tree and charge it 
> > according to its weight.
> As I have said, in this case, the minimal time(1ms) multiple the group
> number is too much for a ssd.
> 
> If we can use iops based scheduler, we can use iops_weight for different
> cgroups and switch cgroup according to this number. So all the
> applications can have a moderate response time which can be estimated.

How iops_weight and switching different than CFQ group scheduling logic?
I think shaohua was talking of using similar logic. What would you do
fundamentally different so that without idling you will get service 
differentiation? 

If you explain your logic in detail, it will help.

BTW, in last mail you mentioned that in iops_mode() we make use of time.
That's not the case. in iops_mode() we charge group based on number of
requests dispatched. (slice_dispatch records number of requests dispatched
from the queue in that slice). So to me counting number of requests
instead of time will effectively switch CFQ to iops based scheduler, isn't
it?

> 
> btw, I have talked with Shaohua in LSF and we made a consensus that I
> will continue his work and try to add cgroup support to it.

That's fine. you can continue to work. But first explaining the problem
clearly and how you are going to fix it will help. Instead of just saying
"CFQ has problem and we will fix it by bringing in a new scheduler".

Thanks
Vivek
