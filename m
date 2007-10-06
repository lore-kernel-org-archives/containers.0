From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for
 cpusets
Date: Sat, 6 Oct 2007 10:54:35 -0700 (PDT)
Message-ID: <alpine.DEB.0.9999.0710061047400.24311@chino.kir.corp.google.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com> <6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com> <20071003105817.7adf6516.pj@sgi.com> <6599ad830710031110r1a74eafej56f20cc33e72ac81@mail.gmail.com> <20071003131632.fed4b848.pj@sgi.com>
 <6599ad830710031331h15d35e90lc63d845efd2de6f5@mail.gmail.com> <20071006012437.c0fd3a8a.pj@sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763837AbXJFR5o@vger.kernel.org>
In-Reply-To: <20071006012437.c0fd3a8a.pj@sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Jackson <pj@sgi.com>
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, ebiederm@xmission.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On Sat, 6 Oct 2007, Paul Jackson wrote:

> This isn't working for me.
> 
> The key kernel routine for updating a tasks cpus_allowed
> cannot be called while holding a spinlock.
> 
> But the above loop holds a spinlock, css_set_lock, between
> the cgroup_iter_start and the cgroup_iter_end.
> 
> I end up generating complaints of:
> 	BUG: scheduling while atomic
> when I invoke the set_cpus_allowed() above.
> 
> Should css_set_lock be a mutex?  Locking changes like that
> can be risky.
> 

It would probably be better to just save references to the tasks.

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
		set_cpus_allowed(tasks[i], cs->cpus_allowed);
		put_task_struct(tasks[i]);
	}

The getting and putting of the tasks will prevent them from exiting or 
being deallocated prematurely.  But this is also a critical section that 
will need to be protected by some mutex so it doesn't race with other 
set_cpus_allowed().

		David
