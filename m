From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Thu, 17 Jun 2010 06:41:49 -0700
Message-ID: <m1631hdbdu.fsf@fess.ebiederm.org>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
	<4C19F0A3.2050707@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C19F0A3.2050707@parallels.com> (Pavel Emelyanov's message of "Thu\, 17 Jun 2010 13\:53\:39 +0400")
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Louis Rilling <louis.rilling@kerlabs.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Pavel Emelyanov <xemul@parallels.com> writes:

> On 06/16/2010 08:34 PM, Louis Rilling wrote:
>> [ Resending, hopefully with all pieces ]
>> 
>> Detached tasks are not seen by zap_pid_ns_processes()->sys_wait4(), so
>> that release_task()->proc_flush_task() of container init can be called
>> before it is for some detached tasks in the namespace.

There are two ways we can go from here.

- Completely asynchronous children exiting.
- Waiting for all of our children to exit.

Your patch appears to be a weird middle ground, that is hard to
analyze, abusing the mount count as a thread count.

I have been weighing the options between them, and to me properly
waiting for all the processes to exit in zap_pid_ns_processes as we
currently try to do is in our advantage.  It is simple and it means
one less cache line bounce for a write to global variable in the
much more common fork/exit path that we have to deal with.

The task->children isn't changed until __unhash_process() which runs
after flush_proc_task().  So we should be able to come up with
a variant of do_wait() that zap_pid_ns_processes can use that does
what we need.

Louis do you want to look at that?

>> Pin proc_mnt's in copy_process(), so that proc_flush_task() becomes safe
>> whatever the ordering of tasks.
>
> See one comment below.
>
>> Signed-off-by: Louis Rilling <louis.rilling@kerlabs.com>
>> ---
>>  fs/proc/base.c          |   18 ++++++++++++++++++
>>  include/linux/proc_fs.h |    4 ++++
>>  kernel/fork.c           |    1 +
>>  3 files changed, 23 insertions(+), 0 deletions(-)
>> 
>> diff --git a/fs/proc/base.c b/fs/proc/base.c
>> index acb7ef8..d6cdd91 100644
>> --- a/fs/proc/base.c
>> +++ b/fs/proc/base.c
>> @@ -2663,6 +2663,23 @@ static const struct inode_operations proc_tgid_base_inode_operations = {
>>  	.setattr	= proc_setattr,
>>  };
>>  
>> +/*
>> + * Pin all proc_mnt so that detached tasks can safely call proc_flush_task()
>> + * after container init calls itself proc_flush_task().
>> + */
>> +void proc_new_task(struct task_struct *task)
>> +{
>> +	struct pid *pid;
>> +	int i;
>> +
>> +	if (!task->pid)
>> +		return;
>> +
>> +	pid = task_pid(task);
>> +	for (i = 0; i <= pid->level; i++)
>> +		mntget(pid->numbers[i].ns->proc_mnt);
>
> NAK. Pids live their own lives - task can change one, pid will
> become orphan and will be destroyed, so you'll leak.

There is that nasty case in exec isn't there.  Why we ever made it
part of the ABI that calling exec on a thread changes the pid of
that thread to the pid of the thread group is beyond me.

> There's another big problem with proc mount - you can umount proc
> and the namespace will have a stale pointer.

Not true. pid_ns->proc_mnt is an internal kernel mount. See
pid_ns_prepare_proc.

> I think we should have a kern_mount-ed proc at the namespace createi

I agree, and we mostly do.  In my queue for the unsharing of the pid
namespace I have a patch that makes that more explicit.

Eric
