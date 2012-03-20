From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Q: cgroup: Questions about possible issues in cgroup locking
Date: Tue, 20 Mar 2012 20:34:14 +0100
Message-ID: <20120320193414.GA21277__23457.7666888528$1332272522$gmane$org@redhat.com>
References: <20120106182535.GJ9511@google.com>
	<20120111160730.GA24556@redhat.com>
	<20120112003102.GB9511@google.com>
	<20120112170728.GA25717@redhat.com>
	<20120112175725.GD9511@google.com>
	<20120113152010.GA19215@redhat.com>
	<20120113182750.GD18166@google.com>
	<20120114173648.GA32543@redhat.com>
	<20120118231742.GS18166@google.com>
	<20120119154522.GA14058@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120119154522.GA14058-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

OK, finally we should do something with this problem ;)

On 01/19, Oleg Nesterov wrote:
>
> I'll try to investigate if we can remove
>
> 	leader->group_leader = tsk;
>
> from de_thread(). In fact I already thought about this change a long
> ago without any connection to while_each_thread(). This assignment
> looks "assymetrical" compared to other threads we kill. But we did
> have a reason (reasons?). Hopefully, the only really important reason
> was already removed by 087806b1.

On the second thought, I think we should not do this.

For example, do_prlimit() assumes that tsk->group_leader is correct
under tasklist_lock.

OK, lets return to the thread_group_leader() check. To ensure we do
not visit the same thread twice we can check 'g', not 't'.

This is what I am going to send, after I re-check once again...

I have the problem with the changelog ;) Somehow it should explain
that while_each_thread_rcu(g, t) can't race with do_group_exit().
I think it can't, list_del_rcu(leader->thread_group) happens when
this entry is already "empty", it should be the last thread in group.
If the non-leader thread goes away from the least, we still have
the "path" to reach the leader. But this is not easy to explain.

As for the barrier. If de_thread() changes the leader it drops
and re-acquires tasklist_lock (this implies mb) after it changes
old_leader->exit_signal (used in thread_group_leader) and before
__unhash_process() which does list_del_rcu().

This means that if while_each_thread() sees the result of
list_del_rcu(old_leader) it must also see that
thread_group_leader(old_leader) != T.

What do you think? Do you see any problems?

Oleg.
---

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7d379a6..f169bfd 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2323,9 +2323,24 @@ extern bool current_is_single_threaded(void);
 #define do_each_thread(g, t) \
 	for (g = t = &init_task ; (g = t = next_task(g)) != &init_task ; ) do
 
+/*
+ * needs tasklist_lock or ->siglock, or rcu if the caller ensures
+ * that 'g' can't exit or exec.
+ */
 #define while_each_thread(g, t) \
 	while ((t = next_thread(t)) != g)
 
+/*
+ * rcu-safe, but should start at ->group_leader.
+ * thread_group_leader(g) protects against the race with exec which
+ * removes the leader from list.
+ * smp_rmb() pairs with implicit mb() implied by unlock + lock in
+ * de_thread()->release_task() path.
+ */
+#define while_each_thread_rcu(g, t)				\
+	while ((t = next_thread(t)) != g &&			\
+		({ smp_rmb(); thread_group_leader(g); }))
+
 static inline int get_nr_threads(struct task_struct *tsk)
 {
 	return tsk->signal->nr_threads;
