From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][-mm] Simple stats for cpu resource controller v4
Date: Mon, 12 May 2008 16:48:33 -0700
Message-ID: <20080512164833.8354abeb.akpm@linux-foundation.org>
References: <200804052339.46632.balajirrao@gmail.com>
	<200805030526.46750.balajirrao@gmail.com>
	<20080502171938.bcb27121.akpm@linux-foundation.org>
	<200805120148.37856.balajirrao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757369AbYELXt7@vger.kernel.org>
In-Reply-To: <200805120148.37856.balajirrao@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Balaji Rao <balajirrao@gmail.com>
Cc: dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org, menage@google.com, balbir@in.ibm.com, vatsa@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, dada1@cosmosbay.com
List-Id: containers.vger.kernel.org

On Mon, 12 May 2008 01:48:37 +0530
Balaji Rao <balajirrao@gmail.com> wrote:

> Hi Andrew,
> 
> Here's a version that uses percpu_counters and which actually works. The 
> only evil it contains is the check, 
> 
> 	if (percpu_counter_ready) {
> 		..
> 	}

There's no instance of "percpu_counter_ready" in the patch so I'm a bit
stumped.

> @@ -3837,6 +3858,16 @@ void account_user_time(struct task_struct *p, cputime_t cputime)
>  		cpustat->nice = cputime64_add(cpustat->nice, tmp);
>  	else
>  		cpustat->user = cputime64_add(cpustat->user, tmp);
> +
> +       /* Charge the task's group */
> +#ifdef CONFIG_CGROUP_SCHED
> +	{
> +		struct task_group *tg;
> +		tg = task_group(p);
> +		__cpu_cgroup_stat_add(tg->stat, CPU_CGROUP_STAT_UTIME,
> +				cputime_to_msecs(cputime));
> +	}
> +#endif
>  }
>  
>  /*
> @@ -3892,8 +3923,17 @@ void account_system_time(struct task_struct *p, int hardirq_offset,
>  		cpustat->irq = cputime64_add(cpustat->irq, tmp);
>  	else if (softirq_count())
>  		cpustat->softirq = cputime64_add(cpustat->softirq, tmp);
> -	else if (p != rq->idle)
> +	else if (p != rq->idle) {
>  		cpustat->system = cputime64_add(cpustat->system, tmp);
> +#ifdef CONFIG_CGROUP_SCHED
> +		{
> +			struct task_group *tg;
> +			tg = task_group(p);
> +			__cpu_cgroup_stat_add(tg->stat, CPU_CGROUP_STAT_STIME,
> +					cputime_to_msecs(cputime));
> +		}
> +	}
> +#endif

I'd suggest that the above be turned into calls to a helper function
which is a no-op if !CONFIG_CGROUP_SCHED.
