From: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: Control groups and Resource Management notes (part I)
Date: Tue, 05 Aug 2008 16:06:17 +0900
Message-ID: <20080805152612.A888.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <489315B2.2080506@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <489315B2.2080506-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi

nice minutes!
below is just my note.

> Control Groups
> ==============
> 
> 1. Multiphase locking - Paul brought up his multi phase locking design and
> suggested approaches to implementing them. The problem with control groups
> currently is that transactions cannot be atomically committed. If some
> transactions fail (can_attach() callback fails or returns error), then there is
> no notification sent out to groups that already committed the transaction
> 
> The suggested design includes
> 	- Acquiring locks across callbacks - Balbir opposed this approach
>           stating that this would make it easier for subsystems to deadlock.
>           Balbir instead suggested that each callback hold it's own lock and
>           add an undo operation that cannot fail (returns void), since
>           uncharging usually succeeds. Dave suggested doing undo without holding
>           any locks.

task_limit cgroup has one problem with atomic related things.
task_limit check number of tasks when can_attach() called and increment number of tasks
when attach() called.
thus, it has race. if two attch processing run parallel, number of tasks exceed task limit.


> 4. Binary statistics - The question about binary statistics was raised. Since
> control groups don't enforce any particular kind of API, is there a way to
> generically handle control files and their parameters in the library? Paul
> suggested his binary API approach, where every control group and it's API is
> documented in an api file. Eric suggested using an ASCII interface (since that
> is very generic) and using one file per API. Balbir mentioned that this will
> lead to too many dentries and issues related to having extensive number of dentries.

if too many dentries come trouble, we should attach it?
I feel binary interface is detour solution.

but if any cgroup need any atomic operation and its implementation is 
difficult on sysfs like inteface, I'll advocate binary api.


> 5. User space notifications - Kamezawa had requested for user space notification
> (through inotify) when a control group reaches it's memory limit for example.
> The questions that were asked were, what happens if no one is listening in on
> notifications? Denis suggested using a FIFO mechanism. Balbir suggested using
> netlinks and building stuff on top of cgroupstats. With netlink we can pass
> type, value and length of arguments, making it more suitable for this kind of
> information exchange. The only concern with netlink is that it can lose
> messages. The general consensus was to add one FIFO per control group and use
> that for all notifications related to the control group.

At least, HPC like batch system need some notification (e.g. elaps time,
cpu time, memory consumption exceed)

In addition, some embedded people want userland oom-manager.
it get notification when system memory shortage, and shrink properly
process memory.
because kernel can't know how much droppable cache user process has.
(e.g. browser cache, free list in malloc, GUI bitmap cache)

if we think system memory shortage, FIFO is not so good idea.
it accelerate to memory stavation more.
and netlink use some kmalloc, then it doesn't works properly 
on memory stavation state.

but We should be thought it?


btw, I guess Peter Zijlstra's memory resavation framework can solve 
above netlink issue. but I'm not sure it.


> 4. CPU controller - There was a request for hard limit feature. Peter opposed
> the approach stating that anyone wanting hard limits should use the real time
> group scheduler and a new EDF scheduler is being implemented. Denis mentioned
> that without hard limits it is not possible for a service provider to
> decide/plan how much capacity a single CPU can provide. Balbir mentioned that
> with hard limits and SLA's the service provider could on reaching the hard limit
> can save power by hard limiting execution on a CPU that is meeting its SLA
> requirements. Peter mentioned that hard limits would make the group scheduler,
> non work conserving.

What's SLA?


> 5. Kernel memory controller - The kernel memory controller was discussed
> briefly. Pavel has not been actively working on it. Denis mentioned that it
> would be nice to have a network buffer controller as well. Questions were asked
> if the kernel memory controller should be merged with the existing memory
> controller?

I don't hope merge it.
I think network buffer control is useful, but kernel memory controller is not.
because it require administrator know kernel implementation.
but it is too difficult.

Swiss army knife like approach press down every trouble to administrator.


I know embedded people like kernel memory controller, 
because they know the kernel internal very well and 
they don't want create custom kernel.
but it is general assumption?
