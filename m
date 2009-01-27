From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Mon, 26 Jan 2009 23:39:18 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0901262325320.13157__23740.426489576$1233042290$gmane$org@chino.kir.corp.google.com>
References: <20090126195431.GC504@balbir.in.ibm.com>
	<20090126195622.1d5bf488@lxorguk.ukuu.org.uk>
	<20090127155825.D476.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090127155825.D476.KOSAKI.MOTOHIRO-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve Hj?nnev?g <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Linus-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 27 Jan 2009, KOSAKI Motohiro wrote:

> Confused.
> 
> As far as I know, people want the method of flexible cache treating.
> but oom seems less flexible than userland notification.
> 
> Why do you think notification is bad?
> 

There're a couple of proposals that have been discussed recently that 
share some functional behavior.

One is the cgroup oom notifier that allows you to attach a task to wait on 
an oom condition for a collection of tasks.  That allows userspace to 
respond to the condition by droping caches, adding nodes to a cpuset, 
elevating memory controller limits, sending a signal, etc.  It can also 
defer to the kernel oom killer as a last resort.

The other is /dev/mem_notify that allows you to poll() on a device file 
and be informed of low memory events.  This can include the cgroup oom 
notifier behavior when a collection of tasks is completely out of memory, 
but can also warn when such a condition may be imminent.  I suggested that 
this be implemented as a client of cgroups so that different handlers can 
be responsible for different aggregates of tasks.

I think the latter is a much more powerful tool and includes all the 
behavior of the former.  It preserves the oom killer as a last resort for 
the kernel and defers all preference killing or lowmem responses to 
userspace.
