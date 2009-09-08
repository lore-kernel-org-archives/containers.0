From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 5/6] c/r: correctly restore pgid
Date: Tue, 08 Sep 2009 09:33:04 -0400
Message-ID: <4AA65D10.6000702@librato.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
	<1252074054-22241-6-git-send-email-orenl@librato.com>
	<20090908030445.GB16460@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090908030445.GB16460-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oren Laadan <orenl-3n9FKfXVdfcggxPgtCmjjw@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>> The main challenge with restoring the pgid of tasks is that the
>> original "owner" (the process with that pid) might have exited
>> already. I call these "ghost" pgids. 'mktree' does create these
>> processes, but they then exit without participating in the restart.
>>
>> To solve this, this patch introduces a RESTART_GHOST flag, used for
>> "ghost" owners that are created only to pass their pgid to other
>> tasks. ('mktree' now makes them call restart(2) instead of exiting).
>>
>> When a "ghost" task calls restart(2), it will be placed on a wait
>> queue until the restart completes and then exit. This guarantees that
>> the pgid that it owns remains available for all (regular) restarting
>> tasks for when they need it.
>>
>> Regular tasks perform the restart as before, except that they also
>> now restore their old pgrp, which is guaranteed to exist.
>>
>> Changelog [v1]:
>>   - Verify that pgid owner is a thread-group-leader.
>>   - Handle the case of pgid/sid == 0 using root's parent pid-ns
>>
>> Signed-off-by: Oren Laadan <orenl-3n9FKfXVdfcggxPgtCmjjw@public.gmane.org>
>> ---
>>  checkpoint/process.c             |  106 ++++++++++++++++++++++++-
>>  checkpoint/restart.c             |  158 ++++++++++++++++++++++++++------------
>>  checkpoint/sys.c                 |    3 +-
>>  include/linux/checkpoint.h       |   11 ++-
>>  include/linux/checkpoint_hdr.h   |    3 +
>>  include/linux/checkpoint_types.h |    6 +-
>>  6 files changed, 230 insertions(+), 57 deletions(-)
>>
>> diff --git a/checkpoint/process.c b/checkpoint/process.c
>> index 40b2580..5d6bdb9 100644
>> --- a/checkpoint/process.c
>> +++ b/checkpoint/process.c
>> @@ -23,6 +23,57 @@
>>  #include <linux/syscalls.h>
>>
>>
>> +pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid)
>> +{
>> +	return pid ? pid_nr_ns(pid, ctx->root_nsproxy->pid_ns) : CKPT_PID_NULL;
>> +}
>> +
>> +/* must be called with tasklist_lock or rcu_read_lock() held */
>> +struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid)
>> +{
>> +	struct task_struct *p;
>> +	struct pid *pgrp;
>> +
>> +	if (pgid == 0) {
>> +		/*
>> +		 * At checkpoint the pgid owner lived in an ancestor
>> +		 * pid-ns. The best we can do (sanely and safely) is
>> +		 * to examine the parent of this restart's root: if in
>> +		 * a distinct pid-ns, use its pgrp; otherwise fail.
>> +		 */
>> +		p = ctx->root_task->real_parent;
>> +		if (p->nsproxy->pid_ns == current->nsproxy->pid_ns)
>> +			return NULL;
>> +		pgrp = task_pgrp(p);
>> +	} else {
>> +		/*
>> +		 * Find the owner process of this pgid (it must exist
>> +		 * if pgrp exists). It must be a thread group leader.
>> +		 */
>> +		pgrp = find_vpid(pgid);
>> +		p = pid_task(pgrp, PIDTYPE_PID);
>> +		if (!p || !thread_group_leader(p))
>> +			return NULL;
>> +		/*
>> +		 * The pgrp must "belong" to our restart tree (compare
>> +		 * p->checkpoint_ctx to ours). This prevents malicious
>> +		 * input from (guessing and) using unrelated pgrps. If
>> +		 * the owner is dead, then it doesn't have a context,
>> +		 * so instead compare against its (real) parent's.
>> +		 */
>> +		if (p->exit_state == EXIT_ZOMBIE)
>> +			p = p->real_parent;
>> +		if (p->checkpoint_ctx != ctx)
>> +			return NULL;
>> +	}
>> +
>> +	if (task_session(current) != task_session(p))
>> +		return NULL;
>> +
>> +	return pgrp;
>> +}
>> +
>> +
>>  #ifdef CONFIG_FUTEX
>>  static void save_task_robust_futex_list(struct ckpt_hdr_task *h,
>>  					struct task_struct *t)
>> @@ -94,8 +145,8 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
>>  		h->exit_signal = t->exit_signal;
>>  		h->pdeath_signal = t->pdeath_signal;
>>
>> -		h->set_child_tid = t->set_child_tid;
>> -		h->clear_child_tid = t->clear_child_tid;
>> +		h->set_child_tid = (unsigned long) t->set_child_tid;
> 
> note that set_child_tid is an int (signed), not a long.  Same on
> x86, but not on other arches.  Shouldn't lose info so could be worse.

{set,clear}_child_tid are both pointers to user space: it's an address
in userspace, so we save it as 'unsigned long'.

{clear,set}_child_tid is defined in include/linux/sched.h ... how can
it differ for different archs ?

> 
> On the whole,
> 
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Thanks. I got a few fixes for the code piles up and now c/r of 'screen'
with a couple of shells is working :)

Oren.
