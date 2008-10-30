From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 08/10] Introduce functions to restart a process
Date: Thu, 30 Oct 2008 11:59:01 -0400
Message-ID: <4909D9C5.5020805__37903.4421210692$1225382799$gmane$org@cs.columbia.edu>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<200810240757.38012.major@openvz.org>
	<49038B4C.2010009@cs.columbia.edu>
	<200810291752.19281.major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810291752.19281.major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org



Andrey Mirkin wrote:
> On Sunday 26 October 2008 01:10 Oren Laadan wrote:
>> Andrey Mirkin wrote:
>>> On Thursday 23 October 2008 17:57 Dave Hansen wrote:
>>>> On Thu, 2008-10-23 at 13:00 +0400, Andrey Mirkin wrote:
>>>>>>>>> It is not related to the freezer code actually.
>>>>>>>>> That is needed to restart syscalls. Right now I don't have a code
>>>>>>>>> in my patchset which restarts a syscall, but later I plan to add
>>>>>>>>> it. In OpenVZ checkpointing we restart syscalls if process was
>>>>>>>>> caught in syscall during checkpointing.
>>>>>>>> Do you checkpoint uninterruptible syscalls as well? If only
>>>>>>>> interruptible syscalls are checkpointed, I'd say that either this
>>>>>>>> syscall uses ERESTARTSYS or ERESTART_RESTARTBLOCK, and then signal
>>>>>>>> handling code already does the trick, or this syscall does not
>>>>>>>> restart itself when interrupted, and well, this is life, userspace
>>>>>>>> just sees -EINTR, which is allowed by the syscall spec.
>>>>>>>> Actually this is how we checkpoint/migrate tasks in interruptible
>>>>>>>> syscalls in Kerrighed and this works.
>>>>>>> We checkpoint only interruptible syscalls. Some syscalls do not
>>>>>>> restart themself, that is why after restarting a process we restart
>>>>>>> syscall to complete it.
>>>>>> Can you please elaborate on this ?  I don't recall having had issues
>>>>>> with that.
>>>>> Right now in 2.6.18 kernel we restarts in such a way pause,
>>>>> rt_sigtimedwait and futex syscalls. Recently futex syscall was reworked
>>>>> and we will not need such hooks for it.
>>>> Could you elaborate on this a bit?
>>>>
>>>> If the futex syscall was reworked, perhaps we can do the same for
>>>> rt_sigtimedwait() and get rid of this code completely.
>>> Well, we can try to rework rt_sigtimedwait(), but we will still need this
>>> code in the future to restart pause syscall from kernel without returning
>>> to user space. Also this code will be needed to restore some complex
>>> states. As concerns pause syscall I have already written to Louis about
>>> the problem we are trying to solve with this code. There is a gap when
>>> process will be in user space just before entering syscall again. At this
>>> time a signal can be delivered to process and it even can be handled. So,
>>> we will miss a signal which must interrupt pause syscall.
>> I'm not convinced that you a real race exists, and even if it does, I'm not
>> convinced that hacking the assembly entry/exit code is the best way to do
>> it.
> 
> Well, as I already told pause() syscall is is not only one case why we need to 
> do some additional job in that place.
> 
>> Let me explain:
>>
>> You are concerned about a race in which a signal is delivered to a task
>> that resumes from restart to user space and is about to (re)invoke
>> 'pause()' (because the restart so arranged its EIP and registers).
>>
>> This almost always means that the user code is buggy and relies on specific
>> scheduling, because you can usually find a scheduling (without the C/R)
>> where the intended recipient of the signal was delayed and only calls
>> pause() after the signal is delivered.
>>
>> For instance, if the sequence of events is:
>> 	A calls pause() -> checkpoint -> restart ->
>> 		B signals A -> A calls pause() (after restart),
>> then the following sequence is possible(*) without C/R:
>> 	B signals A -> A calls pause()
>> because normally B cannot assume anything about when A is actually,
>> really, is suspended (which means the programmer did an imperfect job).
> 
> You right here. Both sequences are possible in theory. You will be surprised 
> but in practice we found out that probability to miss a signal in case of C/R 
> is much higher then during ordinary execution.

