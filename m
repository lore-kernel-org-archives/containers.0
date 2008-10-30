From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix invalid cgrp->dentry before cgroup has been
	completely removed
Date: Thu, 30 Oct 2008 16:07:01 +0800
Message-ID: <49096B25.1080002__47861.6133252673$1225356064$gmane$org@cn.fujitsu.com>
References: <490960EF.7020500@cn.fujitsu.com>
	<6599ad830810300041o1f97999em7b64426414bae380@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830810300041o1f97999em7b64426414bae380-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Thu, Oct 30, 2008 at 12:23 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> This fixes oops when reading /proc/sched_debug.
>>
>> A cgroup won't be removed completely until finishing cgroup_diput(), so we
>> shouldn't invalidate cgrp->dentry in cgroup_rmdir(). Otherwise, when a
>> group is being removed while cgroup_path() gets called, we may trigger NULL
>> dereference BUG.
> 
> Clearly a bug if it can hit a NULL dereference. But clearing the
> dentry to NULL is something that cgroups inherited from cpusets - it
> looks OK to remove it, but I'm mildly nervous.
> 
> Directly after the code in your patch, we dput() the dentry. So
> theoretically it could be released any time after that. But I guess
> that as soon as it *is* released, cgroup_diput() will be called as
> part of that cleanup, at which point any subsystems should drop any
> pointers they have to the cgroup or the dentry. So I guess it should
> be OK.
> 

The bug is:

cgroup           cpu_subsystem
------------------------------------

cgroup_remove()
                 print_cfs_stats()
                 print_cfs_rq()
cgroup_diput()
                 cpu_cgroup_destroy()

I think a different fix is to add pre_destroy() method to cpu_subsystem,
and move some code from sched_destroy_group() to that method.

But I didn't try it out.
