From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH 5/5] Move alloc_pid call to copy_process
Date: Sun, 15 Jul 2007 16:36:00 +0400
Message-ID: <20070715123600.GA210@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759789AbXGOMf5@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Cedric Le Goater <clg@fr.ibm.com>, Dave Hansen <haveblue@us.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Herbert Poetzel <herbert@13thfloor.at>, Pavel Emelianov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
>
> --- lx26-22-rc6-mm1.orig/kernel/pid.c	2007-07-13 18:23:55.000000000 -0700
> +++ lx26-22-rc6-mm1/kernel/pid.c	2007-07-13 18:23:55.000000000 -0700
> @@ -206,6 +206,10 @@ fastcall void free_pid(struct pid *pid)
>  	/* We can be called with write_lock_irq(&tasklist_lock) held */
>  	unsigned long flags;
>  
> +	/* check this here to keep copy_process() cleaner */
> +	if (unlikely(pid == &init_struct_pid))
> +		return;
> +
>  	spin_lock_irqsave(&pidmap_lock, flags);
>  	hlist_del_rcu(&pid->pid_chain);
>  	spin_unlock_irqrestore(&pidmap_lock, flags);
> @@ -214,13 +218,17 @@ fastcall void free_pid(struct pid *pid)
>  	call_rcu(&pid->rcu, delayed_put_pid);
>  }
>  
> -struct pid *alloc_pid(void)
> +struct pid *alloc_pid(enum copy_process_type copy_src)
>  {
>  	struct pid *pid;
>  	enum pid_type type;
>  	int nr = -1;
>  	struct pid_namespace *ns;
>  
> +	/* check this here to keep copy_process() cleaner */
> +	if (unlikely(copy_src == COPY_IDLE_PROCESS))
> +		return &init_struct_pid;
> +
>  	ns = task_active_pid_ns(current);
>  	pid = kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL);
>  	if (!pid)

Ugh. I am sorry! but imho this is so ugly :(

Could you please give more details why we need this change? Even if we really
need this, can't we do these checks in copy_process() ? free_pid(&init_struct_pid)
can only happen when fork fails, this is a slow path, and copy_process() knows
copy_src.

Oleg.
