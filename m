From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] CGROUPS:  Group the CGROUPS Kconfig entries to be
	consecutive.
Date: Wed, 6 Aug 2008 13:01:12 +0900
Message-ID: <20080806130112.82c04664.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.LFD.1.10.0808041213540.2600@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.LFD.1.10.0808041213540.2600-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 4 Aug 2008 12:16:05 -0400 (EDT)
"Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org> wrote:

> 
> Move a few CGROUPS-related Kconfig entries so that they appear
> consecutively when running "make menuconfig."  This shouldn't affect
> the functionality.
> 
> Signed-off-by: Robert P. J. Day <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
> 
Seems nice look. (Below is an menuconfig image, I modified a bit for -mm)

    lqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk x
  x x    --- Control Group support                                        x x
  x x    [ ]   Example debug cgroup subsystem                             x x
  x x    [*]   Namespace cgroup subsystem                                 x x
  x x    [ ]   Device controller for cgroups                              x x
  x x    [*]   Cpuset support                                             x x
  x x    [*]   Simple CPU accounting cgroup subsystem                     x x
  x x    [*]   Resource counters                                          x x
  x x    [*]     Memory Resource Controller for Control Groups            x x
  x x    [ ]   Memory resource limit controls for cgroups                 x x

How do you think Paul ?

Off-topic: to Balbir.

How about "Aggregated Memory rlimit controls for cgroup" instead of
"Memory resource limit controls for cgroups" ?


Thanks,
-Kame
> ---
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index 7e6dae1..b51c133 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -317,6 +317,42 @@ config CPUSETS
> 
>  	  Say N if unsure.
> 
> +config CGROUP_CPUACCT
> +	bool "Simple CPU accounting cgroup subsystem"
> +	depends on CGROUPS
> +	help
> +	  Provides a simple Resource Controller for monitoring the
> +	  total CPU consumed by the tasks in a cgroup
> +
> +config RESOURCE_COUNTERS
> +	bool "Resource counters"
> +	help
> +	  This option enables controller independent resource accounting
> +          infrastructure that works with cgroups
> +	depends on CGROUPS
> +
> +config CGROUP_MEM_RES_CTLR
> +	bool "Memory Resource Controller for Control Groups"
> +	depends on CGROUPS && RESOURCE_COUNTERS
> +	select MM_OWNER
> +	help
> +	  Provides a memory resource controller that manages both page cache and
> +	  RSS memory.
> +
> +	  Note that setting this option increases fixed memory overhead
> +	  associated with each page of memory in the system by 4/8 bytes
> +	  and also increases cache misses because struct page on many 64bit
> +	  systems will not fit into a single cache line anymore.
> +
> +	  Only enable when you're ok with these trade offs and really
> +	  sure you need the memory resource controller.
> +
> +	  This config option also selects MM_OWNER config option, which
> +	  could in turn add some fork/exit overhead.
> +
> +config MM_OWNER
> +	bool
> +
>  #
>  # Architectures with an unreliable sched_clock() should select this:
>  #
> @@ -372,42 +408,6 @@ config CGROUP_SCHED
> 
>  endchoice
> 
> -config CGROUP_CPUACCT
> -	bool "Simple CPU accounting cgroup subsystem"
> -	depends on CGROUPS
> -	help
> -	  Provides a simple Resource Controller for monitoring the
> -	  total CPU consumed by the tasks in a cgroup
> -
> -config RESOURCE_COUNTERS
> -	bool "Resource counters"
> -	help
> -	  This option enables controller independent resource accounting
> -          infrastructure that works with cgroups
> -	depends on CGROUPS
> -
> -config MM_OWNER
> -	bool
> -
> -config CGROUP_MEM_RES_CTLR
> -	bool "Memory Resource Controller for Control Groups"
> -	depends on CGROUPS && RESOURCE_COUNTERS
> -	select MM_OWNER
> -	help
> -	  Provides a memory resource controller that manages both page cache and
> -	  RSS memory.
> -
> -	  Note that setting this option increases fixed memory overhead
> -	  associated with each page of memory in the system by 4/8 bytes
> -	  and also increases cache misses because struct page on many 64bit
> -	  systems will not fit into a single cache line anymore.
> -
> -	  Only enable when you're ok with these trade offs and really
> -	  sure you need the memory resource controller.
> -
> -	  This config option also selects MM_OWNER config option, which
> -	  could in turn add some fork/exit overhead.
> -
>  config SYSFS_DEPRECATED
>  	bool
> 
> 
> ========================================================================
> Robert P. J. Day
> Linux Consulting, Training and Annoying Kernel Pedantry:
>     Have classroom, will lecture.
> 
> http://crashcourse.ca                          Waterloo, Ontario, CANADA
> ========================================================================
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
