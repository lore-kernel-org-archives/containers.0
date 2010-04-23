From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 4/5] freezer cgroup: Fix an RCU warning in
 cgroup_freezing_or_frozen()
Date: Fri, 23 Apr 2010 08:47:52 +0200
Message-ID: <1272005272.1646.20.camel@laptop>
References: <4BD016F4.8060108@cn.fujitsu.com>
	 <4BD01768.2020606@cn.fujitsu.com> <1271939275.1776.345.camel@laptop>
	 <20100422195911.GN2524@linux.vnet.ibm.com> <1271966935.1646.4.camel@laptop>
	  <4BD0F261.6080302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BD0F261.6080302@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: paulmck@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Helsley <matthltc@us.ibm.com>, Cedric Le Goater <clg@vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Fri, 2010-04-23 at 09:05 +0800, Li Zefan wrote:
> 
> 
> You are right in that taking task_lock() is sufficient (I forgot
> this lock rule), but it's not true that whatever locks are held
> in the ->attach method can pin a task's cgroup. 

Ah, can you be more specific about the ->attach() case?

The way I read it, cgroup_attach_task():

        for_each_subsys(root, ss) {
                if (ss->attach)
                        ss->attach(ss, cgrp, oldcgrp, tsk, false);
        }
        set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
        synchronize_rcu();
        put_css_set(cg);

So if you hold a lock that any of those ->attach() methods will use, it
will in fact delay the put_css_set().

Ah, indeed I see your point, it doesn't indeed pin the task to the
cgroup, but does avoid the cgroup from being freed.

Hrmm,.. so anything wanting to really pin a task to its cgroup will have
to use task_lock()? I'll have to see if that works for
sched_setscheduler().
