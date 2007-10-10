From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for
 cpusets
Date: Wed, 10 Oct 2007 13:59:44 -0700 (PDT)
Message-ID: <alpine.DEB.0.9999.0710101351400.4771@chino.kir.corp.google.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>  <6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>  <20071003105817.7adf6516.pj@sgi.com>  <6599ad830710031110r1a74eafej56f20cc33e72ac81@mail.gmail.com>
 <20071003131632.fed4b848.pj@sgi.com>  <6599ad830710031331h15d35e90lc63d845efd2de6f5@mail.gmail.com>  <20071006012437.c0fd3a8a.pj@sgi.com>  <alpine.DEB.0.9999.0710061047400.24311@chino.kir.corp.google.com>  <6599ad830710061411l3fb9368al319a80469d54946e@mail.gmail.com>
  <alpine.DEB.0.9999.0710062250590.11526@chino.kir.corp.google.com> <6599ad830710101346y1ade5ccdgd3b64a041eab7ec1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756891AbXJJVAb@vger.kernel.org>
In-Reply-To: <6599ad830710101346y1ade5ccdgd3b64a041eab7ec1@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, ebiederm@xmission.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On Wed, 10 Oct 2007, Paul Menage wrote:

> On 10/6/07, David Rientjes <rientjes@google.com> wrote:
> >
> > It can race with sched_setaffinity().  It has to give up tasklist_lock as
> > well to call set_cpus_allowed() and can race
> >
> >         cpus_allowed = cpuset_cpus_allowed(p);
> >         cpus_and(new_mask, new_mask, cpus_allowed);
> >         retval = set_cpus_allowed(p, new_mask);
> >
> > and allow a task to have a cpu outside of the cpuset's new cpus_allowed if
> > you've taken it away between cpuset_cpus_allowed() and set_cpus_allowed().
> 
> cpuset_cpus_allowed() takes callback_mutex, which is held by
> update_cpumask() when it updates cs->cpus_allowed. So if we continue
> to hold callback_mutex across the task update loop this wouldn't be a
> race. Having said that, holding callback mutex for that long might not
> be a good idea.
> 

Moving the actual use of set_cpus_allowed() from the cgroup code to 
sched.c would probably be the best in terms of a clean interface.  Then 
you could protect the whole thing by sched_hotcpu_mutex, which is 
expressly designed for migrations.

Something like this:

	struct cgroup_iter it;
	struct task_struct *p, **tasks;
	int i = 0;

	cgroup_iter_start(cs->css.cgroup, &it);
	while ((p = cgroup_iter_next(cs->css.cgroup, &it))) {
		get_task_struct(p);
		tasks[i++] = p;
	}
	cgroup_iter_end(cs->css.cgroup, &it);

	while (--i >= 0) {
		sched_migrate_task(tasks[i], cs->cpus_allowed);
		put_task_struct(tasks[i]);
	}

kernel/sched.c:

	void sched_migrate_task(struct task_struct *task,
				cpumask_t cpus_allowed)
	{
		mutex_lock(&sched_hotcpu_mutex);
		set_cpus_allowed(task, cpus_allowed);
		mutex_unlock(&sched_hotcpu_mutex);
	}

It'd be faster to just pass **tasks to a sched.c function with the number 
of tasks to migrate to reduce the contention on sched_hotcpu_mutex, but 
then the put_task_struct() is left dangling over in cgroup code.  
sched_hotcpu_mutex should be rarely contended, anyway.

		David
