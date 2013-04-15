From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] memcg: force use_hierarchy if sane_behavior
Date: Sun, 14 Apr 2013 20:06:47 -0500
Message-ID: <20130415010647.GE8408@sergelap>
References: <1365808259-31073-1-git-send-email-tj@kernel.org>
	<1365808259-31073-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1365808259-31073-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> Turn on use_hierarchy by default if sane_behavior is specified and
> don't create .use_hierarchy file.
> 
> It is debatable whether to remove .use_hierarchy file or make it ro as
> the former could make transition easier in certain cases; however, the
> behavior changes which will be gated by sane_behavior are intensive
> including changing basic meaning of certain control knobs in a few
> controllers and I don't really think keeping this piece would make
> things easier in any noticeable way, so let's remove it.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> ---
>  include/linux/cgroup.h |  3 +++
>  mm/memcontrol.c        | 13 +++++++++++++
>  2 files changed, 16 insertions(+)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 9c300ad..c562e33 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -269,6 +269,9 @@ enum {
>  	 *
>  	 * - Remount is disallowed.
>  	 *
> +	 * - memcg: use_hierarchy is on by default and the cgroup file for
> +	 *   the flag is not created.
> +	 *
>  	 * The followings are planned changes.
>  	 *
>  	 * - release_agent will be disallowed once replacement notification
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9715c0c..a651131 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5814,6 +5814,7 @@ static struct cftype mem_cgroup_files[] = {
>  	},
>  	{
>  		.name = "use_hierarchy",
> +		.flags = CFTYPE_INSANE,
>  		.write_u64 = mem_cgroup_hierarchy_write,
>  		.read_u64 = mem_cgroup_hierarchy_read,
>  	},
> @@ -6784,6 +6785,17 @@ static void mem_cgroup_move_task(struct cgroup *cont,
>  }
>  #endif
>  
> +/*
> + * Cgroup retains root cgroups across [un]mount cycles making it necessary
> + * to verify sane_behavior flag on each mount attempt.
> + */
> +static void mem_cgroup_bind(struct cgroup *root)
> +{
> +	/* use_hierarchy is forced with sane_behavior */
> +	if (cgroup_sane_behavior(root))
> +		mem_cgroup_from_cont(root)->use_hierarchy = true;
> +}
> +
>  struct cgroup_subsys mem_cgroup_subsys = {
>  	.name = "memory",
>  	.subsys_id = mem_cgroup_subsys_id,
> @@ -6794,6 +6806,7 @@ struct cgroup_subsys mem_cgroup_subsys = {
>  	.can_attach = mem_cgroup_can_attach,
>  	.cancel_attach = mem_cgroup_cancel_attach,
>  	.attach = mem_cgroup_move_task,
> +	.bind = mem_cgroup_bind,
>  	.base_cftypes = mem_cgroup_files,
>  	.early_init = 0,
>  	.use_id = 1,
> -- 
> 1.8.1.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
