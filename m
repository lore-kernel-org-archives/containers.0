From: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Wed, 28 Jan 2009 00:51:18 +0300
Message-ID: <20090127215118.GA12431__16139.6139221781$1233093302$gmane$org@ioremap.net>
References: <20090127155825.D476.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<alpine.DEB.2.00.0901262325320.13157@chino.kir.corp.google.com>
	<20090127164238.D479.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<alpine.DEB.2.00.0901262350110.14525@chino.kir.corp.google.com>
	<20090127093105.GB2646@ioremap.net>
	<alpine.DEB.2.00.0901270134360.20070@chino.kir.corp.google.com>
	<20090127134038.GA18119@ioremap.net>
	<alpine.DEB.2.00.0901271230140.21124@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0901271230140.21124-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve Hj?nnev?g <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jan 27, 2009 at 12:37:21PM -0800, David Rientjes (rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org) wrote:
> > Well, oom-killer can, since it drops unkillable state from the process
> > mask, that may be not enough though, but it tries more than userspace.
> > 
> 
> The only thing it does is send a SIGKILL and gives the thread access to 
> memory reserves with TIF_MEMDIE, it doesn't drop any unkillable state.  If 

There is a small difference between force_sig_info() and usual
send_sinal() used by kill.

> its victim is hung in D state and the memory reserves do not allow it to 
> return to being runnable, this task will not die and the oom killer would 
> livelock unless given another target.

D-states are different. In the current tree we even have
page_lock_killable(), so it depends.

> > My main point was to haev a way to monitor memory usage and that any
> > process could tune own behaviour according to that information. Which is
> > not realated to the system oom-killer at all. Thus /dev/mem_notify is
> > interested first (and only the first) as a memory usage notification
> > interface and not a way to invoke any kind of 'soft' oom-killer.
> 
> It's a way to prevent invoking the kernel oom killer by allowing userspace 
> notification of events where methods such as droping caches, elevating 
> limits, adding nodes, sending signals, etc, can prevent such a problem.  
> When the system (or cgroup) is completely oom, it can also issue SIGKILLs 
> that will free some memory and preempt the oom killer from acting.
> 
> I think there might be some confusion about my proposal for extending 
> /dev/mem_notify.  Not only should it notify of certain low memory events, 
> but it should also allow userspace notification of oom events, just like 
> the cgroup oom notifier patch allowed.  Instead of attaching a task to a 
> cgroup file in that case, however, this would simply be the responsibility 
> of a task that has set up a poll() on the cgroup's mem_notify file.  A 
> configurable delay could be imposed so page allocation attempts simply 
> loop while the userspace handler responds and then only invoke the oom 
> killer when absolutely necessary.

I have really no objections against this and extending oom-killer to
allow to wait a bit in the allocation path before userspace makes some
progress. But do not drop existing oom-killer (i.e. its ability to kill
processes) in favour of this new feature. Let's have both and if
extension failed for some reason, old oom-killer will do the things.

-- 
	Evgeniy Polyakov
