From: "Dmitry Adamushko" <dmitry.adamushko@gmail.com>
Subject: Re: [PATCH] Hookup group-scheduler with task container infrastructure
Date: Wed, 12 Sep 2007 18:25:37 +0200
Message-ID: <b647ffbd0709120925i690ecb11i975149037fc72979@mail.gmail.com>
References: <20070910171049.GA16048@linux.vnet.ibm.com>
	 <Pine.LNX.4.64.0709101903220.5368@fbirervta.pbzchgretzou.qr>
	 <20070910172334.GB19100@linux.vnet.ibm.com>
	 <20070910102259.dc45a481.akpm@linux-foundation.org>
	 <20070910174649.GA16222@linux.vnet.ibm.com>
	 <b647ffbd0709101528i7440a0f9m9837065a43e4a720@mail.gmail.com>
	 <20070911044145.GC16222@linux.vnet.ibm.com>
	 <b647ffbd0709110253y7d9564c4j88aa134330e2a292@mail.gmail.com>
	 <20070912114202.GA30385@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765727AbXILQZw@vger.kernel.org>
In-Reply-To: <20070912114202.GA30385@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: vatsa@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Jan Engelhardt <jengelh@computergmbh.de>, Ingo Molnar <mingo@elte.hu>, dhaval@linux.vnet.ibm.com, menage@google.com
List-Id: containers.vger.kernel.org

Hi Srivatsa,

please find a few more minor comments below.

> [ ... ]
> +
> +/* destroy runqueue etc associated with a task group */
> +static void sched_destroy_group(struct container_subsys *ss,
> +                                       struct container *cont)
> +{
> +       struct task_grp *tg = container_tg(cont);
> +       struct cfs_rq *cfs_rq;
> +       struct sched_entity *se;
> +       int i;
> +
> +       for_each_possible_cpu(i) {
> +               cfs_rq = tg->cfs_rq[i];
> +               list_del_rcu(&cfs_rq->leaf_cfs_rq_list);
> +       }
> +
> +       /* wait for possible concurrent references to cfs_rqs complete */
> +       synchronize_sched();
> +
> +       /* now it should be safe to free those cfs_rqs */
> +       for_each_possible_cpu(i) {
> +               cfs_rq = tg->cfs_rq[i];
> +               kfree(cfs_rq);
> +
> +               se = tg->se[i];
> +               kfree(se);
> +       }
> +
> +       kfree(tg);
> +}

kfree(tg->cfs_rq) && kfree(tg->se) ?


> +
> +/* change task's runqueue when it moves between groups */
> +static void sched_move_task(struct container_subsys *ss, struct container *cont,
> +                       struct container *old_cont, struct task_struct *tsk)
> +{
> +       int on_rq, running;
> +       unsigned long flags;
> +       struct rq *rq;
> +
> +       rq = task_rq_lock(tsk, &flags);
> +
> +       if (tsk->sched_class != &fair_sched_class)
> +               goto done;

this check should be redundant now with sched_can_attach() in place.


> +static void set_se_shares(struct sched_entity *se, unsigned long shares)
> +{
> +       struct cfs_rq *cfs_rq = se->cfs_rq;
> +       struct rq *rq = cfs_rq->rq;
> +       int on_rq;
> +
> +       spin_lock_irq(&rq->lock);
> +
> +       on_rq = se->on_rq;
> +       if (on_rq)
> +               __dequeue_entity(cfs_rq, se);
> +
> +       se->load.weight = shares;
> +       se->load.inv_weight = div64_64((1ULL<<32), shares);

A bit of nit-picking... are you sure, there is no need in non '__'
versions of dequeue/enqueu() here (at least, for the sake of
update_curr())? Although, I don't have -mm at hand at this very moment
and original -rc4 (that I have at hand) doesn't already have
'se->load' at all... so will look later.

>
> --
> Regards,
> vatsa
>


-- 
Best regards,
Dmitry Adamushko
