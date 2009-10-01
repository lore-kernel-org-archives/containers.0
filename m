From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/5] c/r: simplify logic of tracking restarting tasks
Date: Thu, 01 Oct 2009 12:21:54 -0400
Message-ID: <4AC4D722.8010807@librato.com>
References: <1254361634-30076-1-git-send-email-orenl@librato.com>
	<1254361634-30076-2-git-send-email-orenl@librato.com>
	<20091001155823.GB20565@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091001155823.GB20565-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
>> Instead of playing tricks with xchg() of task->checkpoint_ctx, use the
>> task_{lock,unlock} to protect changes to that pointer. This simplifies
>> the logic since we no longer need to check for races (and old_ctx).
>>
>> The remaining changes include cleanup, and unification of common code
>> to handle errors during restart, and some debug statements.
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>> ---
>>  checkpoint/restart.c       |  170 ++++++++++++++++++++++----------------------
>>  checkpoint/sys.c           |    6 +-
>>  include/linux/checkpoint.h |    2 +-
>>  kernel/fork.c              |    6 +-
>>  4 files changed, 92 insertions(+), 92 deletions(-)
>>
>> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
>> index 543b380..5d936cf 100644
>> --- a/checkpoint/restart.c
>> +++ b/checkpoint/restart.c
>> @@ -529,17 +529,54 @@ static inline int is_task_active(struct ckpt_ctx *ctx, pid_t pid)
>>
>>  static inline void _restore_notify_error(struct ckpt_ctx *ctx, int errno)
>>  {
>> -	ckpt_set_ctx_error(ctx, errno);
>> -	complete(&ctx->complete);
>> +	/* first to fail: notify everyone (racy but harmless) */
>> +	if (!ckpt_test_ctx_error(ctx)) {
>> +		ckpt_debug("setting restart error %d\n", errno); \
>> +		ckpt_set_ctx_error(ctx, errno);
>> +		complete(&ctx->complete);
>> +		wake_up_all(&ctx->waitq);
>> +		wake_up_all(&ctx->ghostq);
>> +	}
>>  }
>>
>>  /* Need to call ckpt_debug such that it will get the correct source location */
>>  #define restore_notify_error(ctx, errno) \
>>  do { \
>> -	ckpt_debug("ctx root pid %d err %d", ctx->root_pid, errno); \
>> +	ckpt_debug("restart error %d, root pid %d\n", errno, ctx->root_pid); \
>>  	_restore_notify_error(ctx, errno); \
>>  } while(0)
>>
> 
> Maybe make a note that these can't be called under
> write_lock_irq(&tasklist_lock)?  Also, update the comment above
> task_lock() to add checkpoint_ctx to the list of things protected
> by it.

Right.

> 
>> +static inline struct ckpt_ctx *get_task_ctx(struct task_struct *task)
>> +{
>> +	struct ckpt_ctx *ctx;
>> +
>> +	task_lock(task);
>> +	ctx = ckpt_ctx_get(task->checkpoint_ctx);
>> +	task_unlock(task);
>> +	return ctx;
>> +}
>> +
>> +/* returns 1 on success, 0 otherwise */
> 
> This works, but it's more confusing than it needs to be.  I think using
> two helpers, 'set_task_ctx(tsk, ctx)' and 'clear_task-ctx(tsk)', where
> set_task_ctx always bails if task->checkpoint_ctx is set, would be much
> easier to read.
> 

Sure.

> But
> 
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Thanks,

Oren.
