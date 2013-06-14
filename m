From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 11/11] cgroup: use percpu refcnt for cgroup_subsys_states
Date: Fri, 14 Jun 2013 15:20:26 +0200
Message-ID: <20130614132026.GD10084__43303.1079512604$1371216042$gmane$org@dhcp22.suse.cz>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mikulas Patocka <mpatocka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Alasdair G. Kergon" <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed 12-06-13 21:04:58, Tejun Heo wrote:
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
> percpu_ref. 

I have no objections to change css reference counting scheme if the
guarantees we used to have are still valid. I am just missing some
comparisons. Do you have any numbers that would show benefits clearly?

You are mentioning that especially controllers that are strongly per-cpu
oriented will see the biggest improvements. What about others?
A single atomic_add resp. atomic_dec_return is much less heavy than the
new ref counting. Is it possible that those could regress? Or the
differences would be only within the noise?

I do realize that it is not possible to test all controllers but I
would be interested to see at least that those for which it really
matters get a nice boost. Memcg uses css with caution although there are
places which are in really hot paths (e.g. charging) so any improvement
would be really welcome.

Sorry, if this information has been posted along with the series. I was
CCed only on this one and didn't get to look at the rest yet (apart from
"percpu: implement generic percpu refcounting" in your
review-css-percpu-ref branch).
[...]
-- 
Michal Hocko
SUSE Labs
