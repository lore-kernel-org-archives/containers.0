From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 11/11] cgroup: use percpu refcnt for cgroup_subsys_states
Date: Fri, 14 Jun 2013 14:55:39 +0200
Message-ID: <20130614125539.GC10084@dhcp22.suse.cz>
References: <1371096298-24402-1-git-send-email-tj@kernel.org>
	<1371096298-24402-12-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1371096298-24402-12-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mikulas Patocka <mpatocka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Alasdair G. Kergon" <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed 12-06-13 21:04:58, Tejun Heo wrote:
[...]
> +/**
> + * cgroup_destroy_locked - the first stage of cgroup destruction
> + * @cgrp: cgroup to be destroyed
> + *
> + * css's make use of percpu refcnts whose killing latency shouldn't be
> + * exposed to userland and are RCU protected.  Also, cgroup core needs to
> + * guarantee that css_tryget() won't succeed by the time ->css_offline() is
> + * invoked.  To satisfy all the requirements, destruction is implemented in
> + * the following two steps.
> + *
> + * s1. Verify @cgrp can be destroyed and mark it dying.  Remove all
> + *     userland visible parts and start killing the percpu refcnts of
> + *     css's.  Set up so that the next stage will be kicked off once all
> + *     the percpu refcnts are confirmed to be killed.
> + *
> + * s2. Invoke ->css_offline(), mark the cgroup dead and proceed with the
> + *     rest of destruction.  Once all cgroup references are gone, the
> + *     cgroup is RCU-freed.
> + *
> + * This function implements s1.  After this step, @cgrp is gone as far as
> + * the userland is concerned and a new cgroup with the same name may be
> + * created.  As cgroup doesn't care about the names internally, this
> + * doesn't cause any problem.

Glauber is this asumption correct for kmem caches naming scheme?
I guess it should, but I would rather be sure this won't blow up later
specially when caches might live longer than css_offline.

> + */
>  static int cgroup_destroy_locked(struct cgroup *cgrp)
>  	__releases(&cgroup_mutex) __acquires(&cgroup_mutex)
>  {
-- 
Michal Hocko
SUSE Labs
