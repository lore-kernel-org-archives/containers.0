From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was
	Vpid:)
Date: Wed, 15 Jun 2011 20:46:25 +0200
Message-ID: <20110615184625.GA15573@redhat.com>
References: <20110615145527.4016.70157.stgit@bahia.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110615145527.4016.70157.stgit@bahia.local>
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Kurz <gkurz@fr.ibm.com>
Cc: akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, serge@hallyn.com, daniel.lezcano@free.fr, ebiederm@xmission.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

On 06/15, Greg Kurz wrote:
>
> @@ -176,6 +177,17 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
>  		if (tracer)
>  			tpid = task_pid_nr_ns(tracer, ns);
>  	}
> +	actpid = 0;
> +	sighand = rcu_dereference(p->sighand);
> +	if (sighand) {
> +		struct pid_namespace *pid_ns;
> +		unsigned long flags;
> +		spin_lock_irqsave(&sighand->siglock, flags);

Well. This is not exactly right. We have lock_task_sighand() for this.

But. Why do you need ->siglock? Why rcu_read_lock() is not enough?

Hmm. You don't even need pid_ns afaics, you could simply look at
pid->numbers[pid->level].

Oleg.