The point is that "missing" a signal because of freeze/thaw (or stop/cont)
is perfectly acceptable behavior. It is supposed to work that way. So I
argue that we don't need a workaround.

> 
>> I said "almost always" and "usually", because there is one case where the
>> alternative schedule: task B could, prior to sending the signal, "ensure"
>> that task A is already sleeping within the 'pause()' syscall. While this
>> is possible, it is definitely unusual, and in fact I never code that does
>> that. And what if the sysadmin send SIGSTOP followed by SIGCONT ?  In
>> short, such code is simply broken.
>>
>> More importantly, if you think about the operation and semantics of the
>> freezer cgroup - similar behavior is to be expected when you freeze and
>> then thaw a container.
>>
>> Specifically, when you freeze the container that has a task in sys_pause(),
>> then that task will abort the syscall become frozen. As soon as it becomes
>> unfrozen, it will return to user space (with the EIP "rewinded") only to
>> re-invoke the syscall. So the same "race" remains even if you only freeze
>> and then thaw, regardless of C/R.
> 
> Exactly. But during freeze/unfreeze probability to catch such situation is 
> very low. In our tests we were tried to checkpoint/restart LTP tests. And 
> this "race" were triggered during restart almost in 100% of tests.

Why is it the case ?

At the end of restart, the container remains frozen until you unfreeze it.
So c/r effectively becomes freeze/unfreeze, except - possible - for page
fault that are more likely to happen when thawing following the restart
(and these may slow down the application and allow a signal to "slip in").

If it's nearly 100% of the tests, that it should be easily reproducible
with merely freeze/thaw pairs, no ?

Still, arguing that LTP "breaks" here is like arguing that LTP "breaks"
if we were to run it while sending SIGSTOP/SIGCONT to its processes...

> 
>> Moreover, I argue that basically when you return from a sys_restart(), the
>> entire container should, by default, remain in frozen state - just like it
>> is with sys_checkpoint(). An explicit thaw will make the container resume
>> execution.
> 
> No doubt. That is how we do in OpenVZ, after restart the container remains 
> frozen. And we need to thaw it to resume its execution.
> 
>> Therefore, there are two options: the first is to decide that this behavior
>> - going back to user space to re-invoke the syscall - is valid. In this
>> case you don't need a special hack for returning from sys_restart(). The
>> second option is to decide that it is broken, in which case you need to
>> also fix the freezer code. Personally, I think that this behavior is valid
>> and need not be fixed.
> 
> I still believe that we need to fix such behaviour during restart as in 
> practice it is very easy to trigger it.

did you see any problem outside LTP ?  I never saw any such problems.

> 
>> Finally, even if you do want to fix the behavior for this pathologic case,
>> I don't see why you'd want to do it in this manner. Instead, you can add a
>> simple test prior to returning from sys_restart(), something like this:
>>
>> 	...
>> 	/* almost done: now handle special cases: */
>> 	if (our last syscall == __NR_pause) {
		do_freeze();

>> 		ret = sys_pause();
>> 	} else if (our last syscall == __NR_futex) {
>> 		do some stuff;
		do_freeze();

>> 		ret = sys_futex();
>> 	} else {
>> 		ret = what-we-want-to-return
>> 	}
>> 	/* finally, return to user space */
>> 	return ret;
>> }
> 
> This only works if we do not want to stay in frozen state after restart. Or am 
> I missed something?

Sure: see addition above.

> 
>> I'm not quite know what other "complex states" you refer to; but I wonder
>> whether that code "needed to restore some complex states" could not be
>> implemented along the same idea.
> 
> In the same manner we are restoring for instance ptrace.

Yes, I mentioned that in the past. Can be addressed in the same manner.

> 
>> The upside is clear: the code is less obscure, simple to debug, and not
>> architecture-dependent. (hehe .. it even runs faster because it saves a
>> whole kernel->user->kernel switch, what do you know !).

> In our case we also do not need a switch and the code actually not very 
> complicated.

Fact is that people wondered what was going on there.

I prefer the arch-independent way, because it is, well, arch-independent,
and because it makes the logic and the exception obvious to the reader,
and it is easily extensible to handle additional special cases (like
ptrace), and makes maintenance easier.

Do you object to doing it this way ?

Oren.
