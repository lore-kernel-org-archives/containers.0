From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: Signals to cinit
Date: Wed, 12 Nov 2008 10:53:19 -0600
Message-ID: <20081112165319.GC14572@us.ibm.com>
References: <20081101180505.GA24268@us.ibm.com> <20081110173839.GA11121@redhat.com> <20081110193228.GA15519@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753703AbYKLQxe@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081110193228.GA15519@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: sukadev@linux.vnet.ibm.com, "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, daniel@hozac.com, Nadia Derbey <Nadia.Derbey@bull.net>, clg@fr.ibm.com, Containers <containers@lists.osdl.org>, sukadev@us.ibm.com, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Oleg Nesterov (oleg@redhat.com):
> --- K-IS/kernel/signal.c~T	2008-11-10 19:21:17.000000000 +0100
> +++ K-IS/kernel/signal.c	2008-11-10 20:31:24.000000000 +0100
> @@ -798,11 +798,19 @@ static inline int legacy_queue(struct si
>  	return (sig < SIGRTMIN) && sigismember(&signals->signal, sig);
>  }
> 
> +#define SIG_FROM_USER	INT_MIN		/* MSB */
> +
>  static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
>  			int group)
>  {
>  	struct sigpending *pending;
>  	struct sigqueue *q;
> +	int from_ancestor_ns;
> +
> +	from_ancestor_ns = !is_si_special(info) &&
> +		(info->si_signo | SIG_FROM_USER) &&

I assume you mean '&'?

> +		/* if t can't see us we are from parent ns */
> +		task_pid_nr_ns(current, t->current->nsproxy->pid_ns) <= 0;

This doesn't look so bad...  (but still looking through followup emails)

-serge
