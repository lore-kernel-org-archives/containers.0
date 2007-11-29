From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] sched: cpu accounting controller
Date: Thu, 29 Nov 2007 11:30:35 -0800
Message-ID: <20071129113035.bbdf35db.akpm@linux-foundation.org>
References: <6599ad830711122125u576e85a6w428466a0ab46dbc6@mail.gmail.com>
	<20071113060038.GC3359@linux.vnet.ibm.com>
	<6599ad830711122205g88aae4fua8dd76cf6e8ab84d@mail.gmail.com>
	<20071113074805.GA13499@linux.vnet.ibm.com>
	<6599ad830711122357i60482475o10c0e0935a9e00c0@mail.gmail.com>
	<20071129191737.GH5681@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071129191737.GH5681-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, skumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 30 Nov 2007 00:47:37 +0530
Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> On Mon, Nov 12, 2007 at 11:57:03PM -0800, Paul Menage wrote:
> > > Regarding your concern about tracking cpu usage in different ways, it
> > > could be mitigated if we have cpuacct controller track usage as per
> > > information present in a task's sched entity structure
> > > (tsk->se.sum_exec_runtime) i.e call cpuacct_charge() from
> > > __update_curr() which would accumulate the execution time of the
> > > group in a SMP friendly manner (i.e dump it in a per-cpu per-group counter
> > > first and then aggregate to a global per-group counter).
> > 
> > That seems more reasonable than the current approach in cpu_acct.c
> 
> Paul,
> 	Sorry about the delay in getting back to this thread. I realized
> very recently that cpuacct controller has been removed from Linus's tree
> and have attempted to rework it as per our discussions.
> 
> Linus/Ingo,
> 	Commit cfb5285660aad4931b2ebbfa902ea48a37dfffa1 removed a usefull 
> feature for us, which provided a cpu accounting resource controller. This 
> feature would be usefull if someone wants to group tasks only for accounting 
> purpose and doesnt really want to exercise any control over their cpu 
> consumption.
> 
> The patch below reintroduces the feature. It is based on Paul Menage's
> original patch (Commit 62d0df64065e7c135d0002f069444fbdfc64768f), with
> these differences:
> 
> 	- Removed load average information. I felt it needs
> 	  more thought (esp to deal with SMP and virtualized platforms)
> 	  and can be added for 2.6.25 after more discussions.
> 	- Convert group cpu usage to be nanosecond accurate (as rest
> 	  of the cfs stats are) and invoke cpuacct_charge() from 
> 	  the respective scheduler classes
> 
> The patch also modifies the cpu controller not to provide the same
> accounting information.
>
> ...
> 
> 	- Make the accounting scalable on SMP systems (perhaps
>  	  for 2.6.25)

That sounds like a rather important todo.  How bad is it now?
 
> Index: current/include/linux/cpu_acct.h
> ===================================================================
> --- /dev/null
> +++ current/include/linux/cpu_acct.h
> @@ -0,0 +1,14 @@
> +
> +#ifndef _LINUX_CPU_ACCT_H
> +#define _LINUX_CPU_ACCT_H
> +
> +#include <linux/cgroup.h>
> +#include <asm/cputime.h>
> +
> +#ifdef CONFIG_CGROUP_CPUACCT
> +extern void cpuacct_charge(struct task_struct *, u64 cputime);

                                                  ^ no "p"

> +#else
> +static inline void cpuacct_charge(struct task_struct *p, u64 cputime) {}

                                                         ^ "p"
> +#endif

Personally I think "p" is a dopey name - we tend to standardise on "tsk"
for this.

> --- /dev/null
> +++ current/kernel/cpu_acct.c
> @@ -0,0 +1,103 @@
> +/*
> + * kernel/cpu_acct.c - CPU accounting cgroup subsystem
> + *
> + * Copyright (C) Google Inc, 2006
> + *
> + * Developed by Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org) and Balbir Singh
> + * (balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org)
> + *
> + */
> +
> +/*
> + * Example cgroup subsystem for reporting total CPU usage of tasks in a
> + * cgroup.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/cgroup.h>
> +#include <linux/fs.h>
> +#include <linux/rcupdate.h>
> +
> +#include <asm/div64.h>

I don't think this inclusion is needed?

> +struct cpuacct {
> +	struct cgroup_subsys_state css;
> +	spinlock_t lock;
> +	/* total time used by this class (in nanoseconds) */
> +	u64 time;
> +};
> +
> +struct cgroup_subsys cpuacct_subsys;

This can be made static.
