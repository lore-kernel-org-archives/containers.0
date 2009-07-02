From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: kernel summit topic - 'containers end-game'
Date: Thu, 02 Jul 2009 14:27:59 -0400
Message-ID: <4A4CFC2F.3000307@cs.columbia.edu>
References: <20090623145611.GB19332@us.ibm.com> <4A4CE3A6.200@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A4CE3A6.200-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Daniel Veillard <veillard-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Hi Daniel,

This is a fair-sized list of issues ... must have been cooking
for a while ? ...

Daniel Lezcano wrote:
> Serge E. Hallyn wrote:
> 
> 
>> A topic on ksummit agenda is 'containers end-game and how do we
>> get there'.
>>
>> So for starters, looking just at application (and system) containers, what do
>> the libvirt and liblxc projects want to see in kernel support that is currently
>> missing?  Are there specific things that should be done soon to make containers
>> more useful and usable?
>>
>> More generally, the topic raises the question... what 'end-games' are there?
>> A few I can think of off-hand include:
>>
>> 	1. resource control
>> 	2. lightweight virtual servers
> 
> Hi Serge,
> 
> here are a few suggestions for the containers in general and most of 
> these suggestions are pre-requisites for CR (may be not the higher 
> priority but just to keep in mind).
> 
> 	* time virtualization : for absolute timer CR, TCP socket timestamps, ...

Good point.

> 
> 	* inode virtualization : without this you won't be able to migrate some 
> applications eg. samba which rely on the inode numbers.

Hmmm... have you given it a thought ?

> 
> 	* debugging tools for the containers: at present we are not able to 
> debug a multi-threaded application from outside of the container.

Why not ?  does ptrace-ing from parent container not work ?

> 
> 	* poweroff / reboot from inside the container : at poweroff / reboot, 
> all the processes are killed expect the init process which will stay 
> there making the container blocked. Maybe we can send a SIGINFO signal 
> to the init's parent with some information, so it will be up the parent to:
> 		- ignore the signal
> 		- stop the container (poweroff/halt)
> 		- stop and start again the container (reboot).
> 
>> 	3. (or 2.5) unprivileged containers/jail-on-steroids
>> 		(lightweight virtual servers in which you might, just
>> 		maybe, almost, be able to give away a root account, at
>> 		least as much as you could do so with a kvm/qemu/xen
>> 		partition)
>> 	4. checkpoint, restart, and migration
>>
>> For each end-game, what kernel pieces do we think are missing?  For instance,
>> people seem agreed that resource control needs io control :)  Containers imo
>> need a user namespace.  I think there are quite a few network namespace
>> exploiters who require sysfs directory tagging (or some equivalent) to
>> allow us to migrate physical devices into network namespaces.  And
> 
> Right.
> 
>> checkpoint/restart needs... checkpoint/restart.
> 
> I know you are working hard on a CR patchset and most of the questions / 
> suggestions below were already addressed in the mailing list since some 
> month ago but IMO they were eluded :) If you can talk about these points 
> and clarify what approach would be preferable that would be nice.
> 
> IMHO the all-in-kernel-monolithic approach raise some problems:

Hmmm... anouther round ?  :(

So, clearly, I couldn't restist :p

> 
>   * the tasks are checkpointed from an external process and most of the 
> kernel code is designed to run as current

I think we are already mostly reusing codes, with few exceptions.
Can you elaborate where's the problem ?

> 
>   * if a checkpoint or a restart fails, how do we debug that ? How 
> someone in the community using the CR can report an information about 
> the checkpoint has failed in a particular place ? The same for the 
> restart. And a much more harder case is if a restart succeeded but a 
> resource was badly restored making the application to continue its 
> execution but failing 1 hour later.

For checkpoint we have a nice mechanism that adds (a) record(s) to the
checkpoint image that describe the error when it occurs. There are a
few examples already in the code.

We haven't made much progress on the restart front, yet. I'm pretty
sure any idea to this end is applicable in either approach.

> 
>   * how this can be maintained ? who will port the CR each time a 
> subsystem design changes ?
> 
>   * the current patchset is full kernel but needs an external tool to 
> create the process tree by digging in the statefile, weird.

It uses the head of the data to create the process hierarchy. What's
weird about it ?  The main advantage is the flexibility it provides.

The alternative is to start all tasks in the kernel (a la OpenVZ),
or what you suggest, which sounds like .. hmm .. external tool to
create the process tree by digging in the statefile  :p

>   * the container and the checkpoint/restart are not clearly 
> decorrelated, that brings a dangerous heuristic in the kernel, 
> especially with nested namespace and partial resources checkpoint. IMHO, 
> the checkpoint / restart should succeed even if the resources are not 
> isolated, we should not CR some boundaries like the namespaces.

That's already possible in the current approach.

> 
> Regarding these points and the comments of Kerrighed and google guys, 
> maybe it would be interesting to discuss the following design of the CR:
> 
>   1) create a synchronism barrier (not the freezer), where all the tasks 
> can set the checkpoint or restart status

This is already how it works in restart.

> 
> That allows to have a task to abort the checkpoint at any time by 
							^^^^^^^^^^^
Is this an issue with current approach ?

BTW, to be able to checkpoint at _any time_, preemptively, you _must_
be able to checkpoint externally to the tasks.

For instance, how would you handle a ptraced task ?  STOPed task ?

