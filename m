From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 07/11] pidns: Wait in zap_pid_ns_processes until
	pid_ns->nr_hashed == 1
Date: Thu, 20 Dec 2012 17:19:06 -0800
Message-ID: <87bodourqt.fsf@xmission.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
	<1353083750-3621-7-git-send-email-ebiederm@xmission.com>
	<20121219184757.GB22991@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121219184757.GB22991-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Oleg Nesterov's message of
	"Wed, 19 Dec 2012 19:47:57 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On 11/16, Eric W. Biederman wrote:
>>
>> @@ -216,22 +216,15 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
>>
>>  	/*
>>  	 * sys_wait4() above can't reap the TASK_DEAD children.
>> -	 * Make sure they all go away, see __unhash_process().
>> +	 * Make sure they all go away, see free_pid().
>>  	 */
>>  	for (;;) {
>> -		bool need_wait = false;
>> -
>> -		read_lock(&tasklist_lock);
>> -		if (!list_empty(&current->children)) {
>> -			__set_current_state(TASK_UNINTERRUPTIBLE);
>> -			need_wait = true;
>> -		}
>> -		read_unlock(&tasklist_lock);
>> -
>> -		if (!need_wait)
>> +		set_current_state(TASK_UNINTERRUPTIBLE);
>> +		if (pid_ns->nr_hashed == 1)
>>  			break;
>>  		schedule();
>>  	}
>
> I agree, the patch itself looks fine.
>
> But, with all other changes I do not understand this part at all.
>
> A task from the parent namespace can do setns + fork at any time
> (until nr_hashed >= 0). So ->nr_hashed can be incremented again
> after zap_pid_ns_processes() returns.

I want to talk about how alloc_pid and free_pid prevent nr_hashed
from increasing once the last processes has exited the pid namespace
but that doesn't apply here.

> Or, we can sleep in TASK_UNINTERRUPTIBLE "forever" if this happens
> after kill-them-all.

Sleeping forever should be prevented by this chunk in free_pid:

		switch(--ns->nr_hashed) {
		case 1:
			/* When all that is left in the pid namespace
			 * is the reaper wake up the reaper.  The reaper
			 * may be sleeping in zap_pid_ns_processes().
			 */
			wake_up_process(ns->child_reaper);


I admit it continues to be true that if an injected process or a
debugged process does not exit we can block waiting for all of the
processes to be reaped indefinitely.

> Could you explain why do we need to wait at all? I can be easily
> wrong, but at first glance the original reason for this wait has
> gone away?

It is very nice to know that when you do waitpid for the init process of
a pid namespace that there are no other processes in the pid namespace.

Leaving the wait here has the nice effect that it doesn't penalize
anything but pid namespace code paths.

Eric
