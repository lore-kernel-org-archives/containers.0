From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] introduce task cgroup (#task restrictioon for
	prevent fork bomb by cgroup)
Date: Thu, 5 Jun 2008 14:57:45 +0530
Message-ID: <20080605092745.GA3734@linux.vnet.ibm.com>
References: <20080605132512.9C31.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755777AbYFEJ2f@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080605132512.9C31.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-Id: containers.vger.kernel.org

> +static int task_cgroup_max_tasks_write(struct cgroup *cgrp,
> +				       struct cftype *cftype,
> +				       s64 max_tasks)
> +{
> +	struct task_cgroup *taskcg;
> +
> +	if ((max_tasks > INT_MAX) ||
> +	    (max_tasks < INT_MIN))

It should be < -1 I think.

> +		return -EINVAL;
> +
> +	taskcg = task_cgroup_from_cgrp(cgrp);
> +
> +	spin_lock(&taskcg->lock);
> +	if (max_tasks < taskcg->nr_tasks)
> +		return -EBUSY;

Shouldn't you drop the lock here?

> +	taskcg->max_tasks = max_tasks;
> +	spin_unlock(&taskcg->lock);
> +
> +	return 0;
> +}

How does this controller affect performance? Do you have some numbers?

Thanks,
-- 
regards,
Dhaval
