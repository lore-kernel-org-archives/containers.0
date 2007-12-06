From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH] pid: sys_wait... fixes (v2)
Date: Thu, 6 Dec 2007 21:45:02 +0300
Message-ID: <20071206184502.GA11752@tv-sign.ru>
References: <m17ijsv7iu.fsf@ebiederm.dsl.xmission.com> <20071206170145.GA10674@tv-sign.ru> <m1k5nrsn18.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753151AbXLFSoV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1k5nrsn18.fsf_-_@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Pavel Emelyanov <xemul@openvz.org>, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

On 12/06, Eric W. Biederman wrote:
> 
> +static struct pid *task_pid_type(struct task_struct *task, enum pid_type type)
> +{
> +	struct pid *pid = NULL;
> +	if (type == PIDTYPE_PID)
> +		pid = task->pids[type].pid;
> +	else if (type < PIDTYPE_MAX)
> +		pid = task->group_leader->pids[type].pid;
> +	return pid;
> +}

Looks like a useful helper regardless.

> +static int eligible_child(enum pid_type type, struct pid *pid, int options,
> +			  struct task_struct *p)
>  {
>  	int err;
> -	struct pid_namespace *ns;
>  
> -	ns = current->nsproxy->pid_ns;
> -	if (pid > 0) {
> -		if (task_pid_nr_ns(p, ns) != pid)
> -			return 0;
> -	} else if (!pid) {
> -		if (task_pgrp_nr_ns(p, ns) != task_pgrp_vnr(current))
> -			return 0;
> -	} else if (pid != -1) {
> -		if (task_pgrp_nr_ns(p, ns) != -pid)
> +	if (type < PIDTYPE_MAX) {
> +		if (task_pid_type(p, type) != pid)
>  			return 0;
>  	}

Minor, minor nit.

If type == PIDTYPE_MAX, pid must be == NULL. but task_pid_type(PIDTYPE_PID)
also returns NULL. So we can just do

	if (task_pid_type(p, type) != pid)
		return 0;

Not that it really makes a difference though.

Oleg.

