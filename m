From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] user-cr: invoke exit system call directly from
	ckpt_do_feeder
Date: Tue, 01 Dec 2009 02:12:51 -0500
Message-ID: <4B14C1F3.6020008@cs.columbia.edu>
References: <1259108404.10928.3.camel@localhost.localdomain>
	<4B0E9A57.4020501@cs.columbia.edu>
	<1259604874.6060.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259604874.6060.41.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Nathan Lynch wrote:
> On Thu, 2009-11-26 at 10:10 -0500, Oren Laadan wrote:
>> Nathan Lynch wrote:
>>> The feeder thread can cause the restart process to fail by indirectly
>>> calling exit_group, which sends SIGKILL to all other threads in the
>>> process.  If the feeder thread "wins" the race, the restart is
>>> disrupted.  A common symptom of this race is the coordinator task
>>> returning from the wait_for_completion_interruptible in
>>> wait_all_tasks_finish with a signal (the SIGKILL) pending.
>> So the clone mage page says:
>>   ...
>>   The main use of clone() is to implement threads: multiple threads
>>   of control in a program that run concurrently in a shared memory
>>   space.
>>   ...
>>   When the fn(arg) function application returns, the child process
>>   terminates. The integer returned by fn is the exit code for the
>>   child process.  The child process may also terminate explicitly by
>>   calling exit(2) or after receiving a fatal signal.
>>   ...
>> (http://www.kernel.org/doc/man-pages/online/pages/man2/__clone2.2.html)
>>
>> I expected "terminates" here to mean invoke the syscall _exit().
>> Clearly this is desirable with CLONE_THREAD,
> 
> Calling _exit (as glibc's clone support code does) is clearly
> undesirable for CLONE_THREAD users such as restart.c because _exit calls
> exit_group, terminating the whole thread group.  That's kind of the
> whole point of the patch :)

I did say "syscall _exit()" to distinguish from libc's _exit()...
Anyway, we agree on the necessity of the patch.

> 
> 
>>  but not for regular
>> processes that will want to proceed to the usual glibc exit path
>> (e.g. process at_exit() and what-not). Then again, the last thread
>> to exit should also call glibc's exit for the same reason. So
>> that's probably why it's handled this way.
>>
>> This matters for us because our user-space wrapper to eclone()
>> should eventually do what the glibc's clone() wrapper does, instead
>> of calling _exit() directly as it is today...
> 
> For compatibility's sake, the user-space eclone wrapper should
> eventually do what glibc's clone support code does, yes -- branch to
> _exit.  But I think you've stated the case backwards?  Currently the
> eclone wrappers call sys_exit directly (e.g. "li r0,__NR_exit; sc" on
> powerpc).

Exactly: currently our wrapper calls the syscall _exit() directly,
while the correct behavior which is expected by the user is the
one provided by libc, that is - call libc's _exit() instead. So we
should fix our wrappers...

Oren.
