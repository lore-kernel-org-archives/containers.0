From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Q: cgroup: Questions about possible issues in cgroup locking
Date: Wed, 21 Dec 2011 14:08:48 +0100
Message-ID: <20111221130848.GA19679__12400.8568971933$1324473283$gmane$org@redhat.com>
References: <20111221034334.GD17668@somewhere>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111221034334.GD17668@somewhere>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12/21, Frederic Weisbecker wrote:
> Hi,
>
> Starring at some parts of cgroups, I have a few questions:
>
> - Is cgroup_enable_task_cg_list()'s while_each_thread() safe
> against concurrent exec()? The leader may change in de_thread()
> and invalidate the test done in while_each_thread().

Yes. Oh, we need to do something with while_each_thread.

> - do_each_thread() also needs RCU and cgroup_enable_task_cg_list()
> seems to remind it. But it seems there is at least one caller that
> doesn't call rcu_read_lock(): update_cpu_mask() -> update_tasks_cpumask() -> cgroup_scan_tasks()

I don't see any caller which takes rcu_read_lock...

> - By the time we call cgroup_post_fork(), it is ready to be woken up
> and usable by the scheduler.

No, the new child can't run until do_fork()->wake_up_new_task().

> - Is the check for use_task_css_set_links in cgroup_post_fork() safe? given
> it is checked outside css_set_lock?
>
> Imagine this:
>
> CPU 0                                                        CPU 1
> ----                                                         -----
>
> cgroup_enable_task_cg() {
> 	uset_tasks_css_set_links = 1
> 	for_each_thread() {
> 		add tasks in the list
> 	}
> }
>                                                            do_fork() {
>                                                                cgroup_post_fork() {
>                                                                      use_tasks_css_set_links appears
>                                                                      to be equal to 0 due to write/read
>                                                                       not flushed. New task won't
>                                                                       appear to the list.

Yes, I was thinking about this too.

Or (I think) they can race "contrariwise". CPU_1 creates the new child,
then CPU_0 sets uset_tasks_css_set_links = 1. But afaics there is no any
guarantee that CPU_0 sees the result of list_add_tail_rcu().

Oleg.
