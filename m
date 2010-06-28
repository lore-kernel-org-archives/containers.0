From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [RFC] [PATCH v3 1/2] cgroups: read-write lock CLONE_THREAD
	forking per threadgroup
Date: Mon, 28 Jun 2010 11:43:59 -0400
Message-ID: <20100628154359.GA24629__9393.63912116296$1277739926$gmane$org@ghc01.ghc.andrew.cmu.edu>
References: <20100625054541.GA20610@ghc01.ghc.andrew.cmu.edu>
	<20100625054654.GB20610@ghc01.ghc.andrew.cmu.edu>
	<20100628161031.a8c71fce.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100628161031.a8c71fce.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 28, 2010 at 04:10:31PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 25 Jun 2010 01:46:54 -0400
> Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> 
> > Adds functionality to read/write lock CLONE_THREAD fork()ing per-threadgroup
> > 
> > From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
> > 
> > This patch adds an rwsem that lives in a threadgroup's signal_struct that's
> > taken for reading in the fork path, under CONFIG_CGROUPS. If another part of
> > the kernel later wants to use such a locking mechanism, the CONFIG_CGROUPS
> > ifdefs should be changed to a higher-up flag that CGROUPS and the other system
> > would both depend on.
> > 
> > This is a pre-patch for cgroups-procs-write.patch.
> > 
> 
> Hmm, at adding a new lock, please describe its semantics.
> Following is my understanding, right ?
> 
> Lock range:
> This rwsem is read-locked from cgroup_fork() to cgroup_post_fork(). 
> Most of works for fork() are between cgroup_fork() and cgroup_post_for().
> This means if sig->threadgroup_fork_lock is held, no new do_work() can
> make progress in this process groups. This rwsem is held only when
> CLONE_THREAD is in clone_flags. IOW, this rwsem is taken only at creating
> new thread.
> 
> What we can do with this:
> By locking sig->threadgroup_fork_lock, a code can visit _all_ threads
> in a process group witout any races. So, if you want to implement an
> atomic operation against a process, taking this lock is an idea.
> 
> For what:
> To implement an atomic process move in cgroup, we need this lock.

All good. Should a description like this go in Documentation/ somewhere,
or above the declaration of the lock?

> Why this implemantation:
> Considering cgroup, threads in a cgroup can be under several different
> cgroup. So, we can't implement lock in cgroup-internal, we use signal
> struct.

Not entirely, though that's an additional restriction... The reason it's
in signal_struct: signal_struct is per-threadgroup and has exactly the
lifetime rules we want. Putting the lock in task_struct and taking
current->group_leader->signal... seems like it would also work, but
introduces cacheline conflicts that weren't there before, since fork
doesn't look at group_leader (but it does bump signal's count).

> By the way, IMHO, hiding lock in cgroup_fork() and cgroup_post_fork() doesn't
> seem good idea. How about a code like this ?
> 
>   read_lock_thread_clone(current);
>   cgroup_fork();
>  .....
>   cgroup_post_fork();
>   read_unlock_thrad_clone(current);
> 
> We may have chances to move these lock to better position if cgroup is
> an only user.

I didn't do that out of a desire to change fork.c as little as possible,
but that does look better than what I've got. Those two functions should
be in fork.c under #ifdef CONFIG_CGROUPS.

> 
> Thanks,
> -Kame

Thanks,
-- Ben
