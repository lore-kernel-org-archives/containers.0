From: "Dmitry Adamushko" <dmitry.adamushko@gmail.com>
Subject: Re: [PATCH] Hookup group-scheduler with task container infrastructure
Date: Tue, 11 Sep 2007 11:53:51 +0200
Message-ID: <b647ffbd0709110253y7d9564c4j88aa134330e2a292@mail.gmail.com>
References: <20070910171049.GA16048@linux.vnet.ibm.com>
	 <Pine.LNX.4.64.0709101903220.5368@fbirervta.pbzchgretzou.qr>
	 <20070910172334.GB19100@linux.vnet.ibm.com>
	 <20070910102259.dc45a481.akpm@linux-foundation.org>
	 <20070910174649.GA16222@linux.vnet.ibm.com>
	 <b647ffbd0709101528i7440a0f9m9837065a43e4a720@mail.gmail.com>
	 <20070911044145.GC16222@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762981AbXIKJyQ@vger.kernel.org>
In-Reply-To: <20070911044145.GC16222@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: vatsa@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Jan Engelhardt <jengelh@computergmbh.de>, Ingo Molnar <mingo@elte.hu>, dhaval@linux.vnet.ibm.com, menage@google.com
List-Id: containers.vger.kernel.org

On 11/09/2007, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com> wrote:
>
> [ ... ]

I guess, 'rq->curr == tsk' implies a task was on the 'rq' (before
dequeueing) in this particular case. What's about a minor optimization
like below (plus, let's make use of task_running()):

[ btw., real-time task can be also added to a container, right? I
guess, it can be used at least for group-aware load-balancing of
rt_tasks... otherwise, I guess, cpu-resource controlling is not that
applicable to, say, SCHED_FIFO :-)
Anyway, to this goal rt_task should become aware of group-related bits
of the 'struct sched_entity'... and at the moment, the code below is
effectively just a 'nop' for them.. right? ]

/* change task's runqueue when it moves between groups */
static void sched_move_task(struct container_subsys *ss, struct container *cont,
                      struct container *old_cont, struct task_struct *tsk)
{
       int on_rq, running;
       unsigned long flags;
       struct rq *rq;

       rq = task_rq_lock(tsk, &flags);
       update_rq_clock(rq);

       running = task_running(rq, tsk);
       on_rq = tsk->se.on_rq;
       if (on_rq) {
               dequeue_task(rq, tsk, 0);

               if (unlikely(running) && tsk->sched_class == &fair_sched_class)
                      tsk->sched_class->put_prev_task(rq, tsk);
       }

       set_task_cfs_rq(tsk);

       if (on_rq) {
                enqueue_task(rq, tsk, 0);

                if (unlikely(running) && tsk->sched_class == &fair_sched_class)
                       tsk->sched_class->set_curr_task(rq);
       }

       task_rq_unlock(rq, &flags);
}


> --
> Regards,
> vatsa
>

-- 
Best regards,
Dmitry Adamushko
