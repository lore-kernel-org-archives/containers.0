From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 02/10] Common flat fair queuing code in elevaotor layer
Date: Thu, 19 Mar 2009 14:27:14 +0800
Message-ID: <49C1E5C2.5000107__26502.4381493733$1237444395$gmane$org@cn.fujitsu.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-3-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1236823015-4183-3-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
> +
> +int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
> +			void *sched_queue, int ioprio_class, int ioprio,
> +			int is_sync)
> +{
> +	struct elv_fq_data *efqd = &eq->efqd;
> +	struct io_group *iog = io_lookup_io_group_current(efqd->queue);
> +
> +	RB_CLEAR_NODE(&ioq->entity.rb_node);
> +	atomic_set(&ioq->ref, 0);
> +	ioq->efqd = efqd;
> +	ioq->entity.budget = efqd->elv_slice[is_sync];
> +	elv_ioq_set_ioprio_class(ioq, ioprio_class);
> +	elv_ioq_set_ioprio(ioq, ioprio);
> +	ioq->pid = current->pid;

  Hi Vivek,

  If we are using a scheduler other than cfq, IOW single ioq is used.
  that storing a pid to the ioq makes no sense, it just stores the first 
  serviced task.

> +	ioq->sched_queue = sched_queue;
> +	elv_mark_ioq_idle_window(ioq);
> +	bfq_init_entity(&ioq->entity, iog);
> +	return 0;
> +}
> +EXPORT_SYMBOL(elv_init_ioq);
...
> +
> +extern int elv_slice_idle;
> +extern int elv_slice_async;
> +
> +/* Logging facilities. */
> +#define elv_log_ioq(efqd, ioq, fmt, args...) \
> +	blk_add_trace_msg((efqd)->queue, "%d" fmt, (ioq)->pid, ##args)

   Maybe we need to use current->pid instead, for ioq->pid is not valid
   sometimes.

> +
> +#define elv_log(efqd, fmt, args...) \
> +	blk_add_trace_msg((efqd)->queue, "" fmt, ##args)
> +
> +#define ioq_sample_valid(samples)   ((samples) > 80)
> +


-- 
Regards
Gui Jianfeng
