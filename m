From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IOPS based scheduler (Was: Re: [PATCH 18/21] blkcg: move
	blkio_group_conf->weight to cfq)
Date: Wed, 4 Apr 2012 09:37:05 -0400
Message-ID: <20120404133705.GB12676@redhat.com>
References: <4F7A2217.2030201@tao.ma>
	<20120402221702.GA21017@dhcp-172-17-108-109.mtv.corp.google.com>
	<4F7A261A.9000200@tao.ma> <20120402222504.GA2672@redhat.com>
	<4F7A2B21.5000907@tao.ma> <20120403153736.GI5913@redhat.com>
	<4F7B2708.6080504@tao.ma> <20120403164959.GJ5913@redhat.com>
	<4F7B32AE.7050900@tao.ma>
	<CANejiEU1qAsvogozY3MjZnpcrbYZO4CkRE8s73WGPc_R5LKV9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CANejiEU1qAsvogozY3MjZnpcrbYZO4CkRE8s73WGPc_R5LKV9g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Shaohua Li <shli-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tao Ma <tm-d1IQDZat3X0@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 04, 2012 at 05:35:49AM -0700, Shaohua Li wrote:

[..]
> >> How iops_weight and switching different than CFQ group scheduling logic?
> >> I think shaohua was talking of using similar logic. What would you do
> >> fundamentally different so that without idling you will get service
> >> differentiation?
> > I am thinking of differentiate different groups with iops, so if there
> > are 3 groups(the weight are 100, 200, 300) we can let them submit 1 io,
> > 2 io and 3 io in a round-robin way. With a intel ssd, every io can be
> > finished within 100us. So the maximum latency for one io is about 600us,
> > still less than 1ms. But with cfq, if all the cgroups are busy, we have
> > to switch between these group in ms which means the maximum latency will
> > be 6ms. It is terrible for some applications since they use ssds now.
> Yes, with iops based scheduling, we do queue switching for every request.
> Doing the same thing between groups is quite straightforward. The only issue
> I found is this will introduce more process context switch, this isn't
> a big issue
> for io bound application, but depends. It cuts latency a lot, which I
> guess is more
> important for web 2.0 application.

In iops_mode(), expire each cfqq after dispatch of 1 or bunch of requests
and you should get the same behavior (with slice_idle=0 and group_idle=0).
So why write a new scheduler.

Only thing is that with above, current code will provide iops fairness only
for groups. We should be able to tweak queue scheduling to support iops
fairness also.

Anyway, we will end up doing that at some point of time. Supporting two
scheduling algorihtms for queue and groups is not sustainable. There are
already calls to make CFQ hierarchical and in that case both queue and
groups need to be on a single service tree and that means need to follow
same algorithm for scheduling.

Thanks
Vivek
