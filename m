From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 02/10] Task Containers(V11):  Add tasks file interface
Date: Fri, 20 Jul 2007 16:20:10 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707201616240.9702@d.namei>
References: <20070720183152.637820000@menage.corp.google.com>
 <20070720191247.556709000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933308AbXGTUUj@vger.kernel.org>
In-Reply-To: <20070720191247.556709000@menage.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: menage@google.com
Cc: akpm@linux-foundation.org, dev@sw.ru, xemul@sw.ru, serue@us.ibm.com, vatsa@in.ibm.com, ebiederm@xmission.com, haveblue@us.ibm.com, svaidy@linux.vnet.ibm.com, balbir@in.ibm.com, pj@sgi.com, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, rohitseth@google.com, mbligh@google.com, containers@lists.osdl.org, devel@openvz.org
List-Id: containers.vger.kernel.org

On Fri, 20 Jul 2007, menage@google.com wrote:

> +/*
> + * Attach task with pid 'pid' to container 'cont'. Call with
> + * container_mutex, may take task_lock of task
> + */
> +static int attach_task_by_pid(struct container *cont, char *pidbuf)
> +{
> +	pid_t pid;
> +	struct task_struct *tsk;
> +	int ret;
> +
> +	if (sscanf(pidbuf, "%d", &pid) != 1)
> +		return -EIO;
> +
> +	if (pid) {
> +		rcu_read_lock();
> +		tsk = find_task_by_pid(pid);
> +		if (!tsk || tsk->flags & PF_EXITING) {
> +			rcu_read_unlock();
> +			return -ESRCH;
> +		}
> +		get_task_struct(tsk);
> +		rcu_read_unlock();
> +
> +		if ((current->euid) && (current->euid != tsk->uid)
> +		    && (current->euid != tsk->suid)) {
> +			put_task_struct(tsk);
> +			return -EACCES;

I wonder if we should allow CAP_SYS_ADMIN to do this, too.

-- 
James Morris
<jmorris@namei.org>
