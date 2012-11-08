From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 7/9] cgroup_freezer: introduce
	CGROUP_FREEZING_[SELF|PARENT]
Date: Thu, 8 Nov 2012 06:42:39 -0800
Message-ID: <20121108144239.GF12973__49942.9916766987$1352385782$gmane$org@htj.dyndns.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-8-git-send-email-tj@kernel.org>
	<20121108124755.GG31821@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121108124755.GG31821-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
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

Hello,

On Thu, Nov 08, 2012 at 01:47:55PM +0100, Michal Hocko wrote:
> On Sat 03-11-12 01:38:33, Tejun Heo wrote:
> > Introduce FREEZING_SELF and FREEZING_PARENT and make FREEZING OR of
> > the two flags.  This is to prepare for full hierarchy support.
> > 
> > freezer_apply_date() is updated such that it can handle setting and
> > clearing of both flags.  The two flags are also exposed to userland
> > via read-only files self_freezing and parent_freezing.
> > 
> > Other than the added cgroupfs files, this patch doesn't introduce any
> > behavior change.
> 
> OK, I can imagine that this might be useful to find the first parent
> group that needs to be thawed to unfreeze the group I am interested
> in. Could you also update Documentation/cgroups/freezer-subsystem.txt to
> clarify the intended usage?

Ooh, right.  Will update the doc in the last patch.

> Minor nit. Same as mentioned in the previous patch freezer_apply_state
> should get enum freezer_state_flags state parameter.

But it isn't an enum value.

Thanks.

-- 
tejun
