From: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Subject: Re: Possible race between cgroup_attach_proc and de_thread, and
	questionable code in de_thread.
Date: Thu, 28 Jul 2011 17:13:45 +1000
Message-ID: <20110728171345.67d3797d__19302.0014478408$1311837370$gmane$org@notabene.brown>
References: <20110727171101.5e32d8eb@notabene.brown>
	<20110727150710.GB5242@unix33.andrew.cmu.edu>
	<20110727234235.GA2318@linux.vnet.ibm.com>
	<20110728110813.7ff84b13@notabene.brown>
	<20110728062616.GC15204@unix33.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110728062616.GC15204-japSPQJXeIlCM1neWV3AGuCmf2DRS9x2@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 28 Jul 2011 02:26:16 -0400 Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:

> On Thu, Jul 28, 2011 at 11:08:13AM +1000, NeilBrown wrote:
> > On Wed, 27 Jul 2011 16:42:35 -0700 "Paul E. McKenney"
> > <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > 
> > > On Wed, Jul 27, 2011 at 11:07:10AM -0400, Ben Blum wrote:
> > > > On Wed, Jul 27, 2011 at 05:11:01PM +1000, NeilBrown wrote:
> > > 
> > > [ . . . ]
> > > 
> > > > >  The race as I understand it is with this code:
> > > > > 
> > > > > 
> > > > > 		list_replace_rcu(&leader->tasks, &tsk->tasks);
> > > > > 		list_replace_init(&leader->sibling, &tsk->sibling);
> > > > > 
> > > > > 		tsk->group_leader = tsk;
> > > > > 		leader->group_leader = tsk;
> > > > > 
> > > > > 
> > > > >  which seems to be called with only tasklist_lock held, which doesn't seem to
> > > > >  be held in the cgroup code.
> > > > > 
> > > > >  If the "thread_group_leader(leader)" call in cgroup_attach_proc() runs before
> > > > >  this chunk is run with the same value for 'leader', but the
> > > > >  while_each_thread is run after, then the while_read_thread() might loop
> > > > >  forever.  rcu_read_lock doesn't prevent this from happening.
> > > > 
> > > > Somehow I was under the impression that holding tasklist_lock (for
> > > > writing) provided exclusion from code that holds rcu_read_lock -
> > > > probably because there are other points in the kernel which do
> > > > while_each_thread with only RCU-read held (and not tasklist):
> > > > 
> > > > - kernel/hung_task.c, check_hung_uninterruptible_tasks()
> > > 
> > > This one looks OK to me.  The code is just referencing fields in each
> > > of the task structures, and appears to be making proper use of
> > > rcu_dereference().  All this code requires is that the task structures
> > > remain in existence through the full lifetime of the RCU read-side
> > > critical section, which is guaranteed because of the way the task_struct
> > > is freed.
> > 
> > I disagree.  It also requires - by virtue of the use of while_each_thread() -
> > that 'g' remains on the list that 't' is walking along.
> > 
> > Now for a normal list, the head always stays on the list and is accessible
> > even from an rcu-removed entry.  But the thread_group list isn't a normal
> > list.  It doesn't have a distinct head.  It is a loop of all of the
> > 'task_structs' in a thread group.  One of them is designated the 'leader' but
> > de_thread() can change the 'leader' - though it doesn't remove the old leader.
> > 
> > __unhash_process in mm/exit.c looks like it could remove the leader from the
> > list and definitely could remove a non-leader.
> > 
> > So if a non-leader calls 'exec' and the leader calls 'exit', then a
> > task_struct that was the leader could become a non-leader and then be removed
> > from the list that kernel/hung_task could be walking along.
> 
> That agrees with my understanding.
> 
> > 
> > So I don't think that while_each_thread() is currently safe.  It depends on
> > the thread leader not disappearing and I think it can.
> 
> I think that while_each_thread is perfectly safe, it just needs to be
> protected properly while used. it reads the tasklist, and both competing
> paths (__unhash_process and de_thread) are done with tasklist_lock write
> locked, so read-locking ought to suffice. all it needs is to be better
> documented.

That might be one answer.
However the fact that rcu primitives are used to walk the list (next_thread()
contains list_entry_rcu) seems to suggest that the intention was that RCU
could be used for read access - which in large part it can.
So we have two alternatives:
 1/ take a reader spinlock to walk the thread_group list
 2/ make RCU work safely for walking thread_group

I thought it was best to try the latter first.

> 
> > [...]
> > 
> > +/* Thread group leader can change, so stop loop when we see one
> > + * even if it isn't 'g' */
> >  #define while_each_thread(g, t) \
> > -	while ((t = next_thread(t)) != g)
> > +	while ((t = next_thread(t)) != g && !thread_group_leader(t))
> 
> this is semantically wrong: it will stop as soon as it finds a thread
> that has newly become the leader, and not run the loop body code in that
> thread's case. so the thread that just execed would not get run on, and
> in the case of my code, would "escape" the cgroup migration.

Yes, you are right ...
For your case I think you do want the thread group list to be both safe and
stable.  RCU can only provide 'safe' for a list.  So I think I'm convinced
that you need a readlock on tasklist_lock.  That doesn't mean that all users
of while_each_thread do.


> 
> but I argue it is also organisationally wrong. while_each_thread's
> purpose is just to worry about the structure of the process list, not to
> account for behavioural details of de_thread. this check belongs outside
> of the macro, and it should be protected by tasklist_lock in the same
> critical section in which while_each_thread is used.

Sound fair.

Maybe we need two versions of while_each_thread().  One that assumes
tasklist_lock and guarantees getting every thread, and one that is less
precise but only needs rcu_read_lock().

That would require an audit of each call site to see what is really needed.

But yes: if you replace your rcu_read_lock()s with read_lock(&tasklist_lock)
then you will be safe, and I don't think you can do any better (i.e. less
locking) than that.

Thanks,
NeilBrown
