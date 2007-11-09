From: "Dmitry Adamushko" <dmitry.adamushko@gmail.com>
Subject: Re: [BUG]: Crash with CONFIG_FAIR_CGROUP_SCHED=y
Date: Fri, 9 Nov 2007 11:59:15 +0100
Message-ID: <b647ffbd0711090259u7f2f2f64qe8b6330e55d4b99f@mail.gmail.com>
References: <20071108234805.GA2240@us.ibm.com>
	 <20071109070214.GO3143@linux.vnet.ibm.com>
	 <b647ffbd0711090045o5ebf4681q78f939f5c1e71fe1@mail.gmail.com>
	 <20071109101437.GA22544@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758178AbXKIK71@vger.kernel.org>
In-Reply-To: <20071109101437.GA22544@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: vatsa@linux.vnet.ibm.com
Cc: sukadev@us.ibm.com, balbir@in.ibm.com, Containers <containers@lists.osdl.org>, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, dhaval@linux.vnet.ibm.com, Ingo Molnar <mingo@elte.hu>, efault@gmx.de
List-Id: containers.vger.kernel.org

On 09/11/2007, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com> wrote:
> [ ... ]
>
>   As a solution to this problem, I moved sched_fork() call, which
>   initializes scheduler related fields on a new task, before
>   copy_namespaces(). I am not sure though whether moving up will
>   cause other side-effects. Do you see any issue?

Should be ok (IMHO and at first glance :-)

> - The second problem exposed by this test is that task_new_fair()
>   assumes that parent and child will be part of the same group (which
>   needn't be as this test shows). As a result, cfs_rq->curr can be NULL
>   for the child.

Would it be better, logically-wise, to use is_same_group() instead?
Although, we can't have 2 groups with cfs_rq->curr != NULL on the same
CPU... so if the child belongs to another group, it's cfs_rq->curr is
automatically NULL indeed.



-- 
Best regards,
Dmitry Adamushko
