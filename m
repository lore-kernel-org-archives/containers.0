From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/9] cgroup: implement generic child / descendant walk
	macros
Date: Wed, 7 Nov 2012 09:01:18 -0800
Message-ID: <20121107170118.GD2660__36403.0800796629$1352307707$gmane$org@mtj.dyndns.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-4-git-send-email-tj@kernel.org>
	<20121107165457.GD4131@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121107165457.GD4131-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
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

Hello, Michal.

On Wed, Nov 07, 2012 at 05:54:57PM +0100, Michal Hocko wrote:
> > +struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
> > +					  struct cgroup *cgroup)
> > +{
> > +	struct cgroup *next;
> > +
> > +	WARN_ON_ONCE(!rcu_read_lock_held());
> > +
> > +	/* if first iteration, pretend we just visited @cgroup */
> > +	if (!pos) {
> > +		if (list_empty(&cgroup->children))
> > +			return NULL;
> > +		pos = cgroup;
> > +	}
> 
> Is there any specific reason why the root of the tree is excluded?
> This is bit impractical because you have to special case the root
> in the code.

Yeah, thought about including it but decided against it for two
reasons.

* To be consistent with cgroup_for_each_children() - it's a bit weird
  for descendants to include self when children don't.

* Iteration root is likely to require different treatment anyway.
  e.g. for cgroup_freezer, the root is updated to the specified config
  while all the descendants inherit config from its immediate parent.
  They are different.

Thanks.

-- 
tejun
