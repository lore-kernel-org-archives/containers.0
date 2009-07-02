From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [libvirt] Re: kernel summit topic - 'containers end-game'
Date: Thu, 02 Jul 2009 18:43:18 +0200
Message-ID: <4A4CE3A6.200@fr.ibm.com>
References: <20090623145611.GB19332@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <libvir-list-bounces@redhat.com>
In-Reply-To: <20090623145611.GB19332@us.ibm.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/libvir-list>
List-Post: <mailto:libvir-list@redhat.com>
List-Help: <mailto:libvir-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=subscribe>
Sender: libvir-list-bounces@redhat.com
Errors-To: libvir-list-bounces@redhat.com
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, libvir-list@redhat.com, Cedric Le Goater <clg@fr.ibm.com>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:


> A topic on ksummit agenda is 'containers end-game and how do we
> get there'.
> 
> So for starters, looking just at application (and system) containers, what do
> the libvirt and liblxc projects want to see in kernel support that is currently
> missing?  Are there specific things that should be done soon to make containers
> more useful and usable?
> 
> More generally, the topic raises the question... what 'end-games' are there?
> A few I can think of off-hand include:
> 
> 	1. resource control
> 	2. lightweight virtual servers

Hi Serge,

here are a few suggestions for the containers in general and most of 
these suggestions are pre-requisites for CR (may be not the higher 
priority but just to keep in mind).

	* time virtualization : for absolute timer CR, TCP socket timestamps, ...

	* inode virtualization : without this you won't be able to migrate some 
applications eg. samba which rely on the inode numbers.

	* debugging tools for the containers: at present we are not able to 
debug a multi-threaded application from outside of the container.

	* poweroff / reboot from inside the container : at poweroff / reboot, 
all the processes are killed expect the init process which will stay 
there making the container blocked. Maybe we can send a SIGINFO signal 
to the init's parent with some information, so it will be up the parent to:
		- ignore the signal
		- stop the container (poweroff/halt)
		- stop and start again the container (reboot).

> 	3. (or 2.5) unprivileged containers/jail-on-steroids
> 		(lightweight virtual servers in which you might, just
> 		maybe, almost, be able to give away a root account, at
> 		least as much as you could do so with a kvm/qemu/xen
> 		partition)
> 	4. checkpoint, restart, and migration
> 
> For each end-game, what kernel pieces do we think are missing?  For instance,
> people seem agreed that resource control needs io control :)  Containers imo
> need a user namespace.  I think there are quite a few network namespace
> exploiters who require sysfs directory tagging (or some equivalent) to
> allow us to migrate physical devices into network namespaces.  And

Right.

> checkpoint/restart needs... checkpoint/restart.

I know you are working hard on a CR patchset and most of the questions / 
suggestions below were already addressed in the mailing list since some 
month ago but IMO they were eluded :) If you can talk about these points 
and clarify what approach would be preferable that would be nice.

IMHO the all-in-kernel-monolithic approach raise some problems:

  * the tasks are checkpointed from an external process and most of the 
kernel code is designed to run as current

  * if a checkpoint or a restart fails, how do we debug that ? How 
someone in the community using the CR can report an information about 
the checkpoint has failed in a particular place ? The same for the 
restart. And a much more harder case is if a restart succeeded but a 
resource was badly restored making the application to continue its 
execution but failing 1 hour later.

  * how this can be maintained ? who will port the CR each time a 
subsystem design changes ?

  * the current patchset is full kernel but needs an external tool to 
create the process tree by digging in the statefile, weird.

  * the container and the checkpoint/restart are not clearly 
decorrelated, that brings a dangerous heuristic in the kernel, 
especially with nested namespace and partial resources checkpoint. IMHO, 
the checkpoint / restart should succeed even if the resources are not 
isolated, we should not CR some boundaries like the namespaces.

Regarding these points and the comments of Kerrighed and google guys, 
maybe it would be interesting to discuss the following design of the CR:

  1) create a synchronism barrier (not the freezer), where all the tasks 
can set the checkpoint or restart status

That allows to have a task to abort the checkpoint at any time by 
setting a status error in the synchronism barrier. The initiator of the 
checkpoint / restart is blocked on this barrier until the checkpoint / 
restart finishes or fails. If the initiator exits, that's cancel the 
current operation making possible to do Ctrl+C at checkpoint or restart 
time.

  2) make a vdso which is the entry point of the checkpoint and set this 
entry as a signal handler for a new signal SIGCKPT, the same for 
SIGRESTART (AFAIR this is defined in posix 1003.m).

This approach allows to checkpoint from the current context which is 
less arch dependant and/or to override the handler with a specific 
library making possible to do some work before calling the 
sys_checkpoint itself. That will allows to build the CR step by step by 
making in userspace a best-effort library to checkpoint/restart what is 
not supported in the kernel.

  3) a process gains the checkpointable property with a specific flag or 
whatever. All the childs inherit this flag. That will allows to identify 
all the tasks which are checkpointable without isolating anything and 
than opens the door to the checkpoint/restart of a subset of a process tree.

  4) dump everything in a core-file-like and improve the interpreter to 
recreate the process tree from this file.

Dynamic behaviour would be:

Checkpoint:
	- The initiator of the checkpoint initialize the barrier and send a 
signal SIGCKPT to all the checkpointable tasks and these ones will jump 
on the handler and block on the barrier.

	- When all these tasks reach this barrier, the initiator of the
checkpoint dumps the system wide resources (memory, sysv ipc, struct 
files, etc ...).

	- When this is done, the tasks are released and they store their 
process wide resources (semundo, file descriptor, etc ...) to a 
current->ckpt_restart buffer and then set the status of the operation 
and block on the barrier.

	- The initiator of the checkpoint then collects all these informations 
and dump them.

	- Finally the initiator of the checkpoint release the tasks.


Restart:
	- The user executes the statefile, that spawns the process tree and all 
the processes are blocked in the barrier.

	- The initiator of the restart restore the system wide resources
and fill the restarted processes' current->ckpt_restart buffer.

	- The initiator sends a SIGRESTART to all the tasks and unblock the tasks

	- all the tasks restore their process wide resources regarding the 
current->ckpt_restart buffer.

	- all the tasks write their status and block on the barrier

	- the initiator of the restart release the tasks which will return to 
their execution context when they were checkpointed.

This approach is different of you are doing but I am pretty sure most of 
the code is re-usable. I see different advantages of this approach:

  - because the process resources are checkpointed / restarted from 
current, it would be easy to reuse some syscalls code (from the kernel 
POV) and that would reduce the code duplication and maintenance overhead.

  - the approach is more fine grained as we can implement piece by piece 
the checkpoint / restart.

  - as the statefile is in the elf format, gdb could be used to debug a 
statefile as a core file

  - as each process checkpoint / restart themselves, most of the 
execution context is stored in the stack which is CR with the memory, so 
when returning from the signal handler, the process returns to the right 
context. That is less complicated and more generic than externally 
checkpoint the execution context of a frozen task which would be 
potentially different for the restart.


I hope Serge you can present this approach as an alternative of the 
current patchset __if__ this one is not acceptable.

Regards
   -- Daniel
