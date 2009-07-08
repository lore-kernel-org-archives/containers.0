From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [libvirt] Re: kernel summit topic - 'containers end-game'
Date: Wed, 08 Jul 2009 09:55:27 +0200
Message-ID: <4A5450EF.8030605@fr.ibm.com>
References: <20090623145611.GB19332@us.ibm.com> <4A4CE3A6.200@fr.ibm.com>
	<20090706145137.GB16868@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <libvir-list-bounces@redhat.com>
In-Reply-To: <20090706145137.GB16868@us.ibm.com>
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
> Quoting Daniel Lezcano (dlezcano@fr.ibm.com):
>> Serge E. Hallyn wrote:
> ...
>> Checkpoint:
>> 	- The initiator of the checkpoint initialize the barrier and send a  
>> signal SIGCKPT to all the checkpointable tasks and these ones will jump  
>> on the handler and block on the barrier.
>>
>> 	- When all these tasks reach this barrier, the initiator of the
>> checkpoint dumps the system wide resources (memory, sysv ipc, struct  
>> files, etc ...).
>>
>> 	- When this is done, the tasks are released and they store their  
>> process wide resources (semundo, file descriptor, etc ...) to a  
>> current->ckpt_restart buffer and then set the status of the operation  
>> and block on the barrier.
>>
>> 	- The initiator of the checkpoint then collects all these informations  
>> and dump them.
> 
> Do you envision all of the dumping being done in kernel or by userspace?

Dumping is done by the kernel.

>> 	- Finally the initiator of the checkpoint release the tasks.
>>
>>
>> Restart:
>> 	- The user executes the statefile, that spawns the process tree and all  
>> the processes are blocked in the barrier.
>>
>> 	- The initiator of the restart restore the system wide resources
>> and fill the restarted processes' current->ckpt_restart buffer.
> 
> Same question about restore...

The process tree is recreated from userspace, the rest from the kernel.

This is very similar with what you have currently, the differences are 
the tasks are checkpointed from "current", the statefile is in elf 
format and a synchro is used instead of the freezer (allowing to get rid 
of the cgroup).

The checkpoint is like a 'super-abort' and the restart a 'super-exec' :)

>> 	- The initiator sends a SIGRESTART to all the tasks and unblock the tasks
>>
>> 	- all the tasks restore their process wide resources regarding the  
>> current->ckpt_restart buffer.
>>
>> 	- all the tasks write their status and block on the barrier
>>
>> 	- the initiator of the restart release the tasks which will return to  
>> their execution context when they were checkpointed.
>>
>> This approach is different of you are doing but I am pretty sure most of  
>> the code is re-usable. I see different advantages of this approach:
>>
>>  - because the process resources are checkpointed / restarted from  
>> current, it would be easy to reuse some syscalls code (from the kernel  
>> POV) and that would reduce the code duplication and maintenance overhead.
>>
>>  - the approach is more fine grained as we can implement piece by piece  
>> the checkpoint / restart.
>>
>>  - as the statefile is in the elf format, gdb could be used to debug a  
>> statefile as a core file
> 
> Note btw that Dave has found that a checkpoint is faster than a core-dump
> at the moment :)  That's not entirely an aside - I need to reread your
> email a few times and really process your suggestion, but given that some
> users want to dump hundreds of gigabytes of memory, not slowing down the
> checkpoint is a big consideration.

Interesting, any idea of why the core dump is slower ?

>>  - as each process checkpoint / restart themselves, most of the  
>> execution context is stored in the stack which is CR with the memory, so  
>> when returning from the signal handler, the process returns to the right  
>> context. That is less complicated and more generic than externally  
>> checkpoint the execution context of a frozen task which would be  
>> potentially different for the restart.
>>
>>
>> I hope Serge you can present this approach as an alternative of the  
>> current patchset __if__ this one is not acceptable.
> 
> I'll try to understand it better than I do right now - I don't think
> it's for discussing at ksummit, but definately if we have a mini-summit
> or during the next round of discussions (during or immediately after
> the ckpt-v17 publish).

Maybe the current patchset will be considered good, in this case discard 
my comments and drop this email :) or maybe some people would be arguing 
against the current approach because they don't like it, perhaps for the 
different reasons I gave previously, in this case you have a set of 
ideas / modifications for the patchset to propose alternatively and to 
discuss about, that was the purpose of my email :)

Do you plan to do send the minutes of the ksummit ?

Thanks.

   -- Daniel
