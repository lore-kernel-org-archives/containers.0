From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Subject: Re: [PATCH v2 08/23] cgroup: pass around cgroup_subsys_state instead
	of cgroup in subsystem methods
Date: Tue, 6 Aug 2013 09:19:45 +0200
Message-ID: <5200A391.9030208__47919.8087509305$1375773604$gmane$org@bmw-carit.de>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
	<1375393801-4817-9-git-send-email-tj@kernel.org>
	<20130802202408.GH29736@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130802202408.GH29736-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 08/02/2013 10:24 PM, Tejun Heo wrote:
> cgroup is currently in the process of transitioning to using struct
> cgroup_subsys_state * as the primary handle instead of struct cgroup *
> in subsystem implementations for the following reasons.
>
> * With unified hierarchy, subsystems will be dynamically bound and
>    unbound from cgroups and thus css's (cgroup_subsys_state) may be
>    created and destroyed dynamically over the lifetime of a cgroup,
>    which is different from the current state where all css's are
>    allocated and destroyed together with the associated cgroup.  This
>    in turn means that cgroup_css() should be synchronized and may
>    return NULL, making it more cumbersome to use.
>
> * Differing levels of per-subsystem granularity in the unified
>    hierarchy means that the task and descendant iterators should behave
>    differently depending on the specific subsystem the iteration is
>    being performed for.
>
> * In majority of the cases, subsystems only care about its part in the
>    cgroup hierarchy - ie. the hierarchy of css's.  Subsystem methods
>    often obtain the matching css pointer from the cgroup and don't
>    bother with the cgroup pointer itself.  Passing around css fits
>    much better.
>
> This patch converts all cgroup_subsys methods to take @css instead of
> @cgroup.  The conversions are mostly straight-forward.  A few
> noteworthy changes are
>
> * ->css_alloc() now takes css of the parent cgroup rather than the
>    pointer to the new cgroup as the css for the new cgroup doesn't
>    exist yet.  Knowing the parent css is enough for all the existing
>    subsystems.
>
> * In kernel/cgroup.c::offline_css(), unnecessary open coded css
>    dereference is replaced with local variable access.
>
> This patch shouldn't cause any behavior differences.
>
> v2: Unnecessary explicit cgrp->subsys[] deref in css_online() replaced
>      with local variable @css as suggested by Li Zefan.
>
>      Rebased on top of new for-3.12 which includes for-3.11-fixes so
>      that ->css_free() invocation added by da0a12caff ("cgroup: fix a
>      leak when percpu_ref_init() fails") is converted too.  Suggested
>      by Li Zefan.
>
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
> Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>

netprio and cls part:

Acked-By: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

cheers,
daniel
