From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -mm] Hook up group scheduler with control groups
Date: Thu, 27 Sep 2007 12:00:33 -0700
Message-ID: <20070927120033.45915a61.randy.dunlap@oracle.com>
References: <20070927150624.GG4415@linux.vnet.ibm.com>
	<20070927104005.2ed0b81d.randy.dunlap@oracle.com>
	<20070927180415.GC5715@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759423AbXI0TC5@vger.kernel.org>
In-Reply-To: <20070927180415.GC5715@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: vatsa@linux.vnet.ibm.com, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, dmitry.adamushko@gmail.com, efault@gmx.de, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, 27 Sep 2007 23:34:15 +0530 Dhaval Giani wrote:

> > > +config RESOURCE_COUNTERS
> > > +	bool "Resource counters"
> > > +	help
> > > +	  This option enables controller independent resource accounting
> > > +          infrastructure that works with cgroups
> > 
> > Use tab + 2 spaces consistently for help text indentation.
> > End that sentence with a ".".
> > 
> 
> Hi,
> 
> hmmmm. So I looked into the sources with the patches applied, and they
> don't have an indentation problem. It looks fine. I'm not sure why the
> patch is getting generated like this though. Will fix up the '.' though.
> 
> Here it is,
> 
> Thanks,
> --
> 
> Signed-off-by : Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
> Signed-off-by : Dhaval Giani <dhaval@linux.vnet.ibm.com>
> 
> ---
>  include/linux/cgroup_subsys.h |    6 ++
>  init/Kconfig                  |   24 +++++---
>  kernel/sched.c                |  122 ++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 145 insertions(+), 7 deletions(-)
> 
> Index: current/include/linux/cgroup_subsys.h
> ===================================================================
> --- current.orig/include/linux/cgroup_subsys.h
> +++ current/include/linux/cgroup_subsys.h
> @@ -36,3 +36,9 @@ SUBSYS(mem_cgroup)
>  #endif
>  
>  /* */
> +
> +#ifdef CONFIG_FAIR_CGROUP_SCHED
> +SUBSYS(cpu_cgroup)
> +#endif
> +
> +/* */
> Index: current/init/Kconfig
> ===================================================================
> --- current.orig/init/Kconfig
> +++ current/init/Kconfig
> @@ -319,6 +319,13 @@ config CPUSETS
>  
>  	  Say N if unsure.
>  
> +config RESOURCE_COUNTERS
> +	bool "Resource counters"
> +	help
> +	  This option enables controller independent resource accounting

Above line is tab + 2 spaces (i.e., correct).

> +          infrastructure that works with cgroups.

Above line indent is 10 spaces (i.e., not correct).


> +	depends on CGROUPS
> +
>  config FAIR_GROUP_SCHED
>  	bool "Fair group CPU scheduler"
>  	default y

---
~Randy
Phaedrus says that Quality is about caring.
