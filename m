From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 7/8] Adds functionality to read/write lock CLONE_THREAD
	fork()ing per-threadgroup
Date: Thu, 20 Aug 2009 10:39:12 +0800
Message-ID: <4A8CB750.7040509__27110.1236962297$1250736071$gmane$org@cn.fujitsu.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
	<20090818235843.22531.57310.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090818235843.22531.57310.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> 
> Adds functionality to read/write lock CLONE_THREAD fork()ing per-threadgroup
> 
> This patch adds an rwsem that lives in a threadgroup's sighand_struct (next to
> the sighand's atomic count, to piggyback on its cacheline), and two functions
> in kernel/cgroup.c (for now) for easily+safely obtaining and releasing it. If
> another part of the kernel later wants to use such a locking mechanism, the
> CONFIG_CGROUPS ifdefs should be changed to a higher-up flag that CGROUPS and
> the other system would both depend on, and the lock/unlock functions could be
> moved to sched.c or so.
> 
> Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>

Looks fine to me.

Acked-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

... 

> +struct sighand_struct *threadgroup_fork_lock(struct task_struct *tsk)
> +{
> +	struct sighand_struct *sighand;
> +	struct task_struct *p;
> +
> +	/* tasklist lock protects sighand_struct's disappearance in exit(). */
> +	read_lock(&tasklist_lock);
> +	if (likely(tsk->sighand)) {
> +		/* simple case - check the thread we were given first */
> +		sighand = tsk->sighand;
> +	} else {
> +		sighand = NULL;
> +		/*
> +		 * tsk is exiting; try to find another thread in the group
> +		 * whose sighand pointer is still alive.
> +		 */
> +		rcu_read_lock();

since we are holding tasklist_lock, I think we don't need to
take rcu lock?

> +		list_for_each_entry_rcu(p, &tsk->thread_group, thread_group) {
> +			if (p->sighand) {
> +				sighand = tsk->sighand;

s/tsk->sighand/p->sighand

> +				break;
> +			}
> +		}
> +		rcu_read_unlock();
> +	}
