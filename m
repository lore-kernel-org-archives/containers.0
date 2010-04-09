From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: restore tty pgrp properly
Date: Thu, 08 Apr 2010 23:23:10 -0400
Message-ID: <4BBE9D9E.1040401@cs.columbia.edu>
References: <4BBDFB60.2080505@lvk.cs.msu.su>
	<20100408210008.GF3345@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100408210008.GF3345-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Nikita V. Youshchenko" <yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org>, Leonid Snegirev <leo-n4oKp6kCDthKyFCjRbgQbg@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Thu, Apr 08, 2010 at 03:50:56PM +0000, Leonid Snegirev wrote:
>> When restoring without keeping old PIDs, it is incorrect to set tty pgrp
>> to same numeric value as it was at checkpoint time. This pgrp may not
>> exist at restore time, and do_tiocspgrp() call from restore_signal()
>> returns -ESRCH.
>>
>> This patch tries to solve this by searching process with pgid equal to 
>> tty->pgrp
>> at checkpoint time, save index of that process in checkpoint, and at use 
>> restore-time
>> pgid of that process to set tty->pgrp at restore.
>>
>> Signed-off-by: Leonid Snegirev <leo-n4oKp6kCDthKyFCjRbgQbg@public.gmane.org>
> 
> Seems like a good idea. However, I suspect this is already covered in userspace
> by rewriting the pids array prior to calling sys_restart(). See
> ckpt_init_tree() in user-cr's restart.c and let me know if you agree
> and/or see any problems with that approach.

Indeed it is in the to-do list to have user-space restart, in the
--no-pids case, adjust the pids all over the checkpoint image, i.e.
in all objects that reference a pid, not only for task creation.

Perhaps a clean way to do this is to create a pid object for c/r,
and then reference this object everywhere a pid is mentioned. This
will rid the need to filter the entire checkpoint image.

Oren.

> 
> Do you have a testcase where restart doesn't work because of problems with
> tty->pgrp restore? Or was this just something that caught your eye during
> review?
> 
> Regardless, thanks for taking the time to put this patch together.
> 
>> ---
>>  checkpoint/signal.c            |   16 +++++++++++++---
>>  include/linux/checkpoint_hdr.h |    2 +-
>>  2 files changed, 14 insertions(+), 4 deletions(-)
>>
>> diff --git a/checkpoint/signal.c b/checkpoint/signal.c
>> index 9d0e9c3..9c90e96 100644
>> --- a/checkpoint/signal.c
>> +++ b/checkpoint/signal.c
>> @@ -323,6 +323,7 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, 
>> struct task_struct *t)
>>      cputime_t cputime;
>>      unsigned long flags;
>>      int i, ret = 0;
>> +    pid_t tty_pgrp, prgp_i;
>>
>>      h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
>>      if (!h)
>> @@ -411,7 +412,16 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, 
>> struct task_struct *t)
>>          if (tty) {
>>              /* irq is already disabled */
>>              spin_lock(&tty->ctrl_lock);
>> -            h->tty_pgrp = ckpt_pid_nr(ctx, tty->pgrp);
>> +            h->tty_pgrp_owner = -1;
>> +            tty_pgrp = ckpt_pid_nr(ctx, tty->pgrp);
>> +            for (i = 0; i < ctx->nr_tasks; i++) {
>> +                pgrp_i = task_pgrp_nr_ns(ctx->tasks_arr[i],
>> +                        ctx->root_nsproxy->pid_ns);
>> +                if (tty_pgrp == pgrp_i) {
>> +                    h->tty_pgrp_owner = i;
>> +                    break;
>> +                }
>> +            }    
>>              spin_unlock(&tty->ctrl_lock);
>>              tty_kref_put(tty);
>>          }
>> @@ -537,13 +547,13 @@ static int restore_signal(struct ckpt_ctx *ctx)
>>          if (ret < 0)
>>              goto out;
>>          /* now restore the foreground group (job control) */
>> -        if (h->tty_pgrp) {
>> +        if (h->tty_pgrp_owner != -1) {
> 
> Userspace can change h->tty_pgrp_owner to any value (bug, cosmic ray,
> exploit attempt) before passing the checkpoint image to restart. We don't 
> want malicious programs to be able to cause an Oops or worse so we need to
> make sure the index is less than the number of entries in the pids_arr.
> Since the value was a prgrp id prior to this patch I doubt that check
> already exists.
> 
>>              /*
>>               * If tty_pgrp == CKPT_PID_NULL, below will
>>               * fail, so no need for explicit test
>>               */
>>              ret = do_tiocspgrp(tty, tty_pair_get_tty(tty),
>> -                       h->tty_pgrp);
>> +                    ctx->pids_arr[h->tty_pgrp_owner].vpgid);
>>              if (ret < 0)
>>                  goto out;
>>          }
> 
> <snip>
> 
> Cheers,
> 	-Matt Helsley
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
