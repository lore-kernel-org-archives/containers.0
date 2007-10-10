From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for cpusets
Date: Wed, 10 Oct 2007 13:46:36 -0700
Message-ID: <6599ad830710101346y1ade5ccdgd3b64a041eab7ec1@mail.gmail.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
	 <6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
	 <20071003105817.7adf6516.pj@sgi.com>
	 <6599ad830710031110r1a74eafej56f20cc33e72ac81@mail.gmail.com>
	 <20071003131632.fed4b848.pj@sgi.com>
	 <6599ad830710031331h15d35e90lc63d845efd2de6f5@mail.gmail.com>
	 <20071006012437.c0fd3a8a.pj@sgi.com>
	 <alpine.DEB.0.9999.0710061047400.24311@chino.kir.corp.google.com>
	 <6599ad830710061411l3fb9368al319a80469d54946e@mail.gmail.com>
	 <alpine.DEB.0.9999.0710062250590.11526@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757096AbXJJUq7@vger.kernel.org>
In-Reply-To: <alpine.DEB.0.9999.0710062250590.11526@chino.kir.corp.google.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Cc: Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, ebiederm@xmission.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On 10/6/07, David Rientjes <rientjes@google.com> wrote:
>
> It can race with sched_setaffinity().  It has to give up tasklist_lock as
> well to call set_cpus_allowed() and can race
>
>         cpus_allowed = cpuset_cpus_allowed(p);
>         cpus_and(new_mask, new_mask, cpus_allowed);
>         retval = set_cpus_allowed(p, new_mask);
>
> and allow a task to have a cpu outside of the cpuset's new cpus_allowed if
> you've taken it away between cpuset_cpus_allowed() and set_cpus_allowed().

cpuset_cpus_allowed() takes callback_mutex, which is held by
update_cpumask() when it updates cs->cpus_allowed. So if we continue
to hold callback_mutex across the task update loop this wouldn't be a
race. Having said that, holding callback mutex for that long might not
be a good idea.

A cleaner solution might be to drop callback_mutex after updating
cs->cpus_allowed in update_cpumask() and then make sched_setaffinity()
do a post-check:

	cpus_allowed = cpuset_cpus_allowed(p);
 again:
	cpus_and(new_mask, new_mask, cpus_allowed);
	retval = set_cpus_allowed(p, new_mask);
	if (!retval) {
		/* Check for races with cpuset updates */
		cpus_allowed = cpuset_cpus_allowed(p);
		if (!cpus_subset(new_mask, cpus_allowed)) {
			/*
			 * We raced with a change to cpuset update,
			 * and our cpumask is now outside the
			 * permitted cpumask for the cpuset.  Since a
			 * change to the cpuset's cpus resets the
			 * cpumask for each task, do the same thing
			 * here.
			 */
			new_mask = cpus_allowed;
			goto again;
		}
	}

Paul
