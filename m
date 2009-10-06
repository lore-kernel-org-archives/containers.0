From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: pidns memory leak
Date: Tue, 06 Oct 2009 10:18:50 +0200
Message-ID: <4ACAFD6A.3060008@fr.ibm.com>
References: <4AC5F198.2070407@fr.ibm.com> <20091006040526.GA22923@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091006040526.GA22923-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
> Daniel Lezcano [dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
>> Hi,
>>
>> I am facing a problem with the pid namespace when I launch the following  
>> lxc commands:
>>
>> lxc-execute -n foo sleep 3600 &
>> ls -al /proc/$(pidof lxc-init)/exe && lxc-stop -n foo
>>
>> All the processes related to the container are killed, but there is  
>> still a refcount on the pid_namespace which is never released.
> 
> Thanks for the bug report.
> 
> Did you notice any leak in 'struct pids' also or just the pid_namespace ?
> If the pids are not leaking, this may be slightly different from the problem
> Catalin Marinas ran into:
> 
> 	http://lkml.org/lkml/2009/7/29/406

I am not sure what you mean by 'struct pids' but what I observed is:

pid_2 and pid_namespace (as they are named in /proc/slabinfo) are never 
decremented.

> And the pid_namespace does not seem to reproduce for me, with out the
> 'ls -al /proc/...' above, or with the simpler 'ns_exec' approach to
> creating pid namespace.

I tried to write a simpler program but I failed to reproduce it.

> I am going through the code for lxc-execute, but does it remount /proc 
> in the container ?

Right, the parent does a clone(NEWMNT|NEWPID|NEWIPC|NEWUTS), wait for 
the child while this one (pid 1) 'execs' the lxc-init process. This 
program mounts /proc and fork-exec the command passed as parameter (here 
'sleep 3600').

Without this intermediate process, the leak *seems* not happening.

If you don't access /proc/<pid>/<file>, the leak is not happening.

So to summarize:

Leak when:
----------

lxc-execute -n foo sleep 3600 &
ls -al /proc/$(pidof sleep)/exe && lxc-stop -n foo

The stop can be done, immediately after looking at the proc file or 
later, the leak happens in all the cases.

No leak when:
-------------
lxc-execute -n foo sleep 3600 &
lxc-stop -n foo


I tried to create a simpler program doing the same but that did not 
triggered the problem.

   -- Daniel
