From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/9] cgroup: implement generic child / descendant walk
	macros
Date: Thu, 8 Nov 2012 09:15:32 -0800
Message-ID: <20121108171532.GI12973__14687.5054263093$1352394955$gmane$org@htj.dyndns.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-4-git-send-email-tj@kernel.org>
	<20121108095013.GA31821@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121108095013.GA31821-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey, Michal.

On Thu, Nov 08, 2012 at 10:50:13AM +0100, Michal Hocko wrote:
> On Sat 03-11-12 01:38:29, Tejun Heo wrote:
> > Currently, cgroup doesn't provide any generic helper for walking a
> > given cgroup's children or descendants.  This patch adds the following
> > three macros.
> > 
> > * cgroup_for_each_child() - walk immediate children of a cgroup.
> > 
> > * cgroup_for_each_descendant_pre() - visit all descendants of a cgroup
> >   in pre-order tree traversal.
> > 
> > * cgroup_for_each_descendant_post() - visit all descendants of a
> >   cgroup in post-order tree traversal.
> > 
> > All three only require the user to hold RCU read lock during
> > traversal.  Verifying that each iterated cgroup is online is the
> > responsibility of the user.  When used with proper synchronization,
> > cgroup_for_each_descendant_pre() can be used to propagate config
> > updates to descendants in reliable way.  See comments for details.
> > 
> > Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> 
> I will convert mem_cgroup_iter to use this rather than css_get_next
> after this gets into the next tree so that it can fly via Andrew.
> 
> Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> 
> Just a minor knit. You are talking about a config propagation while I
> would consider state propagation more clear and less confusing. Config
> is usually stable enough so that post_create is not necessary for
> syncing (e.g. memcg.swappiness). It is a state which must be consistent
> throughout the hierarchy which matters here.

Did s/config/state/g

Thanks.

-- 
tejun
