From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 02/11] cpuset: add cs->real_cpus_allowed and
	cs->real_mems_allowed
Date: Wed, 21 Aug 2013 09:22:14 -0400
Message-ID: <20130821132214.GC19286@mtj.dyndns.org>
References: <52148F52.0@huawei.com>
 <52148F6F.4070507@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52148F6F.4070507-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 21, 2013 at 05:59:11PM +0800, Li Zefan wrote:
> We're going to have separate user-configured masks and effective ones.
> 
> At last configured masks can only be changed by writing cpuset.cpus

I suppose you mean "eventually" by "at last"?

> and cpuset.mems, and they won't be restricted by parent cpuset. While
> effective masks reflect cpu/memory hotplug and hierachical restriction.
> 
> This patch adds and initializes the effective masks. The effective
> masks of the top cpuset is the same with configured masks, and a child
> cpuset inherites its parent's effective masks.
> 
> This won't introduce behavior change.
> 
> Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/cpuset.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 46 insertions(+), 11 deletions(-)
> 
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 70ab3fd..404fea5 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -81,8 +81,14 @@ struct cpuset {
>  	struct cgroup_subsys_state css;
>  
>  	unsigned long flags;		/* "unsigned long" so bitops work */
> -	cpumask_var_t cpus_allowed;	/* CPUs allowed to tasks in cpuset */
> -	nodemask_t mems_allowed;	/* Memory Nodes allowed to tasks */
> +
> +	/* user-configured CPUs and Memory Nodes allow to tasks */
> +	cpumask_var_t cpus_allowed;
> +	nodemask_t mems_allowed;
> +
> +	/* effective CPUs and Memory Nodes allow to tasks */
> +	cpumask_var_t real_cpus_allowed;
> +	nodemask_t real_mems_allowed;

Can we stick to the term "effective"?  If it's too long, we can drop
the "allowed" postfix, which is pretty superflous.  effective_cpus and
effective_mems should work, right?  For local vars, ecpus and emems
should do.

Thanks.

-- 
tejun
