From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: Attaching PID 0 to a cgroup
Date: Tue, 1 Jul 2008 15:17:34 +0530
Message-ID: <20080701094734.GE3925@linux.vnet.ibm.com>
References: <20080701094545.GD3925@linux.vnet.ibm.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756500AbYGAJsU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080701094545.GD3925@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, lkml <linux-kernel@vger.kernel.org>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

[put in the wrong alias for containers list correcting it.]

On Tue, Jul 01, 2008 at 03:15:45PM +0530, Dhaval Giani wrote:
> Hi Paul,
> 
> Attaching PID 0 to a cgroup caused the current task to be attached to
> the cgroup. Looking at the code,
> 
>         if (pid) {
>                 rcu_read_lock();
>                 tsk = find_task_by_vpid(pid);
>                 if (!tsk || tsk->flags & PF_EXITING) {
>                         rcu_read_unlock();
>                         return -ESRCH;
>                 }
>                 get_task_struct(tsk);
>                 rcu_read_unlock();
> 
>                 if ((current->euid) && (current->euid != tsk->uid)
>                     && (current->euid != tsk->suid)) {
>                         put_task_struct(tsk);
>                         return -EACCES;
>                 }
>         } else {
>                 tsk = current;
>                 get_task_struct(tsk);
>         }
> 
> I was wondering, why this was done. It seems to be unexpected behavior.
> Wouldn't something like the following be a better response? (I've used
> EINVAL, but I can change it to ESRCH if that is better.)
> 
> ---
> cgroups: Don't allow PID 0 to be attached to a group
> 
> Currently when one trys to attach PID 0 to a cgroup, it attaches
> the current task. That is not expected behavior. It should return
> an error instead.
> 
> Signed-off-by: Dhaval Giani <dhaval@linux.vnet.ibm.com>
> 
> Index: linux-2.6/kernel/cgroup.c
> ===================================================================
> --- linux-2.6.orig/kernel/cgroup.c
> +++ linux-2.6/kernel/cgroup.c
> @@ -1309,8 +1309,7 @@ static int attach_task_by_pid(struct cgr
>  			return -EACCES;
>  		}
>  	} else {
> -		tsk = current;
> -		get_task_struct(tsk);
> +			return -EINVAL;
>  	}
>  
>  	ret = cgroup_attach_task(cgrp, tsk);
> -- 
> regards,
> Dhaval

-- 
regards,
Dhaval
