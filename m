From: "Dmitry Adamushko" <dmitry.adamushko@gmail.com>
Subject: Re: [PATCH] Hookup group-scheduler with task container infrastructure
Date: Tue, 11 Sep 2007 00:28:51 +0200
Message-ID: <b647ffbd0709101528i7440a0f9m9837065a43e4a720@mail.gmail.com>
References: <20070910171049.GA16048@linux.vnet.ibm.com>
	 <Pine.LNX.4.64.0709101903220.5368@fbirervta.pbzchgretzou.qr>
	 <20070910172334.GB19100@linux.vnet.ibm.com>
	 <20070910102259.dc45a481.akpm@linux-foundation.org>
	 <20070910174649.GA16222@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965526AbXIJW3F@vger.kernel.org>
In-Reply-To: <20070910174649.GA16222@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: vatsa@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Jan Engelhardt <jengelh@computergmbh.de>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

On 10/09/2007, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com> wrote:
> On Mon, Sep 10, 2007 at 10:22:59AM -0700, Andrew Morton wrote:
> > objection ;)  "cpuctlr" isn't memorable.  Kernel code is write-rarely,
> > read-often.  "cpu_controller", please.  The extra typing is worth it ;)
>
> Ok! Here's the modified patch (against 2.6.23-rc4-mm1).
>
> [ ... ]
>
> +/* change task's runqueue when it moves between groups */
> +static void sched_move_task(struct container_subsys *ss, struct container *cont,
> +                       struct container *old_cont, struct task_struct *tsk)
> +{
> +       int on_rq;
> +       unsigned long flags;
> +       struct rq *rq;
> +
> +       rq = task_rq_lock(tsk, &flags);
> +

I guess, update_rq_clock(rq) should be placed here.

humm... do you really need deactivate/activate_task() here? 'rq' and
p->se.load.weight stay unchanged so enqueue/dequeue_task() would do a
job, no?
Although, I might be missing (definitely, as this part is not
completely clear to me yet) something important at this late hour :)


> +       on_rq = tsk->se.on_rq;
> +       if (on_rq)
> +               deactivate_task(rq, tsk, 0);
> +
> +       if (unlikely(rq->curr == tsk) && tsk->sched_class == &fair_sched_class)
> +               tsk->sched_class->put_prev_task(rq, tsk);
> +
> +       set_task_cfs_rq(tsk);
> +
> +       if (on_rq)
> +                activate_task(rq, tsk, 0);
> +
> +       if (unlikely(rq->curr == tsk) && tsk->sched_class == &fair_sched_class)
> +               tsk->sched_class->set_curr_task(rq);
> +
> +       task_rq_unlock(rq, &flags);
> +}
> +


-- 
Best regards,
Dmitry Adamushko
