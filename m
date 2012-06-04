From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 10/10] blkcg: implement per-blkg request allocation
Date: Mon, 4 Jun 2012 16:26:20 -0400
Message-ID: <20120604202620.GM4458@redhat.com>
References: <1338793697-10735-1-git-send-email-tj@kernel.org>
	<1338793697-10735-11-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1338793697-10735-11-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 04, 2012 at 12:08:17AM -0700, Tejun Heo wrote:
> Currently, request_queue has one request_list to allocate requests
> from regardless of blkcg of the IO being issued.  When the unified
> request pool is used up, cfq proportional IO limits become meaningless
> - whoever grabs the next request being freed wins the race regardless
> of the configured weights.
> 
> This can be easily demonstrated by creating a blkio cgroup w/ very low
> weight, put a program which can issue a lot of random direct IOs there
> and running a sequential IO from a different cgroup.  As soon as the
> request pool is used up, the sequential IO bandwidth crashes.
> 
> This patch implements per-blkg request_list.  Each blkg has its own
> request_list and any IO allocates its request from the matching blkg
> making blkcgs completely isolated in terms of request allocation.
> 
> * Root blkcg uses the request_list embedded in each request_queue,
>   which was renamed to @q->root_rl from @q->rq.  While making blkcg rl
>   handling a bit harier, this enables avoiding most overhead for root
>   blkcg.
> 
> * Queue fullness is properly per request_list but bdi isn't blkcg
>   aware yet, so congestion state currently just follows the root
>   blkcg.  As writeback isn't aware of blkcg yet, this works okay for
>   async congestion but readahead may get the wrong signals.  It's
>   better than blkcg completely collapsing with shared request_list but
>   needs to be improved with future changes.

Hi Tejun,

It might be worth to update Documentation/block/queue-sysfs.txt and update
nr_requests description to reflect that fact that it is now a per queue
per cgroup/group limit and not per queue limit.

Also it will be good to explicitly mention in changelog that after this
patch allowing non-priviliged users to create blkio cgroups is dangerous
as they can create tons of cgroups, doing IO in those cgroups and locking
non-reclaimable kernel memory.

Otherwise this patch and series looks good to me.

Acked-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Thanks
Vivek
