From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] io-controller: Add io group reference handling for	request
Date: Fri, 15 May 2009 13:15:24 +0800
Message-ID: <4A0CFA6C.3080609@cn.fujitsu.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A03FF3C.4020506@cn.fujitsu.com>
	<20090508135724.GE7293@redhat.com>
	<e98e18940905081041r386e52a5q5a2b1f13f1e8c634@mail.gmail.com>
	<4A078051.5060702@cn.fujitsu.com>
	<20090511154127.GD6036@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090511154127.GD6036-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
>  }
> @@ -1462,20 +1462,27 @@ struct io_cgroup *get_iocg_from_bio(stru
>  /*
>   * Find the io group bio belongs to.
>   * If "create" is set, io group is created if it is not already present.
> + * If "curr" is set, io group is information is searched for current
> + * task and not with the help of bio.
> + *
> + * FIXME: Can we assume that if bio is NULL then lookup group for current
> + * task and not create extra function parameter ?
>   *
> - * Note: There is a narrow window of race where a group is being freed
> - * by cgroup deletion path and some rq has slipped through in this group.
> - * Fix it.
>   */
> -struct io_group *io_get_io_group_bio(struct request_queue *q, struct bio *bio,
> -					int create)
> +struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
> +					int create, int curr)

  Hi Vivek,

  IIUC we can get rid of curr, and just determine iog from bio. If bio is not NULL,
  get iog from bio, otherwise get it from current task.

>  {
>  	struct cgroup *cgroup;
>  	struct io_group *iog;
>  	struct elv_fq_data *efqd = &q->elevator->efqd;
>  
>  	rcu_read_lock();
> -	cgroup = get_cgroup_from_bio(bio);
> +
> +	if (curr)
> +		cgroup = task_cgroup(current, io_subsys_id);
> +	else
> +		cgroup = get_cgroup_from_bio(bio);
> +
>  	if (!cgroup) {
>  		if (create)
>  			iog = efqd->root_group;
> @@ -1500,7 +1507,7 @@ out:
>  	rcu_read_unlock();
>  	return iog;
>  }

-- 
Regards
Gui Jianfeng
