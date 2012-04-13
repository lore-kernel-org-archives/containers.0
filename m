From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 7/8] blkcg: implement per-queue policy activation
Date: Fri, 13 Apr 2012 11:17:05 -0700
Message-ID: <20120413181705.GD12233__41094.0304784619$1334341039$gmane$org@google.com>
References: <1334273380-30233-1-git-send-email-tj@kernel.org>
	<1334273380-30233-8-git-send-email-tj@kernel.org>
	<20120413181257.GG26383@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120413181257.GG26383-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Fri, Apr 13, 2012 at 02:12:57PM -0400, Vivek Goyal wrote:
> On Thu, Apr 12, 2012 at 04:29:39PM -0700, Tejun Heo wrote:
> 
> [..]
> > diff --git a/block/elevator.c b/block/elevator.c
> > index be3ab6d..6a55d41 100644
> > --- a/block/elevator.c
> > +++ b/block/elevator.c
> > @@ -896,8 +896,6 @@ static int elevator_switch(struct request_queue *q, struct elevator_type *new_e)
> >  	ioc_clear_queue(q);
> >  	spin_unlock_irq(q->queue_lock);
> >  
> > -	blkg_destroy_all(q, false);
> > -
> 
> So now groups don't reclaimed until either cgroup is deleted or queue
> exits. So if BLK_DEV_THROTTLE=n and cfq is switched out, blkg created
> by CFQ policy will not be reclaimed (despite the fact nobody is using
> them).

It's not difficult to change.  We can just trigger reclaim if no
policy is enabled for the queue.  Hmmm... yeah, that's gonna be like
five line change.  I'll add it.

Thanks.

-- 
tejun
