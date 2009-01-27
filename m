From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Tue, 27 Jan 2009 12:37:21 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0901271230140.21124__30887.0975197808$1233088933$gmane$org@chino.kir.corp.google.com>
References: <20090127155825.D476.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<alpine.DEB.2.00.0901262325320.13157@chino.kir.corp.google.com>
	<20090127164238.D479.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<alpine.DEB.2.00.0901262350110.14525@chino.kir.corp.google.com>
	<20090127093105.GB2646@ioremap.net>
	<alpine.DEB.2.00.0901270134360.20070@chino.kir.corp.google.com>
	<20090127134038.GA18119@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090127134038.GA18119-i6C2adt8DTjR7s880joybQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Cc: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve Hj?nnev?g <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 27 Jan 2009, Evgeniy Polyakov wrote:

> > There is no additional oom killer limitation imposed here, nor can the oom 
> > killer kill a task hung in D state any better than userspace.
> 
> Well, oom-killer can, since it drops unkillable state from the process
> mask, that may be not enough though, but it tries more than userspace.
> 

The only thing it does is send a SIGKILL and gives the thread access to 
memory reserves with TIF_MEMDIE, it doesn't drop any unkillable state.  If 
its victim is hung in D state and the memory reserves do not allow it to 
return to being runnable, this task will not die and the oom killer would 
livelock unless given another target.

> My main point was to haev a way to monitor memory usage and that any
> process could tune own behaviour according to that information. Which is
> not realated to the system oom-killer at all. Thus /dev/mem_notify is
> interested first (and only the first) as a memory usage notification
> interface and not a way to invoke any kind of 'soft' oom-killer.

It's a way to prevent invoking the kernel oom killer by allowing userspace 
notification of events where methods such as droping caches, elevating 
limits, adding nodes, sending signals, etc, can prevent such a problem.  
When the system (or cgroup) is completely oom, it can also issue SIGKILLs 
that will free some memory and preempt the oom killer from acting.

I think there might be some confusion about my proposal for extending 
/dev/mem_notify.  Not only should it notify of certain low memory events, 
but it should also allow userspace notification of oom events, just like 
the cgroup oom notifier patch allowed.  Instead of attaching a task to a 
cgroup file in that case, however, this would simply be the responsibility 
of a task that has set up a poll() on the cgroup's mem_notify file.  A 
configurable delay could be imposed so page allocation attempts simply 
loop while the userspace handler responds and then only invoke the oom 
killer when absolutely necessary.

> Application can do whatever it wants of course including killing itself
> or the neighbours, but this should not be forced as a usage policy.
> 

If preference killing is your goal, then userspace can do it with the 
/dev/mem_notify functionality.
