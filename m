From: Greg Kurz <gkurz@fr.ibm.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was
 Vpid:)
Date: Thu, 16 Jun 2011 15:00:51 +0200
Message-ID: <1308229251.8230.77.camel@bahia.local>
References: <20110615145527.4016.70157.stgit@bahia.local>
	 <20110615184625.GA15573@redhat.com> <1308222107.8230.49.camel@bahia.local>
	 <20110616123554.GA7230@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110616123554.GA7230@hawkmoon.kerlabs.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Louis Rilling <Louis.Rilling@kerlabs.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

On Thu, 2011-06-16 at 14:35 +0200, Louis Rilling wrote:
> On 16/06/11 13:01 +0200, Greg Kurz wrote:
> > On Wed, 2011-06-15 at 20:46 +0200, Oleg Nesterov wrote:
> > > On 06/15, Greg Kurz wrote:
> > > >
> > > > @@ -176,6 +177,17 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
> > > >  		if (tracer)
> > > >  			tpid = task_pid_nr_ns(tracer, ns);
> > > >  	}
> > > > +	actpid = 0;
> > > > +	sighand = rcu_dereference(p->sighand);
> > > > +	if (sighand) {
> > > > +		struct pid_namespace *pid_ns;
> > > > +		unsigned long flags;
> > > > +		spin_lock_irqsave(&sighand->siglock, flags);
> > > 
> > > Well. This is not exactly right. We have lock_task_sighand() for this.
> > > 
> > 
> > I see... ->sighand could change so we need the for(;;) loop in
> > __lock_task_sighand() to be sure we have the right pointer, correct ?
> > By the way, if we use lock_task_sighand() we'll end up with nested
> > rcu_read_lock(): it will work but I don't know how it may affect
> > performance...
> 
> rcu_read_lock() is very cheap.
> 

Fair enough. In this case, lock_task_sighand() would be the right choice
if locking is needed.

> > 
> > > But. Why do you need ->siglock? Why rcu_read_lock() is not enough?
> > > 
> > 
> > Because there's a race with
> > __exit_signal()->__unhash_process()->detach_pid() that can break
> > task_active_pid_ns() and rcu won't help here (unless *perhaps* by
> > modifying __exit_signal() but I don't want to mess with such a critical
> > path).
> 
> In case of race, the only risk is that task_active_pid_ns() returns NULL.
> Otherwise, RCU guarantees that the pid_ns will stay alive (see below).
> 
> > 
> > > Hmm. You don't even need pid_ns afaics, you could simply look at
> > > pid->numbers[pid->level].
> > > 
> > 
> > True but I will have the same problem: detach_pid() nullifies the pid.
> 
> But the pid won't be freed until an RCU grace period expires. See free_pid(). So
> the non-determinism here is when /proc/<pid>/status is read at the same as
> threaded execve() or task's exit(), in which case a stale pid (execve()) or
> no pid (exit after __unhash_process()) can be accessed. This does not look like
> a big deal...
> 

Ok. You're right, the RCU grace period is just what I need to ensure I
won't dereference a stale pointer. So I don't even have to bother with
->siglock and just check pid_alive() before peeking into pid->numbers.

> Thanks,
> 
> Louis
> 

Thanks for your help.

--
Greg
