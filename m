From: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Subject: Re: Possible race between cgroup_attach_proc and de_thread, and
	questionable code in de_thread.
Date: Mon, 15 Aug 2011 09:58:20 +1000
Message-ID: <20110815095820.33607862__9270.48328235305$1313366374$gmane$org@notabene.brown>
References: <20110727171101.5e32d8eb@notabene.brown>
	<20110727150710.GB5242@unix33.andrew.cmu.edu>
	<20110727234235.GA2318@linux.vnet.ibm.com>
	<20110728110813.7ff84b13@notabene.brown>
	<20110728121741.GB2427@linux.vnet.ibm.com>
	<20110814175119.GC2381@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110814175119.GC2381-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, 14 Aug 2011 19:51:19 +0200 Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On 07/28, Paul E. McKenney wrote:
> >
> > On Thu, Jul 28, 2011 at 11:08:13AM +1000, NeilBrown wrote:
> > >
> > > I disagree.  It also requires - by virtue of the use of while_each_thread() -
> > > that 'g' remains on the list that 't' is walking along.
> >
> > Doesn't the following code in the loop body deal with this possibilty?
> >
> > 	/* Exit if t or g was unhashed during refresh. */
> > 	if (t->state == TASK_DEAD || g->state == TASK_DEAD)
> > 		goto unlock;
> 
> This code is completely wrong even if while_each_thread() was fine.
> 
> I sent the patch but it was ignored.
> 
> 	[PATCH] fix the racy check_hung_uninterruptible_tasks()->rcu_lock_break()
> 	http://marc.info/?l=linux-kernel&m=127688790019041
> 
> Oleg.


I agree with that patch.
RCU only protects a task_struct until release_task() is called (which
removes it from the task list).

So holding rcu_lock doesn't stop put_task_struct from freeing the memory
unless we *know* that release_task hasn't been called.  This is exactly that
pid_alive() tests.


I must say that handling of task_struct seems to violate the law of least
surprise a little to often for my taste.  Maybe it is just a difficult
problem and it needs a complex solution - but it would be really nice if it
were a bit simpler :-(

NeilBrown
