From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Tue, 27 Jan 2009 12:29:20 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0901271223280.21124__35859.1349948712$1233088440$gmane$org@chino.kir.corp.google.com>
References: <200901211638.23101.knikanth@suse.de>
	<200901271638.21720.knikanth@suse.de>
	<alpine.DEB.2.00.0901270316040.25608@chino.kir.corp.google.com>
	<200901271707.48770.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200901271707.48770.knikanth-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, =?UTF-8?Q?Arve_Hj=C3=B8nnev=C3=A5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 27 Jan 2009, Nikanth Karthikesan wrote:

> > That's certainly idealistic, but cannot be done in an inexpensive way that
> > would scale with the large systems that clients of cpusets typically use.
> 
> If we kill only the tasks for which cpuset_mems_allowed_intersects() is true 
> on the first pass and even then if we do not get out of oom, we could go over 
> again with this expensive check.

The oom killer has no memory of previous kills, so it's not possible to 
determine if there've been a series of recent needless ones.  Subsequent 
oom conditions should still check for intersection and, since it's only a 
heuristic, a large memory-hogging task will eventually be killed if there 
are no tasks remaining with such an intersection.

I don't know how you're planning on mapping large memory allocations on 
nodes of interest back to specific tasks, however.  Do you have a 
proposal?

> Using this scheme, could kill more no of 
> tasks than required, if a task with lots of memory has moved to a different 
> cpuset.

That's rare, since cpusets are used for NUMA optimizations and a set of 
cpus has a static affinity to certain memory.  It could happen if a 
cpuset's set of allowable nodes is made to be smaller, but that seems like 
it would trigger the oom in the first place and would encourage killing 
tasks with an intersection.
