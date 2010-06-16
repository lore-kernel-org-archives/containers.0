From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Wed, 16 Jun 2010 20:04:53 +0400
Message-ID: <4C18F625.9040107@openvz.org>
References: <1276703910-16936-1-git-send-email-louis.rilling@kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1276703910-16936-1-git-send-email-louis.rilling@kerlabs.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Louis Rilling <louis.rilling@kerlabs.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

> +void proc_new_task(struct task_struct *task)
> +{
> +	struct pid *pid;
> +	int i;
> +
> +	if (!task->pid)
> +		return;
> +
> +	pid = task_pid(task);
> +	for (i = 0; i <= pid->level; i++)
> +		mntget(pid->numbers[i].ns->proc_mnt);

I feel I'm missing something significant, but this patch breaks
the mntget/mntput balance. Doesn't it?

> +}
