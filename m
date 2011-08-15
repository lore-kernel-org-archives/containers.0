From: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Subject: Re: Possible race between cgroup_attach_proc and de_thread, and
	questionable code in de_thread.
Date: Mon, 15 Aug 2011 10:11:44 +1000
Message-ID: <20110815101144.39812e9f__37488.2819633514$1313367209$gmane$org@notabene.brown>
References: <20110727171101.5e32d8eb@notabene.brown>
	<20110814174000.GA2381@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110814174000.GA2381-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Paul  E.McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, 14 Aug 2011 19:40:00 +0200 Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> Sorry for delay, just noticed this thread...
> 
> On 07/27, NeilBrown wrote:
> >
> >  The race as I understand it is with this code:
> >
> >
> > 		list_replace_rcu(&leader->tasks, &tsk->tasks);
> > 		list_replace_init(&leader->sibling, &tsk->sibling);
> >
> > 		tsk->group_leader = tsk;
> > 		leader->group_leader = tsk;
> >
> >
> >  which seems to be called with only tasklist_lock held, which doesn't seem to
> >  be held in the cgroup code.
> >
> >  If the "thread_group_leader(leader)" call in cgroup_attach_proc() runs before
> >  this chunk is run with the same value for 'leader', but the
> >  while_each_thread is run after, then the while_read_thread() might loop
> >  forever.  rcu_read_lock doesn't prevent this from happening.
> 
> Yes. This was already discussed. See http://marc.info/?t=127688987300002
> 
> Damn. I forgot about this completely.
> 
> >  The code in de_thread() is actually questionable by itself.
> >  "list_replace_rcu" cannot really be used on the head of a list - it is only
> >  meant to be used on a member of a list.
> >  To move a list from one head to another you should be using
> >  list_splice_init_rcu().
> 
> Hmm... can't understand this part.
> 
> And just in case... list_replace_rcu() looks fine afaics. The real problem
> is release_task(old_leader) which does list_del_rcu(old_leader->thread_group),
> this is what breaks while_each_thread().
> 
> >  The ->tasks list doesn't seem to have a clearly distinguished 'head'
> 
> Exactly. This is the problem.
> 
> But: you seem to confused ->tasks and ->thread_group ;)
> 

That last point is certainly correct.  I caught myself confusing the two
several time and wouldn't be at all surprised if I did it without catching
myself.

de_thread can change the group_leader of a thread_group, and release_task can
remove a non-leader while leaving the rest of the thread_group intact.  So
any while_each_thread() loop needs some extra care to ensure that it doesn't
loop infinitely, because the "head" that it is looking for might not be there
any more.
Maybe there are other rules that ensure this can never happen, but they sure
aren't obvious to me (i.e. if you know them - please tell ;-)

NeilBrown
