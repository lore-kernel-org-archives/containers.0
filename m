From: Kent Overstreet <koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/11] cgroup: use percpu refcnt for cgroup_subsys_states
Date: Thu, 13 Jun 2013 16:16:34 -0700
Message-ID: <20130613231634.GD28664@moria.home.lan>
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
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Mikulas Patocka <mpatocka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Alasdair G. Kergon" <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jun 12, 2013 at 09:04:58PM -0700, Tejun Heo wrote:
> A css (cgroup_subsys_state) is how each cgroup is represented to a
> controller.  As such, it can be used in hot paths across the various
> subsystems different controllers are associated with.
> 
> One of the common operations is reference counting, which up until now
> has been implemented using a global atomic counter and can have
> significant adverse impact on scalability.  For example, css refcnt
> can be gotten and put multiple times by blkcg for each IO request.
> For highops configurations which try to do as much per-cpu as
> possible, the global frequent refcnting can be very expensive.
> 
> In general, given the various and hugely diverse paths css's end up
> being used from, we need to make it cheap and highly scalable.  In its
> usage, css refcnting isn't very different from module refcnting.
> 
> This patch converts css refcnting to use the recently added
> percpu_ref.  css_get/tryget/put() directly maps to the matching
> percpu_ref operations and the deactivation logic is no longer
> necessary as percpu_ref already has refcnt killing.
> 
> The only complication is that as the refcnt is per-cpu,
> percpu_ref_kill() in itself doesn't ensure that further tryget
> operations will fail, which we need to guarantee before invoking
> ->css_offline()'s.  This is resolved collecting kill confirmation
> using percpu_ref_kill_and_confirm() and initiating the offline phase
> of destruction after all css refcnt's are confirmed to be seen as
> killed on all CPUs.  The previous patches already splitted destruction
> into two phases, so percpu_ref_kill_and_confirm() can be hooked up
> easily.
> 
> This patch removes css_refcnt() which is used for rcu dereference
> sanity check in css_id().  While we can add a percpu refcnt API to ask
> the same question, css_id() itself is scheduled to be removed fairly
> soon, so let's not bother with it.  Just drop the sanity check and use
> rcu_dereference_raw() instead.
> 
> v2: - init_cgroup_css() was calling percpu_ref_init() without checking
>       the return value.  This causes two problems - the obvious lack
>       of error handling and percpu_ref_init() being called from
>       cgroup_init_subsys() before the allocators are up, which
>       triggers warnings but doesn't cause actual problems as the
>       refcnt isn't used for roots anyway.  Fix both by moving
>       percpu_ref_init() to cgroup_create().
> 
>     - The base references were put too early by
>       percpu_ref_kill_and_confirm() and cgroup_offline_fn() put the
>       refs one extra time.  This wasn't noticeable because css's go
>       through another RCU grace period before being freed.  Update
>       cgroup_destroy_locked() to grab an extra reference before
>       killing the refcnts.  This problem was noticed by Kent.

Reviewed-by: Kent Overstreet <koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
