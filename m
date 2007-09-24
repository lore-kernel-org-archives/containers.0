From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/5] Cleanup code under CONFIG_FAIR_GROUP_SCHED
Date: Mon, 24 Sep 2007 09:53:44 -0700
Message-ID: <20070924095344.ee9ab10e.randy.dunlap@oracle.com>
References: <20070924163326.GA10291@linux.vnet.ibm.com>
	<20070924163937.GD10291@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070924163937.GD10291-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, efault-Mmb7MZpHnFY@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 24 Sep 2007 22:09:37 +0530 Srivatsa Vaddagiri wrote:

> With the view of supporting user-id based fair scheduling (and not just
> container-based fair scheduling), this patch renames several functions
> and makes them independent of whether they are being used for container
> or user-id based fair scheduling.
> 
> Also fix a problem reported by KAMEZAWA Hiroyuki (wrt allocating
> less-sized array for tg->cfs_rq[] and tf->se[]).
> 
> 
> Signed-off-by : Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Signed-off-by : Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> 
> ---
>  include/linux/sched.h |   12 +++
>  init/Kconfig          |   11 +--
>  kernel/sched.c        |  172 ++++++++++++++++++--------------------------------
>  kernel/sched_fair.c   |    5 +
>  4 files changed, 83 insertions(+), 117 deletions(-)
> 
> Index: current/init/Kconfig
> ===================================================================
> --- current.orig/init/Kconfig
> +++ current/init/Kconfig
> @@ -282,13 +282,12 @@ config CPUSETS
>  	  Say N if unsure.
>  
>  config FAIR_GROUP_SCHED
> -	bool "Fair group scheduler"
> -	depends on EXPERIMENTAL && CONTAINERS
> +	bool "Fair group cpu scheduler"

Can we have "CPU" instead of "cpu" ?


> +	default n
> +	depends on EXPERIMENTAL
>  	help
> -	  This option enables you to group tasks and control CPU resource
> -	  allocation to such groups.
> -
> -	  Say N if unsure.
> +	  This feature lets cpu scheduler recognize task groups and control cpu
> +	  bandwidth allocation to such task groups.
>  
>  config SYSFS_DEPRECATED
>  	bool "Create deprecated sysfs files"


---
~Randy
Phaedrus says that Quality is about caring.
