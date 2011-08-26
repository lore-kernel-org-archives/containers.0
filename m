From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/6] cgroup: introduce cgroup_taskset and use it in
	subsys->can_attach(), cancel_attach() and attach()
Date: Thu, 25 Aug 2011 19:38:18 -0700
Message-ID: <20110826023818.GC3457__37456.4409525648$1314326400$gmane$org@count0.beaverton.ibm.com>
References: <1314312192-26885-1-git-send-email-tj@kernel.org>
	<1314312192-26885-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1314312192-26885-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Aug 26, 2011 at 12:43:09AM +0200, Tejun Heo wrote:
> Currently, there's no way to pass multiple tasks to cgroup_subsys
> methods necessitating the need for separate per-process and per-task
> methods.  This patch introduces cgroup_taskset which can be used to
> pass multiple tasks and their associated cgroups to cgroup_subsys
> methods.

This will be the third iterator-ish pattern in the cgroup code.
It's not your fault but it does seem a bit much to have:

	1) When we need to iterate over all tasks in the cgroup and
	don't mind holding the css set lock:
		void cgroup_iter_start(cgroup, iterator)
		task cgroup_iter_next(cgroup, iterator)
		void cgroup_iter_end(cgroup, iterator)

	2) For subsystem methods when we're iterating over a subset of
	tasks that may or may not be in the cgroup (e.g. for can_attach)
	-- use cgroup_tasksets:
		task cgroup_taskset_first(tset)
		task cgroup_taskset_next(tset)

	3) An iterator over all the tasks which doesn't hold the css set
	lock:
		struct cgroup_scanner {
			struct cgroup *cg;
			int (*test_task)(struct task_struct *p,
					struct cgroup_scanner *scan);
			void (*process_task)(struct task_struct *p,
					struct cgroup_scanner *scan);
			struct ptr_heap *heap;
			void *data;
		};
	This is only used in cpuset code so far. Are other cgroup
	patches planning on making use of it?

Is there a sane way to merge all this?

Perhaps we could drop the iterator interfaces in 1) and 2) and replace
it with:

		tset cgroup_taskset_from_cgroup(cgroup)

which would grab the css set lock to construct the tset from the given
cgroup -- essentially inlining the current iterator code into a single
function.

Of course this would eliminate the restriction that all the tasks in the
taskset are part of the same thread group; that would only be true for
those passed as parameters to the subsystem methods.

Cheers,
	-Matt Helsley
