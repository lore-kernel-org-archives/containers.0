From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] [PATCH] cgroups: not to iterate other namespace
	process inside container
Date: Mon, 8 Dec 2008 12:26:11 +0530
Message-ID: <20081208065611.GH13333@balbir.in.ibm.com>
References: <493CC423.5060601@linux.vnet.ibm.com>
	<6599ad830812072231l25aadbd8u6653cda3a22ddc2d@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830812072231l25aadbd8u6653cda3a22ddc2d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

* Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> [2008-12-07 22:31:03]:

> On Sun, Dec 7, 2008 at 10:52 PM, gowrishankar
> <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > Once tasks are populated from system namespace inside cgroup, container
> > replaces
> > other namespace task with 0 while listing tasks, inside container.
> > Though this is expected behaviour
> > from container end, there is no use of showing unwanted 0s.
> > In below patch, we check if a process is in same namespace before
> > loading into pid array.
> >
> > Signed-off-by: Gowrishankar M <gowrishankar.m-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
> 
> Looks sensible, thanks.
> 
> Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> Can you send it on to akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org?
> 
> A couple of small style issues:
> 
> - title would be better as "skip processes from other namespaces when
> listing a cgroup"
> 
> - use the local variable name "pid" rather than "ret"
> 

I would recommend using pid_t as type, since task_pid_vnr returns pid_t and vpid as the
variable name. Although this fixes pid_array_load(), I am worried that
cg_list would still have tasks from other namespaces that can affect
controllers. We'll need other changes to get the controllers working
correctly (a review of the code maybe?).

> > Index: linux-2.6.28-rc3/kernel/cgroup.c
> > ===================================================================
> > --- linux-2.6.28-rc3.orig/kernel/cgroup.c    2008-12-07
> > 13:23:19.000000000 -0500
> > +++ linux-2.6.28-rc3/kernel/cgroup.c    2008-12-07 13:24:28.000000000 -0500
> > @@ -2011,14 +2011,15 @@
> >  */
> >  static int pid_array_load(pid_t *pidarray, int npids, struct cgroup *cgrp)
> >  {
> > -    int n = 0;
> > +    int n = 0, ret;
> >     struct cgroup_iter it;
> >     struct task_struct *tsk;
> >     cgroup_iter_start(cgrp, &it);
> >     while ((tsk = cgroup_iter_next(cgrp, &it))) {
> >         if (unlikely(n == npids))
> >             break;
> > -        pidarray[n++] = task_pid_vnr(tsk);
> > +        if ((ret = task_pid_vnr(tsk)) > 0)
> > +            pidarray[n++] = ret;
> >     }
> >     cgroup_iter_end(cgrp, &it);
> >     return n;

-- 
	Balbir
