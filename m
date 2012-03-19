From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 06/10] cgroup: convert memcg controller to the new cftype
	interface
Date: Mon, 19 Mar 2012 13:26:02 +0900
Message-ID: <4F66B55A.8020307@jp.fujitsu.com>
References: <1331940963-15756-1-git-send-email-tj@kernel.org>
	<1331940963-15756-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1331940963-15756-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/03/17 8:35), Tejun Heo wrote:

> Convert memcg to use the new cftype based interface. memcg is rather
> special in that
> 
> * memsw_cgroup_files creation is dependent on do_swap_account.
> 
> * ->populate() is abused for mem_cgroup_sockets_init().
> 
> memsw_cgroup_files is converted to use CGROUP_SUBSYS_CFTYPES_COND(),
> where the condition is really_do_swap_account.
> 
> ->populate() is preserved for register_kmem_files() invocation but I
> strongly urge moving the initialization to the tail of ->create().  If
> there's something which can't be done from ->create(), which isn't
> clear from the comment, please let me know.
> 

Okay, then, cgroup files are created in kernel/cgroup.c and memcg just
registers entries.



> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Cc: Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> ---
>  mm/memcontrol.c           |   31 ++++++-------------------------
>  net/ipv4/tcp_memcontrol.c |    8 ++++----
>  2 files changed, 10 insertions(+), 29 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ae2f0a8..f2221ce 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4665,7 +4665,9 @@ static struct cftype mem_cgroup_files[] = {
>  		.mode = S_IRUGO,
>  	},
>  #endif
> +	{ },	/* terminate */
>  };
> +CGROUP_SUBSYS_CFTYPES(mem_cgroup_subsys, mem_cgroup_files);
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  static struct cftype memsw_cgroup_files[] = {
> @@ -4694,20 +4696,10 @@ static struct cftype memsw_cgroup_files[] = {
>  		.trigger = mem_cgroup_reset,
>  		.read_u64 = mem_cgroup_read,
>  	},
> +	{ }	/* terminate */
>  };
> -
> -static int register_memsw_files(struct cgroup *cont, struct cgroup_subsys *ss)
> -{
> -	if (!do_swap_account)
> -		return 0;
> -	return cgroup_add_files(cont, ss, memsw_cgroup_files,
> -				ARRAY_SIZE(memsw_cgroup_files));
> -};
> -#else
> -static int register_memsw_files(struct cgroup *cont, struct cgroup_subsys *ss)
> -{
> -	return 0;
> -}
> +CGROUP_SUBSYS_CFTYPES_COND(mem_cgroup_subsys, memsw_cgroup_files,
> +			   really_do_swap_account);


I'm sorry but why you use really_do_swap_account instead of do_swap_account ?

Thanks,
-Kame
