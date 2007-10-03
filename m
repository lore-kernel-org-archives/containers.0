From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for
 cpusets
Date: Wed, 3 Oct 2007 13:52:32 -0700
Message-ID: <20071003135232.af01a624.pj@sgi.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
	<6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
	<20071003105817.7adf6516.pj@sgi.com>
	<6599ad830710031110r1a74eafej56f20cc33e72ac81@mail.gmail.com>
	<20071003131632.fed4b848.pj@sgi.com>
	<6599ad830710031331h15d35e90lc63d845efd2de6f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758822AbXJCUws@vger.kernel.org>
In-Reply-To: <6599ad830710031331h15d35e90lc63d845efd2de6f5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, ebiederm@xmission.com, rientjes@google.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

> What was wrong with my suggestion from a couple of emails back? Adding
> the following in cpuset_attach():
> 
> struct cgroup_iter it;
> struct task_struct *p;
> while ((p = cgroup_iter_next(cs->css.cgroup, &it))) {
>        set_cpus_allowed(p, cs->cpus_allowed);
> }
> cgroup_iter_end(cs->css.cgroup, &it);

Hmmm ... that just might work.

And this brings to light the reason (justification, excuse, whatever
you call it) that I probably didn't do this earlier.

In the dark ages before cgroups (aka containers) we did not have an
efficient way to walk the tasks in a cpuset. One had to walk the entire
task list, comparing task struct cpuset pointers.  On big honking NUMA
iron, one should avoid task list walks as much as one can get away
with, even if it meant sneaking in a little bit racey API.  Since some
updates of a cpusets 'cpus' mask don't need it (you happen to know that
all tasks in that cpuset are pause'd anyway) I might have made the
tradeoff to make this task list walk an explicitly invoked user action,
to be done only when needed.

But now (correct me if I'm wrong here) cgroups has a per-cgroup task
list, and the above loop has cost linear in the number of tasks
actually in the cgroup, plus (unfortunate but necessary and tolerable)
the cost of taking a global css_set_lock, right?

And I take it the above code snipped is missing the cgroup_iter_start,
correct?

I'll ask Andrew to kill this patch of mine, and I will test out your
suggestion this evening.

This still leaves the other creepy crawlies involving cpusets and hot
plug that I glimpsed slithering by in my last message.  I guess I'll
start a separate discussion with Cliff Wickman and whomever else I think
might want to be involved on those issues.

Nice work - thanks.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
