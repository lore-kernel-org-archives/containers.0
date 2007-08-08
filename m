From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] Make access to taks's nsproxy liter
Date: Wed, 8 Aug 2007 11:48:00 -0700
Message-ID: <20070808184800.GB8909@linux.vnet.ibm.com>
References: <46B9E321.6070602@openvz.org> <20070808164107.GB578@tv-sign.ru>
	<20070808172309.GA8909@linux.vnet.ibm.com>
	<20070808173647.GA676@tv-sign.ru>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070808173647.GA676-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 08, 2007 at 09:36:47PM +0400, Oleg Nesterov wrote:
> On 08/08, Paul E. McKenney wrote:
> >
> > On Wed, Aug 08, 2007 at 08:41:07PM +0400, Oleg Nesterov wrote:
> > > > +void switch_task_namespaces(struct task_struct *p, struct nsproxy *new)
> > > > +{
> > > > +	struct nsproxy *ns;
> > > > +
> > > > +	might_sleep();
> > > > +
> > > > +	ns = p->nsproxy;
> > > > +	if (ns == new)
> > > > +		return;
> > > > +
> > > > +	if (new)
> > > > +		get_nsproxy(new);
> > > > +	rcu_assign_pointer(p->nsproxy, new);
> > > > +
> > > > +	if (ns && atomic_dec_and_test(&ns->count)) {
> > > > +		/*
> > > > +		 * wait for others to get what they want from this
> > > > +		 * nsproxy. cannot release this nsproxy via the
> > > > +		 * call_rcu() since put_mnt_ns will want to sleep
> > > > +		 */
> > > > +		synchronize_rcu();
> > > > +		free_nsproxy(ns);
> > > > +	}
> > > > +}
> > > 
> > > (I may be wrong, Paul cc'ed)
> > > 
> > > This is correct with the current implementation of RCU, but strictly speaking,
> > > we can't use synchronize_rcu() here, because write_lock_irq() doesn't imply
> > > rcu_read_lock() in theory.
> > 
> > Can you use synchronize_sched() instead?  The synchronize_sched()
> > primitive will wait until all preempt/irq-disable code sequences complete.
> > Therefore, it would wait for all write_lock_irq() code sequences to
> > complete.
> 
> Thanks Paul!
> 
> But we also need to cover the case when ->nsproxy is used under rcu_read_lock(),
> so if we go this way, we'd better add rcu_read_lock() to do_notify_parent.*() as
> Eric suggested.

Makes sense.  Just for completeness, the other thing you could do would
be to do both a synchronize_sched() and a synchronize_rcu() in the
switch_task_namespaces() function, but I believe that Eric's approach
would be better.  (The only counter-example I can come up with off-hand
would be if there were tons of read paths, and you needed a quick fix.
But even in that case, hopefully the quick fix would be followed by
taking Eric's approach.)

						Thanx, Paul