> setting a status error in the synchronism barrier. The initiator of the 
> checkpoint / restart is blocked on this barrier until the checkpoint / 
> restart finishes or fails. If the initiator exits, that's cancel the 
> current operation making possible to do Ctrl+C at checkpoint or restart 
> time.

Aborting using ctrl-c or any other method is already possible now
with no harm done. In fact, with less harm than when requiring the
cooperation of participating tasks.

> 
>   2) make a vdso which is the entry point of the checkpoint and set this 
> entry as a signal handler for a new signal SIGCKPT, the same for 
> SIGRESTART (AFAIR this is defined in posix 1003.m).
> 
> This approach allows to checkpoint from the current context which is 
> less arch dependant and/or to override the handler with a specific 

Why is it less arch dependent ?  The only arch dependent code in the
current patchset is what is defined differently by separate archs
(cpus, mm-context).

> library making possible to do some work before calling the 
> sys_checkpoint itself. That will allows to build the CR step by step by 
> making in userspace a best-effort library to checkpoint/restart what is 
> not supported in the kernel.

This sort of notification is indeed desirable and can be added to
either approach.

> 
>   3) a process gains the checkpointable property with a specific flag or 
> whatever. All the childs inherit this flag. That will allows to identify 
> all the tasks which are checkpointable without isolating anything and 
> than opens the door to the checkpoint/restart of a subset of a process tree.

Already possible. Isolation is a nice feature, not a requirement (at
least if you ask me :)

> 
>   4) dump everything in a core-file-like and improve the interpreter to 
> recreate the process tree from this file.

How is this different from above ?

> 
> Dynamic behaviour would be:
> 
> Checkpoint:
> 	- The initiator of the checkpoint initialize the barrier and send a 
> signal SIGCKPT to all the checkpointable tasks and these ones will jump 
> on the handler and block on the barrier.
> 
> 	- When all these tasks reach this barrier, the initiator of the
> checkpoint dumps the system wide resources (memory, sysv ipc, struct 
> files, etc ...).

Note that with namespaces, there are no "system wide resources", but
instead there are multiple namespaces with resources.

> 
> 	- When this is done, the tasks are released and they store their 
> process wide resources (semundo, file descriptor, etc ...) to a 
> current->ckpt_restart buffer and then set the status of the operation 
> and block on the barrier.
> 
> 	- The initiator of the checkpoint then collects all these informations 
> and dump them.
> 
> 	- Finally the initiator of the checkpoint release the tasks.

Can you explain why this approach is better than the current one ?
Rename "initiator" to "external checkpointer", and all the rest is
nearly the same.

Only that instead of relying on the freezer code (which is, clearly,
reuse of existing code!), your approach requires a delicate mechanism
to allow all tasks to cooperate at the initiator's will.

> 
> 
> Restart:
> 	- The user executes the statefile, that spawns the process tree and all 
> the processes are blocked in the barrier.

Done already.

> 
> 	- The initiator of the restart restore the system wide resources
> and fill the restarted processes' current->ckpt_restart buffer.
> 
> 	- The initiator sends a SIGRESTART to all the tasks and unblock the tasks
> 
> 	- all the tasks restore their process wide resources regarding the 
> current->ckpt_restart buffer.

Done already (with the exception that they do it one by one because
the checkpoint image is streamed).

> 
> 	- all the tasks write their status and block on the barrier

Done.

> 
> 	- the initiator of the restart release the tasks which will return to 
> their execution context when they were checkpointed.

Ditto.

> 
> This approach is different of you are doing but I am pretty sure most of 
> the code is re-usable. I see different advantages of this approach:
> 
>   - because the process resources are checkpointed / restarted from 
> current, it would be easy to reuse some syscalls code (from the kernel 
> POV) and that would reduce the code duplication and maintenance overhead.

Checkpoint and restart are asymmetric: checkpoint needs to _observe_
and record, and restart needs to _create_ and build.

That's why reusing existing syscalls is extremely helpful for restart,
but not so much for checkpoint.

In current approach, restart indeed is done in the current context. And
that's where you'd like to reuse syscalls.

Checkpoint is done by observing tasks (out of their context), and I
believe the code will be pretty much the same for in-context. Being
out of context requires little bit glue to guarantee safe access to
non-current resources.

> 
>   - the approach is more fine grained as we can implement piece by piece 
> the checkpoint / restart.

Can do. Was discussed on containers mailing list some time ago with
Kerrighead, IIRC in regarding IPC namespaces.

> 
>   - as the statefile is in the elf format, gdb could be used to debug a 
> statefile as a core file
> 
>   - as each process checkpoint / restart themselves, most of the 
> execution context is stored in the stack which is CR with the memory, so 
> when returning from the signal handler, the process returns to the right 
> context. That is less complicated and more generic than externally 
> checkpoint the execution context of a frozen task which would be 
> potentially different for the restart.

Ehh ?   The code is actually straight forward. No kernel stack,
and user stack is in memory anyway.  Take a look at the code, it's
pretty straightforward.

> 
> 
> I hope Serge you can present this approach as an alternative of the 
> current patchset __if__ this one is not acceptable.

There you go. I could not resist   :O

Now, before I go hide (...) - some of these points require attention,
e.g. - error reporting on restart, notification mechanisms, partial
containers and selected resources, etc.

Oren.
