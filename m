From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: Add io group reference handling for request
Date: Fri, 15 May 2009 10:01:13 -0400
Message-ID: <20090515140113.GA19350__32476.5064208352$1242396388$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A03FF3C.4020506@cn.fujitsu.com>
	<20090508135724.GE7293@redhat.com>
	<e98e18940905081041r386e52a5q5a2b1f13f1e8c634@mail.gmail.com>
	<4A078051.5060702@cn.fujitsu.com>
	<20090511154127.GD6036@redhat.com>
	<4A0D1C55.9040700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A0D1C55.9040700-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, May 15, 2009 at 03:40:05PM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> ...
> > Ok, here is the patch which gets rid of rq->iog and rq->rl fields. Good to
> > see some code and data structures trimming. It seems to be working fine for me.
> > 
> > 
> > o Get rid of rq->iog field and rq->rl fields. request descriptor stores
> >   the pointer the the queue it belongs to (rq->ioq) and from the io queue one
> >   can determine the group queue belongs to hence request belongs to. Thanks
> >   to Nauman for the idea.
> > 
> > o There are couple of places where rq->ioq information is not present yet
> >   as request and queue are being setup. In those places "bio" is passed 
> >   around as function argument to determine the group rq will go into. I
> >   did not pass "iog" as function argument becuase when memory is scarce,
> >   we can release queue lock and sleep to wait for memory to become available
> >   and once we wake up, it is possible that io group is gone. Passing bio
> >   around helps that one shall have to remap bio to right group after waking
> >   up. 
> > 
> > o Got rid of io_lookup_io_group_current() function and merged it with
> >   io_get_io_group() to also take care of looking for group using current
> >   task info and not from bio.
> 
> Hi Vivek,
> 
> This patch gets rid of "curr" from io_get_io_group, and seems to be 
> working fine for me.
> 

Thanks Gui. Can't think of a reason why "curr" should be a separate
function argument. I could only find blk_get_request() to be calling
io_get_io_group() without any bio passed. I think even in that case
determining the group from task should not hurt, I guess.

I will apply the patch.  Couple of comments inline.

> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/cfq-iosched.c |   12 ++++++------
>  block/elevator-fq.c |   16 ++++++++--------
>  block/elevator-fq.h |    2 +-
>  3 files changed, 15 insertions(+), 15 deletions(-)
> 
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index c0bb8db..bf87843 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -196,7 +196,7 @@ static struct cfq_queue *cic_bio_to_cfqq(struct cfq_data *cfqd,
>  		 * async bio tracking is enabled and we are not caching
>  		 * async queue pointer in cic.
>  		 */
> -		iog = io_get_io_group(cfqd->queue, bio, 0, 0);
> +		iog = io_get_io_group(cfqd->queue, bio, 0);
>  		if (!iog) {
>  			/*
>  			 * May be this is first rq/bio and io group has not
> @@ -1294,7 +1294,7 @@ static void changed_cgroup(struct io_context *ioc, struct cfq_io_context *cic)
>  
>  	spin_lock_irqsave(q->queue_lock, flags);
>  
> -	iog = io_get_io_group(q, NULL, 0, 1);
> +	iog = io_get_io_group(q, NULL, 0);
>  
>  	if (async_cfqq != NULL) {
>  		__iog = cfqq_to_io_group(async_cfqq);
> @@ -1346,9 +1346,9 @@ retry:
>  	 * back.
>  	 */
>  	if (bio)
> -		iog = io_get_io_group(q, bio, 1, 0);
> +		iog = io_get_io_group(q, bio, 1);
>  	else
> -		iog = io_get_io_group(q, NULL, 1, 1);
> +		iog = io_get_io_group(q, NULL, 1);
>  

Can we now change above to single statement

		io_get_io_group(q, bio, 1);
if bio is present, we will determine the group from that otherwise from
curret task context.


>  	cic = cfq_cic_lookup(cfqd, ioc);
>  	/* cic always exists here */
> @@ -1469,9 +1469,9 @@ cfq_get_queue(struct cfq_data *cfqd, struct bio *bio, int is_sync,
>  	struct io_group *iog = NULL;
>  
>  	if (bio)
> -		iog = io_get_io_group(cfqd->queue, bio, 1, 0);
> +		iog = io_get_io_group(cfqd->queue, bio, 1);
>  	else
> -		iog = io_get_io_group(cfqd->queue, NULL, 1, 1);
> +		iog = io_get_io_group(cfqd->queue, NULL, 1);
>  

Same here. Get rid of "if" condition.

>  	if (!is_sync) {
>  		async_cfqq = io_group_async_queue_prio(iog, ioprio_class,
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index 9b7319e..951c163 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -1006,7 +1006,7 @@ struct request_list *io_group_get_request_list(struct request_queue *q,
>  {
>  	struct io_group *iog;
>  
> -	iog = io_get_io_group(q, bio, 1, 0);
> +	iog = io_get_io_group(q, bio, 1);
>  	BUG_ON(!iog);
>  	return &iog->rl;
>  }
> @@ -1470,7 +1470,7 @@ struct io_cgroup *get_iocg_from_bio(struct bio *bio)
>   *
>   */
>  struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
> -					int create, int curr)
> +					int create)
>  {
>  	struct cgroup *cgroup;
>  	struct io_group *iog;
> @@ -1478,7 +1478,7 @@ struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
>  
>  	rcu_read_lock();
>  
> -	if (curr)
> +	if (!bio)
>  		cgroup = task_cgroup(current, io_subsys_id);
>  	else
>  		cgroup = get_cgroup_from_bio(bio);
> @@ -1959,7 +1959,7 @@ int io_group_allow_merge(struct request *rq, struct bio *bio)
>  		return 1;
>  
>  	/* Determine the io group of the bio submitting task */
> -	iog = io_get_io_group(q, bio, 0, 0);
> +	iog = io_get_io_group(q, bio, 0);
>  	if (!iog) {
>  		/* May be task belongs to a differet cgroup for which io
>  		 * group has not been setup yet. */
> @@ -2000,9 +2000,9 @@ int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
>  retry:
>  	/* Determine the io group request belongs to */
>  	if (bio)
> -		iog = io_get_io_group(q, bio, 1, 0);
> +		iog = io_get_io_group(q, bio, 1);
>  	else
> -		iog = io_get_io_group(q, bio, 1, 1);
> +		iog = io_get_io_group(q, NULL, 1);
>  

"if" not required now.

Thanks
Vivek
