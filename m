From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] sched: Fix an RCU warning in print_task()
Date: Thu, 22 Apr 2010 15:05:04 -0700
Message-ID: <20100422220504.GP2524@linux.vnet.ibm.com>
References: <4BD016F4.8060108@cn.fujitsu.com>
 <4BD01740.7050805@cn.fujitsu.com>
 <1271931604.1776.337.camel@laptop>
 <20100422211212.GA32490@count0.beaverton.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100422211212.GA32490@count0.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

On Thu, Apr 22, 2010 at 02:12:12PM -0700, Matt Helsley wrote:
> On Thu, Apr 22, 2010 at 12:20:04PM +0200, Peter Zijlstra wrote:
> 
> <snip>
> 
> > You can also pin a cgroup by holding whatever locks are held in the
> > ->attach method. But the RCU annotation doesn't know (nor reasonably can
> > know about that).
> 
> For my future reference, what's the right way to "fix" these
> situations with the RCU annotations? (I think your response re: Li's
> freezer patch was correct and illustrates the problem I'm referring to.)

There are several variants of rcu_dereference() for this purpose:

o	rcu_dereference() for code that is always called within an
	RCU read-side critical section -- rcu_read_lock().

o	rcu_dereference_bh() for code that is always called within
	an RCU-bh read-side critical section -- rcu_read_lock_bh().

o	rcu_dereference_sched() for code that is always called within
	an RCU-sched read-side critical section -- either
	rcu_read_lock_sched() or any other primitive that disables
	preemption.

o	srcu_dereference() for code that is always called within an
	SRCU read-side critical section -- srcu_read_lock().

o	rcu_dereference_check() for code that might be called either
	in a read-side critical section or on the update side.	This
	interface takes a second argument, which is normally a logical
	conjunction of rcu_read_lock_held(), rcu_read_lock_sched_held(),
	rcu_read_lock_bh_held(), and srcu_read_lock_held for the read
	side, and lockdep_is_held() for the update side.

o	rcu_dereference_raw(p) is rcu_dereference_check(p, 1).  Expect
	to be asked hard questions if you include this in your patch.
	One legitimate use is for initialization and cleanup code
	sequences where the current CPU is the only one with access
	to the RCU-protected data structure in question.

o	rcu_dereference_protected() for code that is only called from
	the update side.  This interface takes a second argument,
	which would normally only have a logical conjunction of
	lockdep_is_held() invocations.  Don't even think about putting
	rcu_read_lock_held() and friends here!!!

o	rcu_access_pointer() for code that only tests the value of
	the RCU-protected pointer, for example, against NULL.

There you have it!

							Thanx, Paul
