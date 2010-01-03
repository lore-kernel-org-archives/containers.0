From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: +
	cgroups-add-functionality-to-read-write-lock-clone_thread-forking-pe
	r-threadgroup.patch added to -mm tree
Date: Sun, 3 Jan 2010 14:06:14 -0500
Message-ID: <20100103190613.GA13423@andrew.cmu.edu>
References: <200908202114.n7KLEN5H026646@imap1.linux-foundation.org>
	<20090821102611.GA2611@redhat.com>
	<20090821104528.GA3487@redhat.com>
	<6599ad830908211637w6c9fd3a7tbe41bc106ada03d7@mail.gmail.com>
	<20090822130952.GA4240@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090822130952.GA4240-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Aug 22, 2009 at 03:09:52PM +0200, Oleg Nesterov wrote:
> 
> OK, cgroups-add-ability-to-move-all-threads-in-a-process-to-a-new-cgroup-atomically.patch
> does
> 
> 	threadgroup_sighand = threadgroup_fork_lock(leader);
> 
> 	rcu_read_lock();
> 	list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group)
> 
> and this is equally wrong afais. Hmm, and other similar
> list_for_each_entry_rcu's doesn't look right. This code can do something
> like
> 
> 	rcu_read_lock();
> 	if (!tsk->sighand)	// tsk is leader or not, doesn't matter
> 		fail;
> 	list_for_each_rcu(tsk->thread_group) {}
> 	rcu_read_unlock();
> 
> though.
> 
> 
> 
> And why do we need sighand->threadgroup_fork_lock ? I gueess, to protect
> against clone(CLONE_THREAD).
> 
> But. threadgroup_fork_lock() has another problem. Even if the process
> P is singlethreaded, I can't see how ->threadgroup_fork_lock work.
> 
> threadgroup_fork_lock() bumps P->sighand->count. If P exec, it will
> notice sighand->count != 1 and switch to another ->sighand.
> 
> Oleg.

So how about this: Each time we take tasklist_lock to iterate over
thread_group (once in getting the sighand, once to move all the tasks),
check if we raced with exec. The two problems are 1) group_leader
changes - we'll need to find the new leader's task_struct anyway - means
we can't iterate over thread_group, and 2) sighand changes after we take
the old one, means we've taken a useless lock.

I put together draft revisions of the old patches that check for racing
with exec in both cases, and if so, returning EAGAIN. I have the wrapper
function cgroup_procs_write loop around the return value, but it could
also possibly give EAGAIN back to userspace. Hopefully the code is safe
and sane this time :)

-- bblum

---
 Documentation/cgroups/cgroups.txt |    7
 include/linux/cgroup.h            |   14 -
 include/linux/init_task.h         |    9
 include/linux/sched.h             |   15 +
 kernel/cgroup.c                   |  519 ++++++++++++++++++++++++++++++++++----
 kernel/fork.c                     |    9
 6 files changed, 524 insertions(+), 49 deletions(-)
