From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH] Allow cpusets to be configured/built on non-SMP systems
Date: Tue, 3 Mar 2009 09:07:34 +0100
Message-ID: <20090303080734.GB11484__49177.1037145101$1236067938$gmane$org@elte.hu>
References: <20090303013432.11211.18662.stgit@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090303013432.11211.18662.stgit-B63HFAS8fGlSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org


* Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> Allow cpusets to be configured/built on non-SMP systems
> 
> Currently it's impossible to build cpusets under UML on x86-64, since
> cpusets depends on SMP and x86-64 UML doesn't support SMP.
> 
> There's code in cpusets that doesn't depend on SMP.  This patch
> surrounds the minimum amount of cpusets code with #ifdef CONFIG_SMP in
> order to allow cpusets to build/run on UP systems (for testing
> purposes under UML).
> 
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> ---
> 
>  init/Kconfig    |    2 +-
>  kernel/cpuset.c |   14 ++++++++++++++
>  2 files changed, 15 insertions(+), 1 deletions(-)
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index 92d2c64..3f20aa2 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -477,7 +477,7 @@ config CGROUP_DEVICE
>  
>  config CPUSETS
>  	bool "Cpuset support"
> -	depends on SMP && CGROUPS
> +	depends on CGROUPS
>  	help
>  	  This option will let you create and manage CPUSETs which
>  	  allow dynamically partitioning a system into sets of CPUs and
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index a46d693..b4d12d8 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
>
> @@ -517,6 +517,8 @@ static int validate_change(const struct cpuset *cur, const struct cpuset *trial)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_SMP
> +
>  /*
>   * Helper routine for generate_sched_domains().
>   * Do cpusets a, b have overlapping cpus_allowed masks?
> @@ -811,6 +813,16 @@ static void do_rebuild_sched_domains(struct work_struct *unused)
>  
>  	put_online_cpus();
>  }
> +#else

Please use:

> +#else /* !CONFIG_SMP: */

to show that it's the UP branch - even if the #ifdef itself has 
scrolled off from screen already.

> +static void do_rebuild_sched_domains(struct work_struct *unused)
> +{
> +}
> +
> +static int generate_sched_domains(struct cpumask **domains,
> +			struct sched_domain_attr **attributes)
> +{
> +}
> +#endif // CONFIG_SMP

Please dont use C++ comments.

Looks good otherwise. (Btw., please try to Cc: PeterZ and me to 
cpusets patches in the future, especially when it affects the 
scheduler.)

	Ingo
