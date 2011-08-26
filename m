From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/6] cgroup: introduce cgroup_taskset and use it in
	subsys->can_attach(), cancel_attach() and attach()
Date: Fri, 26 Aug 2011 08:40:11 +0200
Message-ID: <20110826064011.GA2632__17953.3848925077$1314340931$gmane$org@htj.dyndns.org>
References: <1314312192-26885-1-git-send-email-tj@kernel.org>
	<1314312192-26885-4-git-send-email-tj@kernel.org>
	<20110826023818.GC3457@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110826023818.GC3457-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Matt.

On Thu, Aug 25, 2011 at 07:38:18PM -0700, Matt Helsley wrote:
> On Fri, Aug 26, 2011 at 12:43:09AM +0200, Tejun Heo wrote:
> > Currently, there's no way to pass multiple tasks to cgroup_subsys
> > methods necessitating the need for separate per-process and per-task
> > methods.  This patch introduces cgroup_taskset which can be used to
> > pass multiple tasks and their associated cgroups to cgroup_subsys
> > methods.
> 
> This will be the third iterator-ish pattern in the cgroup code.
> It's not your fault but it does seem a bit much to have:
...
> Is there a sane way to merge all this?

If merging isn't complicated and simplifies the code and its users,
definitely but I don't think that will be the case here.  If there are
different targets to iterate, having matching iterators isn't a weird
thing after all.  I personally am not too enthusiastic about mixing
locking with iterator (the implied read_lock in the cgroup iterator)
or iteration-by-callback but that's a different issue.

> Perhaps we could drop the iterator interfaces in 1) and 2) and replace
> it with:
> 
> 		tset cgroup_taskset_from_cgroup(cgroup)
> 
> which would grab the css set lock to construct the tset from the given
> cgroup -- essentially inlining the current iterator code into a single
> function.

* It doesn't need to walk the whole cgroup.

* It requires stable set of tasks (ie. atomicity w.r.t. the thread
  group) with sleepable context which is currently achieved by a rwsem
  in the task to protect against fork and getting an extra reference
  to the tasks in the set.

I don't think widening the scope would achieve much (why do we want to
pass in unrelated tasks to subsystems as a single bundle?) while
introducing unnecessary scalability limitation (moving out a single
process ends up being an operation on the whole cgroup).

I don't see how it would be better but, if you do, please go ahead.
Consolidating stuff is (almost) always a good idea. :)

Thanks.

-- 
tejun
