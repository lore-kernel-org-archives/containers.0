From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] pidns: Fix wait for zombies to be reaped in zap_pid_ns_processes
Date: Wed, 14 Jul 2010 14:35:52 -0700
Message-ID: <m14og1oifb.fsf@fess.ebiederm.org>
References: <20100625212758.GA30474@redhat.com>
	<20100625220713.GA31123@us.ibm.com>
	<m1r5jd5l0v.fsf_-_@fess.ebiederm.org>
	<m1mxu15kv4.fsf_-_@fess.ebiederm.org>
	<20100709121425.GB18586@hawkmoon.kerlabs.com>
	<m1lj9k4xfx.fsf@fess.ebiederm.org>
	<20100709141324.GC18586@hawkmoon.kerlabs.com>
	<m1aaq04ph2.fsf_-_@fess.ebiederm.org>
	<20100711141406.GD18586@hawkmoon.kerlabs.com>
	<m1tyo4shas.fsf_-_@fess.ebiederm.org>
	<20100714205324.GA13956@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714205324.GA13956@us.ibm.com> (Sukadev Bhattiprolu's message of "Wed\, 14 Jul 2010 13\:53\:24 -0700")
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>, Oleg Nesterov <oleg@redhat.com>, "Serge E. Hallyn" <serge@hallyn.com>
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com> writes:

> Eric W. Biederman [ebiederm@xmission.com] wrote:
> | 
> |   Changing zap_pid_ns_processes to fix the problem instead of
> |   changing the code elsewhere is one of the few solutions I have
> |   seen that does not increase the cost of the lat_proc test from
> |   lmbench.
>
> I think its a good fix for the problem. but I have a nit and a minor
> comment below.
>
> Thanks,
>
> Sukadev
>
> | 
> | Reported-by: Louis Rilling <Louis.Rilling@kerlabs.com>
>
> Reviewed-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
>
> | Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> | ---
> |  kernel/pid_namespace.c |   50 ++++++++++++++++++++++++++++++++++++-----------
> |  1 files changed, 38 insertions(+), 12 deletions(-)
> | 
> | diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
> | index a5aff94..aaf2ab0 100644
> | --- a/kernel/pid_namespace.c
> | +++ b/kernel/pid_namespace.c
> | @@ -139,16 +139,20 @@ void free_pid_ns(struct kref *kref)
> | 
> |  void zap_pid_ns_processes(struct pid_namespace *pid_ns)
> |  {
> | +	struct task_struct *me = current;
> |  	int nr;
> |  	int rc;
> |  	struct task_struct *task;
> | 
> |  	/*
> | -	 * The last thread in the cgroup-init thread group is terminating.
> | -	 * Find remaining pid_ts in the namespace, signal and wait for them
> | -	 * to exit.
> | +	 * The last task in the pid namespace-init threa group is terminating.
>
> nit:                                               thread

Agreed.

> | +	 * Find remaining pids in the namespace, signal and wait for them
> | +	 * to to be reaped.
> |  	 *
> | -	 * Note:  This signals each threads in the namespace - even those that
> | +	 * By waiting for all of the tasks to be reaped before init is reaped
> | +	 * we provide the invariant that no task can escape the pid namespace.
> | +	 *
> | +	 * Note:  This signals each task in the namespace - even those that
> |  	 * 	  belong to the same thread group, To avoid this, we would have
> |  	 * 	  to walk the entire tasklist looking a processes in this
> |  	 * 	  namespace, but that could be unnecessarily expensive if the
> | @@ -157,28 +161,50 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
> |  	 *
> |  	 */
> |  	read_lock(&tasklist_lock);
> | -	nr = next_pidmap(pid_ns, 1);
> | -	while (nr > 0) {
> | -		rcu_read_lock();
> | +	for (nr = next_pidmap(pid_ns, 0); nr > 0; nr = next_pidmap(pid_ns, nr)) {
>
> Is it necessary to start the search at nr == 0 ? We will find nr == 1
> first and then immediately skip over it - bc same_thread_group() will
> be TRUE.

Which means we exercise that code path, and ensure we have same_thread_group
test working properly.  Given how rare threaded inits are every little bit
of extra test coverage that doesn't really cost us anything seems important.

> |  		/*
> |  		 * Any nested-container's init processes won't ignore the
> |  		 * SEND_SIG_NOINFO signal, see send_signal()->si_fromuser().
> |  		 */
> | -		task = pid_task(find_vpid(nr), PIDTYPE_PID);
> | -		if (task)
> | +		rcu_read_lock();
> | +		task = pid_task(find_pid_ns(nr, pid_ns), PIDTYPE_PID);
> | +		if (task && !same_thread_group(task, me))
> |  			send_sig_info(SIGKILL, SEND_SIG_NOINFO, task);
>
> Also, if we start the search at 1, we could skip the only the other possible
> thread in the group with
>
> 	(nr != my_pid_nr)
>
> but its not really an optimization.

It is possible that other threads of a multi-threaded init are in the PF_EXITING
state and still visible for sending signals to.  I really don't want to send
SIG_KILL to another thread of init.  There is a chance of messing up the return
code if I do that, and do not want to need to think about that case.

Eric
