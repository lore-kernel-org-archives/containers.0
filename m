From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 05/24] io-controller: Modify cfq to make use of flat
	elevator fair queuing
Date: Thu, 30 Jul 2009 14:30:14 -0400
Message-ID: <20090730183014.GA6067__23166.6675922044$1248978715$gmane$org@redhat.com>
References: <1248467274-32073-1-git-send-email-vgoyal@redhat.com>
	<1248467274-32073-6-git-send-email-vgoyal@redhat.com>
	<4A71BF76.6040709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A71BF76.6040709-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 30, 2009 at 05:42:46PM +0200, Jerome Marchand wrote:
> Vivek Goyal wrote:
> > @@ -1616,11 +1234,12 @@ static void changed_ioprio(struct io_context *ioc, struct cfq_io_context *cic)
> >  	struct cfq_data *cfqd = cic->key;
> >  	struct cfq_queue *cfqq;
> >  	unsigned long flags;
> > +	struct request_queue *q = cfqd->queue;
> 
> cfqd may be NULL here. We'd better test it before using it.
> 

Thanks Jerome. 

Actually I will drop this chage altogether. This is not required. I don't
know why did I change original code to introduce another local variable. 

Thanks
Vivek

> >  
> >  	if (unlikely(!cfqd))
> >  		return;
> >  
> > -	spin_lock_irqsave(cfqd->queue->queue_lock, flags);
> > +	spin_lock_irqsave(q->queue_lock, flags);
> >  
> >  	cfqq = cic->cfqq[BLK_RW_ASYNC];
> >  	if (cfqq) {
> > @@ -1637,7 +1256,7 @@ static void changed_ioprio(struct io_context *ioc, struct cfq_io_context *cic)
> >  	if (cfqq)
> >  		cfq_mark_cfqq_prio_changed(cfqq);
> >  
> > -	spin_unlock_irqrestore(cfqd->queue->queue_lock, flags);
> > +	spin_unlock_irqrestore(q->queue_lock, flags);
> >  }
> >  
> >  static void cfq_ioc_set_ioprio(struct io_context *ioc)
> 
> 
> --- block/cfq-iosched.c.orig	2009-07-29 10:22:08.000000000 +0200
> +++ block/cfq-iosched.c	2009-07-30 17:25:05.000000000 +0200
> @@ -1271,11 +1271,12 @@ static void changed_ioprio(struct io_con
>  	struct cfq_data *cfqd = cic->key;
>  	struct cfq_queue *cfqq;
>  	unsigned long flags;
> -	struct request_queue *q = cfqd->queue;
> +	struct request_queue *q;
>  
>  	if (unlikely(!cfqd))
>  		return;
>  
> +	q = cfqd->queue;
>  	spin_lock_irqsave(q->queue_lock, flags);
>  
>  	cfqq = cic->cfqq[BLK_RW_ASYNC];
