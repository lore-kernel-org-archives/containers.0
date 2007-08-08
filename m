From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [RFC][PATCH] Make access to taks's nsproxy liter
Date: Wed, 8 Aug 2007 21:19:55 +0400
Message-ID: <20070808171955.GA655@tv-sign.ru>
References: <46B9E321.6070602@openvz.org> <20070808163757.GA578@tv-sign.ru>
	<m14pjac61z.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m14pjac61z.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 08/08, Eric W. Biederman wrote:
>
> Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org> writes:
> 
> > On 08/08, Pavel Emelyanov wrote:
> >>
> >> +void switch_task_namespaces(struct task_struct *p, struct nsproxy *new)
> >> +{
> >> +	struct nsproxy *ns;
> >> +
> >> +	might_sleep();
> >> +
> >> +	ns = p->nsproxy;
> >> +	if (ns == new)
> >> +		return;
> >> +
> >> +	if (new)
> >> +		get_nsproxy(new);
> >> +	rcu_assign_pointer(p->nsproxy, new);
> >> +
> >> +	if (ns && atomic_dec_and_test(&ns->count)) {
> >> +		/*
> >> +		 * wait for others to get what they want from this
> >> +		 * nsproxy. cannot release this nsproxy via the
> >> +		 * call_rcu() since put_mnt_ns will want to sleep
> >> +		 */
> >> +		synchronize_rcu();
> >> +		free_nsproxy(ns);
> >> +	}
> >> +}
> >
> > (I may be wrong, Paul cc'ed)
> >
> > This is correct with the current implementation of RCU, but strictly speaking,
> > we can't use synchronize_rcu() here, because write_lock_irq() doesn't imply
> > rcu_read_lock() in theory.
> 
> But we should be able to do:
> 
> write_lock_irq();
> rcu_read_lock();
> 	muck with other tasks nsproxy.
> rcu_read_unlock();
> write_unlock_irq();
> 
> Which would make rcu fine.

Yes sure. I just meant that the patch looks incomplete. But we didn't
hear Paul yet, perhaps I'm just wrong.

> The real locking we have is that only a task is allowed to modify it's
> own nsproxy pointer.  Other processes are not.
> 
> The practical question is how do we enable other processes to read
> a particular tasks nsproxy or something pointed to by it?

task_lock(). The only problem we can't take it in do_notify_parent(),
but if we add read_lock(tasklist) to sys_unshare, we can safely access
->parent->nsproxy.

Oleg.
