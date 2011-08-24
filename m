From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCHSET] cgroup: introduce cgroup_taskset and consolidate
	subsys methods
Date: Wed, 24 Aug 2011 03:14:30 +0200
Message-ID: <20110824011428.GC23979__22331.2274822549$1314148524$gmane$org@somewhere>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1314138000-2049-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Aug 24, 2011 at 12:19:54AM +0200, Tejun Heo wrote:
> Hello,
> 
> cgroup has grown quite some number of subsys methods.  Some of them
> are overlapping, inconsistent with each other and called under
> different conditions depending on whether they're called for a single
> task or whole process.  Unfortunately, these callbacks are complicated
> and incomplete at the same time.
> 
> * ->attach_task() is called after migration for task attach but before
>   for process.
> 
> * Ditto for ->pre_attach().
> 
> * ->can_attach_task() is called for every task in the thread group but
>   ->attach_task() skips the ones which don't actually change cgroups.
> 
> * Task attach becomes noop if the task isn't actually moving.  Process
>   attach is always performed.
> 
> * ->attach_task() doesn't (or at least aren't supposed to) have access
>   to the old cgroup.
> 
> * During cancel, there's no way to access the affected tasks.
> 
> This patchset introduces cgroup_taskset along with some accessors and
> iterator, updates methods to use it, consolidates usages and drops
> superflous methods.
> 
> It contains the following six patches.
> 
>  0001-cgroup-subsys-attach_task-should-be-called-after-mig.patch
>  0002-cgroup-improve-old-cgroup-handling-in-cgroup_attach_.patch
>  0003-cgroup-introduce-cgroup_taskset-and-use-it-in-subsys.patch
>  0004-cgroup-don-t-use-subsys-can_attach_task-or-attach_ta.patch
>  0005-cgroup-cpuset-don-t-use-ss-pre_attach.patch
>  0006-cgroup-kill-subsys-can_attach_task-pre_attach-and-at.patch

I don't understand the point on patches 3,4,5,6

Why pushing the task iterations down to the subsystems?
