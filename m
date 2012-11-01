From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/8] cgroup: use cgroup_lock_live_group(parent) in
	cgroup_create()
Date: Thu, 1 Nov 2012 08:43:20 -0700
Message-ID: <20121101154320.GA8712@htj.dyndns.org>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-4-git-send-email-tj@kernel.org>
	<20121031155514.GD22809@dhcp22.suse.cz>
	<20121031170431.GF2945@htj.dyndns.org>
	<20121101091644.GA8533@dhcp22.suse.cz>
	<CAOS58YM+kRtspVUzmnSmOmrDoNS_kF6KA02zWGxqH5FUcRWo1Q@mail.gmail.com>
	<20121101150532.GA5065@dhcp22.suse.cz>
	<20121101151556.GB5065@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121101151556.GB5065-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey, Michal.

On Thu, Nov 01, 2012 at 04:15:56PM +0100, Michal Hocko wrote:
> > 	if (!cgroup_lock_live_group(parent))
> > 		return -ENODEV;
> > 
> >         cgrp = kzalloc(sizeof(*cgrp), GFP_KERNEL);
> >         if (!cgrp)
> >                 return -ENOMEM;
> 
> this needs to drop the lock of course but it doesn't make it much more
> complicated...

Yeah, now look at the error exit path of the function.  You have to
reorder them too so that it matches the changed order above, which is
all fine and dandy, but one way is not necessarily better than the
other, so there's no good reason to incur that churn.

Thanks.

-- 
tejun
