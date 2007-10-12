From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for
 cpusets
Date: Thu, 11 Oct 2007 18:23:59 -0700
Message-ID: <20071011182359.7d069143.pj@sgi.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
	<6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
	<20071003105817.7adf6516.pj@sgi.com>
	<6599ad830710031110r1a74eafej56f20cc33e72ac81@mail.gmail.com>
	<20071003131632.fed4b848.pj@sgi.com>
	<6599ad830710031331h15d35e90lc63d845efd2de6f5@mail.gmail.com>
	<20071006012437.c0fd3a8a.pj@sgi.com>
	<alpine.DEB.0.9999.0710061047400.24311@chino.kir.corp.google.com>
	<20071006125904.a26ed99f.pj@sgi.com>
	<6599ad830710061409p2dcaa1c8u8c6864beaaafb149@mail.gmail.com>
	<20071011150315.78c4f45f.pj@sgi.com>
	<m13awhb5mc.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754899AbXJLBY2@vger.kernel.org>
In-Reply-To: <m13awhb5mc.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: menage@google.com, rientjes@google.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, svaidy@linux.vnet.ibm.com, xemul@openvz.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

> Since we know that the tasks are not running, and that we have
> exclusive access to the tasks in the control group we can take action
> as if we were the actual tasks themselves.  Which should simplify
> locking.

The Big Kernel Lock (BKL), born again, as a Medium Sized Cgroup Lock ?

This only simplifies things if it enables us to remove finer grain
locking, but some finer grain locking is essential for performance on
higher processor count systems (which if Intel and AMD have their way,
will be just about any system bigger than a cell phone.)

There is no escaping actually having to think about these things, and
clearly understand and document what locks what.  Locks don't just
guard code sections, and they don't just guard particular data items.

Rather, in my view, they ensure certain invariants on your data.
Non-atomic code sections that depend on, or modify, data subject to
such invariants must be done while holding the appropriate lock.
One is guaranteed not to see the invariant violated while holding
the lock, nor to expose others to temporary violations of the invariant
done while locked.

In this case, we have multiple copies of cpumasks in task structs and
cpusets that must honor the invariant that they are equal or subsets
of, cpu_online_map.  Changes to the set of online CPUs must hold some
lock, apparently sched_hotcpu_mutex, until all those cpumasks are
adjusted to once again honor, this invariant.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
