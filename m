From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 04/19] io-controller: Modify cfq to make use of flat
	elevator fair queuing
Date: Mon, 15 Jun 2009 16:56:50 +0800
Message-ID: <4A360CD2.8060707__19496.6060495519$1245056718$gmane$org@cn.fujitsu.com>
References: <1244513342-11758-1-git-send-email-vgoyal@redhat.com>
	<1244513342-11758-5-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1244513342-11758-5-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> This patch changes cfq to use fair queuing code from elevator layer.
> 
> Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
> Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  block/Kconfig.iosched     |    3 +-
>  block/cfq-iosched.c       | 1097 +++++++++------------------------------------
>  include/linux/iocontext.h |    4 -
>  3 files changed, 219 insertions(+), 885 deletions(-)
> 
> diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
> index 3398134..dd5224d 100644
> --- a/block/Kconfig.iosched
> +++ b/block/Kconfig.iosched
> @@ -3,7 +3,7 @@ if BLOCK
>  menu "IO Schedulers"
>  
>  config ELV_FAIR_QUEUING
> -	bool "Elevator Fair Queuing Support"
> +	bool
>  	default n
>  	---help---
>  	  Traditionally only cfq had notion of multiple queues and it did
> @@ -46,6 +46,7 @@ config IOSCHED_DEADLINE
>  
>  config IOSCHED_CFQ
>  	tristate "CFQ I/O scheduler"
> +	select ELV_FAIR_QUEUING
>  	default y
>  	---help---
>  	  The CFQ I/O scheduler tries to distribute bandwidth equally
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index a55a9bd..f90c534 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -12,7 +12,6 @@
>  #include <linux/rbtree.h>
>  #include <linux/ioprio.h>
>  #include <linux/blktrace_api.h>
> -
>  /*
>   * tunables
>   */
> @@ -23,15 +22,7 @@ static const int cfq_fifo_expire[2] = { HZ / 4, HZ / 8 };
>  static const int cfq_back_max = 16 * 1024;
>  /* penalty of a backwards seek */
>  static const int cfq_back_penalty = 2;
> -static const int cfq_slice_sync = HZ / 10;
> -static int cfq_slice_async = HZ / 25;
>  static const int cfq_slice_async_rq = 2;
> -static int cfq_slice_idle = HZ / 125;
> -
> -/*
> - * offset from end of service tree
> - */
> -#define CFQ_IDLE_DELAY		(HZ / 5)
>  
>  /*
>   * below this threshold, we consider thinktime immediate
> @@ -43,7 +34,7 @@ static int cfq_slice_idle = HZ / 125;
>  
>  #define RQ_CIC(rq)		\
>  	((struct cfq_io_context *) (rq)->elevator_private)
> -#define RQ_CFQQ(rq)		(struct cfq_queue *) ((rq)->elevator_private2)
> +#define RQ_CFQQ(rq)	(struct cfq_queue *) (ioq_sched_queue((rq)->ioq))
>  
>  static struct kmem_cache *cfq_pool;
>  static struct kmem_cache *cfq_ioc_pool;
> @@ -53,8 +44,6 @@ static struct completion *ioc_gone;
>  static DEFINE_SPINLOCK(ioc_gone_lock);
>  
>  #define CFQ_PRIO_LISTS		IOPRIO_BE_NR
> -#define cfq_class_idle(cfqq)	((cfqq)->ioprio_class == IOPRIO_CLASS_IDLE)
> -#define cfq_class_rt(cfqq)	((cfqq)->ioprio_class == IOPRIO_CLASS_RT)
>  
>  #define sample_valid(samples)	((samples) > 80)
>  
> @@ -75,12 +64,6 @@ struct cfq_rb_root {
>   */
>  struct cfq_data {
>  	struct request_queue *queue;
> -
> -	/*
> -	 * rr list of queues with requests and the count of them
> -	 */
> -	struct cfq_rb_root service_tree;
> -
>  	/*
>  	 * Each priority tree is sorted by next_request position.  These
>  	 * trees are used when determining if two or more queues are
> @@ -88,39 +71,10 @@ struct cfq_data {
>  	 */
>  	struct rb_root prio_trees[CFQ_PRIO_LISTS];
>  
> -	unsigned int busy_queues;
> -	/*
> -	 * Used to track any pending rt requests so we can pre-empt current
> -	 * non-RT cfqq in service when this value is non-zero.
> -	 */
> -	unsigned int busy_rt_queues;
> -
> -	int rq_in_driver;
>  	int sync_flight;
>  
> -	/*
> -	 * queue-depth detection
> -	 */
> -	int rq_queued;
> -	int hw_tag;
> -	int hw_tag_samples;
> -	int rq_in_driver_peak;
> -
> -	/*
> -	 * idle window management
> -	 */
> -	struct timer_list idle_slice_timer;
> -	struct work_struct unplug_work;
> -
> -	struct cfq_queue *active_queue;
>  	struct cfq_io_context *active_cic;
>  
> -	/*
> -	 * async queue for each priority case
> -	 */
> -	struct cfq_queue *async_cfqq[2][IOPRIO_BE_NR];
> -	struct cfq_queue *async_idle_cfqq;
> -
>  	sector_t last_position;
>  	unsigned long last_end_request;
>  
> @@ -131,9 +85,7 @@ struct cfq_data {
>  	unsigned int cfq_fifo_expire[2];
>  	unsigned int cfq_back_penalty;
>  	unsigned int cfq_back_max;
> -	unsigned int cfq_slice[2];
>  	unsigned int cfq_slice_async_rq;
> -	unsigned int cfq_slice_idle;
>  
>  	struct list_head cic_list;
>  };
> @@ -142,16 +94,11 @@ struct cfq_data {
>   * Per process-grouping structure
>   */
>  struct cfq_queue {
> -	/* reference count */
> -	atomic_t ref;
> +	struct io_queue *ioq;
>  	/* various state flags, see below */
>  	unsigned int flags;
>  	/* parent cfq_data */
>  	struct cfq_data *cfqd;
> -	/* service_tree member */
> -	struct rb_node rb_node;
> -	/* service_tree key */
> -	unsigned long rb_key;
>  	/* prio tree member */
>  	struct rb_node p_node;
>  	/* prio tree root we belong to, if any */
> @@ -167,33 +114,23 @@ struct cfq_queue {
>  	/* fifo list of requests in sort_list */
>  	struct list_head fifo;
>  
> -	unsigned long slice_end;
> -	long slice_resid;
>  	unsigned int slice_dispatch;
>  
>  	/* pending metadata requests */
>  	int meta_pending;
> -	/* number of requests that are on the dispatch list or inside driver */
> -	int dispatched;
>  
>  	/* io prio of this group */
> -	unsigned short ioprio, org_ioprio;
> -	unsigned short ioprio_class, org_ioprio_class;
> +	unsigned short org_ioprio;
> +	unsigned short org_ioprio_class;
>  
>  	pid_t pid;
>  };
>  
>  enum cfqq_state_flags {
> -	CFQ_CFQQ_FLAG_on_rr = 0,	/* on round-robin busy list */
> -	CFQ_CFQQ_FLAG_wait_request,	/* waiting for a request */
> -	CFQ_CFQQ_FLAG_must_dispatch,	/* must be allowed a dispatch */
>  	CFQ_CFQQ_FLAG_must_alloc,	/* must be allowed rq alloc */
>  	CFQ_CFQQ_FLAG_must_alloc_slice,	/* per-slice must_alloc flag */
>  	CFQ_CFQQ_FLAG_fifo_expire,	/* FIFO checked in this slice */
> -	CFQ_CFQQ_FLAG_idle_window,	/* slice idling enabled */
>  	CFQ_CFQQ_FLAG_prio_changed,	/* task priority has changed */
> -	CFQ_CFQQ_FLAG_slice_new,	/* no requests dispatched in slice */
> -	CFQ_CFQQ_FLAG_sync,		/* synchronous queue */
>  	CFQ_CFQQ_FLAG_coop,		/* has done a coop jump of the queue */
>  };
>  
> @@ -211,16 +148,10 @@ static inline int cfq_cfqq_##name(const struct cfq_queue *cfqq)		\
>  	return ((cfqq)->flags & (1 << CFQ_CFQQ_FLAG_##name)) != 0;	\
>  }
>  
> -CFQ_CFQQ_FNS(on_rr);
> -CFQ_CFQQ_FNS(wait_request);
> -CFQ_CFQQ_FNS(must_dispatch);
>  CFQ_CFQQ_FNS(must_alloc);
>  CFQ_CFQQ_FNS(must_alloc_slice);
>  CFQ_CFQQ_FNS(fifo_expire);
> -CFQ_CFQQ_FNS(idle_window);
>  CFQ_CFQQ_FNS(prio_changed);
> -CFQ_CFQQ_FNS(slice_new);
> -CFQ_CFQQ_FNS(sync);
>  CFQ_CFQQ_FNS(coop);
>  #undef CFQ_CFQQ_FNS
>  
> @@ -259,66 +190,32 @@ static inline int cfq_bio_sync(struct bio *bio)
>  	return 0;
>  }
>  
> -/*
> - * scheduler run of queue, if there are requests pending and no one in the
> - * driver that will restart queueing
> - */
> -static inline void cfq_schedule_dispatch(struct cfq_data *cfqd)
> +static inline struct io_group *cfqq_to_io_group(struct cfq_queue *cfqq)
>  {
> -	if (cfqd->busy_queues) {
> -		cfq_log(cfqd, "schedule dispatch");
> -		kblockd_schedule_work(cfqd->queue, &cfqd->unplug_work);
> -	}
> +	return ioq_to_io_group(cfqq->ioq);
>  }
>  
> -static int cfq_queue_empty(struct request_queue *q)
> +static inline int cfq_class_idle(struct cfq_queue *cfqq)
>  {
> -	struct cfq_data *cfqd = q->elevator->elevator_data;
> -
> -	return !cfqd->busy_queues;
> +	return elv_ioq_class_idle(cfqq->ioq);
>  }
>  
> -/*
> - * Scale schedule slice based on io priority. Use the sync time slice only
> - * if a queue is marked sync and has sync io queued. A sync queue with async
> - * io only, should not get full sync slice length.
> - */
> -static inline int cfq_prio_slice(struct cfq_data *cfqd, int sync,
> -				 unsigned short prio)
> -{
> -	const int base_slice = cfqd->cfq_slice[sync];
> -
> -	WARN_ON(prio >= IOPRIO_BE_NR);
> -
> -	return base_slice + (base_slice/CFQ_SLICE_SCALE * (4 - prio));
> -}
> -
> -static inline int
> -cfq_prio_to_slice(struct cfq_data *cfqd, struct cfq_queue *cfqq)
> +static inline int cfq_class_rt(struct cfq_queue *cfqq)
>  {
> -	return cfq_prio_slice(cfqd, cfq_cfqq_sync(cfqq), cfqq->ioprio);
> +	return elv_ioq_class_rt(cfqq->ioq);
>  }

Hi Vivek,

cfq_class_rt isn't needed now, clean it up.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/cfq-iosched.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 705e7ba..23b24b9 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -234,11 +234,6 @@ static inline int cfq_class_idle(struct cfq_queue *cfqq)
 	return elv_ioq_class_idle(cfqq->ioq);
 }
 
-static inline int cfq_class_rt(struct cfq_queue *cfqq)
-{
-	return elv_ioq_class_rt(cfqq->ioq);
-}
-
 static inline int cfq_cfqq_sync(struct cfq_queue *cfqq)
 {
 	return elv_ioq_sync(cfqq->ioq);
-- 
1.5.4.rc3
