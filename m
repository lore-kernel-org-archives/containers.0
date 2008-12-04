From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/3] ftrace: use struct pid
Date: Thu, 4 Dec 2008 10:35:37 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0812041033240.5240@gandalf.stny.rr.com>
References: <20081204052638.425740534@goodmis.org>  <20081204052735.175697908@goodmis.org> <m1d4g8un6b.fsf@frodo.ebiederm.org>  <1228395378.13111.23.camel@nimitz> <1228396022.13111.27.camel@nimitz>  <m1prk8t5xr.fsf@frodo.ebiederm.org>
 <1228403547.13111.73.camel@nimitz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755558AbYLDPfx@vger.kernel.org>
In-Reply-To: <1228403547.13111.73.camel@nimitz>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-kernel@vger.kernel.org, Steven Rostedt <srostedt@redhat.com>, containers@lists.osdl.org, Ingo Molnar <mingo@elte.hu>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org


On Thu, 4 Dec 2008, Dave Hansen wrote:
> > >> 
> > >> Could we get away with sticking the rcu_read_{un}lock() inside those
> > >> macros?  Those are going to get used in pretty high level code and we're
> > >> allowed to nest rcu_read_lock().  No danger of deadlocks or lock
> > >> inversions.
> > >
> > > Why don't any of the other users of do_each_pid_task() use
> > > rcu_read_lock()?  They all seem to be under read_lock(&tasklist_lock)
> > > (except one is under a write lock of the same).
> > 
> > We probably should.  Historically read_lock(&tasklist_lock) implies
> > rcu_read_lock().
> 
> You mean because the current task can't go through a quiescent period
> until it hits userspace, and we can't go to userspace while holding
> read_lock()?  Nah, that's not subtle. ;)

Has nothing to do with userspace. We can not go through a quiescent period 
while holding a rcu_read_lock, or if preemption is disabled. read_lock 
prevents preemption, as does spin_locks.

> 
> > And the tasklist lock is what we hold when it is safe.
> > 
> > But if you look at find_vpid we should be holding just the rcu lock there.
> 
> Yup, I see it there.
> 
> So, any reason not to do this?  Brown-bag compile tested.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> 
> ---
> 
>  linux-2.6.git-dave/include/linux/pid.h |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff -puN include/linux/pid.h~put-rcu-ops-in-do_each_pid_task include/linux/pid.h
> --- linux-2.6.git/include/linux/pid.h~put-rcu-ops-in-do_each_pid_task	2008-12-04 06:03:09.000000000 -0800
> +++ linux-2.6.git-dave/include/linux/pid.h	2008-12-04 06:19:35.000000000 -0800
> @@ -147,6 +147,7 @@ pid_t pid_vnr(struct pid *pid);
>  #define do_each_pid_task(pid, type, task)				\
>  	do {								\
>  		struct hlist_node *pos___;				\
> +		rcu_read_lock();					\
>  		if (pid != NULL)					\
>  			hlist_for_each_entry_rcu((task), pos___,	\
>  				&pid->tasks[type], pids[type].node) {
> @@ -159,6 +160,7 @@ pid_t pid_vnr(struct pid *pid);
>  				if (type == PIDTYPE_PID)		\
>  					break;				\
>  			}						\
> +		rcu_read_unlock();					\
>  	} while (0)

That probably could work.

-- Steve
