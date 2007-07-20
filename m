From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] [V2] Define is_global_init() and
 is_container_init()
Date: Fri, 20 Jul 2007 15:41:13 -0700
Message-ID: <20070720154113.db9fb8a4.akpm@linux-foundation.org>
References: <20070719071206.GE10195@us.ibm.com>
	<20070719072158.GD28216@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S937664AbXGTWmN@vger.kernel.org>
In-Reply-To: <20070719072158.GD28216@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@us.ibm.com
Cc: linux-kernel@vger.kernel.org, Containers <containers@lists.osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>, Pavel Emelianov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

On Thu, 19 Jul 2007 00:21:58 -0700
sukadev@us.ibm.com wrote:

> --- lx26-22-rc6-mm1a.orig/kernel/pid.c	2007-07-16 12:55:15.000000000 -0700
> +++ lx26-22-rc6-mm1a/kernel/pid.c	2007-07-16 13:10:48.000000000 -0700
> @@ -69,6 +69,13 @@ struct pid_namespace init_pid_ns = {
>  	.last_pid = 0,
>  	.child_reaper = &init_task
>  };
> +EXPORT_SYMBOL(init_pid_ns);
> +
> +int is_global_init(struct task_struct *tsk)
> +{
> +	return tsk == init_pid_ns.child_reaper;
> +}
> +EXPORT_SYMBOL(is_global_init);

I don't immediately see why init_pid_ns was exported to modules.

It would need to be exported if is_global_init() was made static inline in a
header (which seems like a sensible thing to do), but it wasn't.
