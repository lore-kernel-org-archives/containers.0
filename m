From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Date: Mon, 13 Oct 2008 12:12:43 -0400
Message-ID: <48F3737B.6070904__34218.6971022331$1223914717$gmane$org@cs.columbia.edu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>	<20081009124658.GE2952@elte.hu>
	<1223557122.11830.14.camel@nimitz>	<20081009131701.GA21112@elte.hu>
	<1223559246.11830.23.camel@nimitz>	<20081009134415.GA12135@elte.hu>
	<1223571036.11830.32.camel@nimitz>
	<20081010153951.GD28977@elte.hu> <48F30315.1070909@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48F30315.1070909-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org



Cedric Le Goater wrote:
> Ingo Molnar wrote:
>> * Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>>
>>> On Thu, 2008-10-09 at 15:44 +0200, Ingo Molnar wrote:
>>>> there might be races as well, especially with proxy state - and 
>>>> current->flags updates are not serialized.
>>>>
>>>> So maybe it should be a completely separate flag after all? Stick it 
>>>> into the end of task_struct perhaps.
>>> What do you mean by proxy state?  nsproxy?
>> it's a concept: one task installing some state into another task (which 
>> state must be restored after a checkpoint event), while that other task 
>> is running. Such as a pi-futex state for example.
>>
>> So a task can acquire state not just by its own doing, but via some 
>> other task too.
> 
> thinking aloud,
> 
> hmm, that's rather complex, because we have to take into account the 
> kernel stack, no ? This is what Andrey was trying to solve in his patchset 
> back in September :
> 
> 	http://lkml.org/lkml/2008/9/3/96
> 
> the restart phase simulates a clone and switch_to to (not) restore the kernel 
> stack. right ? 
> 
> the self checkpoint and self restore syscalls, like Oren is proposing, are 
> simpler but they require the process cooperation to be triggered. we could
> image doing that in a special signal handler which would allow us to jump
> in the right task context. 

This description is not accurate:

For checkpoint, both implementations use an "external" task to read the state
from other tasks. (In my implementation that "other" task can be self).

For restart, both implementation expect the restarting process to restore its
own state. They differ in that Andrew's patchset also creates that process
while mine (at the moment) relies on the existing (self) task.

In other words, none of them will require any cooperation on part of the
checkpointed tasks, and both will require cooperation on part of the restarting
tasks (the latter is easy since we create and fully control these tasks).

> 
> I don't have any preference but looking at the code of the different patchsets
> there are some tricky areas and I'm wondering which path is easier, safer, 
> and portable. 

I am thinking which path is preferred: create the processes in kernel space
(like Andrew's patch does) or in user space (like Zap does). In the mini-summit
we agreed in favor of kernel space, but I can still see arguments why user space
may be better. (note: I refer strictly to the creation of the processes during
restart, not how their state is restored).

any thoughts ?

Oren.
