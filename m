From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] c/r: [signal 2/3] checkpoint/restart of rlimit
Date: Fri, 24 Jul 2009 13:11:30 -0400
Message-ID: <4A69EB42.1070305@librato.com>
References: <1248360514-20710-1-git-send-email-orenl@librato.com>
	<1248360514-20710-2-git-send-email-orenl@librato.com>
	<20090723222825.GA23596@us.ibm.com> <4A6910E5.4010605@librato.com>
	<20090724142235.GB6910@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724142235.GB6910-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
>>
>> Serge E. Hallyn wrote:
>>> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>>>> This patch adds checkpoint and restart of rlimit information
>>>> that is part of shared signal_struct.
>>> ...
>>>
>>>>  static int restore_signal(struct ckpt_ctx *ctx)
>>>>  {
>>>>  	struct ckpt_hdr_signal *h;
>>>> +	struct rlimit rlim;
>>>> +	int i, ret;
>>>>
>>>>  	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
>>>>  	if (IS_ERR(h))
>>>>  		return PTR_ERR(h);
>>>>
>>>> -	/* fill in later */
>>>> -
>>>> +	/* rlimit */
>>>> +	for (i = 0; i < RLIM_NLIMITS; i++) {
>>>> +		rlim.rlim_cur = h->rlim[i].rlim_cur;
>>>> +		rlim.rlim_max = h->rlim[i].rlim_max;
>>>> +		ret = do_setrlimit(i, &rlim);
>>> ...
>>>> +int do_setrlimit(unsigned int resource, struct rlimit *new_rlim)
>>>>  {
>>>> -	struct rlimit new_rlim, *old_rlim;
>>>> +	struct rlimit *old_rlim;
>>>>  	int retval;
>>>>
>>>> -	if (resource >= RLIM_NLIMITS)
>>>> -		return -EINVAL;
>>>> -	if (copy_from_user(&new_rlim, rlim, sizeof(*rlim)))
>>>> -		return -EFAULT;
>>>> -	if (new_rlim.rlim_cur > new_rlim.rlim_max)
>>>> -		return -EINVAL;
>>>>  	old_rlim = current->signal->rlim + resource;
>>>> -	if ((new_rlim.rlim_max > old_rlim->rlim_max) &&
>>>> +	if ((new_rlim->rlim_max > old_rlim->rlim_max) &&
>>>>  	    !capable(CAP_SYS_RESOURCE))
>>>>  		return -EPERM;
>>>> -	if (resource == RLIMIT_NOFILE && new_rlim.rlim_max > sysctl_nr_open)
>>>> +	if (resource == RLIMIT_NOFILE && new_rlim->rlim_max > sysctl_nr_open)
>>>>  		return -EPERM;
>>>>
>>>> -	retval = security_task_setrlimit(resource, &new_rlim);
>>>> +	retval = security_task_setrlimit(resource, new_rlim);
>>>>  	if (retval)
>>>>  		return retval;
>>>>
>>>> -	if (resource == RLIMIT_CPU && new_rlim.rlim_cur == 0) {
>>>> +	if (resource == RLIMIT_CPU && new_rlim->rlim_cur == 0) {
>>>>  		/*
>>>>  		 * The caller is asking for an immediate RLIMIT_CPU
>>>>  		 * expiry.  But we use the zero value to mean "it was
>>>>  		 * never set".  So let's cheat and make it one second
>>>>  		 * instead
>>>>  		 */
>>>> -		new_rlim.rlim_cur = 1;
>>>> +		new_rlim->rlim_cur = 1;
>>>>  	}
>>>>
>>>>  	task_lock(current->group_leader);
>>>> -	*old_rlim = new_rlim;
>>>> +	*old_rlim = *new_rlim;
>>>>  	task_unlock(current->group_leader);
>>>>
>>>>  	if (resource != RLIMIT_CPU)
>>>> @@ -1189,14 +1183,27 @@ SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
>>>>  	 * very long-standing error, and fixing it now risks breakage of
>>>>  	 * applications, so we live with it
>>>>  	 */
>>>> -	if (new_rlim.rlim_cur == RLIM_INFINITY)
>>>> +	if (new_rlim->rlim_cur == RLIM_INFINITY)
>>>>  		goto out;
>>>>
>>>> -	update_rlimit_cpu(new_rlim.rlim_cur);
>>>> +	update_rlimit_cpu(new_rlim->rlim_cur);
>>>>  out:
>>>>  	return 0;
>>>>  }
>>>>
>>>> +SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
>>>> +{
>>>> +	struct rlimit new_rlim;
>>>> +
>>>> +	if (resource >= RLIM_NLIMITS)
>>>> +		return -EINVAL;
>>>> +	if (copy_from_user(&new_rlim, rlim, sizeof(*rlim)))
>>>> +		return -EFAULT;
>>>> +	if (new_rlim.rlim_cur > new_rlim.rlim_max)
>>>> +		return -EINVAL;
>>> Should the above check go into do_setrlimit()?  No sense trusting
>>> the data sent to sys_checkpoint() any more than the data sent to
>>> sys_setrlimit().
>> You are very correct.
>>
>> I wonder though: moving the first check will change the order of
>> input sanitizing, which will change the syscall behavior on bad
>> input. E.g, setrlimit(4096, NULL) used to return EINVAL but now
>> will return EFAULT.
>>
>> Not that I really care that much, but I've seen a similar case
>> that confused LTP scripts into seeing the "wrong" error from a
>> syscall and failing a test.
> 
> Heh, I could be wrong, but when you mess up 2 ways, I don't think the kernel
> needs to guarantee which one you'll be warned about :)  Of course there are
> cases where that is well-defined (i.e. DAC-before-MAC).  Maybe we should ask at
> linux-api?

I totally agree with you - I don't think it's an API issue.

I only wonder whether this would cause an LTP test or a libc test
to fail (because it expected one error and got another). Of course,
it would be a false negative, but would still happen.

Oh, well .. I'll just assume it doesn't break anything unless it
is proved wrong :p

Oren.

> 
> Putting the same check before both callers of do_setrlimit() isn't *that*
> bad, and I suppose we can put a comment above do_setrlimit() saying that
> that any new callers need to do that check themselves...
> 
> -serge
