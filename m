From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup_freezer: Freezing and task move race fix
Date: Tue, 10 Aug 2010 18:10:33 -0700
Message-ID: <20100811011033.GF2927__48836.4771161743$1281489124$gmane$org@count0.beaverton.ibm.com>
References: <1281470001-14320-1-git-send-email-tomasz.buchert@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1281470001-14320-1-git-send-email-tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 10, 2010 at 09:53:21PM +0200, Tomasz Buchert wrote:
> Writing 'FROZEN' to freezer.state file does not
> forbid the task to be moved away from its cgroup
> (for a very short time). Nevertheless the moved task
> can become frozen OUTSIDE its cgroup which puts
> discussed task in a permanent 'D' state.

SUMMARY (for supporting info see the "DETAILS" heading below)

I can't reproduce this.

My preliminary conclusion is that your testcase doesn't really reproduce
what you described. Instead, your testcase prints an incorrect message which
could easily lead the person running it to the wrong conclusion.

DETAILS

I tried it with and without the cpuset portions of the testcase on a dual
core bare metal system with a 2.6.31-derived distro kernel. Since it
*should* be obeying the cpuset portions of the testcase I don't think the
fact that it's dual-core should make a difference.

I also tried with a 2.6.34-rc5 kernel in a single-cpu kvm on a different
distro (but on the same physical hardware). I also tried it with and without
the sleep(1) in the child's for(;;) loop in case the cpu load somehow enabled
me to trigger the race.

I used the following bash snippet to run the testcase variations and did not
observe any tasks in the D state:

mount -t cgroup -o freezer,cpuset none /cg
while /bin/true ; do
	./bug /cg
	ps -C bug -o state= | grep D && break
done

If there is a race then I should be able to run that ps line anytime afterwards
to see the stuck task.

Note that the test message:

	printf("Succesfully moved frozen task!\n");

is bogus. In fact there is no guarantee the task or cgroup is frozen at that
point in the testcase. This should be apparent from a careful reading of
Documentation/cgroups/freezer-subsystem.txt, especially:

	This is the basic mechanism which should do the right thing for user space task
	in a simple scenario.

	It's important to note that freezing can be incomplete. In that case we return
	EBUSY. This means that some tasks in the cgroup are busy doing something that
	prevents us from completely freezing the cgroup at this time. After EBUSY,
	the cgroup will remain partially frozen -- reflected by freezer.state reporting
	"FREEZING" when read. The state will remain "FREEZING" until one of these
	things happens:

		1) Userspace cancels the freezing operation by writing "THAWED" to
			the freezer.state file
		2) Userspace retries the freezing operation by writing "FROZEN" to
			the freezer.state file (writing "FREEZING" is not legal
			and returns EINVAL)
		3) The tasks that blocked the cgroup from entering the "FROZEN"
			state disappear from the cgroup's set of tasks.

So simply writing FROZEN to freezer.state is necessary to initiate freezing
but insufficient to assert that the task and/or cgroup is frozen.
That's why the FREEZING state exists. It's intentionally not specified when/why
we can't immediately enter FROZEN. Thus userspace must read the freezer.state
to determine if the current state matches the requested/expected state.

This is why I have the extra ps step in the script above -- to determine
if the task is actually in D. I should also check that the cgroup it belongs
to is THAWED. However while attempting to reproduce your report that hasn't
been necessary -- none of the tasks have even entered the D state.

Which brings us to the final portion of this analysis: Why isn't anything
entering the D state?

The behavior I have been able to reproduce and which is not a bug is
moving the task immediately after writing FROZEN to freezer.state. We don't
know the state of the task or cgroup at that time (in this testcase) so
this is acceptable. I've even made a sequence of modifications to your
testcase and run it after each modification to bring it successively more
in line with correct use of the cgroup freezer. I still was unable to
reproduce your report.

So I'm fairly confident there is no bug. I say "fairly" because there may
be some aspect of your system that I am not reproducing. At this point it
would be great if you could provide more details so I can more thoroughly
attempt to recreate your conditions.

Cheers,
	-Matt Helsley

> 
> This patch forbids migration of either FROZEN
> or FREEZING tasks.
> 
> This behavior was observed and easily reproduced on
> a single core laptop. Program and instructions how
> to reproduce the bug can be fetched from:
> http://pentium.hopto.org/~thinred/repos/linux-misc/freezer_bug.c
> 
> Signed-off-by: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
> ---
>  kernel/cgroup_freezer.c |   10 ++++++++--
>  1 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index ce71ed5..e49aa8c 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -161,6 +161,12 @@ static bool is_task_frozen_enough(struct task_struct *task)
>  		(task_is_stopped_or_traced(task) && freezing(task));
>  }
> 
> +/* Task is in a state that forbids any cgroup migration. */
> +static bool is_task_pinned_down(struct task_struct *task)
> +{
> +	return freezing(task) || frozen(task);
> +}
> +
>  /*
>   * The call to cgroup_lock() in the freezer.state write method prevents
>   * a write to that file racing against an attach, and hence the
> @@ -179,7 +185,7 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
>  	 * frozen, so it's sufficient to check the latter condition.
>  	 */
> 
> -	if (is_task_frozen_enough(task))
> +	if (is_task_pinned_down(task))
>  		return -EBUSY;
> 
>  	freezer = cgroup_freezer(new_cgroup);
> @@ -191,7 +197,7 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
> 
>  		rcu_read_lock();
>  		list_for_each_entry_rcu(c, &task->thread_group, thread_group) {
> -			if (is_task_frozen_enough(c)) {
> +			if (is_task_pinned_down(c)) {
>  				rcu_read_unlock();
>  				return -EBUSY;
>  			}
> -- 
> 1.6.3.3
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
