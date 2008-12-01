From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] Unused check for thread group leader in
	mem_cgroup_move_task
Date: Mon, 1 Dec 2008 13:30:30 +0900
Message-ID: <20081201133030.0a330c7b.kamezawa.hiroyu__13400.3768944696$1228106021$gmane$org@jp.fujitsu.com>
References: <200811291259.27681.knikanth@suse.de>
	<20081201101208.08e0aa98.kamezawa.hiroyu@jp.fujitsu.com>
	<200812010951.36392.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200812010951.36392.knikanth-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, nikanth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 1 Dec 2008 09:51:35 +0530
Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> wrote:

> Ok. Then should we remove the unused code which simply checks for thread group 
> leader but does nothing?
>  
> Thanks
> Nikanth
> 
Hmm, it seem that code is obsolete. thanks.
Balbir, how do you think ?

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Anyway we have to visit here, again.


> Remove the unused test for thread group leader in mem_cgroup_move_task.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
> 
> ---
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 866dcc7..8e9287d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1151,14 +1151,6 @@ static void mem_cgroup_move_task(struct cgroup_subsys 
> *ss,
>  	mem = mem_cgroup_from_cont(cont);
>  	old_mem = mem_cgroup_from_cont(old_cont);
>  
> -	/*
> -	 * Only thread group leaders are allowed to migrate, the mm_struct is
> -	 * in effect owned by the leader
> -	 */
> -	if (!thread_group_leader(p))
> -		goto out;
> -
> -out:
>  	mmput(mm);
>  }
>  
> 
> 
