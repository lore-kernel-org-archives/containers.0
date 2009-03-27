From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IO Controller: Don't store the pid in single queue
	circumstances
Date: Fri, 27 Mar 2009 09:52:35 -0400
Message-ID: <20090327135235.GD30476__49552.8654581451$1238162212$gmane$org@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-3-git-send-email-vgoyal@redhat.com>
	<49CC8EBA.9040804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49CC8EBA.9040804-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Mar 27, 2009 at 04:30:50PM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> ...
> > +int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
> > +			void *sched_queue, int ioprio_class, int ioprio,
> > +			int is_sync)
> > +{
> > +	struct elv_fq_data *efqd = &eq->efqd;
> > +	struct io_group *iog = io_lookup_io_group_current(efqd->queue);
> > +
> > +	RB_CLEAR_NODE(&ioq->entity.rb_node);
> > +	atomic_set(&ioq->ref, 0);
> > +	ioq->efqd = efqd;
> > +	ioq->entity.budget = efqd->elv_slice[is_sync];
> > +	elv_ioq_set_ioprio_class(ioq, ioprio_class);
> > +	elv_ioq_set_ioprio(ioq, ioprio);
> > +	ioq->pid = current->pid;
> 
>   Hi Vivek,
> 
>   Storing a pid in single queue circumstances doesn't make sence.
>   So just store the pid when cfq is used.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>  ---
>  block/elevator-fq.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index df53418..c72f7e6 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -1988,7 +1988,10 @@ int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
>  	ioq->entity.budget = efqd->elv_slice[is_sync];
>  	elv_ioq_set_ioprio_class(ioq, ioprio_class);
>  	elv_ioq_set_ioprio(ioq, ioprio);
> -	ioq->pid = current->pid;
> +	if (elv_iosched_single_ioq(eq))
> +		ioq->pid = 0;
> +	else
> +		ioq->pid = current->pid;
>  	ioq->sched_queue = sched_queue;

Thanks Gui. Yes, if there is a single ioq, this pid will reflect the
pid of the process who caused the creation of the io queue and later
requests from all the other processess will go into same queue.

In fact cfq also has the same issue for async queues where async queue
will store the pid when it is created later all other processes of same
prio level will use it.

So if you think displaying "0" is better than displaying the the pid of
the process who created the queue, then I will include this patch. Right
now I don't have very strong opinion about it. 

Thanks
Vivek
