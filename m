From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/5] c/r: let entire thread group in sys_restart before
	restoring a thread
Date: Thu, 01 Oct 2009 15:03:39 -0400
Message-ID: <4AC4FD0B.7010608@librato.com>
References: <1254361634-30076-1-git-send-email-orenl@librato.com>
	<1254361634-30076-3-git-send-email-orenl@librato.com>
	<20091001162026.GC20565@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091001162026.GC20565-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>> Ensure that all members of a thread group are in sys_restart before
>> restoring any of them. Otherwise, restore may modify shared state and
>> crash or fault a thread still in userspace,
>>
>> For thread groups, each thread scans the entire group and tests for
>> PF_RESTARTING on every member. If not all are set, then we wait, and
>> when woken up try again (unless signaled). If all are set, then we're
>> done and wakeup all threads.
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>> ---
>>  checkpoint/restart.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++
>>  1 files changed, 52 insertions(+), 0 deletions(-)
>>
>> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
>> index 5d936cf..37454c5 100644
>> --- a/checkpoint/restart.c
>> +++ b/checkpoint/restart.c
>> @@ -695,6 +695,54 @@ static int do_ghost_task(void)
>>  	/* NOT REACHED */
>>  }
>>
>> +/*
>> + * Ensure that all members of a thread group are in sys_restart before
>> + * restoring any of them. Otherwise, restore may modify shared state
>> + * and crash or fault a thread still in userspace,
>> + */
>> +static int wait_sync_threads(void)
>> +{
>> +	struct task_struct *p, *leader;
>> +
>> +	if (thread_group_empty(current))
>> +		return 0;
>> +
>> +	p = leader = current->group_leader;
>> +
>> +	/*
>> +	 * Our PF_RESTARTING is already set. Each thread loops through
>> +	 * the group testing everyone's PF_RESTARTING. If not set on
>> +	 * all members, it sleeps to retry later. Otherwise it wakes
>> +	 * up all sleepers and returns.
>> +	 */
>> + retry:
>> +	__set_current_state(TASK_INTERRUPTIBLE);
>> +
>> +	read_lock(&tasklist_lock);
>> +	do {
>> +		if (!(p->flags & PF_RESTARTING))
>> +			break;
>> +		p = next_thread(p);
>> +	} while (p != leader);
>> +
>> +	if (p != leader) {
>> +		read_unlock(&tasklist_lock);
>> +		if (signal_pending(current))
> 
> Not sure...  but do you need to get back to TASK_RUNNING
> in this case?  (the schedule() below does it automatically,
> but not this failure case)

Correct. But as you suggested over IRC, I'll change the logic
to avoid unnecessary loops there.

Oren.
