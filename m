From: "Dmitry Adamushko" <dmitry.adamushko@gmail.com>
Subject: Re: [BUG]: Crash with CONFIG_FAIR_CGROUP_SCHED=y
Date: Fri, 9 Nov 2007 09:45:21 +0100
Message-ID: <b647ffbd0711090045o5ebf4681q78f939f5c1e71fe1@mail.gmail.com>
References: <20071108234805.GA2240@us.ibm.com>
	 <20071109070214.GO3143@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751971AbXKIIpe@vger.kernel.org>
In-Reply-To: <20071109070214.GO3143@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: vatsa@linux.vnet.ibm.com
Cc: sukadev@us.ibm.com, balbir@in.ibm.com, Containers <containers@lists.osdl.org>, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, dhaval@linux.vnet.ibm.com, Ingo Molnar <mingo@elte.hu>, efault@gmx.de
List-Id: containers.vger.kernel.org

Hi Srivatsa,

> [ ... ]
> --
>
> current task is not present in its runqueue in case of sched_fair class
> tasks. Take care of this fact in rt_mutex_setprio(),
> sched_setscheduler() and sched_move_task() routines.
>
> Signed-off-by : Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
>
>
> ---
>  kernel/sched.c |   45 +++++++++++++++++++++++++--------------------
>  1 files changed, 25 insertions(+), 20 deletions(-)
>
> Index: current/kernel/sched.c
> ===================================================================
> --- current.orig/kernel/sched.c
> +++ current/kernel/sched.c
> @@ -3986,11 +3986,13 @@ void rt_mutex_setprio(struct task_struct
>         oldprio = p->prio;
>         on_rq = p->se.on_rq;
>         running = task_running(rq, p);
> -       if (on_rq) {
> +       if (on_rq)
>                 dequeue_task(rq, p, 0);
> -               if (running)
> -                       p->sched_class->put_prev_task(rq, p);
> -       }
> +       /* current task is not kept in its runqueue in case of sched_fair class.
> +        * Hence we need the 'on_rq?' and 'running?' tests to be separate.

Humm... the 'current' is not kept within the tree but
current->se.on_rq is supposed to be '1' ,
so the old code looks ok to me (at least for the 'leaf' elements).

Maybe you were able to get more useful oops on your site?


> --
> Regards,
> vatsa
>

-- 
Best regards,
Dmitry Adamushko
