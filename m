From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v3][PATCH 1/9] Create syscalls: sys_checkpoint,	sys_restart
Date: Thu, 04 Sep 2008 17:05:00 -0400
Message-ID: <48C04D7C.6020500@cs.columbia.edu>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040401320.5982@takamine.ncl.cs.columbia.edu>
	<20080904144223.GA19364@us.ibm.com>
	<48C01B92.60900@cs.columbia.edu>
	<20080904203730.GA28313@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080904203730.GA28313-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>
>> Serge E. Hallyn wrote:
>>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>>> Create trivial sys_checkpoint and sys_restore system calls. They will
>>>> enable to checkpoint and restart an entire container, to and from a
>>>> checkpoint image file descriptor.
>>>>
>>>> The syscalls take a file descriptor (for the image file) and flags as
>>>> arguments. For sys_checkpoint the first argument identifies the target
>>>> container; for sys_restart it will identify the checkpoint image.
>>>>
>>>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>>>> ---
>> [...]
>>
>>>> +/**
>>>> + * sys_checkpoint - checkpoint a container
>>>> + * @pid: pid of the container init(1) process
>>>> + * @fd: file to which dump the checkpoint image
>>>> + * @flags: checkpoint operation flags
>>>> + */
>>>> +asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
>>>> +{
>>>> +	pr_debug("sys_checkpoint not implemented yet\n");
>>>> +	return -ENOSYS;
>>>> +}
>>>> +/**
>>>> + * sys_restart - restart a container
>>>> + * @crid: checkpoint image identifier
>>> So can we compare your api to Andrey's?
>>>
>>> You've explained before that crid is used to tie together multiple
>>> calls to checkpoint, but why do you have to specify it for restart?
>>> Can't it just come from the fd?  Or, the fd will be passed in
>>> seek()d to the right position for the data for this task, so the crid
>>> won't be available there?
>> I added the 'crid' inside to support a mode of operation in which we
>> would like the checkpoint data to remain in memory across multiple
>> system calls. Here are example scenarios:
>>
>> 1) We will want to reduce down time by first buffering the checkpoint
>> image in memory, then resuming the container, and only then writing
>> the data back to a (the) file descriptor.
>> So instead of:
>>   freeze -> checkpoint and write back -> unfreeze
>> We want:
>>   freeze -> checkpoint to buffer -> unfreeze -> write back
>> I envision each of these steps to be a separate invocation of a syscall.
>> to the 'crid' returned by the sys_checkpoint() at the 2nd step, will be
>> used to identify that data in the 4th step. (Note, that between the
>> unfreeze and the write-back, another checkpoint may be already taken).
>>
>> 2) A task may want to take a checkpoint (e.g. of itself, or a whole
>> container) and keep that checkpoint in memory; at a later time it may
>> want to revert to that checkpoint. Moreover, it may keep multiple such
>> checkpoints (to where it may want to return). 'crid' tells sys_restart
>> which one to use.
>>
>> Note that this 'crid' will in fact be tied to resources that are kept
>> by the kernel - e.g. references to COW pages (when we add that).
>> Louis suggested to use a specialized FD instead of a numeric 'crid'
>> (that is: create a anonymous inode and a struct file that represent
>> that checkpoint in the kernel, and return an FD to it). This approach
>> has pros and cons of 'crid' (see the archives of the containers
>> mailing list). For now I kept 'crid', but I'm definitely open to change
>> it to a FD.
>>
>> Oren.
> 
> Oh, so the crid identifies one checkpoint inside the file - the single
> file can store multiple checkpoints?

Not quite. Let me rephrase the motivation first:

There are occasions when we would like to keep the checkpoint data in the
kernel for some (relatively long) time, between syscalls. By "checkpoint
data" I mean references to memory contents (pages) and all the other data.

The two scenarios above are two examples: between the syscall to checkpoint
and the syscall to unfreeze and then write-back the data to a file (first
example), and for some time until a task may want to "go back in time"
(second example, useful for ultra fast "undo" for a task).

Note that in both cases when I say "keep in kernel" I mean before it is
written to a file, or to the network. Simply in memory, in some efficient
manner.

Subsequent syscalls will need to refer to a specific checkpoint data that
is kept in memory - e.g. to write-back to a file-descriptor, or to clean
up, or to restart from it. (At any single time a specific container may
have multiple checkpoints associated with it - eg. because they have not
yet been written back to storage but already taken).

Once the data is written back to a file descriptor, the in-kernel data can
be discarded and cleaned-up.

The main reason why I want to keep the data in the kernel and not instead
copy to user space, is efficiency: most of the checkpoint data is the memory
footprint; by keeping the data in the kernel, one can merely keep a COW
reference instead of a whole copy of everything (save space and copy time).

So, if we have keep data in kernel between syscalls, then we must have a
way to refer to it. The current implementation uses a very simple 'crid'
value to do that - although, clearly, at the moment it isn't used.

I hope this explains better.

Oren.

> 
>>> Andrey, how will the 'ctid' in your patchset be used?  It sounds
>>> like it's actually going to set some integer id on the created
>>> container?  We actually don't have container ids (or even
>>> containers) right now, so we probably don't want that in our api,
>>> right?
> 
> -serge
