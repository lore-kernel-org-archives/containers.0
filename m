From: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Tue, 27 Jan 2009 16:40:38 +0300
Message-ID: <20090127134038.GA18119__32002.8918133632$1233063805$gmane$org@ioremap.net>
References: <20090127155825.D476.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<alpine.DEB.2.00.0901262325320.13157@chino.kir.corp.google.com>
	<20090127164238.D479.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<alpine.DEB.2.00.0901262350110.14525@chino.kir.corp.google.com>
	<20090127093105.GB2646@ioremap.net>
	<alpine.DEB.2.00.0901270134360.20070@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0901270134360.20070-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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

Hi David.

On Tue, Jan 27, 2009 at 01:37:55AM -0800, David Rientjes (rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org) wrote:
> > /dev/mem_notify is a great idea, but please do not limit existing
> > oom-killer in its ability to do the job and do not rely on application's
> > ability to send a SIGKILL which will not kill tasks in unkillable state
> > contrary to oom-killer.
> > 
> 
> You're missing the point, /dev/mem_notify would notify userspace of lowmem 
> situations and allow it to respond appropriately in any number of ways 
> before an oom condition exists.

Yes, I know.

> When the system (or cpuset, memory controller, etc) is oom, userspace can 
> choose to defer to the oom killer so that it may kill a task that would 
> most likely lead to future memory freeing with access to memory reserves.
> 
> There is no additional oom killer limitation imposed here, nor can the oom 
> killer kill a task hung in D state any better than userspace.

Well, oom-killer can, since it drops unkillable state from the process
mask, that may be not enough though, but it tries more than userspace.

My main point was to haev a way to monitor memory usage and that any
process could tune own behaviour according to that information. Which is
not realated to the system oom-killer at all. Thus /dev/mem_notify is
interested first (and only the first) as a memory usage notification
interface and not a way to invoke any kind of 'soft' oom-killer.
Application can do whatever it wants of course including killing itself
or the neighbours, but this should not be forced as a usage policy.

-- 
	Evgeniy Polyakov
