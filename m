From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 5/5] Deny external checkpoint unless task is frozen
Date: Thu, 12 Mar 2009 23:19:25 -0400
Message-ID: <49B9D0BD.40701@cs.columbia.edu>
References: <20090312042416.GC7733@us.ibm.com>	<20090312042614.GE8703@us.ibm.com>
	<20090312173707.GC17253@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090312173707.GC17253-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>> Subject: [PATCH 5/5] Deny external checkpoint unless task is frozen
>>
>> Remove a 'FIXME' and ensure that the tasks we are checkpointing are
>> frozen unless its a self-checkpoint.
>>
>> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> I remain not-a-fan of self-checkpoint, and think it needlessly
> complicates locking, but it isn't for this patch to change that :)

lol ... here's is an interesting use case for self checkpoint: "ASSURE:
Automatic Software Self-healing Using REscue points" (ASPLOS 2009).

Oren.

> 
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
>> ---
>>  checkpoint/checkpoint.c |    5 ++++-
>>  1 files changed, 4 insertions(+), 1 deletions(-)
>>
>> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
>> index 9189abb..cfa6b4f 100644
>> --- a/checkpoint/checkpoint.c
>> +++ b/checkpoint/checkpoint.c
>> @@ -19,6 +19,7 @@
>>  #include <linux/mount.h>
>>  #include <linux/utsname.h>
>>  #include <linux/magic.h>
>> +#include <linux/freezer.h>
>>  #include <linux/checkpoint.h>
>>  #include <linux/checkpoint_hdr.h>
>>
>> @@ -280,7 +281,9 @@ static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
>>  	if (!ptrace_may_access(t, PTRACE_MODE_READ))
>>  		return -EPERM;
>>
>> -	/* FIXME: verify that the task is frozen (unless self) */
>> +	/* verify that the task is frozen (unless self) */
>> +	if (t != current && !frozen(t))
>> +		return -EBUSY;
>>
>>  	/* FIXME: change this for nested containers */
>>  	if (task_nsproxy(t) != ctx->root_nsproxy)
>> -- 
>> 1.5.2.5
>>
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linux-foundation.org/mailman/listinfo/containers
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
