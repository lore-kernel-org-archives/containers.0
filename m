From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: Containers Digest, Vol 24, Issue 82
Date: Thu, 24 Jul 2008 14:38:50 -0400
Message-ID: <4888CC3A.50302@cs.columbia.edu>
References: <mailman.318.1216822966.8462.containers@lists.linux-foundation.org>
	<e7d8f83e0807231617y17ba889drf80c3d8994be4e73@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e7d8f83e0807231617y17ba889drf80c3d8994be4e73-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Dolding <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Peter Dolding wrote:
>> Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
>>  * What are the problems that the linux community can solve with the
>> checkpoint/restart ?
>>
>>        EB : Better to add a little CR functionnality into the kernel itself
>> and add more after.
>>
>>        DLu : Problem with kernel version
>>
>>        OL : Compatibility with intermediate kernel version should be possible
>> with userspace conversion tools
> 
> Please look at BSD Jails and Solaris Branded Zones.  Both provide
> virtual of system calls.

Compatibility in the context above refers to ensuring that the restart code
of a newer kernel will be able to read the checkpoint image taken by an older
kernel. One way to do it is to include glue layers in the kernel; the solution
we proposed was to convert the image in user space, if necessary.

> 
> Its a major reason why BSD can just change there syscalls at will and
> still run old applications.   So really its another container in its
> own right.   Inside this container system calls are fake.  Removing
> system call dependency from containers.   Both allow virtual syscalls
> to be done in user space.  It ends this problem of worrying about
> kernel version.   Do we have the system call container ok we fine.
> Slower if we have to use it but fine to get around these issues.
> 
>>        DLu : Non sequential file for checkpoint statefile is a challenge
>>
>>        OL : yes, but possible and useful for compression/encryption
>>
>>        We showed that there are five steps to realize a checkpoint:
>>
>>        1 - Pre-dump
>>        2 - Freeze
>>        3 - Dump
>>        4 - Resume/kill
>>        5 - Post-dump
>>
>>        At this point we state we want create a proof of concept and
>> checkpoint/restart the simplest application.
>>
>>        We will add iteratively more and more kernel resources.
>>
>>        Process hierarchy created from kernel or userspace ?
>>
>>        OL : Seems better to send a chunk of data to kernel and that restores
>> the processes hierarchy
>>        PE : Agreed
>>        OL : We should be able to checkpoint from inside the container, keep
>> that in mind for later.
>>
>>        => we need a syscall or a ioctl
>>
>>        The first items to address before implementing the Checkpoint are:
>>        1 - Make a container object (the context)
>>        2 - Freeze the container (extend cgroup freezer ?)
>>        3 - syscall | ioctl
>>
>>        First step:
>>                * simplest application : A single process, without any file, no
>> checkpoint of text file (same file system for restart), no signals, no
>> syscall in the application, no ipc/no msgq, no network
>>
>>        Second step:
>>                * multiple processes + zombie state
>>
>>        Third step:
>>                * files, pipe, signals, socketpair ?
>>
>>        This proof of concept must came with a documentation describing what is
>> supported, what is not supported and what we plan to do.
>>
> Missing critical Step 4.  How to deal with processes like games or
> virus scanners  using hardware assist or cups half way threw printing
> or other services half way threw doing something to a external device
> who state is going to change.   That cannot be Frosen because the
> state in those devices will be lost.   Even if there state could be
> saved you might be unfreezing on a container without them.

If they are using hardware that isn't (and cannot be) virtualized, they cannot
be migrated to another machine.

If they communicate with CUPS, then either the CUPS server lives within the
same container, in which case it moves with the container; or they otherwise
must communicate with the server via the network, in which case the network
connections will be migrated with the container (and the application) as well.

> Are the told to the user on freese and have to be terminated.
> 
> Are the told to user on freese  with the users with a option to go
> past and user on unfreese has the option to have those applications
> terminated to allow clean restart.
> 
> Of course the hard bit is going to be detecting them all.
> 
> There will always be the odd things.   Container freesing and
> unfreesing could be aligned with the kernel level hibernate.  One
> system does them both stable.
> 
> Peter Dolding
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
