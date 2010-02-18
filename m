From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH RFC] checkpoint: handle saved_sigmask
Date: Thu, 18 Feb 2010 11:50:06 -0500
Message-ID: <4B7D6FBE.5010805@cs.columbia.edu>
References: <20100202180718.GA28249@us.ibm.com>
	<20100218160846.GA9141@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100218160846.GA9141-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> I thought there had been followup discussion on this, but I don't
> see it in my mbox.  (maybe it was on irc?)

The patch seems correct.

The only comment is that naming the hook "task_restore_sigmask"
confused me to think it is part of restart logic, which it isn't.

How about "task_saved_sigmask" instead ?

> Did we decide to punt on this until v20?

Probably better to add to v19 while we're at it. I'll do it
right away unless you object to the name change.

Oren.

> 
> -serge
> 
> Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> Each arch seems to have its own way of specifying that
>> current->saved_sigmask should contains the valid blocked
>> sigmask.  So provide an arch-specific hook for that test,
>> and, if true, then store saved_sigmask in place of blocked
>> in the checkpoint image.  None of the architectures currently
>> save these flags, so we don't need to do anything special
>> to unset them after restart.
>>
>> If right after sys_restart the a signal needs to be handled
>> (which was sent during restart) then it will just do the right
>> thing (save blocked back to saved_sigmask and set
>> TIF_RESTORE_SIGMASK or whatever).
>>
>> Thoughts?
>>
>> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> ---
>>  arch/powerpc/kernel/signal.c  |    9 +++++++++
>>  arch/s390/kernel/checkpoint.c |    2 --
>>  arch/s390/kernel/signal.c     |    7 +++++++
>>  arch/x86/kernel/signal.c      |    6 ++++++
>>  checkpoint/signal.c           |    5 ++++-
>>  include/linux/signal.h        |    6 ++++++
>>  6 files changed, 32 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/powerpc/kernel/signal.c b/arch/powerpc/kernel/signal.c
>> index 00b5078..4aa0128 100644
>> --- a/arch/powerpc/kernel/signal.c
>> +++ b/arch/powerpc/kernel/signal.c
>> @@ -188,6 +188,15 @@ static int do_signal_pending(sigset_t *oldset, struct pt_regs *regs)
>>  	return ret;
>>  }
>>
>> +int task_restore_sigmask(struct task_struct *task)
>> +{
>> +	struct thread_info *ti = task_thread_info(task);
>> +	if (ti->local_flags & _TLF_RESTORE_SIGMASK)
>> +		return 1;
>> +	return 0;
>> +}
>> +
>> +
>>  void do_signal(struct pt_regs *regs, unsigned long thread_info_flags)
>>  {
>>  	if (thread_info_flags & _TIF_SIGPENDING)
>> diff --git a/arch/s390/kernel/checkpoint.c b/arch/s390/kernel/checkpoint.c
>> index 092fd87..048e820 100644
>> --- a/arch/s390/kernel/checkpoint.c
>> +++ b/arch/s390/kernel/checkpoint.c
>> @@ -200,8 +200,6 @@ int restore_thread(struct ckpt_ctx *ctx)
>>  		set_thread_flag(TIF_RESTARTBLOCK);
>>  	}
>>
>> -	/* need to do something with TIF_RESTORE_SIGMASK ? */
>> -
>>  	ckpt_hdr_put(ctx, h);
>>  	return 0;
>>  }
>> diff --git a/arch/s390/kernel/signal.c b/arch/s390/kernel/signal.c
>> index 503fd09..0654f12 100644
>> --- a/arch/s390/kernel/signal.c
>> +++ b/arch/s390/kernel/signal.c
>> @@ -538,6 +538,13 @@ void do_signal(struct pt_regs *regs)
>>  	}
>>  }
>>
>> +int task_restore_sigmask(struct task_struct *task)
>> +{
>> +	if (test_tsk_thread_flag(task, TIF_RESTORE_SIGMASK))
>> +		return 1;
>> +	return 0;
>> +}
>> +
>>  void do_notify_resume(struct pt_regs *regs)
>>  {
>>  	clear_thread_flag(TIF_NOTIFY_RESUME);
>> diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
>> index 6a44a76..a6e8035 100644
>> --- a/arch/x86/kernel/signal.c
>> +++ b/arch/x86/kernel/signal.c
>> @@ -849,6 +849,12 @@ static void do_signal(struct pt_regs *regs)
>>  	}
>>  }
>>
>> +int task_restore_sigmask(struct task_struct *task) {
>> +	if (task_thread_info(t)->status & TS_RESTORE_SIGMASK)
>> +		return 1;
>> +	return 0;
>> +}
>> +
>>  /*
>>   * notification of userspace execution resumption
>>   * - triggered by the TIF_WORK_MASK flags
>> diff --git a/checkpoint/signal.c b/checkpoint/signal.c
>> index 609e924..ad95e0c 100644
>> --- a/checkpoint/signal.c
>> +++ b/checkpoint/signal.c
>> @@ -682,7 +682,10 @@ int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t)
>>  	if (!h)
>>  		return -ENOMEM;
>>
>> -	fill_sigset(&h->blocked, &t->blocked);
>> +	if (task_restore_sigmask(t))
>> +		fill_sigset(&h->blocked, &t->saved_sigmask);
>> +	else
>> +		fill_sigset(&h->blocked, &t->blocked);
>>
>>  	ret = ckpt_write_obj(ctx, &h->h);
>>  	ckpt_hdr_put(ctx, h);
>> diff --git a/include/linux/signal.h b/include/linux/signal.h
>> index ab9272c..aa18432 100644
>> --- a/include/linux/signal.h
>> +++ b/include/linux/signal.h
>> @@ -376,6 +376,12 @@ int unhandled_signal(struct task_struct *tsk, int sig);
>>
>>  void signals_init(void);
>>
>> +/*
>> + * arch-specific query, used at checkpoint: should saved_sigmask be used
>> + * in place of blocked
>> + */
>> +int task_restore_sigmask(struct task_struct *task);
>> +
>>  #endif /* __KERNEL__ */
>>
>>  #endif /* _LINUX_SIGNAL_H */
>> -- 
>> 1.6.1
>>
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
