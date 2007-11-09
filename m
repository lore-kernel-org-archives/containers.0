From: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Subject: Re: [BUG]: Crash with CONFIG_FAIR_CGROUP_SCHED=y
Date: Fri, 9 Nov 2007 17:41:57 +0530
Message-ID: <20071109121157.GA24630@linux.vnet.ibm.com>
References: <20071108234805.GA2240@us.ibm.com> <20071109070214.GO3143@linux.vnet.ibm.com> <b647ffbd0711090045o5ebf4681q78f939f5c1e71fe1@mail.gmail.com> <20071109101437.GA22544@linux.vnet.ibm.com> <b647ffbd0711090259u7f2f2f64qe8b6330e55d4b99f@mail.gmail.com>
Reply-To: vatsa@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761711AbXKIL7l@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b647ffbd0711090259u7f2f2f64qe8b6330e55d4b99f@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: sukadev@us.ibm.com, balbir@in.ibm.com, Containers <containers@lists.osdl.org>, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, dhaval@linux.vnet.ibm.com, Ingo Molnar <mingo@elte.hu>, efault@gmx.de
List-Id: containers.vger.kernel.org

On Fri, Nov 09, 2007 at 11:59:15AM +0100, Dmitry Adamushko wrote:
> > - The second problem exposed by this test is that task_new_fair()
> >   assumes that parent and child will be part of the same group (which
> >   needn't be as this test shows). As a result, cfs_rq->curr can be NULL
> >   for the child.
> 
> Would it be better, logically-wise, to use is_same_group() instead?
> Although, we can't have 2 groups with cfs_rq->curr != NULL on the same
> CPU... so if the child belongs to another group, it's cfs_rq->curr is
> automatically NULL indeed.

Yeah ..I feel safe with an explicit !curr check, perhaps with a comment like
below added to explain when curr can be NULL?


---
 kernel/sched_fair.c |    1 +
 1 files changed, 1 insertion(+)

Index: current/kernel/sched_fair.c
===================================================================
--- current.orig/kernel/sched_fair.c
+++ current/kernel/sched_fair.c
@@ -1022,6 +1022,7 @@ static void task_new_fair(struct rq *rq,
 	update_curr(cfs_rq);
 	place_entity(cfs_rq, se, 1);
 
+	/* 'curr' will be NULL if the child belongs to a different group */
 	if (sysctl_sched_child_runs_first && this_cpu == task_cpu(p) &&
 			curr && curr->vruntime < se->vruntime) {
 		/*



-- 
Regards,
vatsa
