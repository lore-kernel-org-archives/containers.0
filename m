From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: Fix task hanging when there are more
	than one groups
Date: Sun, 13 Sep 2009 22:44:01 -0400
Message-ID: <20090914024401.GA14077__31073.9638669931$1252896440$gmane$org@redhat.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<4AA4B905.8010801@cn.fujitsu.com>
	<20090908191941.GF15974@redhat.com>
	<4AA75B71.5060109@cn.fujitsu.com>
	<20090909150537.GD8256@redhat.com> <4AA9A4BE.30005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AA9A4BE.30005-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Sep 11, 2009 at 09:15:42AM +0800, Gui Jianfeng wrote:

[..]
> Hi Vivek, Jens,
> 
> Currently, If there's only the root cgroup and no other child cgroup available, io-controller will
> optimize to stop expiring the current ioq, and we thought the current ioq belongs to root group. But
> in some cases, this assumption is not true. Consider the following scenario, if there is a child cgroup
> located in root cgroup, and task A is running in the child cgroup, and task A issues some IOs. Then we
> kill task A and remove the child cgroup, at this time, there is only root cgroup available. But the ioq
> is still under service, and from now on, this ioq won't expire because "only root" optimization.
> The following patch ensures the ioq do belongs to the root group if there's only root group existing.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Cool. Good catch Gui. Queued for next posting.

Thanks
Vivek

> ---
>  block/elevator-fq.c |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index b723c12..3f86552 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -2338,9 +2338,10 @@ void elv_reset_request_ioq(struct request_queue *q, struct request *rq)
>  	}
>  }
>  
> -static inline int is_only_root_group(void)
> +static inline int is_only_root_group(struct elv_fq_data *efqd)
>  {
> -	if (list_empty(&io_root_cgroup.css.cgroup->children))
> +	if (list_empty(&io_root_cgroup.css.cgroup->children) &&
> +	    efqd->busy_queues == 1 && efqd->root_group->ioq)
>  		return 1;
>  
>  	return 0;
> @@ -2383,7 +2384,7 @@ static void io_free_root_group(struct elevator_queue *e)
>  int elv_iog_should_idle(struct io_queue *ioq) { return 0; }
>  EXPORT_SYMBOL(elv_iog_should_idle);
>  
> -static inline int is_only_root_group(void)
> +static inline int is_only_root_group(struct elv_fq_data *efqd)
>  {
>  	return 1;
>  }
> @@ -2547,7 +2548,7 @@ elv_iosched_expire_ioq(struct request_queue *q, int slice_expired, int force)
>  	struct elevator_queue *e = q->elevator;
>  	struct io_queue *ioq = elv_active_ioq(q->elevator);
>  	int ret = 1;
> -
> +	
>  	if (e->ops->elevator_expire_ioq_fn) {
>  		ret = e->ops->elevator_expire_ioq_fn(q, ioq->sched_queue,
>  							slice_expired, force);
> @@ -2969,7 +2970,7 @@ void *elv_select_ioq(struct request_queue *q, int force)
>  	 * single queue ioschedulers (noop, deadline, AS).
>  	 */
>  
> -	if (is_only_root_group() && elv_iosched_single_ioq(q->elevator))
> +	if (is_only_root_group(efqd) && elv_iosched_single_ioq(q->elevator))
>  		goto keep_queue;
>  
>  	/* We are waiting for this group to become busy before it expires.*/
> @@ -3180,7 +3181,7 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
>  		 * unnecessary overhead.
>  		 */
>  
> -		if (is_only_root_group() &&
> +		if (is_only_root_group(ioq->efqd) &&
>  			elv_iosched_single_ioq(q->elevator)) {
>  			elv_log_ioq(efqd, ioq, "select: only root group,"
>  					" no expiry");
> -- 
> 1.5.4.rc3
> 
> 
> 
> 
> 
