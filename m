From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 21/25] io-controller: Per cgroup request descriptor support
Date: Tue, 21 Jul 2009 13:37:56 +0800
Message-ID: <4A655434.5060404__2032.34206787801$1248154789$gmane$org@cn.fujitsu.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<1246564917-19603-22-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246564917-19603-22-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> o Currently a request queue has got fixed number of request descriptors for
>   sync and async requests. Once the request descriptors are consumed, new
>   processes are put to sleep and they effectively become serialized. Because
>   sync and async queues are separate, async requests don't impact sync ones
>   but if one is looking for fairness between async requests, that is not
>   achievable if request queue descriptors become bottleneck.
> 
> o Make request descriptor's per io group so that if there is lots of IO
>   going on in one cgroup, it does not impact the IO of other group.
> 
> o This is just one relatively simple way of doing things. This patch will
>   probably change after the feedback. Folks have raised concerns that in
>   hierchical setup, child's request descriptors should be capped by parent's
>   request descriptors. May be we need to have per cgroup per device files
>   in cgroups where one can specify the upper limit of request descriptors
>   and whenever a cgroup is created one needs to assign request descritor
>   limit making sure total sum of child's request descriptor is not more than
>   of parent.
> 
>   I guess something like memory controller. Anyway, that would be the next
>   step. For the time being, we have implemented something simpler as follows.
> 
> o This patch implements the per cgroup request descriptors. request pool per
>   queue is still common but every group will have its own wait list and its
>   own count of request descriptors allocated to that group for sync and async
>   queues. So effectively request_list becomes per io group property and not a
>   global request queue feature.
> 
> o Currently one can define q->nr_requests to limit request descriptors
>   allocated for the queue. Now there is another tunable q->nr_group_requests
>   which controls the requests descriptr limit per group. q->nr_requests
>   supercedes q->nr_group_requests to make sure if there are lots of groups
>   present, we don't end up allocating too many request descriptors on the
>   queue.
> 

  Hi Vivek,

  In order to prevent q->nr_requests from becoming the bottle-neck of allocating
  requests, whether we can update nr_requests accordingly when allocating or removing
  a cgroup?

-- 
Regards
Gui Jianfeng
