From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Mon, 16 Jun 2008 11:16:54 +0900
Message-ID: <20080616111410.7896.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080607195733.9C77.KOSAKI.MOTOHIRO@jp.fujitsu.com> <484E0F7F.3000606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757942AbYFPCR1@vger.kernel.org>
In-Reply-To: <484E0F7F.3000606@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Hi

> > v1 -> v2
> >   o implement can_attach() and attach() method.
> >   o remvoe can_fork member from cgroup_subsys.
> >     instead, copy_process() call task_cgroup_can_fork() directly.
> >   o fixed dead lock bug.
> >   o add Documentation/contoroller/task.txt
> > 
> 
> I think Documentation/kernel-parameters.txt should also be updated.
> 
> 	cgroup_disable= [KNL] Disable a particular controller
> 			Format: {name of the controller(s) to disable}
> 				{Currently supported controllers - "memory"}

Yup, You are right.
I'll fix it.

> > +config CGROUP_TASK
> > +	bool "Simple number of task accounting cgroup subsystem"
> > +	depends on CGROUPS && EXPERIMENTAL
> > +	default n
> > +	help
> > +          Provides a simple number of task accounting cgroup subsystem for
> 
> should use TAB

Ah, Thanks.


> > +static void task_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
> > +{
> > +	kfree(cgrp->subsys[task_cgroup_subsys_id]);
> 
> You should kfree task_cgroup* instead of cgroup_subsys_state*.

There point to the same address.
but, your opinion has better code clearness, of cource.

Thanks.
