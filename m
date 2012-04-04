From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IOPS based scheduler (Was: Re: [PATCH 18/21] blkcg: move
	blkio_group_conf->weight to cfq)
Date: Wed, 4 Apr 2012 13:17:12 -0400
Message-ID: <20120404171712.GG12676__32974.483507178$1333559847$gmane$org@redhat.com>
References: <20120402222504.GA2672@redhat.com> <4F7A2B21.5000907@tao.ma>
	<20120403153736.GI5913@redhat.com> <4F7B2708.6080504@tao.ma>
	<20120403164959.GJ5913@redhat.com> <4F7B32AE.7050900@tao.ma>
	<CANejiEU1qAsvogozY3MjZnpcrbYZO4CkRE8s73WGPc_R5LKV9g@mail.gmail.com>
	<20120404133705.GB12676@redhat.com> <4F7C7A91.8040707@tao.ma>
	<20120404165048.GF12676@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120404165048.GF12676-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Wed, Apr 04, 2012 at 12:50:48PM -0400, Vivek Goyal wrote:
> On Thu, Apr 05, 2012 at 12:45:05AM +0800, Tao Ma wrote:
> 
> [..]
> > > In iops_mode(), expire each cfqq after dispatch of 1 or bunch of requests
> > > and you should get the same behavior (with slice_idle=0 and group_idle=0).
> > > So why write a new scheduler.
> > really? How could we config cfq to work like this? Or you mean we can
> > change the code for it?
> 
> You can just put a few lines of code to expire queue after 1-2 requests
> dispatched from the queue. Than run your workload with slice_idle=0
> and group_idle=0 and see what happens.

Can you apply following patch and test your workload with slice_idle=0,
group_idle=0 and quantum=64/128.

I expect that fast queue and group switching will take place. Even if your
workload is creating continuously backlogged queues, we will still
expire the queue after dispatching 5 requests from the queue and requeue
it.

I also expect that you should see service differentation at *group level*.
(And not at cfqq level), if your workload is creating continuously
backlogged groups. Otherwise it will effectively become round robin
scheduling.

If possible, send me small backtrace (5 seconds trace), of your workload
and that can help understand little better what is going on.

Thanks
Vivek


---
 block/cfq-iosched.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-2.6/block/cfq-iosched.c
===================================================================
--- linux-2.6.orig/block/cfq-iosched.c	2012-04-03 23:18:33.000000000 -0400
+++ linux-2.6/block/cfq-iosched.c	2012-04-05 00:02:07.517806185 -0400
@@ -655,8 +655,13 @@ cfq_set_prio_slice(struct cfq_data *cfqd
  */
 static inline bool cfq_slice_used(struct cfq_queue *cfqq)
 {
+	/* In iops mode, we really are not looking for time measurement */
+	if (iops_mode(cfqq->cfqd) && cfqq->slice_dispatch > 5)
+		return true;
+
 	if (cfq_cfqq_slice_new(cfqq))
 		return false;
+
 	if (time_before(jiffies, cfqq->slice_end))
 		return false;
